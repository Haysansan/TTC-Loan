// import 'package:apploan/core/core.dart';
// import 'package:apploan/models/models.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ReceivedController extends GetxController {
//   final RxBool isLoadingList = false.obs;
//   final RxBool isReceiving = false.obs;

//   final RxList<PaymentModel> pendingRepayments = <PaymentModel>[].obs;
//   final RxList<PaymentModel> filteredRepayments = <PaymentModel>[].obs;
//   final RxList<String> loanOfficers = <String>[].obs;

//   final TextEditingController totalClient = TextEditingController();
//   final TextEditingController totalAmount = TextEditingController();

//   final selectedOfficer = RxnString();

//   // Summary card values
//   final RxInt totalCOsInBranch = 0.obs;
//   final RxDouble totalRepaymentRaw = 0.0.obs;
//   final RxDouble receivedSumRaw = 0.0.obs;
//   final RxInt receivedCount = 0.obs;
//   final RxInt totalCount = 0.obs;
//   // TODO: replace receivedSumRaw seed with API value when backend is ready
//   // Example:
//   // final rawCollected = double.tryParse(
//   //   (response.data['collectedAmount'] ?? '0').toString(),
//   // ) ?? 0.0;
//   // receivedSumRaw.value = rawCollected;
//   int get transferredCOCount =>
//       pendingRepayments.map((e) => e.loan_officer).toSet().length;
//   @override
//   void onInit() {
//     super.onInit();
//     fetchPendingRepayments();
//   }

//   Future<int?> _getBranchId() async =>
//       SharedPreferencesManager.getIntValue('branch_id');

//   Future<int?> _getUserId() async =>
//       SharedPreferencesManager.getIntValue('user_id');

//   Future<void> fetchPendingRepayments() async {
//     isLoadingList.value = true;
//     try {
//       final branchId = await _getBranchId();
//       final response = await Get.find<ApiService>().get(
//         '${EndPoints.repaymentPending}/$branchId',
//       );

//       final List users = response.data['users'] ?? [];
//       totalCOsInBranch.value = users.length;
//       loanOfficers.value =
//           users
//               .map((u) => u['full_name']?.toString() ?? '')
//               .where((name) => name.isNotEmpty)
//               .toSet()
//               .toList();

//       final List data = response.data['data'] ?? [];
//       pendingRepayments.value =
//           data.map((e) => PaymentModel.fromJson(e)).toList();

//       // Total is fixed at load time (pending + already received)
//       // For now: sum of pending only. Will add collectedAmount from API later.
//       totalRepaymentRaw.value = _sum(pendingRepayments);
//       totalCount.value = pendingRepayments.length;
//       _updateTotals();
//     } catch (e) {
//       DialogManager.showDialog(
//         title: LocaleKeys.error.tr,
//         subTitle: LocaleKeys.syncFailed.tr,
//         onPressed: () => Get.back(),
//       );
//     } finally {
//       isLoadingList.value = false;
//     }
//   }

//   void filterByOfficer(String? officer) {
//     selectedOfficer.value = officer;
//     filteredRepayments.value =
//         officer == null
//             ? []
//             : pendingRepayments
//                 .where((e) => e.loan_officer == officer)
//                 .toList();
//     _updateTotals();
//   }

//   void _updateTotals() {
//     final list =
//         selectedOfficer.value == null ? pendingRepayments : filteredRepayments;
//     totalClient.text = list.length.toString();
//     totalAmount.text = formatCurrency(_sum(list).toString());
//   }

//   double _sum(List<PaymentModel> list) => list.fold(
//     0.0,
//     (prev, e) => prev + (double.tryParse(e.total_repayment) ?? 0.0),
//   );

//   Future<void> receiveRepayment(PaymentModel item) async {
//     isReceiving.value = true;
//     try {
//       final userId = await _getUserId();
//       await Get.find<ApiService>().get(
//         '${EndPoints.repaymentReceive}/${item.loan_id}/approval_repayment/${item.client_code}',
//         queryParameters: {'received_by_id': userId},
//       );

//       final amount = double.tryParse(item.total_repayment) ?? 0.0;
//       pendingRepayments.remove(item);
//       filteredRepayments.remove(item);
//       receivedSumRaw.value += amount; // arc grows
//       receivedCount.value += 1;

//       _updateTotals();

//       DialogManager.showDialog(
//         title: LocaleKeys.successfully.tr,
//         subTitle: LocaleKeys.youHavesuccessfullysyncData.tr,
//         onPressed: () => Get.back(),
//       );
//     } catch (e) {
//       DialogManager.showDialog(
//         title: LocaleKeys.error.tr,
//         subTitle: LocaleKeys.syncFailed.tr,
//         onPressed: () => Get.back(),
//       );
//     } finally {
//       isReceiving.value = false;
//     }
//   }

//   String formatCurrency(String amount) {
//     final parsed = double.tryParse(amount);
//     if (parsed == null) return 'N/A';
//     return NumberFormat.currency(
//       locale: 'en_US',
//       symbol: '',
//     ).format(parsed).replaceAll('.00', '');
//   }
// }
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReceivedController extends GetxController {
  final RxBool isLoadingList = false.obs;
  final RxBool isReceiving = false.obs;

  final RxList<CoRepaymentGroup> coGroups = <CoRepaymentGroup>[].obs;
  final RxList<CoRepaymentGroup> filteredGroups = <CoRepaymentGroup>[].obs;
  final RxList<String> coNames = <String>[].obs;

  final selectedOfficer = RxnString();
  final RxDouble totalKhr = 0.0.obs;
  final RxInt totalCOs = 0.obs;

  // Fixed at fetch time; used to compare against amount received so far.
  final RxDouble totalTransferKhr = 0.0.obs;
  final RxDouble receivedKhr = 0.0.obs;

  double get receivedPercentage {
    if (totalTransferKhr.value == 0) return 0;
    return (receivedKhr.value / totalTransferKhr.value * 100).clamp(0, 100);
  }

  @override
  void onInit() {
    super.onInit();
    fetchPendingRepayments();
  }

  Future<int?> _getBranchId() async =>
      SharedPreferencesManager.getIntValue('branch_id');

  Future<int?> _getUserId() async =>
      SharedPreferencesManager.getIntValue('user_id');

  Future<void> fetchPendingRepayments() async {
    isLoadingList.value = true;
    try {
      final branchId = await _getBranchId();
      final response = await Get.find<ApiService>().get(
        '${EndPoints.repaymentPending}/$branchId',
      );

      final List users = response.data['users'] ?? [];
      final Map<String, int> coIdByName = {
        for (final u in users)
          if ((u['full_name'] ?? '').toString().isNotEmpty)
            u['full_name'].toString(): u['id'] as int,
      };

      coNames.value = coIdByName.keys.toList();
      totalCOs.value = coNames.length;

      final List data = response.data['data'] ?? [];
      coGroups.value =
          data
              .map((e) {
                final name = e['name_co']?.toString() ?? '';
                return CoRepaymentGroup(
                  coId: coIdByName[name] ?? 0,
                  coName: name,
                  amount: double.tryParse(e['amount']?.toString() ?? '') ?? 0.0,
                );
              })
              .where((g) => g.amount > 0)
              .toList();

      totalKhr.value = coGroups.fold(0.0, (sum, g) => sum + g.amount);
      totalTransferKhr.value = totalKhr.value;
      receivedKhr.value = 0;
    } catch (e) {
      DialogManager.showDialog(
        title: LocaleKeys.error.tr,
        subTitle: LocaleKeys.syncFailed.tr,
        onPressed: () => Get.back(),
      );
    } finally {
      isLoadingList.value = false;
    }
  }

  void filterByOfficer(String? name) {
    selectedOfficer.value = name;
    filteredGroups.value =
        name == null ? [] : coGroups.where((g) => g.coName == name).toList();
  }

  List<CoRepaymentGroup> get displayedGroups =>
      selectedOfficer.value == null ? coGroups : filteredGroups;

  Future<void> receiveGroup(CoRepaymentGroup group) async {
    isReceiving.value = true;
    try {
      final branchId = await _getBranchId();
      await Get.find<ApiService>().get(
        '${EndPoints.repaymentReceive}/$branchId/approval_repayment/${group.coId}',
      );

      coGroups.remove(group);
      filteredGroups.remove(group);
      totalKhr.value -= group.amount;
      receivedKhr.value += group.amount;
    } catch (e) {
      DialogManager.showDialog(
        title: LocaleKeys.error.tr,
        subTitle: LocaleKeys.syncFailed.tr,
        onPressed: () => Get.back(),
      );
    } finally {
      isReceiving.value = false;
    }
  }

  String formatKhr(double amount) => NumberFormat.currency(
    locale: 'en_US',
    symbol: '',
  ).format(amount).replaceAll('.00', '');
}
