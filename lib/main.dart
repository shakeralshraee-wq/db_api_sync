import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task.dart';
import 'models/category.dart';
import 'controllers/theme_controller.dart';
import 'controllers/locale_controller.dart';
import 'controllers/auth_controller.dart';
import 'helpera/themes.dart';
import 'helpera/translations.dart';
import 'helpera/routes.dart';
import 'helpera/app_pages.dart';
import 'helpera/constants.dart';
import 'controllers/task_controller.dart';
import 'controllers/category_controller.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: call GetStorage.init() on platforms that require explicit initialization.

  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(CategoryAdapter());

  await Hive.openBox<Task>(AppConstants.boxTasks);
  await Hive.openBox<Category>(AppConstants.boxCategories);
  await Hive.openBox(AppConstants.boxSettings);

  // Start SyncService (listens for connectivity and performs background sync)
  // Registered here so controllers can call Get.find<SyncService>() safely.
  // Register the SyncService so it starts listening to connectivity and can be
  // used by controllers. Keep synchronous registration simple.
  Get.put(SyncService());

  // Register controllers globally so they are available for SyncService and initial sync
  final taskController = Get.put(TaskController());
  Get.put(CategoryController());

  // Sync todos from json-server on startup (merge-only; do not overwrite local unsynced data)
  try {
    final remoteTodos = await taskController.fetchTodosApi(limit: 100);

    final tasksBox = Hive.box<Task>(AppConstants.boxTasks);
    // Merge remote todos into local store without overwriting local changes
    for (final t in remoteTodos) {
      final local = tasksBox.get(t.id);
      if (local == null) {
        // remote-only item: save as synced (originated remotely)
        t.isSynced = true;
        t.syncAction = '';
        t.updatedAt = DateTime.now();
        tasksBox.put(t.id, t);
      } else {
        // don't overwrite local unsynced changes
        if (local.isSynced) {
          t.isSynced = true;
          t.syncAction = '';
          t.updatedAt = DateTime.now();
          tasksBox.put(t.id, t);
        }
      }
    }
    Get.log('Synced ${remoteTodos.length} todos from json-server');
  } catch (e) {
    Get.log('Failed to sync todos: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ThemeController());
    Get.put(LocaleController());
    Get.put(AuthController());

    return Obx(() => GetMaterialApp(
          title: 'Todo App',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
          themeMode: Get.find<ThemeController>().themeMode,
          translations: AppTranslations(),
          locale: Get.find<LocaleController>().locale.value,
          fallbackLocale: const Locale('en', 'US'),
          initialRoute: AppRoutes.SPLASH,
          getPages: AppPages.pages,
        ));
  }
}
