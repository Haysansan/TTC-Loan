class DashboardModel {
  final dynamic totalPackage;
  final String totalAmount;
  final String extraAmountTaxi;
  final num numberOfDelivery;
  final String commissionFee;
  final String totalPackageAllInStock;
  final num totalPackageDeliveryInProgress;
  final String codAmountUsd;
  final String codAmountKhr;
  final num isProblem;
  final num rating;

  DashboardModel({
    required this.totalPackage,
    required this.totalAmount,
    required this.extraAmountTaxi,
    required this.numberOfDelivery,
    required this.commissionFee,
    required this.totalPackageAllInStock,
    required this.totalPackageDeliveryInProgress,
    required this.codAmountUsd,
    required this.codAmountKhr,
    required this.isProblem,
    required this.rating,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalPackage: json['total_package'] ?? 0,
      totalAmount: json['total_amount'] ?? '0.0',
      extraAmountTaxi: json['extra_amount_taxi'] ?? '0.0',
      numberOfDelivery: json['number_of_delivery'] ?? 0,
      commissionFee: json['commission_fee'] ?? '0.0',
      totalPackageAllInStock: json['total_package_all_in_stock'] ?? '0.0',
      totalPackageDeliveryInProgress:
          json['total_package_delivery_in_progress'] ?? 0,
      codAmountUsd: json['cod_amount_usd'] ?? '0.0',
      codAmountKhr: json['cod_amount_khr'] ?? '0.0',
      isProblem: json['is_problem'] ?? 0,
      rating: json['kh_amount'] ?? 0,
    );
  }
}

class StatItem {
  final String title;
  final String sublabel;
  final String amount;

  const StatItem({
    required this.title,
    required this.sublabel,
    required this.amount,
  });
}

class CoCollectionSummary {
  final int coId;
  final String coName;
  final int activeClients;
  final int overdueClients;
  final int expectedClients;
  final int paidClients;
  final int totalClients;
  final double totalOutstanding;
  final double overdueAmount;
  final double expectedAmount;
  final double repayDue;
  final double totalAmount;

  CoCollectionSummary({
    required this.coId,
    required this.coName,
    required this.activeClients,
    required this.overdueClients,
    required this.expectedClients,
    required this.paidClients,
    required this.totalClients,
    required this.totalOutstanding,
    required this.overdueAmount,
    required this.expectedAmount,
    required this.repayDue,
    required this.totalAmount,
  });

  factory CoCollectionSummary.fromJson(Map<String, dynamic> json) {
    return CoCollectionSummary(
      coId: int.tryParse('${json['id']}') ?? 0,
      coName: json['name_co']?.toString() ?? '',
      activeClients: int.tryParse('${json['client_active']}') ?? 0,
      overdueClients: int.tryParse('${json['client_over_due']}') ?? 0,
      expectedClients:
          double.tryParse('${json['ExpectedClientDue']}')?.toInt() ?? 0,
      paidClients: int.tryParse('${json['client_paid']}') ?? 0,
      totalClients: double.tryParse('${json['total_client']}')?.toInt() ?? 0,
      totalOutstanding: double.tryParse('${json['principal']}') ?? 0.0,
      overdueAmount: double.tryParse('${json['over_due_amount']}') ?? 0.0,
      expectedAmount: double.tryParse('${json['ExpectedAmount']}') ?? 0.0,
      repayDue: double.tryParse('${json['RepaydueDue']}') ?? 0.0,
      totalAmount: double.tryParse('${json['total_amount']}') ?? 0.0,
    );
  }
}
