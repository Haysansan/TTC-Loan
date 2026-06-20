import 'package:flutter/material.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

enum SummaryCardMode { totalRepayment, totalDisbursement }

class CustomSummaryCard extends StatelessWidget {
  const CustomSummaryCard({Key? key, required this.mode, required this.config})
    : super(key: key);

  final SummaryCardMode mode;
  final SummaryCardConfig config;

  double get _percentage {
    if (config.totalRepaymentUsd == 0) return 0;
    return (config.collectedUsd / config.totalRepaymentUsd).clamp(0.0, 1.0);
  }

  String get _percentageLabel => '${(_percentage * 100).toStringAsFixed(0)}%';

  String get _circleLabel =>
      mode == SummaryCardMode.totalDisbursement
          ? 'Total\nDisbursed'
          : 'Total\nRepaid';

  String _toKhr(double usd) =>
      '៛${NumberFormat('#,##0.00').format(usd * config.exchangeRate)}';

  String _toUsd(double usd) => '\$${NumberFormat('#,##0.00').format(usd)}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF0000).withValues(alpha: 0.55),
              const Color(0xFFFF8386),
              const Color(0xFFFF0000).withValues(alpha: 0.55),
            ],
            stops: const [0.0, 0.51, 0.92],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53935).withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCircularProgress(),
              const SizedBox(width: 16),
              _buildDivider(vertical: true, length: 130),
              const SizedBox(width: 16),
              Expanded(child: _buildRightSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularProgress() {
    const double size = 130;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(size, size),
            painter: _ArcPainter(progress: _percentage),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _circleLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _percentageLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightSection() {
    final bool hasData = config.totalCount > 0;
    final rightTotal = config.coTotal ?? config.totalCount;
    final clientsLabel = hasData ? rightTotal.toString().padLeft(2, '0') : '00';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: config.onCountTap,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.people_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.countLabel,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    clientsLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (config.onCountTap != null)
                const Icon(Icons.chevron_right, color: Colors.white, size: 22),
            ],
          ),
        ),

        const SizedBox(height: 10),
        _buildDivider(vertical: false),
        const SizedBox(height: 10),

        if (mode == SummaryCardMode.totalRepayment)
          _buildTotalRepaymentSection()
        else
          _buildTotalDisbursementSection(),
      ],
    );
  }

  Widget _buildTotalRepaymentSection() {
    final pendingAmount = config.totalRepaymentUsd - config.collectedUsd;
    return _buildAmountRow(
      label: LocaleKeys.totalRepayment.tr,
      primary: _toKhr(pendingAmount),
      primaryFontSize: 16,
    );
  }

  Widget _buildTotalDisbursementSection() {
    return _buildAmountRow(
      label: LocaleKeys.totalDisbursement.tr,
      primary: _toKhr(config.totalRepaymentUsd),
      primaryFontSize: 16,
    );
  }

  Widget _buildAmountRow({
    required String label,
    required String primary,
    String? secondary,
    String? count, // ← add this
    double primaryFontSize = 18,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          // ← prevents overflow on long KHR amounts
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            primary,
            style: TextStyle(
              color: Colors.white,
              fontSize: primaryFontSize,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ),
        if (count != null) ...[
          const SizedBox(height: 2),
          Text(
            count,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 16,
            ),
          ),
        ],
        if (secondary != null)
          Text(
            secondary,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildDivider({
    required bool vertical,
    double length = double.infinity,
  }) {
    return Container(
      width: vertical ? 1 : length,
      height: vertical ? length : 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: vertical ? Alignment.topCenter : Alignment.centerLeft,
          end: vertical ? Alignment.bottomCenter : Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.0),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    const strokeWidth = 14.0;
    const startAngle = math.pi * 0.25;
    const sweepTotal = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepTotal * progress,
        false,
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}
// how to call and use on other views
// total repayment
// CustomSummaryCard(
//   mode: SummaryCardMode.totalRepayment,
//   collectedClients: 0, // placeholder until backend ready
//   totalClients: controller.clientCount,
//   totalRepaymentUsd: controller.totalRepaymentUsd,
//   collectedUsd: controller.collectedUsd,
//   exchangeRate: controller.exchangeRate,
//   onClientsTap: ...,
// )

// total disbursement
// CustomSummaryCard(
//   mode: SummaryCardMode.totalDisbursement,
//   totalClients: controller.totalLoansCount,
//   totalRepaymentUsd: controller.totalDisbursementUsd, // total amount approved/to disburse
//   collectedUsd: controller.disbursedUsd,               // amount already disbursed -> drives the % circle
//   exchangeRate: controller.exchangeRate,
//   onClientsTap: ...,
// )
