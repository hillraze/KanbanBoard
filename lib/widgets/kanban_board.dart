import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertest/show_feature_notifications.dart';
import 'package:provider/provider.dart';
import '/home_screen_notifier.dart';
import 'package:gap/gap.dart';

class KanbanBoard extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isMinimized;
  final List<int> columnOrder = [314660, 314661]; // TODO and In Progress IDs

  KanbanBoard({super.key, required this.data, required this.isMinimized});

  @override
  _KanbanBoardState createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  bool _isInterfaceVisible = true;
  double _scale = 1.0;
  bool _isMinimized = false;

  @override
  Widget build(BuildContext context) {
    final tasks = widget.data['rows'] as List<dynamic>? ?? [];
    final Map<int, List<Map<String, dynamic>>> columns = {
      314660: [], // Initialize TODO column
      314661: [], // Initialize In Progress column
    };

    for (var task in tasks) {
      final parentId = task['parent_id'];
      if (columns.containsKey(parentId)) {
        columns[parentId]!.add(task as Map<String, dynamic>);
      }
    }

    double scale = widget.isMinimized ? 0.5 : 1.0;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.columnOrder.map((parentId) {
              final columnTasks = columns[parentId] ?? [];
              return Transform.scale(
                alignment: Alignment.topLeft,
                scale: scale,
                child: DragTarget<Map<String, dynamic>>(
                  onWillAccept: (task) => true,
                  onAccept: (receivedTask) {
                    final newOrder =
                        columnTasks.isEmpty ? 1 : columnTasks.last['order'] + 1;
                    Provider.of<HomeScreenNotifier>(context, listen: false)
                        .moveTask(receivedTask, parentId, newOrder);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 300,
                      margin: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 20, 20, 20),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  parentId == 314660 ? 'TODO' : 'In Progress',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ReorderableListView(
                            shrinkWrap: true,
                            onReorder: (oldIndex, newIndex) {
                              if (newIndex > oldIndex) {
                                newIndex--; // Adjust index if moving downwards
                              }
                              final task = columnTasks.removeAt(oldIndex);
                              columnTasks.insert(newIndex, task);

                              // Update the order of tasks
                              for (int i = 0; i < columnTasks.length; i++) {
                                columnTasks[i]['order'] = i + 1;
                              }

                              // Notify provider about the task movement
                              Provider.of<HomeScreenNotifier>(context,
                                      listen: false)
                                  .moveTask(task, parentId, newIndex + 1);
                            },
                            children: columnTasks.map((task) {
                              return LongPressDraggable<Map<String, dynamic>>(
                                key: Key(task['indicator_to_mo_id'].toString()),
                                data: task,
                                feedback: Transform.rotate(
                                  angle: -25 * 3.14159 / 180,
                                  child: Opacity(
                                    opacity: 0.8,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Card(
                                        color: const Color.fromARGB(
                                            255, 34, 39, 43),
                                        child: Container(
                                          width: 275,
                                          height: 75,
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            task['name'],
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 182, 194, 207),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Container(),
                                onDragUpdate: (details) {
                                  _autoScroll(details.globalPosition);
                                },
                                onDragEnd: (details) {
                                  _stopAutoScroll();
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Card(
                                    color:
                                        const Color.fromARGB(255, 34, 39, 43),
                                    child: ListTile(
                                      title: Text(
                                        task['name'],
                                        style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 182, 194, 207),
                                        ),
                                      ),
                                      subtitle: Text('${task['order']}'),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          DragTarget<Map<String, dynamic>>(
                            onWillAccept: (task) => true,
                            onAccept: (receivedTask) {
                              final newOrder = columnTasks.isEmpty
                                  ? 1
                                  : columnTasks.last['order'] + 1;
                              Provider.of<HomeScreenNotifier>(context,
                                      listen: false)
                                  .moveTask(receivedTask, parentId, newOrder);
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onTap: () => showFeatureNotification(context),
                                  child: const Row(
                                    children: [
                                      Gap(20),
                                      Text(
                                        '+',
                                        style: TextStyle(
                                          fontSize: 25,
                                          color: Color.fromARGB(
                                              255, 182, 194, 207),
                                        ),
                                      ),
                                      Gap(10),
                                      Text(
                                        'Add new task',
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 182, 194, 207),
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // IconButton(
                          //     icon: Icon(Icons.zoom_out_map),
                          //     onPressed: () {
                          //       setState(() {
                          //         _isMinimized = !_isMinimized;
                          //         _scale = _isMinimized
                          //             ? 0.5
                          //             : 1.0; // Adjust scale as needed
                          //       });
                          //     })
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Timer? _scrollTimer;

  void _autoScroll(Offset globalPosition) {
    const scrollSpeed = 10.0;
    const edgeMargin = 50.0;

    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);

    if (localPosition.dx < edgeMargin) {
      _startAutoScroll(_horizontalScrollController, -scrollSpeed);
    } else if (localPosition.dx > box.size.width - edgeMargin) {
      _startAutoScroll(_horizontalScrollController, scrollSpeed);
    } else if (localPosition.dy < edgeMargin) {
      _startAutoScroll(_verticalScrollController, -scrollSpeed);
    } else if (localPosition.dy > box.size.height - edgeMargin) {
      _startAutoScroll(_verticalScrollController, scrollSpeed);
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll(ScrollController controller, double speed) {
    _stopAutoScroll();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      controller.animateTo(
        controller.offset + speed,
        duration: const Duration(milliseconds: 50),
        curve: Curves.linear,
      );
    });
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }
}
