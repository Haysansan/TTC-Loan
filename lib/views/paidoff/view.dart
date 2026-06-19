import 'package:apploan/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/views.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

class PaidOffView extends GetView<PaidOffController> {
  const PaidOffView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCO = UserRepository.shared.isCO;

    return Scaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.paidoff.tr,
        onBack: () {
          final startCtl = Get.find<StartController>();
          startCtl.changeMenu(startCtl.previousIndex.value);
        },
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.red),
          );
        }

        final List<PaidOffModel> paidoffItems = controller.repaymentModels;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SummarySection(),
            if (isCO) _SearchSection() else _FilterSection(),

            if (paidoffItems.isEmpty)
              const Expanded(child: NoDataWidget())
            else
              Expanded(
                child: RefreshIndicator(
                  backgroundColor: AppColor.white,
                  color: AppColor.primary,
                  onRefresh: () async => await controller.onRefresh(),
                  child: pull.SmartRefresher(
                    header: pull.CustomHeader(
                      height: 0,
                      builder: (context, mode) => const SizedBox.shrink(),
                    ),
                    enablePullUp: !controller.pagination.isEndOfPage,
                    controller: controller.refreshCtl,
                    onLoading: () async => await controller.onLoading(),
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        left: UIConstants.spacing.toDouble(),
                        right: UIConstants.spacing.toDouble(),
                        top: UIConstants.midSpacing.toDouble(),
                      ),
                      itemCount: paidoffItems.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: UIConstants.spacing.padBottom,
                          child: PaidOffItemWidget(
                            paidoff: paidoffItems[index],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PaidOffController>();
    return Padding(
      padding: UIConstants.spacing.padHorizontal,
      child: Column(
        children: [
          UIConstants.spacing.height,
          SearchField(
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
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PaidOffController>();
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

class _SummarySection extends StatelessWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PaidOffController>();
    return Obx(() {
      if (c.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final totalCount = int.tryParse(c.totalClient.text) ?? 0;
      final totalAmount = double.tryParse(c.totalAmount.text) ?? 0.0;

      final config = _buildConfig(
        user: UserRepository.shared,
        totalCount: totalCount,
        totalAmount: totalAmount,
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
    required int totalCount,
    required double totalAmount,
  }) {
    if (user.isCO) {
      return SummaryCardConfig.forCO(
        collectedClients: totalCount,
        totalClients: totalCount,
        totalRepaymentUsd: totalAmount,
        collectedUsd: totalAmount,
        onTap: () => Get.toNamed(Routes.customers),
      );
    }
    if (user.isBM) {
      return SummaryCardConfig.forBM(
        collectedCOs: totalCount,
        totalCOs: totalCount,
        totalRepaymentUsd: totalAmount,
        collectedUsd: totalAmount,
      );
    }
    return SummaryCardConfig.forCEO(
      collectedBMs: totalCount,
      totalBMs: totalCount,
      totalRepaymentUsd: totalAmount,
      collectedUsd: totalAmount,
    );
  }
}
