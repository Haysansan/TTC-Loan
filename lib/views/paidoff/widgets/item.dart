import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';

class PaidOffItemWidget extends StatelessWidget {
  const PaidOffItemWidget({Key? key, required this.paidoff}) : super(key: key);

  final PaidOffModel paidoff;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          () => BottomSheetManager.custom(
            content: PaidOffSheet(paidoff: paidoff),
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
            // Overdue days (left) and amount paid (right)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'កាលបរិច្ឆេទ៖ ${paidoff.last_payment_date}',
                    style: AppTextStyle.smallGreyRegular,
                  ),
                ),
                8.width,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 251, 231, 231),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'យឺត ${paidoff.arrea}',
                    style: AppTextStyle.smallGreyRegular.copyWith(
                      color: const Color.fromARGB(255, 147, 22, 22),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            10.height,

            // Avatar + client name/cycle + phone/zone + amount paid
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColor.white,
                  child: ClipOval(
                    child: CustomNetworkImage(
                      imageUrl: paidoff.photo,
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
                        '${paidoff.client} (វដ្គទី ${paidoff.cycle})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.normalPrimaryBold.copyWith(
                          color: const Color(0xFF171617),
                        ),
                      ),
                      4.height,
                      Text(
                        '${paidoff.mobile} (${paidoff.villages_name})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.smallGreyRegular,
                      ),
                      4.height,
                      Text(
                        'ទឹកប្រាក់ត្រូវផ្ដាច់ ៖ ${formatCurrency(paidoff.total_repayment.toString())} រៀល',
                        style: AppTextStyle.normalSecondaryBold.copyWith(
                          color: AppColor.red,
                        ),
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
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
    ).format(double.parse(amount)).replaceAll('.00', '');
  }
}
