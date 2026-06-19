import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/views/views.dart';

class WrittenoffWidget extends StatelessWidget {
  const WrittenoffWidget({Key? key, required this.woLoan}) : super(key: key);

  final WrittenOffModel woLoan;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (UserRepository.shared.isCO) {
          BottomSheetManager.custom(content: WrittenoffSheet(woLoan: woLoan));
        } else {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            barrierColor: Colors.black54,
            builder: (_) => WrittenOffReadOnlySheet(woLoan: woLoan),
          );
        }
      },
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
            // Date (left) and amount due to close (right)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    woLoan.client_code,
                    style: AppTextStyle.smallGreyRegular,
                  ),
                ),
                8.width,
                Text(
                  'ប្រាក់ត្រូវបង់ផ្ដាច់៖ ${formatCurrency(woLoan.total_repayment.toString())}',
                  style: AppTextStyle.normalSecondaryBold.copyWith(
                    color: AppColor.red,
                  ),
                ),
              ],
            ),
            10.height,

            // Avatar + client name/cycle + phone/zone + loan amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColor.white,
                  child: ClipOval(
                    child: CustomNetworkImage(
                      imageUrl: woLoan.photo,
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
                        '${woLoan.client} (វដ្គទី ${woLoan.cycle})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.normalPrimaryBold.copyWith(
                          color: const Color(0xFF171617),
                        ),
                      ),
                      4.height,
                      Text(
                        '${woLoan.mobile} (${woLoan.villages_name})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.smallGreyRegular,
                      ),
                      4.height,
                      Text(
                        'ប្រាក់កម្ចី៖ ${formatCurrency(woLoan.principal.toString())}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.smallGreyRegular,
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
    return '${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount))} រៀល'
        .replaceAll('.00', '');
  }
}
