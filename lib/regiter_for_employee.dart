/* import 'dart:convert';
import 'dart:ui';
import 'package:appweb/login.dart';
import 'package:appweb/regiter.dart';
import 'package:appweb/user_session.dart';
import 'package:appweb/verifiedemailpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
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

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

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
            colors: [
              Colors.pink.shade300,
              Colors.purple.shade400,
              Colors.blue.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _handleRegister,
                                  child: const Text(
                                    "Sign in",
                                    style: TextStyle(fontSize: 20),
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

  Future<void> _handleRegister() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Check email/password validity
    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email invalid or password less than 6 chars"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1️⃣ Register in backend first
      bool backendSuccess = await registerUser(
        firstname: firstnameController.text,
        familyname: familynameController.text,
        adress: adressController.text,
        phonenumber: phoneController.text,
        email: email,
        password: password,
        context: context,
      );

      if (!backendSuccess) {
        print("❌ Backend registration failed");
        setState(() => isLoading = false);
        return;
      }

      // 2️⃣ Register in Firebase
      print("🚀 Starting Firebase registration...");
      UserSession.firstname = firstnameController.text;
      UserSession.familyname = familynameController.text;
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      print("✅ Firebase registration success: ${userCredential.user?.uid}");
      UserSession.firstname = firstnameController.text;
      UserSession.familyname = familynameController.text;

      // 3️⃣ Send email verification
      await userCredential.user!.sendEmailVerification();
      print("📧 Verification email sent");

      // 4️⃣ Navigate to VerifiedEmailPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifiedEmailPage(user: userCredential.user!),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print("❌ FirebaseAuthException: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Firebase error: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print("❌ General Firebase error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Firebase general error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
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

// ==================== BACKEND REGISTER ====================
 */
//claude ai correction
/* import 'dart:convert';
import 'dart:ui';
import 'package:appweb/login.dart';
import 'package:appweb/regiter.dart';
import 'package:appweb/user_session.dart';
import 'package:appweb/verifiedemailpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
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

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

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
            colors: [
              Colors.pink.shade300,
              Colors.purple.shade400,
              Colors.blue.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _handleRegister,
                                  child: const Text(
                                    "Sign in",
                                    style: TextStyle(fontSize: 20),
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

  Future<void> _handleRegister() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email invalid or password less than 6 chars"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      bool backendSuccess = await registerUser(
        firstname: firstnameController.text,
        familyname: familynameController.text,
        adress: adressController.text,
        phonenumber: phoneController.text,
        email: email,
        password: password,
        context: context,
      );

      if (!backendSuccess) {
        print("❌ Backend registration failed");
        setState(() => isLoading = false);
        return;
      }

      print("🚀 Starting Firebase registration...");
      UserSession.firstname = firstnameController.text;
      UserSession.familyname = familynameController.text;
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      print("✅ Firebase registration success: ${userCredential.user?.uid}");
      UserSession.firstname = firstnameController.text;
      UserSession.familyname = familynameController.text;

      await userCredential.user!.sendEmailVerification();
      print("📧 Verification email sent");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifiedEmailPage(user: userCredential.user!),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print("❌ FirebaseAuthException: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Firebase error: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print("❌ General Firebase error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Firebase general error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
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
 */
import 'dart:convert';
import 'dart:ui';
import 'package:appweb/login.dart';
import 'package:appweb/regiter.dart';
import 'package:appweb/user_session.dart';
import 'package:appweb/verifiedemailpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
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

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

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

  Future<void> _handleRegister() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email invalid or password less than 6 chars"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      bool backendSuccess = await registerUser(
        firstname: firstnameController.text,
        familyname: familynameController.text,
        adress: adressController.text,
        phonenumber: phoneController.text,
        email: email,
        password: password,
        context: context,
      );

      if (!backendSuccess) {
        setState(() => isLoading = false);
        return;
      }

      UserSession.firstname = firstnameController.text;
      UserSession.familyname = familynameController.text;

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.sendEmailVerification();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifiedEmailPage(user: userCredential.user!),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Firebase error: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Firebase general error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink.shade300,
              Colors.purple.shade400,
              Colors.blue.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _handleRegister,
                                  child: const Text(
                                    "Sign in",
                                    style: TextStyle(fontSize: 20),
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
