import 'dart:convert';
import 'package:appweb/workers/modelworkers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ================= REGISTER =================
Future<bool> registerUser({
  required String firstname,
  required String familyname,
  required String adress,
  required String phonenumber,
  required String email,
  required String password,
  required BuildContext context,
}) async {
  final url = Uri.parse("http://127.0.0.1:5500/api/usersmagni/auth");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "firstname": firstname,
        "familyname": familyname,
        "adress": adress,
        "phonenumber": phonenumber,
        "email": email,
        "password": password,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 201) {
      // ه
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(" you are signed now you can verfie your email only "),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } else {
      print("REGISTER ERROR: ${response.statusCode} - ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("failed to sig in $response.statusCode})"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  } catch (e) {
    print("REGISTER EXCEPTION: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("failed to connect with server"),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }
}

// ================= LOGIN =================
Future<bool> loginUser({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  final url = Uri.parse("http://127.0.0.1:5500/api/usersmagni/login");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(" yes you are connecting  now "),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } else if (response.statusCode == 401) {
      print("LOGIN ERROR: ${response.statusCode} - ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("email or password are incorrect"),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    } else {
      print("LOGIN ERROR: ${response.statusCode} - ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${response.statusCode}"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  } catch (e) {
    print("LOGIN EXCEPTION: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("failed to connect with server "),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }
}

// fetch workers from data base
Future<List<Worker>> fetchWorkers() async {
  try {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:5500/api/users/workers"),
    );

    print("HTTP Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData
          .map<Worker>((e) => Worker.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception("Failed to load workers");
    }
  } catch (e) {
    print("FetchWorkers Error: $e");
    throw Exception("Failed to fetch workers");
  }
}
