import 'dart:convert';
import 'package:http/http.dart' as http;

class UserSession {
  static String userId = "";
  static String firstname = "";
  static String familyname = "";
  static String email = "";
  static int? employeeid;
  static int employeidforrating = 0;

  // ✅ تجيب DB id وتحفظه في userId
  static Future<void> fetchAndSaveDbId(String email) async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://10.229.109.205:5500/api/usersmagni/getid?email=$email",
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userId = data['id'].toString();
        print("✅ UserSession.userId = $userId");
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  // ✅ تجيب DB id وترجعه مباشرة
  static Future<String> getDbId(String email) async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://10.229.109.205:5500/api/usersmagni/getid?email=$email",
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'].toString();
      }
    } catch (e) {
      print("❌ Error: $e");
    }
    return userId;
  }
}
