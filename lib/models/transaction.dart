class AppTransaction {
  AppTransaction({
    required this.id,
    required this.reference,
    required this.serviceType,
    required this.title,
    required this.meta,
    required this.amount,
    required this.credit,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String reference;
  final String serviceType;
  final String title;
  final String meta;
  final double amount;
  final bool credit;
  final String status;
  final DateTime createdAt;

  factory AppTransaction.fromJson(Map<String, dynamic> json) => AppTransaction(
        id: json['id'] as int,
        reference: json['reference'] as String,
        serviceType: json['service_type'] as String,
        title: json['title'] as String,
        meta: json['meta'] as String,
        amount: (json['amount'] as num).toDouble(),
        credit: json['credit'] as bool,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
