import 'package:flutter/material.dart';
import 'package:fluttertest/widgets/kanban_board.dart';
import 'package:provider/provider.dart';
import 'home_screen_notifier.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 68, 68, 68),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 36, 36, 36),
        title: Text(
          'Kanban Board',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Consumer<HomeScreenNotifier>(
            builder: (context, dataProvider, child) {
              if (dataProvider.isLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (dataProvider.data != null) {
                return KanbanBoard(
                  data: dataProvider.data!,
                  isMinimized: dataProvider.isMinimized,
                );
              } else {
                return Center(
                  child: GestureDetector(
                    onTap: () => context.read<HomeScreenNotifier>().fetchData(),
                    child: Container(
                      width: 100,
                      height: 50,
                      color: Colors.blue,
                      child: Center(
                        child: Text(
                          'Fetch Data',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: MinimizeButton(),
          ),
        ],
      ),
    );
  }
}

class MinimizeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<HomeScreenNotifier>().toggleMinimize();
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          context.watch<HomeScreenNotifier>().isMinimized
              ? Icons.zoom_out
              : Icons.zoom_in,
          color: Colors.white,
        ),
      ),
    );
  }
}
