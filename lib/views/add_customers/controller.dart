import 'dart:io';

import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/add_customers/guarantor_controller.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:apploan/views/views.dart';

class AddCustomersController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController gender = TextEditingController();
  final TextEditingController dateOfBirth = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController gisCode = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController district = TextEditingController();
  final TextEditingController commune = TextEditingController();
  final TextEditingController village = TextEditingController();
  final RxList<CoBorrowerIdTypeModel> idTypes = <CoBorrowerIdTypeModel>[].obs;
  final Rxn<CoBorrowerIdTypeModel> selectedIdType =
      Rxn<CoBorrowerIdTypeModel>();
  final TextEditingController externalIdController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isLoading_district = false.obs;
  final RxBool isLoading_commune = false.obs;
  final RxBool isLoading_village = false.obs;

  final RxList<DistrictModel> districtList = <DistrictModel>[].obs;
  final RxList<ProvinceModel> ProvinceList = <ProvinceModel>[].obs;
  final RxList<CommuneModel> CommuneList = <CommuneModel>[].obs;
  final RxList<VillageModel> VillageList = <VillageModel>[].obs;
  final Rx<String?> selectedCustomer = Rx<String?>(null);
  final List<String> genderItems = ['Female', 'Male'];
  final Rxn<XFile> profileImage = Rxn<XFile>();
  final Rxn<XFile> idCardImage = Rxn<XFile>();

  ProvinceModel? ProvinceSelected;
  DistrictModel? DistrictSelected;
  CommuneModel? CommuneSelected;
  VillageModel? VillageSelected;

  void pickProfileImage() {
    ImagePickerManager.pickImage((file) {
      if (file != null) profileImage.value = file;
    });
  }

  void pickIdCardImage() {
    ImagePickerManager.pickImage((file) {
      if (file != null) idCardImage.value = file;
    });
  }

  void selectGender(String value) => selectedCustomer.value = value;

  final RxBool isFetchingLocation = false.obs;

  Future<void> fetchCurrentLocation() async {
    if (isFetchingLocation.value) return;
    isFetchingLocation.value = true;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        DialogManager.showDialog(
          title: LocaleKeys.error.tr,
          subTitle: 'Please enable location services to get your GIS location.',
          onPressed: () => Get.back(),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        DialogManager.showDialog(
          title: LocaleKeys.error.tr,
          subTitle:
              'Location permission is required to get your GIS location.',
          onPressed: () => Get.back(),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      gisCode.text =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    } finally {
      isFetchingLocation.value = false;
    }
  }

  @override
  void onInit() async {
    await Future.wait([fetchProvince(), _fetchIdTypes()]);
    super.onInit();
  }

  Future<int?> getbranchId() async =>
      SharedPreferencesManager.getIntValue('branch_id');

  Future<int?> getUserId() async =>
      SharedPreferencesManager.getIntValue('user_id');

  Future<void> _fetchIdTypes() async {
    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.clientCreate,
        isShowLoading: false,
      );
      idTypes.assignAll(
        (res.data['identification_types'] as List)
            .map(
              (e) => CoBorrowerIdTypeModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    }
  }

  Future<void> fetchProvince() async {
    try {
      isLoading.value = true;
      final res = await Get.find<ApiService>().get(
        EndPoints.getprovince,
        isShowLoading: false,
      );
      final data = getPropertyFromJson(res.data, 'data');
      ProvinceList.value = List.from(
        (data as List).map((e) => ProvinceModel.fromJson(e)),
      );
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDistrict(int? id) async {
    try {
      isLoading_district.value = true;
      districtList.clear();
      CommuneList.clear();
      VillageList.clear();
      final res = await Get.find<ApiService>().get(
        '${EndPoints.getdistrict}/$id',
        isShowLoading: false,
      );
      final data = getPropertyFromJson(res.data, 'data');
      districtList.value = List.from(
        (data as List).map((e) => DistrictModel.fromJson(e)),
      );
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    } finally {
      isLoading_district.value = false;
    }
  }

  Future<void> fetchCommune(int? id) async {
    try {
      isLoading_commune.value = true;
      CommuneList.clear();
      VillageList.clear();
      final res = await Get.find<ApiService>().get(
        '${EndPoints.getcommune}/$id',
        isShowLoading: false,
      );
      final data = getPropertyFromJson(res.data, 'data');
      CommuneList.value = List.from(
        (data as List).map((e) => CommuneModel.fromJson(e)),
      );
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    } finally {
      isLoading_commune.value = false;
    }
  }

  Future<void> fetchVillage(int? id) async {
    try {
      isLoading_village.value = true;
      VillageList.clear();
      final res = await Get.find<ApiService>().get(
        '${EndPoints.getvillage}/$id',
        isShowLoading: false,
      );
      final data = getPropertyFromJson(res.data, 'data');
      VillageList.value = List.from(
        (data as List).map((e) => VillageModel.fromJson(e)),
      );
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    } finally {
      isLoading_village.value = false;
    }
  }

  DatePicker getDatePicker() {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        dateOfBirth.text.isEmpty
            ? now
            : DateTime.tryParse(dateOfBirth.text) ?? now;
    return DatePicker(
      controller: dateOfBirth,
      initialDate: initialDate,
      minDate: DateTime(now.year - 90),
      maxDate: DateTime(now.year + 1),
      minYear: now.year,
      maxYear: now.year + 200,
    );
  }

  String formatCurrency(String amount) {
    return amount != null
        ? '${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))}'
            .replaceAll('.00', '')
        : 'N/A';
  }

  void onProvinceChanged(ProvinceModel? value) => ProvinceSelected = value;
  void onDistrictChanged(DistrictModel? value) => DistrictSelected = value;
  void onCommuneChanged(CommuneModel? value) => CommuneSelected = value;
  void onVillageChanged(VillageModel? value) => VillageSelected = value;

  Future<void> submitBooking() async {
    try {
      final int? branchId = await getbranchId();
      final int? userId = await getUserId();

      final coBorrowerCtrl = Get.find<CoBorrowerController>();
      final guarantorCtrl = Get.find<GuarantorController>();

      final Map<String, dynamic> payload = {
        'first_name': firstName.text,
        'last_name': lastName.text,
        'gender': selectedCustomer.value,
        'dob': dateOfBirth.text,
        'mobile': phoneNumber.text,
        'gis_code': gisCode.text,
        'id_type_id': selectedIdType.value?.id,
        'external_id': externalIdController.text,
        'province_id': ProvinceSelected?.id,
        'district_id': DistrictSelected?.id,
        'commune_id': CommuneSelected?.id,
        'village_id': VillageSelected?.id,
        'branch_id': branchId,
        'user_id': userId,
      };

      // Merge co-borrowers
      // for (final coborrower in coBorrowerCtrl.added) {
      //   coborrower.toJson().forEach((key, value) {
      //     if (value != null) payload[key] = value;
      //   });
      // }
      // Single co-borrower
      if (coBorrowerCtrl.added.isNotEmpty) {
        coBorrowerCtrl.added.first.toJson().forEach((key, value) {
          if (value != null) payload[key] = value;
        });
      }

      // Merge guarantors
      // for (final guarantor in guarantorCtrl.added) {
      //   guarantor.toJson().forEach((key, value) {
      //     if (value != null) payload[key] = value;
      //   });
      // }

      // Single guarantor
      if (guarantorCtrl.added.isNotEmpty) {
        guarantorCtrl.added.first.toJson().forEach((key, value) {
          if (value != null) payload[key] = value;
        });
      }

      // Multiple co-borrowers
      // for (int i = 0; i < coBorrowerCtrl.added.length; i++) {
      //   coBorrowerCtrl.added[i].toJson().forEach((key, value) {
      //     if (value != null) payload['co_borrowers[$i][$key]'] = value;
      //   });
      // }

      // Multiple guarantors
      // for (int i = 0; i < guarantorCtrl.added.length; i++) {
      //   guarantorCtrl.added[i].toJson().forEach((key, value) {
      //     if (value != null) payload['guarantors[$i][$key]'] = value;
      //   });
      // }

      dio.FormData formData = dio.FormData.fromMap(payload);

      if (profileImage.value != null) {
        formData.files.add(
          MapEntry(
            'photo',
            await dio.MultipartFile.fromFile(
              profileImage.value!.path,
              filename: profileImage.value!.name,
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      if (idCardImage.value != null) {
        formData.files.add(
          MapEntry(
            'id_card_photo',
            await dio.MultipartFile.fromFile(
              idCardImage.value!.path,
              filename: idCardImage.value!.name,
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      await Get.find<ApiService>().post(
        EndPoints.clientStore,
        formData,
        isShowLoading: true,
      );

      DialogManager.showDialog(
        title: LocaleKeys.successfully.tr,
        subTitle: LocaleKeys.youHaveSuccessfullyCreated.tr,
        onPressed: () => Get.back(),
      );
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    }
  }

  @override
  void onClose() {
    externalIdController.dispose();
    super.onClose();
  }

  final RxList<File> imageFiles = RxList<File>([File('')]);
  final int totalImage = 5;
  bool isNoMoreUpload() => imageFiles.length == totalImage + 1;
}
