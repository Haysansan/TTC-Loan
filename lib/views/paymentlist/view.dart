import 'package:apploan/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/views/views.dart';
import 'package:apploan/models/models.dart';

class PaymentCollectionView extends GetView<PaymentListController> {
  const PaymentCollectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCO = UserRepository.shared.isCO;

    return Scaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.paymentslist.tr,
        onBack: () {
          final startCtl = Get.find<StartController>();
          startCtl.changeMenu(startCtl.previousIndex.value);
        },
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UIConstants.midSpacing.height,
            Obx(
              () => CustomSummaryCard(
                mode: SummaryCardMode.collectedUncollected,
                config: SummaryCardConfig.forCO(
                  collectedClients: controller.collectedClients.value,
                  totalClients: int.tryParse(controller.totalClient.text) ?? 0,
                  totalRepaymentUsd: controller.totalRepaymentRaw.value,
                  collectedUsd: controller.collectedSumRaw.value,
                  exchangeRate: controller.exchangeRate.value,
                  onTap: () => Get.toNamed(Routes.customers),
                ),
              ),
            ),
            UIConstants.spacing.height,
            if (isCO) _SearchSection() else _FilterSection(),
            UIConstants.spacing.height,

            if (isCO)
              _CoList(controller: controller)
            else
              _BmList(controller: controller),
          ],
        );
      }),
    );
  }
}

// CO list
class _CoList extends StatelessWidget {
  const _CoList({required this.controller});
  final PaymentListController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.isDone && controller.repayment.isEmpty) {
        return NoDataWidget(text: LocaleKeys.searchNotFound.tr);
      }

      return Expanded(
        child: ListView.builder(
          padding: UIConstants.spacing.padHorizontal,
          itemCount: controller.repayment.length,
          itemBuilder:
              (ctx, i) => CustomTimeLinesWidget(
                isFirst: i == 0,
                isLast: i == controller.repayment.length - 1,
                tracking: controller.repayment[i],
                controller: controller,
              ),
        ),
      );
    });
  }
}

// BM/CEO list paylist only now, tab logic removed
class _BmList extends StatelessWidget {
  const _BmList({required this.controller});
  final PaymentListController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Expanded(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.repayment.isEmpty) {
        return Expanded(
          child: NoDataWidget(text: LocaleKeys.searchNotFound.tr),
        );
      }

      return Expanded(
        child: AbsorbPointer(
          child: ListView.builder(
            padding: UIConstants.spacing.padHorizontal,
            itemCount: controller.repayment.length,
            itemBuilder:
                (ctx, i) => CustomTimeLinesWidget(
                  isFirst: i == 0,
                  isLast: i == controller.repayment.length - 1,
                  tracking: controller.repayment[i],
                  controller: controller,
                ),
          ),
        ),
      );
    });
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PaymentListController>();
    return Padding(
      padding: UIConstants.spacing.padHorizontal,
      child: SearchField(
        controller: c.searchCtl,
        hintText: LocaleKeys.searchByCIDName.tr,
        onClear: () {
          c.clearFilter();
          c.fetchpaymentList();
        },
        onSubmitted: (_) => c.fetchpaymentList(),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PaymentListController>();
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
