import 'package:flutter/material.dart';
import 'api/api_service.dart';

class HomeScreenNotifier extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _data;
  bool _isLoading = false;
  bool _isMinimized = false;

  Map<String, dynamic>? get data => _data;
  bool get isLoading => _isLoading;
  bool get isMinimized => _isMinimized;

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    final formData = {
      'period_start': '2024-05-01',
      'period_end': '2024-05-31',
      'period_key': 'month',
      'requested_mo_id': 478,
      'behaviour_key': 'task',
      'with_result': false,
      'response_fields': 'name,indicator_to_mo_id,parent_id,order',
      'auth_user_id': 2,
    };
    final data = await _apiService.postIndicators(formData);

    _data = data?['DATA'];
    _isLoading = false;
    notifyListeners();
  }

  void moveTask(
      Map<String, dynamic> task, int newParentId, int newOrder) async {
    // Remove task from old position
    final oldParentId = task['parent_id'];
    _data?['rows'].removeWhere(
        (t) => t['indicator_to_mo_id'] == task['indicator_to_mo_id']);

    // Update task's parent_id and order
    task['parent_id'] = newParentId;
    task['order'] = newOrder;

    // Add task to new position
    _data?['rows'].add(task);

    // Update the order of tasks in the old column
    final oldTasksInColumn =
        _data?['rows'].where((t) => t['parent_id'] == oldParentId).toList();
    oldTasksInColumn
        ?.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));

    for (int i = 0; i < oldTasksInColumn!.length; i++) {
      oldTasksInColumn[i]['order'] = i + 1;
    }

    // Update the order of tasks in the new column
    final newTasksInColumn =
        _data?['rows'].where((t) => t['parent_id'] == newParentId).toList();
    newTasksInColumn
        ?.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));

    for (int i = 0; i < newTasksInColumn!.length; i++) {
      newTasksInColumn[i]['order'] = i + 1;
    }

    notifyListeners();

    // Save the new task position to the backend
    final formData = {
      'period_start': '2024-05-01',
      'period_end': '2024-05-31',
      'period_key': 'month',
      'indicator_to_mo_id': task['indicator_to_mo_id'],
      'field_name': 'parent_id',
      'field_value': newParentId,
      'auth_user_id': 2,
      'order': newOrder,
    };

    await _apiService.saveTaskData(formData);
  }

  void swapTaskOrder(Map<String, dynamic> task, int parentId, int oldIndex,
      int newIndex) async {
    final tasksInColumn =
        _data?['rows'].where((t) => t['parent_id'] == parentId).toList();
    if (tasksInColumn == null) return;

    final taskToSwap = tasksInColumn[newIndex];

    // Swap the order values
    final tempOrder = task['order'];
    task['order'] = taskToSwap['order'];
    taskToSwap['order'] = tempOrder;

    notifyListeners();

    // Save the new order positions to the backend
    final formData = {
      'period_start': '2024-05-01',
      'period_end': '2024-05-31',
      'period_key': 'month',
      'indicator_to_mo_id': task['indicator_to_mo_id'],
      'field_name': 'order',
      'field_value': task['order'],
      'auth_user_id': 2,
    };
    await _apiService.saveTaskData(formData);

    final formDataSwap = {
      'period_start': '2024-05-01',
      'period_end': '2024-05-31',
      'period_key': 'month',
      'indicator_to_mo_id': taskToSwap['indicator_to_mo_id'],
      'field_name': 'order',
      'field_value': taskToSwap['order'],
      'auth_user_id': 2,
    };
    await _apiService.saveTaskData(formDataSwap);
  }

  void toggleMinimize() {
    _isMinimized = !_isMinimized;
    notifyListeners();
  }
}
