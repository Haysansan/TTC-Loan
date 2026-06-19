import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';

class ArrearItemWidget extends StatelessWidget {
  const ArrearItemWidget({Key? key, required this.delivery}) : super(key: key);

  final ArrearModel delivery;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          () => BottomSheetManager.custom(
            content: ArrearSheet(delivery: delivery),
          ),
      child: Container(
        padding: 12.padAll,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery
                            .clientId, // Old: delivery.client_code — see note 1
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.normalPrimaryBold.copyWith(
                          color: AppColor.primary,
                        ),
                      ),
                      2.height,
                      Text(
                        delivery.lastPaymentDate,
                        style: AppTextStyle.smallGreyRegular,
                      ),
                    ],
                  ),
                ),
                8.width,
                Text(
                  formatCurrency(
                    delivery.totalOverdue,
                  ), // Old: delivery.total_repayment
                  style: AppTextStyle.normalSecondaryBold.copyWith(
                    color: AppColor.red,
                  ),
                ),
              ],
            ),
            10.height,

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColor.white,
                  child: ClipOval(
                    child: CustomNetworkImage(
                      imageUrl: '', // Old: delivery.photo — see note 2
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.client,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.normalPrimaryBold.copyWith(
                          color: const Color(0xFF171617),
                        ),
                      ),
                      4.height,
                      Text(
                        delivery.mobile,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.smallGreyRegular,
                      ),
                      4.height,
                      Text(
                        'យឺត ${delivery.ageOfLoan} ថ្ងៃ', // Old: delivery.arrea — see note 3
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.smallRedSemibold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatCurrency(String amount) {
    return 'រៀល ${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))}'
        .replaceAll('.00', '');
  }
}
