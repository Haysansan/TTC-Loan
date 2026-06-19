import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/flavor/flavor.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/routes.dart';
import 'package:apploan/views/sync_data/controller.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController usernameCtl = TextEditingController();
  final TextEditingController passCtl = TextEditingController();

  final RxBool isPassVisible = true.obs;

  @override
  void onInit() {
    _onInit();
    super.onInit();
  }

  Future<void> _onInit() async {
    final String username =
        await SharedPreferencesManager.get(Credential.username.name) ?? '';
    final String password =
        await SharedPreferencesManager.get(Credential.password.name) ?? '';

    if (username.isNotEmpty && password.isNotEmpty) {
      usernameCtl.text = username;
      passCtl.text = password;
    }
  }

  @override
  void onClose() {
    usernameCtl.dispose();
    passCtl.dispose();
    super.onClose();
  }

  Future<void> login() async {
    try {
      final Map<String, dynamic> payload = {
        'username': usernameCtl.text.replaceAll(' ', '').trim(),
        'password': passCtl.text,
      };

      final res = await Get.find<ApiService>().post(
        EndPoints.login,
        payload,
        encode: false,
        contentType: Headers.formUrlEncodedContentType,
        isShowLoading: true,
      );

      // Check if the response indicates failure
      if (res.statusCode != 200 || res.data['success'] == false) {
        // Get the error message from the response
        final String errorMessage =
            res.data['message'] ?? 'Login failed. Please try again.';

        // Show error dialog with the message
        DialogManager.showDialog(title: 'Error', subTitle: errorMessage);
        return;
      }

      final data = getPropertyFromJson(res.data, 'data');

      final LoginModel login = LoginModel.fromJson(data);

      final String permission = login.permission;
      final String token = login.token;

      if (permission.isNotEmpty &&
          permission != Rule.co.name &&
          permission != Rule.bm.name &&
          permission != Rule.eco.name) {
        DialogManager.showDialog(
          title: LocaleKeys.permission.tr,
          subTitle: LocaleKeys.noPermission.tr,
        );
        return;
      }

      /// Pass token becuase when user login at the first time there is no token value when we init AppConfig in main
      AppConfig.shared.token = token;
      //await _getProfile(login.user_id);

      await SharedPreferencesManager.setValue(Credential.token.name, token);
      await SharedPreferencesManager.setValue(
        Credential.username.name,
        usernameCtl.text,
      );
      await SharedPreferencesManager.setValue('name', login.name);
      await SharedPreferencesManager.setValue(
        Credential.password.name,
        passCtl.text,
      );
      await SharedPreferencesManager.setValue(
        Credential.branch_id.name,
        login.branch_id,
      );
      await SharedPreferencesManager.setValue(
        Credential.user_id.name,
        login.user_id,
      );
      await SharedPreferencesManager.setValue(
        Credential.permission.name,
        login.permission,
      );
      UserRepository.shared.setUserTypeFromPermission(login.permission);

      DialogManager.hideLoading();
      Get.offAllNamed(Routes.start);

      // Refresh local cache in the background so offline screens and the
      // disbursement form's cached lookups are up to date after login.
      // SyncDataController().syncCore();
    } catch (e) {
      if (isClosed) {
        return;
      }
      // Generic error handling
      String errorMessage =
          'Login failed. Please check your credentials and try again.';

      // Show error dialog
      DialogManager.showDialog(title: 'Error', subTitle: errorMessage);

      ExceptionHandler.handleException(e);
    }
  }

  Future<void> _getProfile(int UserId) async {
    final Map<String, dynamic> params = {'id': UserId};
    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.profile,
        queryParameters: params,
        isShowLoading: false,
      );

      final data = getPropertyFromJson(res.data, 'data');

      if (data != null) {
        final ProfileModel profile = ProfileModel.fromJson(data);
        UserRepository.shared.setProfile(profile);
        return;
      }

      Get.offAllNamed(Routes.login);
    } catch (e) {
      if (isClosed) {
        return;
      }

      ExceptionHandler.handleException(e);
    }
  }
}
