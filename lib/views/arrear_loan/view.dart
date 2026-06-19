import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/arrear_loan/widgets/item.dart';
import 'package:apploan/views/views.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArrearLoanView extends GetView<ArrearLoanController> {
  const ArrearLoanView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.arrearloan.tr,
        onBack: () => Navigator.pop(context, false),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        final List<ArrearModel> delivery = controller.arrearModel;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: UIConstants.spacing.padHorizontal,
              child: SingleChildScrollView(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UIConstants.spacing.height,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.choosestaff.tr,
                            style: AppTextStyle.normalPrimaryRegular,
                          ),
                          SearchDropDown<StaffModel>(
                            items: controller.StaffList,
                            itemAsString:
                                (item) =>
                                    '${item.id} - ${item.name}', // Convert StaffModel to String
                            onChanged: (value) {
                              controller.onClientChanged(value as StaffModel?);
                            },
                            selectedItem: controller.StaffSelected,
                          ),
                          UIConstants.spacing.height,

                          Text(
                            LocaleKeys.date.tr,
                            style: AppTextStyle.normalPrimaryRegular,
                          ),
                          const SizedBox(height: 2),
                          InkWell(
                            onTap: () => controller.getDatePicker().show(),
                            child: StackTextField(
                              controller: controller.dateCtl,
                              hintText: LocaleKeys.chooseDate.tr,
                              validator:
                                  (text) => FormValidator.phoneNumber(text),
                            ),
                          ),
                        ],
                      ),
                      10.height,
                      PrimaryButton(
                        text: LocaleKeys.filter.tr,
                        onPressed: () async {
                          if (!controller.formKey.currentState!.validate()) {
                            return;
                          }
                          controller.formKey.currentState!.save();
                          await controller.fetchArrear();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() {
              if (controller.isLoadings.value) {
                return Center(child: CircularProgressIndicator());
              } else if (controller.isDone && controller.arrearModel.isEmpty) {
                return NoDataWidget(text: LocaleKeys.searchNotFound.tr);
              } else {
                return Expanded(
                  child: ListView.builder(
                    padding: UIConstants.spacing.padHorizontal,
                    itemCount: controller.arrearModel.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: UIConstants.spacing.padBottom,
                        child: ArrearItemWidget(delivery: delivery[index]),
                      );
                    },
                  ),
                );
              }
            }),
          ],
        );
      }),
    );
  }
}
