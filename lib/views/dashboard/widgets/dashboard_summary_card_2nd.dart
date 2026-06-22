import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:apploan/core/core.dart';

class ClientCollectionSummary {
  const ClientCollectionSummary({
    required this.overdueClients,
    required this.activeClients,
    required this.overdueAmount,
    required this.principal,
    required this.totalOutstanding,
    required this.paidClients,
    required this.repayDue,
    required this.expectedAmount,
    required this.expectedClients,
  });

  // Card 1 — Clients
  final int overdueClients;
  final int activeClients;
  final String overdueAmount;
  final String principal;
  final String totalOutstanding;

  // Card 2 — Collection
  final int paidClients;
  final String repayDue;
  final String expectedAmount;
  final int expectedClients;
}

/// Two-block summary card for the TTC Loan dashboard.
class DashboardSummaryCard2 extends StatelessWidget {
  const DashboardSummaryCard2({
    Key? key,
    required this.summary,
    required this.userName,
    this.companyName = 'Soft Creative CO.,LTD',
    this.currencySymbol = '៛',
    this.entityLabel = 'Clients',
  }) : super(key: key);

  final ClientCollectionSummary summary;
  final String userName;
  final String companyName;
  final String currencySymbol;
  final String entityLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(companyName: companyName, userName: userName),
          12.height,
          GlassStatsCard(
            left: GlassStatItem(
              label: 'Overdue',
              value: '$currencySymbol${_noDecimals(summary.overdueAmount)}',
              count: '${summary.overdueClients} $entityLabel',
            ),
            right: GlassStatItem(
              label: 'Outstanding',
              value:
                  '$currencySymbol${_noDecimals(summary.totalOutstanding)}',
              count: '${summary.activeClients} active',
            ),
          ),
          8.height,
          GlassStatsCard(
            left: GlassStatItem(
              label: 'Collected',
              value: '$currencySymbol${_noDecimals(summary.repayDue)}',
              count: '${summary.paidClients} paid',
            ),
            right: GlassStatItem(
              label: 'Plan',
              value: '$currencySymbol${_noDecimals(summary.expectedAmount)}',
              count: '${summary.expectedClients} expected',
            ),
          ),
        ],
      ),
    );
  }

  /// Drops the decimal portion (e.g. "1,234.00" -> "1,234").
  String _noDecimals(String amount) => amount.split('.').first;
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.companyName, required this.userName});

  final String companyName;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          image: true,
          label: '$companyName logo',
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(AssetPath.appLogo.path, fit: BoxFit.cover),
            ),
          ),
        ),
        12.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                companyName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              4.height,
              Text(
                'Hi, $userName! Welcome to SC Loan.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GlassStatItem {
  const GlassStatItem({
    required this.label,
    required this.value,
    required this.count,
  });

  final String label;
  final String value;
  final String count;
}

class GlassStatsCard extends StatelessWidget {
  const GlassStatsCard({required this.left, required this.right, this.header});

  final GlassStatItem left;
  final GlassStatItem right;
  final String? header;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (header != null) ...[
                Text(
                  header!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                8.height,
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _StatColumn(item: left)),
                  Container(
                    width: 1,
                    height: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  Expanded(child: _StatColumn(item: right)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.item});

  final GlassStatItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${item.label}: ${item.value}, ${item.count}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
          ),
          4.height,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              item.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          2.height,
          Text(
            item.count,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
