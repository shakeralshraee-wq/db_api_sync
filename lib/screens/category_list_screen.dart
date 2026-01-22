import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../controllers/task_controller.dart';
import '../helpera/themes.dart';
import '../widgets/add_category_dialog.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Scaffold(
      appBar: AppBar(title: Text('categories'.tr)),
      body: GetBuilder<CategoryController>(
        builder: (controller) {
          if (controller.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category, size: 64, color: AppColors.iconSubtle),
                  const SizedBox(height: 16),
                  Text('no_categories'.tr,
                      style: TextStyle(color: AppColors.textSubtleDark)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              final taskCount = taskController.tasks
                  .where((t) => t.categoryId == category.id)
                  .length;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(category.colorValue),
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(category.name),
                  subtitle: Text('$taskCount ${'tasks'.tr}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'edit'.tr,
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          // Await dialog result; controller will perform update and snackbar
                          await Get.dialog(
                              AddCategoryDialog(category: category));
                        },
                      ),
                      IconButton(
                        tooltip: 'delete'.tr,
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () async =>
                            await _deleteCategory(category.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.dialog(AddCategoryDialog());
          if (result != null) {
            Get.log('CategoryListScreen: added category id=$result');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteCategory(String id) async {
    final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: Text('delete'.tr),
            content: Text('delete_confirm'.tr),
            actions: [
              TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text('cancel'.tr)),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('delete'.tr,
                    style: const TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final taskController = Get.find<TaskController>();
    for (var task in taskController.tasks) {
      if (task.categoryId == id) {
        task.categoryId = null;
        task.isSynced = false;
        task.syncAction = 'update';
        task.updatedAt = DateTime.now();
        task.save();
      }
    }
    // Delete category via controller (handles local-first + sync + snackbar)
    Get.find<CategoryController>().deleteCategory(id);
  }
}
