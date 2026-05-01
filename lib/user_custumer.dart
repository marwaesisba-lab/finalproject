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
// alter code
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
      backgroundColor: const Color(0xFFF7EEE3), // نفس خلفية التطبيق
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // أيقونة ترحيبية أو لوغو بسيط
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    size: 40,
                    color: Color(0xFF8D6E63),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "CREATE ACCOUNT",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D2D2D),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Join our community today",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                // الحقول بتنسيق أنيق
                _buildTextField(
                  Icons.person_rounded,
                  "First Name",
                  controller: firstnameController,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  Icons.people_rounded,
                  "Family Name",
                  controller: familynameController,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  Icons.email_rounded,
                  "Email Address",
                  controller: emailController,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  Icons.phone_android_rounded,
                  "Phone Number",
                  controller: phoneController,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  Icons.location_on_rounded,
                  "Full Address",
                  controller: adressController,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  Icons.lock_rounded,
                  "Password",
                  controller: passwordController,
                  isPassword: true,
                ),

                const SizedBox(height: 35),

                // زر التسجيل الاحترافي
                isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF8D6E63))
                    : SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF2D2D2D,
                            ), // أسود فخم
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "SIGN UP",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 25),

                // رابط تسجيل الدخول
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                      child: const Text(
                        "LOG IN",
                        style: TextStyle(
                          color: Color(0xFF8D6E63),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // الودجت الخاص بالحقول بتصميم الـ Modern Glass
  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(
          color: Color(0xFF2D2D2D),
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF8D6E63), size: 20),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // --- المنطق (Logic) يبقى كما هو تماماً ---
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
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
 */
import 'dart:convert';
import 'dart:ui';
import 'package:appweb/login.dart';
import 'package:appweb/regiter.dart'; // تأكد من اسم الملف الصحيح (register.dart غالباً)
import 'package:appweb/user_session.dart';
import 'package:appweb/verifiedemailpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

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

  // للتحقق في الوقت الفعلي
  bool isEmailValid = true;
  bool isPasswordValid = true;

  PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'DZ');
  String? phoneNumberFull; // الرقم الكامل مع كود الدولة

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

  // دالة التحقق من الإيميل
  bool _validateEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  // دالة التحقق من كلمة السر (يمكنك تعزيزها لاحقاً)
  bool _validatePassword(String password) {
    return password.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EEE3),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    size: 40,
                    color: Color(0xFF8D6E63),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "CREATE ACCOUNT",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D2D2D),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Join our community today",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                _buildTextField(
                  Icons.person_rounded,
                  "First Name",
                  controller: firstnameController,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  Icons.people_rounded,
                  "Family Name",
                  controller: familynameController,
                ),
                const SizedBox(height: 15),

                // حقل الإيميل مع تحقق لون أحمر
                _buildEmailField(),
                const SizedBox(height: 15),

                // حقل الهاتف الدولي
                _buildPhoneField(),
                const SizedBox(height: 15),

                _buildTextField(
                  Icons.location_on_rounded,
                  "Full Address",
                  controller: adressController,
                ),
                const SizedBox(height: 15),

                // حقل كلمة السر مع تحقق لون أحمر
                _buildPasswordField(),
                const SizedBox(height: 35),

                isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF8D6E63))
                    : SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D2D2D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "SIGN UP",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                      child: const Text(
                        "LOG IN",
                        style: TextStyle(
                          color: Color(0xFF8D6E63),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Color(0xFF2D2D2D),
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF8D6E63), size: 20),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  //
  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isEmailValid ? Colors.transparent : Colors.red,
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          color: Color(0xFF2D2D2D),
          fontWeight: FontWeight.bold,
        ),
        onChanged: (value) {
          setState(() {
            isEmailValid = _validateEmail(value.trim());
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.email_rounded,
            color: isEmailValid ? const Color(0xFF8D6E63) : Colors.red,
            size: 20,
          ),
          hintText: "Email Address",
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // حقل الهاتف الدولي
  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InternationalPhoneNumberInput(
        onInputChanged: (PhoneNumber number) {
          setState(() {
            phoneNumberFull = number.phoneNumber;
          });
        },
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          useBottomSheetSafeArea: true,
          setSelectorButtonAsPrefixIcon: true,
          leadingPadding: 12,
          useEmoji: true,
        ),
        ignoreBlank: false,
        autoValidateMode: AutovalidateMode.onUserInteraction,
        selectorTextStyle: const TextStyle(
          color: Color(0xFF2D2D2D),
          fontWeight: FontWeight.bold,
        ),
        initialValue: initialPhoneNumber,
        textFieldController: phoneController,
        formatInput: true,
        keyboardType: const TextInputType.numberWithOptions(
          signed: true,
          decimal: true,
        ),
        inputDecoration: const InputDecoration(
          hintText: "Phone Number",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
        textStyle: const TextStyle(
          color: Color(0xFF2D2D2D),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // حقل كلمة السر مع لون أحمر
  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isPasswordValid ? Colors.transparent : Colors.red,
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: passwordController,
        obscureText: true,
        style: const TextStyle(
          color: Color(0xFF2D2D2D),
          fontWeight: FontWeight.bold,
        ),
        onChanged: (value) {
          setState(() {
            isPasswordValid = _validatePassword(value);
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_rounded,
            color: isPasswordValid ? const Color(0xFF8D6E63) : Colors.red,
            size: 20,
          ),
          hintText: "Password",
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // تحقق نهائي قبل التسجيل
    if (email.isEmpty || !_validateEmail(email)) {
      setState(() => isEmailValid = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("please enter a verfied email "),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 6) {
      setState(() => isPasswordValid = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("كلمة السر يجب أن تكون 6 أحرف على الأقل"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (phoneNumberFull == null || phoneNumberFull!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء إدخال رقم الهاتف"),
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
        phonenumber: phoneNumberFull!, // نستخدم الرقم الكامل
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
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
