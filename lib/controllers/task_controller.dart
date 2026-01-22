import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../models/task.dart';
import '../helpera/constants.dart';
import '../helpera/themes.dart';
import '../services/sync_service.dart';
import '../services/api/dio_client.dart';

class TaskController extends GetxController {
  final DioClient _client = DioClient();
  final bool debug = true; // or pass via constructor if needed
  late Box<Task> taskBox;
  String? selectedCategoryId;

  @override
  void onInit() {
    super.onInit();
    taskBox = Hive.box<Task>(AppConstants.boxTasks);
  }

  List<Task> get tasks => taskBox.values.toList();

  List<Task> get filteredTasks {
    if (selectedCategoryId == null) {
      return tasks;
    }
    return tasks.where((t) => t.categoryId == selectedCategoryId).toList();
  }

  List<Task> get completedTasks =>
      filteredTasks.where((t) => t.isCompleted).toList();
  List<Task> get pendingTasks =>
      filteredTasks.where((t) => !t.isCompleted).toList();

  Future<void> addTask(Task task) async {

    try {
      task.isSynced = false;
      task.syncAction = 'insert';
      task.updatedAt = DateTime.now();
      taskBox.put(task.id, task);
      update();
      Get.log(
          'TaskController: saved task id=${task.id} title=${task.title} category=${task.categoryId}');
      Get.snackbar('Success', 'Task saved locally',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successContainer,
          colorText: AppColors.success);

      Get.find<SyncService>().triggerSync();
    } catch (e) {
      Get.log('TaskController: failed to save task id=${task.id} error=$e');
      Get.snackbar('Error', 'Failed to save task: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorContainer,
          colorText: AppColors.error);
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {

      task.isSynced = false;
      task.syncAction = 'update';
      task.updatedAt = DateTime.now();
      task.save();
      update();
      Get.log('TaskController: updated task id=${task.id}');
      Get.snackbar('Success', 'Task updated locally',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successContainer,
          colorText: AppColors.success);
      Get.find<SyncService>().triggerSync();
    } catch (e) {
      Get.log('TaskController: failed to update task id=${task.id} error=$e');
      Get.snackbar('Error', 'Failed to update task: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorContainer,
          colorText: AppColors.error);
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {

      final task = taskBox.get(id);
      if (task != null) {
        task.isSynced = false;
        task.syncAction = 'delete';
        task.updatedAt = DateTime.now();
        task.save();
        update();
        Get.log('TaskController: marked task id=$id for deletion');
        Get.snackbar('Success', 'Task marked for deletion',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successContainer,
            colorText: AppColors.success);
        Get.find<SyncService>().triggerSync();
      }
    } catch (e) {
      Get.log('TaskController: failed to delete task id=$id error=$e');
      Get.snackbar('Error', 'Failed to delete task: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorContainer,
          colorText: AppColors.error);
      rethrow;
    }
  }

  void toggleComplete(String id) {
    final task = taskBox.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;

      task.isSynced = false;
      task.syncAction = 'update';
      task.updatedAt = DateTime.now();
      task.save();
      update();
      Get.log(
          'TaskController: toggled complete for task id=$id isCompleted=${task.isCompleted}');
      Get.find<SyncService>().triggerSync();
    }
  }


  Future<void> sync() async {
    await Get.find<SyncService>().syncTasks();
  }

  void setFilter(String? categoryId) {
    selectedCategoryId = categoryId;
    update();
  }

  Task? getTask(String id) => taskBox.get(id);

  // -------------------- API Methods --------------------
  Future<List<Task>> fetchTodosApi({int limit = 30, int skip = 0}) async {
    const path = '/orders';
    if (debug) log('TaskController.Api: GET $path');
    final resp = await _client.get(path);
    if (debug) log('TaskController.Api: GET $path responseStatus=${resp.statusCode}');
    final data = resp.data;
    if (data == null || data is! List) return [];
    final todos = <Task>[];
    for (final item in data) {
      todos.add(_fromJson(item));
    }
    return todos;
  }

  Future<Task> addTaskApi(Task task) async {
    const path = '/orders';
    final body = task.toApiJson();
    if (debug) log('TaskController.Api: POST $path body=${jsonEncode(body)}');
    final resp = await _client.post(path, data: body);
    if (debug) log('TaskController.Api: POST $path responseStatus=${resp.statusCode}');
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return _fromJson(resp.data);
    }
    throw Exception('Failed to create task: status=${resp.statusCode}');
  }

  Future<Task> updateTaskApi(Task task) async {
    final idNum = int.tryParse(task.id) ?? 0;
    final path = '/orders/$idNum';
    final body = task.toApiJson();
    if (debug) log('TaskController.Api: PUT $path body=${jsonEncode(body)}');
    final resp = await _client.put(path, data: body);
    if (debug) log('TaskController.Api: PUT $path responseStatus=${resp.statusCode}');
    if (resp.statusCode == 200) {
      return _fromJson(resp.data);
    }
    throw Exception(
        'Failed to update task id=$idNum status=${resp.statusCode}');
  }

  Future<void> deleteTaskApi(String id) async {
    final idNum = int.tryParse(id) ?? 0;
    final path = '/orders/$idNum';
    if (debug) log('TaskController.Api: DELETE $path');
    final resp = await _client.delete(path);
    if (debug) log('TaskController.Api: DELETE $path responseStatus=${resp.statusCode}');
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception(
          'Failed to delete task id=$idNum status=${resp.statusCode}');
    }
  }

  Task _fromJson(dynamic json) {
    return Task.fromJson(json as Map<String, dynamic>);
  }
}
