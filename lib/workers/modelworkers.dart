class Worker {
  final int id; // ✅ int
  final String fullname;
  final String phoneNumber;
  final String job;
  final String address;
  final String firebaseUid;
  final double rating;

  Worker({
    required this.id,
    required this.fullname,
    required this.phoneNumber,
    required this.job,
    required this.address,
    this.firebaseUid = "",
    this.rating = 0.0,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: int.tryParse(json['id'].toString()) ?? 0, //
      fullname: "${json['first_name'] ?? ''} ${json['family_name'] ?? ''}"
          .trim(),
      phoneNumber: json['phone_number']?.toString() ?? '',
      job: json['Job']?.toString() ?? '',
      address: json['Adrres']?.toString() ?? '',
      firebaseUid: json['firebase_uid']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
    );
  }
}
