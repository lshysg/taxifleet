class Order {
  final int id;
  final String addressFrom;
  final String addressTo;
  final String clientName;
  final String clientPhone;
  final String status;
  final double? cost;
  final String createdAt;

  Order({
    required this.id,
    required this.addressFrom,
    required this.addressTo,
    required this.clientName,
    required this.clientPhone,
    required this.status,
    this.cost,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      addressFrom: json['addressFrom'] as String? ?? '',
      addressTo: json['addressTo'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      clientPhone: json['clientPhone'] as String? ?? '',
      status: json['status'] as String? ?? 'NEW',
      cost: (json['cost'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
