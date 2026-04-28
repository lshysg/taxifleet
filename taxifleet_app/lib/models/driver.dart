class Driver {
  final int id;
  final String fullName;
  final String phone;
  final String licenseNumber;
  final String status;
  final String? hiredAt;

  Driver({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.licenseNumber,
    required this.status,
    this.hiredAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as int,
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      licenseNumber: json['licenseNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'UNAVAILABLE',
      hiredAt: json['hiredAt'] as String?,
    );
  }
}
