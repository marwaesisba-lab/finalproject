import 'dart:convert';
import 'package:appweb/user_session.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl = "http://10.229.109.205:5500";

  static Future<Map<String, String>> fetchWorkerStatuses(String userId) async {
    try {
      final url = Uri.parse(
        "$baseUrl/getnotificationsfromemployee?user_id=$userId",
      );

      print("🌐 Fetching from: $url");

      final res = await http.get(url);

      print("📡 Status code: ${res.statusCode}");
      print("📡 Raw body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;

        print("📋 Total notifications: ${data.length}");

        Map<String, String> statuses = {};

        for (var n in data) {
          final employeeId = n['employee_id']?.toString() ?? '';
          UserSession.employeidforrating = int.tryParse(employeeId) ?? 0;
          print(" user session : ${UserSession.employeidforrating} ");
          final content = n['content']?.toString().toLowerCase() ?? '';

          print("🔍 employeeId: $employeeId | content: $content");

          if (employeeId.isEmpty) continue;

          if (content.contains("accepted") ||
              content.contains("completed") ||
              content.contains("progress")) {
            statuses[employeeId] = "accepted";
            print("✅ $employeeId => accepted");
          } else if (content.contains("cancel") ||
              content.contains("refused")) {
            statuses[employeeId] = "refused";
            print("❌ $employeeId => refused");
          } else {
            statuses[employeeId] = "wait";
            print("⏳ $employeeId => wait");
          }
        }

        print("📦 Final statuses: $statuses");
        return statuses;
      } else {
        print("❌ Bad status code: ${res.statusCode}");
        return {};
      }
    } catch (e) {
      print("❌ Error in NotificationService: $e");
      return {};
    }
  }
}
