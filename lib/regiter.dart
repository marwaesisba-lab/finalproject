import 'dart:convert';
import 'package:appweb/workers/modelworkers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = "http://localhost:5500";

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
  final url = Uri.parse("$baseUrl/api/usersmagni/auth");

  try {
    print("📤 Sending REGISTER request to: $url");

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

    print("📥 STATUS: ${response.statusCode}");
    print("📥 BODY: ${response.body}");

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created. Please verify your email."),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Register failed: ${response.body}"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  } catch (e) {
    print("❌ REGISTER EXCEPTION: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Connection error: $e"),
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
  final url = Uri.parse("$baseUrl/api/usersmagni/login");

  try {
    print("📤 Sending LOGIN request to: $url");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    print("📥 STATUS: ${response.statusCode}");
    print("📥 BODY: ${response.body}");

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login successful"),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: ${response.body}"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  } catch (e) {
    print("❌ LOGIN EXCEPTION: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Connection error: $e"),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }
}

// ================= FETCH WORKERS =================
Future<List<Worker>> fetchWorkers() async {
  final url = Uri.parse("$baseUrl/api/users/workers");
  try {
    print("📤 Fetching workers from: $url");

    final response = await http.get(url);

    print("📥 STATUS: ${response.statusCode}");
    print("📥 BODY: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      print("👷 RAW DATA: $jsonData"); // ✅ زيد هذا

      return jsonData
          .map<Worker>((e) => Worker.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception("Server returned ${response.statusCode}");
    }
  } catch (e) {
    print("❌ FETCH WORKERS ERROR: $e");
    throw Exception("Failed to fetch workers");
  }
}
