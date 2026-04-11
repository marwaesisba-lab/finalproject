// worker_model.dart
class Worker {
  final String fullname;
  final String phoneNumber;
  final String job;
  final String address;

  Worker({
    required this.fullname,
    required this.phoneNumber,
    required this.job,
    required this.address,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      fullname: json['full_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      job: json['Job']?.toString() ?? '',
      address: json['Adrres']?.toString() ?? '',
    );
  }
}
