import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/flavor/flavor.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/routes.dart';

class UserRepository {
  UserRepository._() {
    _context = Get.context;
    _checkDeviceType();
  }

  static final UserRepository _instance = UserRepository._();
  static UserRepository get shared => _instance;

  final String _telegram = 'soft_creative';
  String get telegram => _telegram.replaceAll('@', '');

  final String _phoneNumber = '078 358 272';
  String get phoneNumber => _phoneNumber.replaceAll('@', '');

  final RxString _permission = ''.obs;
  String get permission => _permission.value;

  String get userName {
    final name = profile.name;
    return name.isNotEmpty ? name : 'User';
  }

  static final ProfileModel _emptyProfile = ProfileModel(
    id: 0,
    name: '',
    email: '',
    profile: '',
    phone: '',
    gender: '',
    status: '',
    branch_id: 0,
    created_at: '',
    updated_at: '',
    profilePath: '',
    policy: '',
    type: '',
    full_name: '',
  );

  ProfileModel? _profile;
  ProfileModel get profile => _profile ?? _emptyProfile;

  Future<void> logout() async {
    SharedPreferencesManager.remove(Credential.token.name);
    AppConfig.shared.isDeliveryTapOpened = false;
    Get.offAllNamed(Routes.login);
  }

  void setProfile(ProfileModel profile) {
    setUserType(profile.type);
    _profile = profile;
  }

  void setUserType(String value) {
    _isCO = false;
    _isBM = false;
    _isEco = false;
    switch (value) {
      case 'Credit Officer':
        _isCO = true;
        break;
      case 'Branch Manager':
        _isBM = true;
        break;
      case 'Ceo':
        _isEco = true;
        break;
    }
  }

  void setUserTypeFromPermission(String value) {
    _permission.value = value.toLowerCase(); // ← triggers Obx rebuild
    _isCO = false;
    _isBM = false;
    _isEco = false;
    switch (value.toLowerCase()) {
      case 'co':
        _isCO = true;
        break;
      case 'bm':
        _isBM = true;
        break;
      case 'eco':
        _isEco = true;
        break;
    }
  }

  bool _isTablet = false;
  bool _isCO = false;
  bool _isBM = false;
  bool _isEco = false;
  bool get isTablet => _isTablet;
  bool get isCO => _isCO;
  bool get isBM => _isBM;
  bool get isEco => _isEco;

  BuildContext? _context;
  BuildContext? get context => _context;

  void _checkDeviceType() {
    _isTablet = context!.isTablet;
  }
}
