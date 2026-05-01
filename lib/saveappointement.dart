import 'package:appweb/AppState.dart';
import 'package:appweb/allidsusedtologin.dart';
import 'package:appweb/globalwork.dart';
import 'package:appweb/user_session.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> saveAppointment() async {
  final url = Uri.parse("http://localhost:5500/showusers");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "first_name": UserSession.firstname,
      "family_name": UserSession.familyname,
      "date": globalDate != null
          ? "${globalDate!.year}-${globalDate!.month.toString().padLeft(2, '0')}-${globalDate!.day.toString().padLeft(2, '0')}"
          : "",
      "timer": globalTime != null
          ? "${globalTime!.hour.toString().padLeft(2, '0')}:${globalTime!.minute.toString().padLeft(2, '0')}"
          : "",
      "appointemet": selectedServiceforemployee ?? "",
      //"workerSelect": AppState.selectedWorker?.fullname ?? "",
      "user_id": UserSession.getDbId(UserSession.email),
    }),
  );

  if (response.statusCode == 200) {
    print("✅ Appointment saved successfully");
  } else {
    print("❌ Error saving appointment: ${response.body}");
  }
}
