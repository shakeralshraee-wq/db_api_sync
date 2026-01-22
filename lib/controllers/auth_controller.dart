import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';
import '../services/api/dio_client.dart';
import '../helpera/routes.dart';
import '../helpera/constants.dart';
import '../helpera/themes.dart';

class AuthController extends GetxController {
  final _dioClient = DioClient();
  final _settingsBox = Hive.box(AppConstants.boxSettings);
  final _storage = GetStorage();

  final isLoading = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<bool> refreshUser() async {
    try {
      _loadUser();
      return currentUser.value != null;
    } catch (_) {
      return false;
    }
  }

  void _loadUser() {

    final stored = _storage.read(AppConstants.keyUser) ??
        _settingsBox.get(AppConstants.keyUser);
    if (stored != null) {
      try {
        Map<String, dynamic> userMap;
        if (stored is String) {
          userMap = jsonDecode(stored) as Map<String, dynamic>;
        } else if (stored is Map) {
          userMap = Map<String, dynamic>.from(stored);
        } else {
          userMap = {};
        }
        currentUser.value = UserModel.fromJson(userMap);
      } catch (e) {
        debugPrint('Error parsing user data: $e');
      }
    }
  }

  Future<void> login(String username, String password) async {
    try {
      isLoading.value = true;

      final response = await _dioClient.post(
        AppConstants.loginEndpoint,
        data: {
          'email': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

        final token = response.data['accessToken'] ?? response.data['token'];
        final userJson = response.data['user'] ?? response.data;
        if (token != null) {

          await _storage.write(AppConstants.keyToken, token);
          await _settingsBox.put(AppConstants.keyToken, token);
          debugPrint('AuthController: token stored');

          try {
            final user = UserModel.fromJson(userJson);
            await _storage.write(
                AppConstants.keyUser, jsonEncode(user.toJson()));
            await _settingsBox.put(
                AppConstants.keyUser, jsonEncode(user.toJson()));
            currentUser.value = user;
          } catch (_) {

          }

          Get.offAllNamed(AppRoutes.MAIN);
          Get.snackbar('Success', 'Logged in successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.successContainer,
              colorText: AppColors.success);
        }
      }
    } catch (e) {

      if (e is DioException && e.response?.statusCode == 401) {
        Get.snackbar('Error', 'Invalid credentials',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorContainer,
            colorText: AppColors.error);
      } else {
        Get.snackbar('Error', 'Login failed: ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorContainer,
            colorText: AppColors.error);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(Map<String, dynamic> payload) async {
    try {
      isLoading.value = true;
      final resp =
          await _dioClient.post(AppConstants.registerEndpoint, data: payload);
      if (resp.statusCode == 201 || resp.statusCode == 200) {

        final token = resp.data['accessToken'] ?? resp.data['token'];
        final userJson = resp.data['user'] ?? resp.data;
        if (token != null) {
          await _storage.write(AppConstants.keyToken, token);
          await _settingsBox.put(AppConstants.keyToken, token);
          debugPrint('AuthController: token stored (register)');
        }
        try {
          final user = UserModel.fromJson(userJson);
          await _storage.write(AppConstants.keyUser, jsonEncode(user.toJson()));
          await _settingsBox.put(
              AppConstants.keyUser, jsonEncode(user.toJson()));
          currentUser.value = user;
        } catch (_) {}
        Get.offAllNamed(AppRoutes.MAIN);
        Get.snackbar('Success', 'Registered',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Register failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  bool get isLoggedIn {

    final token = _storage.read(AppConstants.keyToken) ??
        _settingsBox.get(AppConstants.keyToken);
    return token != null;
  }

  Map<String, dynamic> debugGetStoredAuth() {
    final tokenGet = _storage.read(AppConstants.keyToken);
    final userGet = _storage.read(AppConstants.keyUser);
    final tokenHive = _settingsBox.get(AppConstants.keyToken);
    final userHive = _settingsBox.get(AppConstants.keyUser);
    return {
      'getStorage': {'token': tokenGet, 'user': userGet},
      'hive': {'token': tokenHive, 'user': userHive},
    };
  }

  void printStoredAuth() {
    final info = debugGetStoredAuth();
    debugPrint('AuthController.storedAuth: $info');
  }

  Future<void> logout() async {
    try {
      await _settingsBox.delete(AppConstants.keyToken);
      await _settingsBox.delete(AppConstants.keyUser);
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.LOGIN);
      Get.snackbar('Success', 'Logged out',
          snackPosition: SnackPosition.BOTTOM,

          backgroundColor: AppColors.successContainer,
          colorText: AppColors.success);
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorContainer,
          colorText: AppColors.error);
    }
  }
}
