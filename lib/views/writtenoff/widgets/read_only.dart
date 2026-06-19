import 'package:flutter/material.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:intl/intl.dart';

class WrittenOffReadOnlySheet extends StatelessWidget {
  const WrittenOffReadOnlySheet({Key? key, required this.woLoan})
    : super(key: key);

  final WrittenOffModel woLoan;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColor.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Total Repayment (bold header row)
          _buildRow(
            label: 'Total To Close',
            value: woLoan.total_repayment.toString(),
            isBold: true,
          ),
          const Divider(),

          _buildRow(label: 'Principal', value: woLoan.principal),
          _buildRow(label: 'Interest', value: woLoan.interest),
          _buildRow(label: 'Fee', value: woLoan.monthly_fee),

          // _buildRow(label: 'Penalty', value: woLoan.penalty),
          const SizedBox(height: 20),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: AppTextStyle.normalWhiteBold),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    bool isBold = false,
  }) {
    final style =
        isBold
            ? AppTextStyle.normalPrimaryBold
            : AppTextStyle.normalPrimaryRegular;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(_formatCurrency(value), style: style),
        ],
      ),
    );
  }

  String _formatCurrency(String amount) {
    try {
      return 'រៀល ${NumberFormat.currency(locale: 'en_US', symbol: '').format(double.parse(amount)).replaceAll('.00', '')}';
    } catch (_) {
      return 'N/A';
    }
  }
}
