class Car {
  final int id;
  final String licensePlate;
  final String brand;
  final String model;
  final int year;
  final String status;
  final double mileageKm;

  Car({
    required this.id,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.year,
    required this.status,
    required this.mileageKm,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as int,
      licensePlate: json['licensePlate'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      status: json['status'] as String? ?? 'UNAVAILABLE',
      mileageKm: (json['mileageKm'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
