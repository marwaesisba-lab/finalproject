import 'dart:async';
import 'dart:ui';
import 'package:appweb/login.dart';
import 'package:appweb/regiter.dart';
import 'package:appweb/verifiedemailpage.dart';
import 'package:appweb/workers/modelworkers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import './homepage_dummy.dart';

// ==================== Main ====================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyD3tyvt5U2ZZPlD3TKqmyLxp2-_ErzwfNs",
          authDomain: "marwaappesi.firebaseapp.com",
          projectId: "marwaappesi",
          storageBucket: "marwaappesi.firebasestorage.app",
          messagingSenderId: "2363741169",
          appId: "1:2363741169:web:0e17c43ce68af9b408ea50",
          measurementId: "G-W80LKHPQQ1",
        ),
      );
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: RegisterPage()),
  );
}

// ==================== Register Page ====================
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController familynameController = TextEditingController();
  final TextEditingController adressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    firstnameController.dispose();
    familynameController.dispose();
    adressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink.shade300,
              Colors.purple.shade400,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 45,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Hello and welcome to your application",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 5,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Store your information please",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 35),
                        _buildTextField(
                          Icons.person,
                          "First name",
                          controller: firstnameController,
                        ),
                        const SizedBox(height: 18),
                        _buildTextField(
                          Icons.person_outline,
                          "Family name",
                          controller: familynameController,
                        ),
                        const SizedBox(height: 18),
                        _buildTextField(
                          Icons.email_outlined,
                          "E-mail",
                          controller: emailController,
                        ),
                        const SizedBox(height: 18),
                        _buildTextField(
                          Icons.phone,
                          "Phone number",
                          controller: phoneController,
                        ),
                        const SizedBox(height: 18),
                        _buildTextField(
                          Icons.home_outlined,
                          "Address",
                          controller: adressController,
                        ),
                        const SizedBox(height: 18),
                        _buildTextField(
                          Icons.lock_outline,
                          "Password",
                          controller: passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 28),
                        isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              )
                            : Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purpleAccent.shade100,
                                      Colors.blueAccent.shade400,
                                    ],
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() => isLoading = true);
                                    try {
                                      UserCredential userCredential =
                                          await FirebaseAuth.instance
                                              .createUserWithEmailAndPassword(
                                                email: emailController.text
                                                    .trim(),
                                                password: passwordController
                                                    .text
                                                    .trim(),
                                              );

                                      await userCredential.user!
                                          .sendEmailVerification();

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => VerifiedEmailPage(
                                            user: userCredential.user!,
                                          ),
                                        ),
                                      );
                                    } on FirebaseAuthException catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(e.message ?? "Error"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    setState(() => isLoading = false);
                                  },
                                  child: const Text(
                                    "Sign in",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "You have an account?",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Log in",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField(
  IconData icon,
  String hint, {
  bool isPassword = false,
  required TextEditingController controller,
}) {
  return TextField(
    controller: controller,
    obscureText: isPassword,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white70),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: Colors.white10,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white),
      ),
    ),
  );
}

// ==================== Verified Email Page ====================

// ==================== HTTP Helper Functions ====================
Future<bool> registerUser({
  required String firstname,
  required String familyname,
  required String adress,
  required String phonenumber,
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    var response = await http.post(
      Uri.parse("http://10.154.81.205:5500/api/usersmagni/auth"),
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

    if (response.statusCode == 200) {
      return true;
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      return false;
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Error: $e")));
    return false;
  }
}

Future<bool> loginUser({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return true;
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Error: $e")));
    return false;
  }
}
