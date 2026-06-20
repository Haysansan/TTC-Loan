import 'package:apploan/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/core/offline/database_helper.dart';
import 'package:apploan/flavor/flavor.dart';
import 'package:apploan/models/models.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:apploan/views/views.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WrittenoffController extends GetxController {
  final RxInt selectedStatusValue = 0.obs;
  final TextEditingController startBillCreateDateCtl = TextEditingController();
  final TextEditingController endBillCreateDateCtl = TextEditingController();
  final TextEditingController startBillFinishDateCtl = TextEditingController();
  final TextEditingController endBillFinishDateCtl = TextEditingController();
  final TextEditingController searchCtl = TextEditingController();
  final RxBool isSearchVisible = false.obs;
  final RxList<WrittenOffModel> repaymentModel = <WrittenOffModel>[].obs;
  final RxBool isLoading = false.obs;
  final PaginationModel pagination = PaginationModel(limit: 15);
  final RefreshController refreshCtl = RefreshController(initialRefresh: false);
  final RxBool isToggleOpen = false.obs;
  num total = 0;
  num totalclient = 0;
  final StartController startCtl = Get.find<StartController>();
  final List<WrittenOffModel> _allItems = [];

  final RxList<WrittenOffModel> writtenOffModel = <WrittenOffModel>[].obs;

  final selectedOfficer = RxnString();
  final RxList<CoRepaymentGroup> coGroups = <CoRepaymentGroup>[].obs;
  final RxList<CoRepaymentGroup> filteredGroups = <CoRepaymentGroup>[].obs;
  final RxList<String> coNames = <String>[].obs;

  @override
  void onInit() {
    fetchDelivery();
    super.onInit();
  }

  // show branch_id for login
  Future<int?> getbranchId() async {
    int? branchId = await SharedPreferencesManager.getIntValue('branch_id');
    return branchId;
  }

  // show user_id from login
  Future<int?> getUserId() async {
    int? user_id = await SharedPreferencesManager.getIntValue('user_id');
    return user_id;
  }

  // void searchLocally(String query) {
  //   if (query.isEmpty) {
  //     repaymentModel.value = List.from(_allItems);
  //     return;
  //   }
  //   final q = query.toLowerCase();
  //   repaymentModel.value =
  //       _allItems
  //           .where(
  //             (c) =>
  //                 c.client.toLowerCase().contains(q) ||
  //                 c.client_code.toLowerCase().contains(q),
  //           )
  //           .toList();
  // }

  void filterByOfficer(String? name) {
    selectedOfficer.value = name;
    if (name == null) {
      repaymentModel.value = _allItems;
    } else {
      repaymentModel.value =
          _allItems.where((e) => e.loan_officer == name).toList();
    }
  }

  void goToTab(int index) {
    startCtl.changeMenu(index);
    Get.until((route) => route.settings.name == Routes.start);
  }

  List<Widget> getItems() {
    final List<Widget> items = [
      BottomBarWidget(
        label: LocaleKeys.dashboard.tr,
        isSelected: false,
        icon: Icons.dashboard,
        onTap: () => goToTab(0),
      ),
      BottomBarWidget(
        label: LocaleKeys.paymentslist.tr,
        isSelected: false,
        icon: Icons.payment,
        onTap: () => goToTab(1),
      ),
      BottomBarWidget(
        label: LocaleKeys.paidoff.tr,
        isSelected: false,
        icon: Icons.people_sharp,
        onTap: () => goToTab(2),
      ),
      BottomBarWidget(
        label: LocaleKeys.loanDisbursmentsList.tr,
        isSelected: false,
        icon: Icons.more,
        onTap: () => goToTab(3),
      ),
    ];
    return items;
  }

  Future<void> fetchDelivery({
    bool isRefresh = false,
    bool isLoadMore = false,
    bool isFilter = false,
  }) async {
    try {
      if (isRefresh) {
        if (!isFilter) clearFilter();
        pagination.refresh();
      }

      if (pagination.isEndOfPage) return;

      if ((!isRefresh && !isLoadMore) || isFilter) {
        isLoading.value = true;
      }

      int? branchId = await getbranchId();
      int? userId = await getUserId();

      final res = await Get.find<ApiService>().get(
        EndPoints.getWrittenOffList,
        queryParameters: {'branch_id': branchId, 'user_id': userId},
        isShowLoading: false,
      );

      final data = getPropertyFromJson(res.data, 'data');
      total =
          num.tryParse(
            getPropertyFromJson(res.data, 'totalAmount')?.toString() ?? '0',
          ) ??
          0;
      totalclient =
          num.tryParse(
            getPropertyFromJson(res.data, 'totalClient')?.toString() ?? '0',
          ) ??
          0;

      final fetched = List<WrittenOffModel>.from(
        (data as List).map((e) => WrittenOffModel.fromJson(e)),
      );

      if (isRefresh || (!isLoadMore && !isFilter)) {
        repaymentModel.value = fetched;
      } else if (isLoadMore) {
        repaymentModel.addAll(fetched);
      }

      _allItems
        ..clear()
        ..addAll(repaymentModel);

      coNames.value =
          _allItems
              .map((e) => e.loan_officer)
              .where((name) => name.isNotEmpty && name != 'N/A')
              .toSet()
              .cast<String>()
              .toList()
            ..sort();
    } catch (e) {
      if (isClosed) return;
      ExceptionHandler.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWrittenOffSearch({
    bool isRefresh = false,
    bool isFilter = false,
  }) async {
    if (isFilter) {
      final searchText = searchCtl.text.toLowerCase();
      repaymentModel.value =
          _allItems
              .where(
                (item) =>
                    item.client.toLowerCase().contains(searchText) ||
                    item.client_code.toLowerCase().contains(searchText),
              )
              .toList();
    } else {
      if (isRefresh) onRefresh();
    }
  }

  Future<void> onRefresh({bool isFilter = false}) async {
    await fetchDelivery(isRefresh: true, isFilter: isFilter);
    refreshCtl.refreshCompleted();
  }

  Future<void> onLoading() async {
    await fetchDelivery(isLoadMore: true);
    refreshCtl.loadComplete();
  }

  DatePicker getStartBillCreatePicker(
    TextEditingController startDateCtl,
    TextEditingController endDateCtl,
  ) {
    final DatePicker startPicker = DatePicker(
      controller: startDateCtl,
      initialDate:
          startDateCtl.text.isEmpty
              ? DateTime.parse(
                '${DateFormat("yyyy-MM-dd").format(DateTime.now())} 00:00:00',
              )
              : DateTime.parse(startDateCtl.text),
      minDate: DateTime(DateTime.now().year - 200),
      maxDate:
          endDateCtl.text.isEmpty
              ? DateTime(DateTime.now().year + 200)
              : DateTime.parse(
                endDateCtl.text,
              ).subtract(const Duration(days: 1)),
      minYear: DateTime.now().year - 200,
      maxYear: DateTime.now().year + 200,
    );
    return startPicker;
  }

  DatePicker getEndBillCreatePicker(
    TextEditingController startDateCtl,
    TextEditingController endDateCtl,
  ) {
    final DatePicker startPicker = DatePicker(
      controller: endDateCtl,
      initialDate:
          endDateCtl.text.isNotEmpty
              ? DateTime.parse(endDateCtl.text)
              : startDateCtl.text.isNotEmpty
              ? DateTime.parse(startDateCtl.text)
              : DateTime.parse(
                '${DateFormat("yyyy-MM-dd").format(DateTime.now())} 00:00:00',
              ),
      minDate:
          startDateCtl.text.isNotEmpty
              ? DateTime.parse(startDateCtl.text)
              : endDateCtl.text.isNotEmpty
              ? DateTime.parse(endDateCtl.text)
              : DateTime(DateTime.now().year - 200),
      maxDate: DateTime(DateTime.now().year + 200),
      minYear:
          startDateCtl.text.isEmpty
              ? DateTime.now().year - 200
              : DateTime.parse(startDateCtl.text).year,
      maxYear: DateTime.now().year + 200,
    );
    return startPicker;
  }

  List<IdNameModel> getStatus() {
    final List<IdNameModel> status = [
      IdNameModel(id: 0, name: '--- ${LocaleKeys.chooseDeliveyStatus.tr} ---'),
      IdNameModel(id: 1, name: LocaleKeys.inStock.tr),
      IdNameModel(id: 2, name: LocaleKeys.inprogress.tr),
      IdNameModel(id: 3, name: LocaleKeys.complete.tr),
      IdNameModel(id: 4, name: LocaleKeys.returned.tr),
    ];
    return status;
  }

  void clearSearch() {
    searchCtl.clear();
    fetchDelivery(isRefresh: true);
  }

  void setSearchValue() {
    startBillCreateDateCtl.clear();
    endBillCreateDateCtl.clear();
    startBillFinishDateCtl.clear();
    endBillCreateDateCtl.clear();
    selectedStatusValue.value = 0;
  }

  void setFilterValue({num value = 0}) {
    searchCtl.text = '';
  }

  void clearFilter({int status = 0}) {
    searchCtl.text = '';
    selectedStatusValue.value = status;
    startBillCreateDateCtl.clear();
    endBillCreateDateCtl.clear();
    startBillFinishDateCtl.clear();
    endBillCreateDateCtl.clear();
  }

  void toggleSearch() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) {
      clearFilter();
      fetchWrittenOffSearch(isRefresh: true, isFilter: false);
    }
  }

  @override
  void onClose() {
    startBillCreateDateCtl.dispose();
    endBillCreateDateCtl.dispose();
    startBillFinishDateCtl.dispose();
    endBillCreateDateCtl.dispose();
    searchCtl.dispose();
    refreshCtl.dispose();
    super.onClose();
  }
}
