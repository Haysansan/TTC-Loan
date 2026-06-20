import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:intl/intl.dart';
import 'package:apploan/views/views.dart';

class DisburmentListController extends GetxController {
  final TextEditingController searchCtl = TextEditingController();
  final RxBool isSearchVisible = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxList<DisbursementListModel> disburment =
      <DisbursementListModel>[].obs;
  final RxBool isLoading = false.obs;
  final TextEditingController totalClient = TextEditingController();
  final TextEditingController totalAmount = TextEditingController();

  bool isDone = false;
  final StartController startCtl = Get.find<StartController>();

  final selectedOfficer = RxnString();
  final RxList<CoRepaymentGroup> coGroups = <CoRepaymentGroup>[].obs;
  final RxList<CoRepaymentGroup> filteredGroups = <CoRepaymentGroup>[].obs;
  final RxList<String> coNames = <String>[].obs;

  List<DisbursementListModel> _allItems = [];

  bool get isBmOrCeo =>
      UserRepository.shared.isBM || UserRepository.shared.isEco;

  @override
  void onInit() {
    super.onInit();
    fetchDisburmentList();
  }

  @override
  void onClose() {
    searchCtl.dispose();
    totalClient.dispose();
    totalAmount.dispose();
    super.onClose();
  }

  String formatCurrency(String amount) {
    return '${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))}'
        .replaceAll('.00', ' រៀល');
  }

  Future<int?> _getBranchId() async =>
      SharedPreferencesManager.getIntValue('branch_id');

  Future<int?> _getUserId() async =>
      SharedPreferencesManager.getIntValue('user_id');

  void filterByName() {
    final query = searchCtl.text.trim().toLowerCase();
    if (query.isEmpty) {
      disburment.value = _allItems;
    } else {
      disburment.value =
          _allItems
              .where((item) => item.client.toLowerCase().contains(query))
              .toList();
    }
  }

  void filterByOfficer(String? name) {
    selectedOfficer.value = name;
    if (name == null) {
      disburment.value = _allItems;
    } else {
      disburment.value =
          _allItems.where((e) => e.loan_officer == name).toList();
    }
  }

  void clearFilter() {
    searchCtl.text = '';
  }

  void toggleSearch() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) {
      clearFilter();
      filterByName();
    }
  }

  Future<void> fetchDisburmentList() async {
    try {
      isLoading.value = true;
      final userId = await _getUserId();
      final branchId = await _getBranchId();

      final res = await Get.find<ApiService>().get(
        EndPoints.disbursement,
        queryParameters: {
          'branch_id': branchId,
          'user_id': userId,
          if (isBmOrCeo) 'permission': 'co',
        },
        isShowLoading: true,
      );

      final data = getPropertyFromJson(res.data, 'data') as List;
      _allItems =
          data
              .map((e) => DisbursementListModel.fromJson(e))
              .toList()
              .reversed
              .toList();
      disburment.value = _allItems;

      coNames.value =
          _allItems
              .map((e) => e.loan_officer)
              .where((name) => name.isNotEmpty && name != 'N/A')
              .toSet()
              .cast<String>()
              .toList()
            ..sort();

      totalClient.text =
          getPropertyFromJson(res.data, 'totalClient')?.toString() ?? '0';
      totalAmount.text = formatCurrency(
        getPropertyFromJson(res.data, 'totalDisbursement')?.toString() ?? '0',
      );
      isDone = true;
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }
}
