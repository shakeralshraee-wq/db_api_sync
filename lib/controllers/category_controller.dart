import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../models/category.dart';
import '../services/sync_service.dart';
import '../helpera/themes.dart';
import '../helpera/constants.dart';
import '../services/api/dio_client.dart';

class CategoryController extends GetxController {
  final DioClient _client = DioClient();
  final bool debug = true;
  late Box<Category> categoryBox;

  @override
  void onInit() {
    super.onInit();
    categoryBox = Hive.box<Category>(AppConstants.boxCategories);
  }

  List<Category> get categories => categoryBox.values.toList();

  Future<String> addCategory(Category category) async {
    final existing = categoryBox.values.firstWhere(
        (c) => c.name.toLowerCase() == category.name.toLowerCase(),
        orElse: () => Category(id: '', name: '', colorValue: 0));
    if (existing.id.isNotEmpty) {
      Get.log(
          'CategoryController: duplicate category name=${category.name} existingId=${existing.id}');
      Get.snackbar('Info', 'Category already exists',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.transparent,
          colorText: AppColors.info);
      return existing.id;
    }

    try {
      category.isSynced = false;
      category.syncAction = 'insert';
      category.updatedAt = DateTime.now();
      categoryBox.put(category.id, category);
      update();
      Get.log(
          'CategoryController: added category id=${category.id} name=${category.name}');
      Get.snackbar('Success', 'Category added',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successContainer,
          colorText: AppColors.success);
      Get.find<SyncService>().triggerSync();
      return category.id;
    } catch (e) {
      Get.log(
          'CategoryController: failed to add category name=${category.name} error=$e');
      Get.snackbar('Error', 'Failed to add category: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorContainer,
          colorText: AppColors.error);
      rethrow;
    }
  }

  void updateCategory(Category category) {
    try {
      category.isSynced = false;
      category.syncAction = 'update';
      category.updatedAt = DateTime.now();
      categoryBox.put(category.id, category);
      update();
      Get.log(
          'CategoryController: updated category id=${category.id} name=${category.name}');
      Get.snackbar('Success', 'Category updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successContainer,
          colorText: AppColors.success);
      Get.find<SyncService>().triggerSync();
    } catch (e) {
      Get.log(
          'CategoryController: failed to update category id=${category.id} error=$e');
      Get.snackbar('Error', 'Failed to update category: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorContainer,
          colorText: AppColors.error);
    }
  }

  void deleteCategory(String id) {
    try {
      final cat = categoryBox.get(id);
      if (cat != null) {
        cat.isSynced = false;
        cat.syncAction = 'delete';
        cat.updatedAt = DateTime.now();
        cat.save();
        Get.find<SyncService>().triggerSync();
        Get.log('CategoryController: deleted category id=$id');
      }
      update();
      Get.snackbar('Success', 'Category deleted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successContainer,
          colorText: AppColors.success);
    } catch (e) {
      Get.log('CategoryController: failed to delete category id=$id error=$e');
      Get.snackbar('Error', 'Failed to delete category: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorContainer,
          colorText: AppColors.error);
    }
  }

  Category? getCategory(String id) => categoryBox.get(id);

  // -------------------- API Methods --------------------
  Future<List<Category>> fetchCategoriesApi() async {
    const path = '/categories';
    if (debug) log('CategoryController.Api: GET $path');
    final resp = await _client.get(path);
    if (debug) log('CategoryController.Api: GET $path responseStatus=${resp.statusCode}');
    final data = resp.data;
    if (data == null || data is! List) return [];
    final cats = <Category>[];
    for (final item in data) {
      cats.add(Category.fromJson(item as Map<String, dynamic>));
    }
    return cats;
  }

  Future<Category> addCategoryApi(Category cat) async {
    const path = '/categories';
    final body = cat.toApiJson();
    if (debug) log('CategoryController.Api: POST $path body=${jsonEncode(body)}');
    final resp = await _client.post(path, data: body);
    if (debug) log('CategoryController.Api: POST $path responseStatus=${resp.statusCode}');
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return Category.fromJson(resp.data as Map<String, dynamic>);
    }
    throw Exception('Failed to create category: status=${resp.statusCode}');
  }

  Future<Category> updateCategoryApi(Category cat) async {
    final idNum = int.tryParse(cat.id) ?? 0;
    final path = '/categories/$idNum';
    final body = cat.toApiJson();
    if (debug) log('CategoryController.Api: PUT $path body=${jsonEncode(body)}');
    final resp = await _client.put(path, data: body);
    if (debug) log('CategoryController.Api: PUT $path responseStatus=${resp.statusCode}');
    if (resp.statusCode == 200) {
      return Category.fromJson(resp.data as Map<String, dynamic>);
    }
    throw Exception(
        'Failed to update category id=$idNum status=${resp.statusCode}');
  }

  Future<void> deleteCategoryApi(String id) async {
    final idNum = int.tryParse(id) ?? 0;
    final path = '/categories/$idNum';
    if (debug) log('CategoryController.Api: DELETE $path');
    final resp = await _client.delete(path);
    if (debug) log('CategoryController.Api: DELETE $path responseStatus=${resp.statusCode}');
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception(
          'Failed to delete category id=$idNum status=${resp.statusCode}');
    }
  }
}
