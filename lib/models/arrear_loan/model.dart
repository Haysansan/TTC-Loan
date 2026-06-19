class ArrearModel {
  final String client;
  final String mobile;
  final String loanOfficer;
  final String branch;
  final String clientId;
  final String loanProduct;
  final String expectedMaturityDate;
  final String disbursedOnDate;
  final int id;
  final String dateArrea;
  final int ageOfLoan;
  final String principalOverdue;
  final String interestOverdue;
  final String penaltiesOverdue;
  final String feesOverdue;
  final String totalOverdue;
  final String lastPaymentDate;
  final String principal;

  ArrearModel({
    required this.client,
    required this.mobile,
    required this.loanOfficer,
    required this.branch,
    required this.clientId,
    required this.loanProduct,
    required this.expectedMaturityDate,
    required this.disbursedOnDate,
    required this.id,
    required this.dateArrea,
    required this.ageOfLoan,
    required this.principalOverdue,
    required this.interestOverdue,
    required this.penaltiesOverdue,
    required this.feesOverdue,
    required this.totalOverdue,
    required this.lastPaymentDate,
    required this.principal,
  });

  factory ArrearModel.fromJson(Map<String, dynamic> json) {
    return ArrearModel(
      client: json['client'] ?? '',
      mobile: json['mobile'] ?? '',
      loanOfficer: json['loan_officer'] ?? '',
      branch: json['branch'] ?? '',
      clientId: json['client_id']?.toString() ?? '',
      loanProduct: json['loan_product'] ?? '',
      expectedMaturityDate: json['expected_maturity_date'] ?? '',
      disbursedOnDate: json['disbursed_on_date'] ?? '',
      id: json['id'] ?? 0,
      dateArrea: json['DateArrea'] ?? '',
      ageOfLoan: json['ageofloan'] ?? 0,
      principalOverdue: json['principal_overdue']?.toString() ?? '0',
      interestOverdue: json['interest_overdue']?.toString() ?? '0',
      penaltiesOverdue: json['penalties_overdue']?.toString() ?? '0',
      feesOverdue: json['fees_overdue']?.toString() ?? '0',
      totalOverdue: json['total_overdue']?.toString() ?? '0',
      lastPaymentDate: json['last_payment_date'] ?? '',
      principal: json['principal']?.toString() ?? '0',
    );
  }
}
