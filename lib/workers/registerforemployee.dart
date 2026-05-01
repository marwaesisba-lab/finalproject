import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> registerEmployee({
  required String firstname,
  required String familyname,
  required String email,
  required String password,
  required String adress,
  required String job,
  required String phonenumber,
}) async {
  try {
    final url = Uri.parse(
      "http://localhost:5500/api/usersmagni/register-employee",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": firstname,
        "family_name": familyname,
        "E_mail": email,
        "pass_word": password,
        "Adress": adress,
        "job": job,
        "phone_number": phonenumber,
      }),
    );

    // ← هذا مهم، شوف اللي يطلع
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    return response.statusCode == 201;
  } catch (e) {
    print("ERROR: $e");
    return false;
  }
}
