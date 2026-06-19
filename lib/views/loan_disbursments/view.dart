import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/views/views.dart';

class LoanDisbursmentsView extends GetView<LoanDisbursmentsController> {
  const LoanDisbursmentsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: LocaleKeys.loanDisbursments.tr,
        onBack: () => Navigator.pop(context, false),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.red),
          );
        }
        return Padding(
          padding: UIConstants.spacing.padHorizontal,
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UIConstants.spacing.height,

                  _SectionTitle(LocaleKeys.clientInformation.tr),
                  UIConstants.midSpacing.height,

                  // Staff (read-only)
                  LabeledField(
                    label: LocaleKeys.choosestaff.tr,
                    child: Obx(
                      () => AbsorbPointer(
                        child: CustomTextField(
                          controller: TextEditingController(
                            text: controller.loggedUserName.value,
                          ),
                          hintText: '',
                        ),
                      ),
                    ),
                  ),

                  // Client
                  LabeledField(
                    label: LocaleKeys.chooseclients.tr,
                    required: true,
                    child: Obx(() {
                      if (controller.isLoadingClients.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColor.red),
                        );
                      }
                      return SearchDropDown<ClientDisbModel>(
                        items: controller.clientList,
                        itemAsString:
                            (item) => '${item.client_code} - ${item.name}',
                        onChanged: controller.onClientChanged,
                        selectedItem: controller.selectedClient.value,
                      );
                    }),
                  ),
                  UIConstants.spacing.height,

                  _SectionTitle(LocaleKeys.loanDetails.tr),
                  UIConstants.midSpacing.height,

                  // Product Type | Date Frequency
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: LocaleKeys.productType.tr,
                          required: true,
                          child: Obx(() {
                            if (controller.isLoadingProductTypes.value) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColor.red,
                                ),
                              );
                            }
                            return CustomDropdown(
                              hintText: LocaleKeys.productType.tr,
                              items: controller.productTypeList,
                              onChanged: controller.onProductTypeChanged,
                              initValue:
                                  controller.selectedProductType.value?.id,
                              validator: (v) => FormValidator.empty(v),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LabeledField(
                          label: LocaleKeys.dateFrequency.tr,
                          required: true,
                          child: Obx(
                            () => CustomDropdown(
                              hintText: LocaleKeys.dateFrequency.tr,
                              items: controller.frequencyTypeList,
                              onChanged: controller.onFrequencyChanged,
                              initValue: controller.selectedFrequency.value?.id,
                              validator: (v) => FormValidator.empty(v),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  UIConstants.spacing.height,

                  // Product
                  LabeledField(
                    label: LocaleKeys.product.tr,
                    required: true,
                    child: Obx(() {
                      if (controller.isLoadingProducts.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColor.red),
                        );
                      }
                      return CustomDropdown(
                        key: ValueKey(controller.productList.length),
                        hintText: LocaleKeys.product.tr,
                        items: controller.productList.toList(),
                        onChanged: controller.onProductChanged,
                        initValue:
                            controller.selectedProduct.value?.id.toString(),
                        validator: (v) => FormValidator.empty(v),
                      );
                    }),
                  ),
                  UIConstants.spacing.height,

                  // Principal
                  LabeledField(
                    label: LocaleKeys.principals.tr,
                    required: true,
                    child: Obx(
                      () => CustomDropdown(
                        hintText: '0',
                        items: controller.appliedAmountList.toList(),
                        onChanged: controller.onAppliedAmountChanged,
                        initValue:
                            controller.selectedAppliedAmount.value?.id
                                .toString(),
                        validator: (v) => FormValidator.empty(v),
                      ),
                    ),
                  ),
                  UIConstants.spacing.height,

                  // Fee
                  LabeledField(
                    label: LocaleKeys.fee.tr,
                    child: Obx(
                      () => MultiSelectDropdown<FeeModel>(
                        items: controller.feeList.toList(),
                        selectedItems: controller.selectedFees.toList(),
                        itemLabel: (f) => f.name,
                        onChanged: controller.onFeeChanged,
                      ),
                    ),
                  ),
                  UIConstants.spacing.height,

                  // Installment | Interest
                  Obx(() {
                    if (controller.isLoadingProductDetail.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColor.red),
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: LabeledField(
                            label: LocaleKeys.inst.tr,
                            child: CustomTextField(
                              controller: controller.instCtl,
                              hintText: '0.00',
                              readOnly: true,
                              textInputAction: TextInputAction.next,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (text) => FormValidator.empty(text),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: LabeledField(
                            label: LocaleKeys.interast.tr,
                            child: CustomTextField(
                              controller: controller.intCtl,
                              hintText: '0.00',
                              readOnly: true,
                              textInputAction: TextInputAction.next,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (text) => FormValidator.empty(text),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  // Daily Income | Total Debt
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: LocaleKeys.dailyIncome.tr,
                          required: true,
                          child: Obx(() {
                            if (controller.isLoadingDailyIncome.value) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColor.red,
                                ),
                              );
                            }
                            return CustomDropdown(
                              hintText: LocaleKeys.dailyIncome.tr,
                              items: controller.dailyIncomeTypeList,
                              onChanged: controller.onDailyIncomeChanged,
                              initValue:
                                  controller.selectedDailyIncome.value?.id
                                      .toString(),
                              validator: (v) => FormValidator.empty(v),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LabeledField(
                          label: LocaleKeys.totalDebt.tr,
                          required: true,
                          child: CustomTextField(
                            controller: controller.totalDebtCtl,
                            hintText: '0',
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            validator: (text) => FormValidator.empty(text),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Loan Purpose
                  LabeledField(
                    label: LocaleKeys.loanPurpose.tr,
                    required: true,
                    child: Obx(() {
                      if (controller.isLoadingLoanPurpose.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColor.red),
                        );
                      }
                      return SearchDropDown<LoanPurposeModel>(
                        items: controller.loanPurposeList,
                        itemAsString: (item) => item.name,
                        onChanged: controller.onLoanPurposeChanged,
                        selectedItem: controller.selectedLoanPurpose.value,
                      );
                    }),
                  ),
                  UIConstants.spacing.height,
                  // Disbursed Date
                  LabeledField(
                    label: LocaleKeys.disbursedDate.tr,
                    required: true,
                    child: InkWell(
                      onTap: () => controller.getDatePicker().show(),
                      child: StackTextField(
                        controller: controller.dateOpenLoanCtl,
                        hintText: LocaleKeys.chooseDate.tr,
                        validator: (text) => FormValidator.phoneNumber(text),
                      ),
                    ),
                  ),

                  // First Repayment Date
                  LabeledField(
                    label: LocaleKeys.firstrepaymentdate.tr,
                    required: true,
                    child: InkWell(
                      onTap: () => controller.getDateFirstPicker().show(),
                      child: StackTextField(
                        controller: controller.dateFirstRepaymentCtl,
                        hintText: LocaleKeys.chooseDate.tr,
                        validator: (text) => FormValidator.phoneNumber(text),
                      ),
                    ),
                  ),
                  UIConstants.spacing.height,

                  // normal primary button for all role
                  // PrimaryButton(
                  //   text: LocaleKeys.submit.tr,
                  //   onPressed: () async {
                  //     if (!controller.formKey.currentState!.validate()) return;
                  //     controller.formKey.currentState!.save();
                  //     await controller.submitBooking();
                  //   },
                  // ),
                  Builder(
                    builder: (context) {
                      final canSubmit = UserRepository.shared.isCO;
                      return Opacity(
                        opacity: canSubmit ? 1.0 : 0.4,
                        child: PrimaryButton(
                          text: LocaleKeys.submit.tr,
                          onPressed: () async {
                            if (!canSubmit) {
                              final role =
                                  UserRepository.shared.isBM
                                      ? 'Branch Manager'
                                      : 'CEO';
                              DialogManager.showDialog(
                                title: 'Access Denied',
                                subTitle:
                                    '$role does not have permission to create disbursement.',
                              );
                              return;
                            }
                            if (!controller.formKey.currentState!.validate())
                              return;
                            controller.formKey.currentState!.save();
                            await controller.submitBooking();
                          },
                        ),
                      );
                    },
                  ),
                  30.height,
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.grey300, width: 1)),
      ),
      child: Text(title, style: AppTextStyle.midPrimaryBold),
    );
  }
}
