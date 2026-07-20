class DataPlan {
  DataPlan({
    required this.id,
    required this.provider,
    required this.providerCode,
    required this.planId,
    required this.name,
    required this.type,
    required this.price,
  });

  final int id;
  final String provider;
  final String providerCode;
  final String planId;
  final String name;
  final String type;
  final double price;

  factory DataPlan.fromJson(Map<String, dynamic> json) => DataPlan(
        id: json['id'] as int,
        provider: json['provider'] as String,
        providerCode: json['provider_code'].toString(),
        planId: json['plan_id'].toString(),
        name: json['name'] as String,
        type: json['type'] as String,
        price: double.parse(json['price'].toString()),
      );
}
