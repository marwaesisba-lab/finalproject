/* import 'package:appweb/AppState.dart';
import 'package:appweb/employee/dashboardpage.dart';

import 'package:appweb/regiter_for_employee.dart';
import 'package:appweb/workers/registerforemployee.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appweb/workers/modelworkers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppWeb',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProfessionalSignUp(),
    );
  }
}

// --------------------- SIGNUP PAGE ---------------------
class ProfessionalSignUp extends StatefulWidget {
  const ProfessionalSignUp({super.key});

  @override
  State<ProfessionalSignUp> createState() => _ProfessionalSignUpState();
}

class _ProfessionalSignUpState extends State<ProfessionalSignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _familyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECDD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LOGO
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/homelogo.png', height: 51, width: 51),
                  const SizedBox(width: 10),
                  const Text(
                    'AT Your\nDoor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Sign up to continue using the service',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 25),
              // PROFESSIONAL TAG
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Professional',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // FORM FIELDS
              _buildTextField(
                Icons.person_outline,
                "ENTER YOUR NAME",
                controller: _nameController,
              ),
              _buildTextField(
                Icons.person_outline,
                "ENTER YOUR FAMILY NAME",
                controller: _familyController,
              ),
              _buildTextField(
                Icons.email_outlined,
                "ENTER YOUR EMAIL",
                controller: _emailController,
              ),
              _buildTextField(
                Icons.lock_outline,
                "ENTER YOUR PASSWORD",
                controller: _passwordController,
                isPassword: true,
              ),
              _buildTextField(
                Icons.location_on_outlined,
                "ENTER YOUR ADDRESS",
                controller: _addressController,
              ),
              _buildTextField(
                Icons.work_outline,
                "ENTER YOUR JOB",
                controller: _jobController,
              ),
              _buildTextField(
                Icons.phone_outlined,
                "ENTER YOUR PHONE NUMBER",
                controller: _phoneController,
              ),
              const SizedBox(height: 25),
              // SIGN UP BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // FOOTER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Do you have account ? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfessionalLogin(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 3,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(icon, color: Colors.blueGrey[800], size: 22),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  // --------------------- SIGN UP FUNCTION ---------------------
  void _signUp() async {
    if (_nameController.text.isEmpty ||
        _familyController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _jobController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    // Worker object
    AppState.selectedWorker = Worker(
      id: DateTime.now().millisecondsSinceEpoch,
      fullname: _nameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      job: _jobController.text,
    );

    // Backend registration
    bool backendSuccess = await registerEmployee(
      firstname: _nameController.text,
      familyname: _familyController.text,
      adress: _addressController.text,
      phonenumber: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
      job: _jobController.text,
    );

    if (!backendSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Backend registration failed")),
      );
      setState(() => isLoading = false);
      return;
    }

    // Firebase registration
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup failed, no user returned")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Firebase Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }
}

// --------------------- LOGIN PAGE ---------------------
class ProfessionalLogin extends StatefulWidget {
  const ProfessionalLogin({super.key});

  @override
  State<ProfessionalLogin> createState() => _ProfessionalLoginState();
}

class _ProfessionalLoginState extends State<ProfessionalLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECDD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/homelogo.png', height: 51, width: 51),
                  const SizedBox(width: 10),
                  const Text(
                    'AT Your\nDoor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Login to continue using the service',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'lib/images/worker.webp',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Professional',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                Icons.email_outlined,
                "ENTER YOUR EMAIL",
                controller: _emailController,
              ),
              _buildTextField(
                Icons.lock_outline,
                "ENTER YOUR PASSWORD",
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Connect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(icon, color: Colors.blueGrey[800], size: 22),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  // --------------------- LOGIN FUNCTION ---------------------
  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;

      if (user != null) {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please verify your email first")),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login successful")));

          // ---------------------- NAVIGATE TO HOME PAGE ----------------------
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardPage(),
            ), // هنا حط الصفحة لي تحب تروح لها
          );
          // ------------------------------------------------------------------
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed, no user found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Firebase Login Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }
}

// --------------------- PLACEHOLDER HOME PAGE ---------------------
 */

// claude ai
/* import 'dart:convert';
import 'package:appweb/AppState.dart';
import 'package:appweb/employee/dashboardpage.dart';
import 'package:appweb/regiter_for_employee.dart';
import 'package:appweb/workers/registerforemployee.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appweb/workers/modelworkers.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppWeb',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProfessionalSignUp(),
    );
  }
}

// --------------------- SIGNUP PAGE ---------------------
class ProfessionalSignUp extends StatefulWidget {
  const ProfessionalSignUp({super.key});

  @override
  State<ProfessionalSignUp> createState() => _ProfessionalSignUpState();
}

class _ProfessionalSignUpState extends State<ProfessionalSignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _familyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECDD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/homelogo.png', height: 51, width: 51),
                  const SizedBox(width: 10),
                  const Text(
                    'AT Your\nDoor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Sign up to continue using the service',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 25),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Professional',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                Icons.person_outline,
                "ENTER YOUR NAME",
                controller: _nameController,
              ),
              _buildTextField(
                Icons.person_outline,
                "ENTER YOUR FAMILY NAME",
                controller: _familyController,
              ),
              _buildTextField(
                Icons.email_outlined,
                "ENTER YOUR EMAIL",
                controller: _emailController,
              ),
              _buildTextField(
                Icons.lock_outline,
                "ENTER YOUR PASSWORD",
                controller: _passwordController,
                isPassword: true,
              ),
              _buildTextField(
                Icons.location_on_outlined,
                "ENTER YOUR ADDRESS",
                controller: _addressController,
              ),
              _buildTextField(
                Icons.work_outline,
                "ENTER YOUR JOB",
                controller: _jobController,
              ),
              _buildTextField(
                Icons.phone_outlined,
                "ENTER YOUR PHONE NUMBER",
                controller: _phoneController,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Do you have account ? "),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfessionalLogin(),
                      ),
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 3,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(icon, color: Colors.blueGrey[800], size: 22),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    if (_nameController.text.isEmpty ||
        _familyController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _jobController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    AppState.selectedWorker = Worker(
      id: DateTime.now().millisecondsSinceEpoch,
      fullname: _nameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      job: _jobController.text,
    );

    bool backendSuccess = await registerEmployee(
      firstname: _nameController.text,
      familyname: _familyController.text,
      adress: _addressController.text,
      phonenumber: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
      job: _jobController.text,
    );

    if (!backendSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Backend registration failed")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;
      if (user != null) {
        await http.post(
          Uri.parse("http://10.38.213.205:5500/api/employee/saveuid"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": _emailController.text.trim(),
            "firebase_uid": user.uid,
          }),
        );

        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup failed, no user returned")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Firebase Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }
}

// --------------------- LOGIN PAGE ---------------------
class ProfessionalLogin extends StatefulWidget {
  const ProfessionalLogin({super.key});

  @override
  State<ProfessionalLogin> createState() => _ProfessionalLoginState();
}

class _ProfessionalLoginState extends State<ProfessionalLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECDD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/homelogo.png', height: 51, width: 51),
                  const SizedBox(width: 10),
                  const Text(
                    'AT Your\nDoor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Login to continue using the service',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'lib/images/worker.webp',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Professional',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                Icons.email_outlined,
                "ENTER YOUR EMAIL",
                controller: _emailController,
              ),
              _buildTextField(
                Icons.lock_outline,
                "ENTER YOUR PASSWORD",
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Connect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(icon, color: Colors.blueGrey[800], size: 22),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;

      if (user != null) {
        AppState.currentUserFirebaseUid = user.uid;
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please verify your email first")),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login successful")));

          // ✅ FIX: احفظ firebase_uid في قاعدة البيانات
          await http.post(
            Uri.parse("http://10.38.213.205:5500/api/employee/saveuid"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": _emailController.text.trim(),
              "firebase_uid": user.uid,
            }),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(userId: user.uid),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed, no user found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Firebase Login Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }
}
 */
/* 
import 'dart:convert';
import 'package:appweb/AppState.dart';
import 'package:appweb/employee/dashboardpage.dart';
import 'package:appweb/regiter_for_employee.dart';
import 'package:appweb/workers/registerforemployee.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appweb/workers/modelworkers.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppWeb',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProfessionalSignUp(),
    );
  }
}

// --------------------- SIGNUP PAGE ---------------------
class ProfessionalSignUp extends StatefulWidget {
  const ProfessionalSignUp({super.key});

  @override
  State<ProfessionalSignUp> createState() => _ProfessionalSignUpState();
}

class _ProfessionalSignUpState extends State<ProfessionalSignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _familyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECDD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/homelogo.png', height: 51, width: 51),
                  const SizedBox(width: 10),
                  const Text(
                    'AT Your\nDoor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Sign up to continue using the service',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 25),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Professional',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                Icons.person_outline,
                "ENTER YOUR NAME",
                controller: _nameController,
              ),
              _buildTextField(
                Icons.person_outline,
                "ENTER YOUR FAMILY NAME",
                controller: _familyController,
              ),
              _buildTextField(
                Icons.email_outlined,
                "ENTER YOUR EMAIL",
                controller: _emailController,
              ),
              _buildTextField(
                Icons.lock_outline,
                "ENTER YOUR PASSWORD",
                controller: _passwordController,
                isPassword: true,
              ),
              _buildTextField(
                Icons.location_on_outlined,
                "ENTER YOUR ADDRESS",
                controller: _addressController,
              ),
              _buildTextField(
                Icons.work_outline,
                "ENTER YOUR JOB",
                controller: _jobController,
              ),
              _buildTextField(
                Icons.phone_outlined,
                "ENTER YOUR PHONE NUMBER",
                controller: _phoneController,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Do you have account ? "),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfessionalLogin(),
                      ),
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 3,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(icon, color: Colors.blueGrey[800], size: 22),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    if (_nameController.text.isEmpty ||
        _familyController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _jobController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    AppState.selectedWorker = Worker(
      id: DateTime.now().millisecondsSinceEpoch,
      fullname: _nameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      job: _jobController.text,
    );

    bool backendSuccess = await registerEmployee(
      firstname: _nameController.text,
      familyname: _familyController.text,
      adress: _addressController.text,
      phonenumber: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
      job: _jobController.text,
    );

    if (!backendSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Backend registration failed")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Firebase Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }
}

// --------------------- LOGIN PAGE ---------------------
class ProfessionalLogin extends StatefulWidget {
  const ProfessionalLogin({super.key});

  @override
  State<ProfessionalLogin> createState() => _ProfessionalLoginState();
}

class _ProfessionalLoginState extends State<ProfessionalLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECDD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/homelogo.png', height: 51, width: 51),
                  const SizedBox(width: 10),
                  const Text(
                    'AT Your\nDoor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Login to continue using the service',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'lib/images/worker.webp',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Professional',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                Icons.email_outlined,
                "ENTER YOUR EMAIL",
                controller: _emailController,
              ),
              _buildTextField(
                Icons.lock_outline,
                "ENTER YOUR PASSWORD",
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Connect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(icon, color: Colors.blueGrey[800], size: 22),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;

      if (user != null) {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please verify your email first")),
          );
        } else {
          // ✅ جيب الـ id الرقمي من قاعدة البيانات
          final response = await http.get(
            Uri.parse(
              "http://10.38.213.205:5500/api/employee/getid?email=${_emailController.text.trim()}",
            ),
          );

          // إذا السيرفر ما ردش - نوقفوا كاملاً ونظهروا error
          if (response.statusCode != 200) {
            return;
          }
          final String dbId = data['id'].toString(); // DB ID فقط

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login successful")));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(userId: dbId), // ✅ رقم
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Firebase Login Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }
}
  */

/* import 'dart:convert';
import 'package:appweb/AppState.dart';
import 'package:appweb/employee/dashboardpage.dart';
import 'package:appweb/regiter_for_employee.dart';
import 'package:appweb/workers/registerforemployee.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appweb/workers/modelworkers.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppWeb',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProfessionalSignUp(),
    );
  }
}

// --------------------- SIGNUP PAGE ---------------------
// (بقي كما هو بدون أي تغيير)
class ProfessionalSignUp extends StatefulWidget {
  const ProfessionalSignUp({super.key});

  @override
  State<ProfessionalSignUp> createState() => _ProfessionalSignUpState();
}

class _ProfessionalSignUpState extends State<ProfessionalSignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _familyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECDD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/homelogo.png', height: 51, width: 51),
                  const SizedBox(width: 10),
                  const Text(
                    'AT Your\nDoor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Sign up to continue using the service',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 25),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Professional',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                Icons.person_outline,
                "ENTER YOUR NAME",
                controller: _nameController,
              ),
              _buildTextField(
                Icons.person_outline,
                "ENTER YOUR FAMILY NAME",
                controller: _familyController,
              ),
              _buildTextField(
                Icons.email_outlined,
                "ENTER YOUR EMAIL",
                controller: _emailController,
              ),
              _buildTextField(
                Icons.lock_outline,
                "ENTER YOUR PASSWORD",
                controller: _passwordController,
                isPassword: true,
              ),
              _buildTextField(
                Icons.location_on_outlined,
                "ENTER YOUR ADDRESS",
                controller: _addressController,
              ),
              _buildTextField(
                Icons.work_outline,
                "ENTER YOUR JOB",
                controller: _jobController,
              ),
              _buildTextField(
                Icons.phone_outlined,
                "ENTER YOUR PHONE NUMBER",
                controller: _phoneController,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Do you have account ? "),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfessionalLogin(),
                      ),
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 3,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(icon, color: Colors.blueGrey[800], size: 22),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    if (_nameController.text.isEmpty ||
        _familyController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _jobController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    AppState.selectedWorker = Worker(
      id: DateTime.now().millisecondsSinceEpoch,
      fullname: _nameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      job: _jobController.text,
    );

    bool backendSuccess = await registerEmployee(
      firstname: _nameController.text,
      familyname: _familyController.text,
      adress: _addressController.text,
      phonenumber: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
      job: _jobController.text,
    );

    if (!backendSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Backend registration failed")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Firebase Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }
}

// --------------------- LOGIN PAGE ---------------------
class ProfessionalLogin extends StatefulWidget {
  const ProfessionalLogin({super.key});

  @override
  State<ProfessionalLogin> createState() => _ProfessionalLoginState();
}

class _ProfessionalLoginState extends State<ProfessionalLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECDD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/homelogo.png', height: 51, width: 51),
                  const SizedBox(width: 10),
                  const Text(
                    'AT Your\nDoor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Login to continue using the service',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'lib/images/worker.webp',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Professional',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                Icons.email_outlined,
                "ENTER YOUR EMAIL",
                controller: _emailController,
              ),
              _buildTextField(
                Icons.lock_outline,
                "ENTER YOUR PASSWORD",
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Connect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(icon, color: Colors.blueGrey[800], size: 22),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  // ====================== دالة اللوغين المصححة ======================
  // ====================== دالة اللوغين المصححة ======================
  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;

      if (user != null) {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please verify your email first")),
          );
        } else {
          // ✅ جيب الـ id الرقمي من قاعدة البيانات
          final response = await http.get(
            Uri.parse(
              "http://10.38.213.205:5500/api/employee/getid?email=${_emailController.text.trim()}",
            ),
          );

          print("📡 Status Code: ${response.statusCode}");
          print("📄 Response Body: ${response.body}");

          // إذا السيرفر ما ردش - نوقفوا كاملاً ونظهروا error
          if (response.statusCode != 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Failed to fetch user ID: ${response.statusCode}",
                ),
              ),
            );
            setState(() => isLoading = false);
            return;
          }

          // 🔥 هنا كان الخطأ: data ما كانش معرف
          final Map<String, dynamic> data = jsonDecode(response.body);

          final String dbId = data['id'].toString(); // DB ID فقط

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login successful")));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(userId: dbId),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Firebase Login Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }
}
 */
/* import 'dart:convert';
import 'package:appweb/AppState.dart';
import 'package:appweb/employee/dashboardpage.dart';
import 'package:appweb/regiter_for_employee.dart';
import 'package:appweb/workers/registerforemployee.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appweb/workers/modelworkers.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppWeb',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProfessionalSignUp(),
    );
  }
}

// --------------------- SIGNUP PAGE ---------------------
class ProfessionalSignUp extends StatefulWidget {
  const ProfessionalSignUp({super.key});

  @override
  State<ProfessionalSignUp> createState() => _ProfessionalSignUpState();
}

class _ProfessionalSignUpState extends State<ProfessionalSignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _familyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECDD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/homelogo.png', height: 51, width: 51),
                  const SizedBox(width: 10),
                  const Text(
                    'AT Your\nDoor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Sign up to continue using the service',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 25),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Professional',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                Icons.person_outline,
                "ENTER YOUR NAME",
                controller: _nameController,
              ),
              _buildTextField(
                Icons.person_outline,
                "ENTER YOUR FAMILY NAME",
                controller: _familyController,
              ),
              _buildTextField(
                Icons.email_outlined,
                "ENTER YOUR EMAIL",
                controller: _emailController,
              ),
              _buildTextField(
                Icons.lock_outline,
                "ENTER YOUR PASSWORD",
                controller: _passwordController,
                isPassword: true,
              ),
              _buildTextField(
                Icons.location_on_outlined,
                "ENTER YOUR ADDRESS",
                controller: _addressController,
              ),
              _buildTextField(
                Icons.work_outline,
                "ENTER YOUR JOB",
                controller: _jobController,
              ),
              _buildTextField(
                Icons.phone_outlined,
                "ENTER YOUR PHONE NUMBER",
                controller: _phoneController,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Do you have account ? "),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfessionalLogin(),
                      ),
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 3,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(icon, color: Colors.blueGrey[800], size: 22),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    if (_nameController.text.isEmpty ||
        _familyController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _jobController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    AppState.selectedWorker = Worker(
      id: DateTime.now().millisecondsSinceEpoch,
      fullname: _nameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      job: _jobController.text,
    );

    bool backendSuccess = await registerEmployee(
      firstname: _nameController.text,
      familyname: _familyController.text,
      adress: _addressController.text,
      phonenumber: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
      job: _jobController.text,
    );

    if (!backendSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Backend registration failed")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Firebase Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }
}

// --------------------- LOGIN PAGE ---------------------
class ProfessionalLogin extends StatefulWidget {
  const ProfessionalLogin({super.key});

  @override
  State<ProfessionalLogin> createState() => _ProfessionalLoginState();
}

class _ProfessionalLoginState extends State<ProfessionalLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECDD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/homelogo.png', height: 51, width: 51),
                  const SizedBox(width: 10),
                  const Text(
                    'AT Your\nDoor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Login to continue using the service',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'lib/images/worker.webp',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Professional',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                Icons.email_outlined,
                "ENTER YOUR EMAIL",
                controller: _emailController,
              ),
              _buildTextField(
                Icons.lock_outline,
                "ENTER YOUR PASSWORD",
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Connect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(icon, color: Colors.blueGrey[800], size: 22),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1️⃣ Firebase login
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final User? user = userCredential.user;

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login failed")));
        setState(() => isLoading = false);
        return;
      }

      // 2️⃣ التحقق من تفعيل الإيميل
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please verify your email first")),
        );
        setState(() => isLoading = false);
        return;
      }

      // 3️⃣ جيب الـ ID من السيرفر
      final response = await http.get(
        Uri.parse(
          "http://10.38.213.205:5500/api/employee/getid?email=${_emailController.text.trim()}",
        ),
      );

      print("📡 STATUS: ${response.statusCode}");
      print("📄 BODY: ${response.body}");

      // 4️⃣ تحقق من الـ status code مع رسالة واضحة
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Server error (${response.statusCode}): ${response.body}",
            ),
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      // 5️⃣ parse الـ JSON
      final Map<String, dynamic> data = jsonDecode(response.body);

      // 6️⃣ تحقق إن id موجود
      if (data['id'] == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User ID not found")));
        setState(() => isLoading = false);
        return;
      }

      final String dbId = data['id'].toString();

      // 7️⃣ روح للصفحة
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login successful ✅")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage(userId: dbId)),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
 */
import 'dart:convert';
import 'package:appweb/AppState.dart';
import 'package:appweb/employee/dashboardpage.dart';
import 'package:appweb/regiter_for_employee.dart';
import 'package:appweb/user_session.dart';
import 'package:appweb/workers/registerforemployee.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appweb/workers/modelworkers.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppWeb',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProfessionalSignUp(),
    );
  }
}

// --------------------- SIGNUP PAGE ---------------------
class ProfessionalSignUp extends StatefulWidget {
  const ProfessionalSignUp({super.key});

  @override
  State<ProfessionalSignUp> createState() => _ProfessionalSignUpState();
}

class _ProfessionalSignUpState extends State<ProfessionalSignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _familyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECDD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/homelogo.png', height: 51, width: 51),
                  const SizedBox(width: 10),
                  const Text(
                    'AT Your\nDoor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Sign up to continue using the service',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 25),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Professional',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                Icons.person_outline,
                "ENTER YOUR NAME",
                controller: _nameController,
              ),
              _buildTextField(
                Icons.person_outline,
                "ENTER YOUR FAMILY NAME",
                controller: _familyController,
              ),
              _buildTextField(
                Icons.email_outlined,
                "ENTER YOUR EMAIL",
                controller: _emailController,
              ),
              _buildTextField(
                Icons.lock_outline,
                "ENTER YOUR PASSWORD",
                controller: _passwordController,
                isPassword: true,
              ),
              _buildTextField(
                Icons.location_on_outlined,
                "ENTER YOUR ADDRESS",
                controller: _addressController,
              ),
              _buildTextField(
                Icons.work_outline,
                "ENTER YOUR JOB",
                controller: _jobController,
              ),
              _buildTextField(
                Icons.phone_outlined,
                "ENTER YOUR PHONE NUMBER",
                controller: _phoneController,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Do you have account ? "),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfessionalLogin(),
                      ),
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 3,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(icon, color: Colors.blueGrey[800], size: 22),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    if (_nameController.text.isEmpty ||
        _familyController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _jobController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    AppState.selectedWorker = Worker(
      id: DateTime.now().millisecondsSinceEpoch,
      fullname: _nameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      job: _jobController.text,
    );

    bool backendSuccess = await registerEmployee(
      firstname: _nameController.text,
      familyname: _familyController.text,
      adress: _addressController.text,
      phonenumber: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
      job: _jobController.text,
    );

    if (!backendSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Backend registration failed")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Firebase Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }
}

// --------------------- LOGIN PAGE ---------------------
class ProfessionalLogin extends StatefulWidget {
  const ProfessionalLogin({super.key});

  @override
  State<ProfessionalLogin> createState() => _ProfessionalLoginState();
}

class _ProfessionalLoginState extends State<ProfessionalLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECDD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/homelogo.png', height: 51, width: 51),
                  const SizedBox(width: 10),
                  const Text(
                    'AT Your\nDoor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Login to continue using the service',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'lib/images/worker.webp',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Professional',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                Icons.email_outlined,
                "ENTER YOUR EMAIL",
                controller: _emailController,
              ),
              _buildTextField(
                Icons.lock_outline,
                "ENTER YOUR PASSWORD",
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Connect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(icon, color: Colors.blueGrey[800], size: 22),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1️⃣ Firebase login
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final User? user = userCredential.user;

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login failed")));
        setState(() => isLoading = false);
        return;
      }

      // 2️⃣ التحقق من تفعيل الإيميل
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please verify your email first")),
        );
        setState(() => isLoading = false);
        return;
      }

      // 3️⃣ ✅ احفظ firebase_uid في DB تاع employee
      await http.post(
        Uri.parse("http://10.229.109.205:5500/api/employee/saveuid"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "firebase_uid": user.uid,
        }),
      );
      print("✅ firebase_uid saved: ${user.uid}");

      // 4️⃣ جيب الـ DB id من السيرفر
      final response = await http.get(
        Uri.parse(
          "http://10.229.109.205:5500/api/employee/getid?email=${_emailController.text.trim()}",
        ),
      );

      print("📡 STATUS: ${response.statusCode}");
      print("📄 BODY: ${response.body}");

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Server error (${response.statusCode}): ${response.body}",
            ),
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      // 5️⃣ parse الـ JSON
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['id'] == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User ID not found")));
        setState(() => isLoading = false);
        return;
      }
      final String dbId = data['id'].toString();
      print("🔍 !!!!!!!!!!!  dbId value = '$dbId'"); // ✅ زيد هذا
      print("🔍 full data = $data"); // ✅ زيد هذا

      UserSession.employeeid = int.tryParse(dbId) ?? 0; // ✅ tryParse أأمن

      // 6️⃣ روح للصفحة
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login successful ✅")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DashboardPage(userId: dbId, firebaseUid: user.uid),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
