import 'package:apploan/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/views.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

class RepaymentView extends GetView<RepaymentController> {
  const RepaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCO = UserRepository.shared.isCO;

    return Scaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.repayment.tr,
        onBack: () => Navigator.pop(context, false),
      ),
      bottomNavigationBar: AppBottomNav(items: controller.getItems()),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.red),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SummarySection(),
            if (isCO) _SearchSection() else _FilterSection(),
            if (controller.repaymentModel.isEmpty)
              const Expanded(child: NoDataWidget())
            else
              _RepaymentList(items: controller.repaymentModel),
          ],
        );
      }),
    );
  }
}

String formatCurrency(String amount) {
  // ignore: unnecessary_null_comparison
  return amount != null
      ? 'រៀល ${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))}'
          .replaceAll('.00', '')
      : 'N/A';
}

// Summary card
class _SummarySection extends StatelessWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RepaymentController>();
    return Obx(() {
      if (c.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final totalClients = int.tryParse(c.totalClient.text) ?? 0;
      final totalAmount =
          double.tryParse(c.totalAmount.text.replaceAll(',', '')) ?? 0;

      final config = _buildConfig(
        user: UserRepository.shared,
        collectedCount: c.coGroups.length,
        totalCount: totalClients,
        totalRepaymentUsd: totalAmount,
      );

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: CustomSummaryCard(
          mode: SummaryCardMode.totalRepayment,
          config: config,
        ),
      );
    });
  }

  SummaryCardConfig _buildConfig({
    required UserRepository user,
    required int collectedCount,
    required int totalCount,
    required double totalRepaymentUsd,
  }) {
    if (user.isCO) {
      return SummaryCardConfig.forCO(
        collectedClients: collectedCount,
        totalClients: totalCount,
        totalRepaymentUsd: totalRepaymentUsd,
        collectedUsd: 0,
        onTap: () => Get.toNamed(Routes.customers),
      );
    }
    if (user.isBM) {
      return SummaryCardConfig.forBM(
        collectedCOs: collectedCount,
        totalCOs: totalCount,
        totalRepaymentUsd: totalRepaymentUsd,
        collectedUsd: 0,
      );
    }
    // user.isEco
    return SummaryCardConfig.forCEO(
      collectedBMs: collectedCount,
      totalBMs: totalCount,
      totalRepaymentUsd: totalRepaymentUsd,
      collectedUsd: 0,
    );
  }
}

// Repayment List
class _RepaymentList extends StatelessWidget {
  const _RepaymentList({required this.items});

  final List<RepaymentModel> items;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        backgroundColor: AppColor.white,
        color: AppColor.primary,
        onRefresh:
            () async => await Get.find<RepaymentController>().onRefresh(),
        child: pull.SmartRefresher(
          header: pull.CustomHeader(
            height: 0,
            builder: (context, mode) => const SizedBox.shrink(),
          ),
          enablePullUp: !Get.find<RepaymentController>().pagination.isEndOfPage,
          controller: Get.find<RepaymentController>().refreshCtl,
          onLoading:
              () async => await Get.find<RepaymentController>().onLoading(),
          child: ListView.builder(
            padding: EdgeInsets.only(
              left: UIConstants.spacing.toDouble(),
              right: UIConstants.spacing.toDouble(),
              // top: UIConstants.midSpacing.toDouble(),
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: RepaymentItemWidget(repayment: items[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Search
class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RepaymentController>();
    return Padding(
      padding: UIConstants.spacing.padHorizontal,
      child: SearchField(
        controller: c.searchCtl,
        hintText: LocaleKeys.searchByCIDName.tr,
        onClear: () {
          c.clearFilter();
          c.fetchRepaymentSearch(isRefresh: true, isFilter: false);
        },
        onSubmitted: (_) {
          c.setSearchValue();
          c.fetchRepaymentSearch(isRefresh: true, isFilter: true);
        },
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RepaymentController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter by CO', style: AppTextStyle.normalPrimaryBold),
              Obx(() {
                if (c.selectedOfficer.value == null) return const SizedBox();
                return GestureDetector(
                  onTap: () => c.filterByOfficer(null),
                  child: Text('Clear', style: AppTextStyle.normalRedBold),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => SearchDropDown<String>(
              items: c.coNames,
              itemAsString: (item) => item,
              onChanged: c.filterByOfficer,
              selectedItem: c.selectedOfficer.value,
              label: 'Search for CO',
            ),
          ),
        ],
      ),
    );
  }
}
