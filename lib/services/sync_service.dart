import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../helpera/constants.dart';

import '../controllers/task_controller.dart';
import '../controllers/category_controller.dart';
import '../helpera/routes.dart';


class SyncService extends GetxService {
  late final Box<Task> _taskBox;
  late final Box<Category> _categoryBox;
  final Connectivity _connectivity = Connectivity();
  bool _isSyncing = false;

  @override
  void onInit() {
    super.onInit();
    _taskBox = Hive.box<Task>(AppConstants.boxTasks);
    _categoryBox = Hive.box<Category>(AppConstants.boxCategories);

    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        Get.log('SyncService: connectivity restored, triggering sync');
        triggerSync();
      }
    });
  }

  void triggerSync() {
    if (!_isSyncing) {
      syncTasks();
    }
  }

  Future<void> syncTasks() async {
    if (_isSyncing) return;
    _isSyncing = true;
    Get.log('SyncService: starting sync');
    try {
      // Ensure controllers are available
      if (!Get.isRegistered<TaskController>() || !Get.isRegistered<CategoryController>()) {
        Get.log('SyncService: controllers not registered, skipping sync');
        return;
      }

      final taskController = Get.find<TaskController>();
      final categoryController = Get.find<CategoryController>();

      final pendingTasks = _taskBox.values.where((t) => !t.isSynced).toList();
      for (final t in pendingTasks) {
        try {
          if (t.syncAction == 'insert') {
            final remote = await taskController.addTaskApi(t);

            if (remote.id != t.id) {
              Get.log(
                  'SyncService: insert created remote id=${remote.id}; replacing local id=${t.id}');
              final newTask = remote
                ..isSynced = true
                ..syncAction = ''
                ..updatedAt = DateTime.now();
              _taskBox.delete(t.id);
              _taskBox.put(newTask.id, newTask);
            } else {
              remote.isSynced = true;
              remote.syncAction = '';
              remote.updatedAt = DateTime.now();
              _taskBox.put(remote.id, remote);
            }
          } else if (t.syncAction == 'update') {
            final remote = await taskController.updateTaskApi(t);
            remote.isSynced = true;
            remote.syncAction = '';
            remote.updatedAt = DateTime.now();
            _taskBox.put(remote.id, remote);
          } else if (t.syncAction == 'delete') {
            await taskController.deleteTaskApi(t.id);

            _taskBox.delete(t.id);
          } else {

            t.isSynced = true;
            t.syncAction = '';
            t.updatedAt = DateTime.now();
            t.save();
          }
        } catch (e) {

          Get.log(
              'SyncService: failed to sync task id=${t.id} action=${t.syncAction} error=$e');

          try {
            if (e is DioException && e.response?.statusCode == 401) {
              Get.log(
                  'SyncService: authentication required (401). Stopping sync.');

              Get.snackbar(
                  'Authentication', 'Session expired. Please login again.',
                  snackPosition: SnackPosition.BOTTOM);
              Get.offAllNamed(AppRoutes.LOGIN);
              break;
            }
          } catch (_) {}
        }
      }


      final pendingCats =
          _categoryBox.values.where((c) => !c.isSynced).toList();
      for (final c in pendingCats) {
        try {
          if (c.syncAction == 'insert') {
            final remote = await categoryController.addCategoryApi(c);
            if (remote.id != c.id) {
              Get.log(
                  'SyncService: insert created remote category id=${remote.id}; replacing local id=${c.id}');
              final newCat = remote
                ..isSynced = true
                ..syncAction = ''
                ..updatedAt = DateTime.now();
              _categoryBox.delete(c.id);
              _categoryBox.put(newCat.id, newCat);
            } else {
              remote.isSynced = true;
              remote.syncAction = '';
              remote.updatedAt = DateTime.now();
              _categoryBox.put(remote.id, remote);
            }
          } else if (c.syncAction == 'update') {
            final remote = await categoryController.updateCategoryApi(c);
            remote.isSynced = true;
            remote.syncAction = '';
            remote.updatedAt = DateTime.now();
            _categoryBox.put(remote.id, remote);
          } else if (c.syncAction == 'delete') {
            await categoryController.deleteCategoryApi(c.id);
            _categoryBox.delete(c.id);
          } else {
            c.isSynced = true;
            c.syncAction = '';
            c.updatedAt = DateTime.now();
            c.save();
          }
        } catch (e) {
          Get.log(
              'SyncService: failed to sync category id=${c.id} action=${c.syncAction} error=$e');
          try {
            if (e is DioException && e.response?.statusCode == 401) {
              Get.log(
                  'SyncService: authentication required (401) while syncing categories. Stopping sync.');
              Get.snackbar(
                  'Authentication', 'Session expired. Please login again.',
                  snackPosition: SnackPosition.BOTTOM);
              Get.offAllNamed(AppRoutes.LOGIN);
              break;
            }
          } catch (_) {}
        }
      }
    } finally {
      _isSyncing = false;

      if (Get.isRegistered<TaskController>()) {
        Get.find<TaskController>().update();
      }
      if (Get.isRegistered<CategoryController>()) {
        Get.find<CategoryController>().update();
      }
      Get.log('SyncService: sync completed');
    }
  }
}
