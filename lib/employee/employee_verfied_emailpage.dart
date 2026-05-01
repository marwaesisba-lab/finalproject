/* import 'package:appweb/employee/dashboardpage.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class employeeverefiedpage extends StatefulWidget {
  const employeeverefiedpage({super.key});

  @override
  State<employeeverefiedpage> createState() => _employeeverefiedpageState();
}

class _employeeverefiedpageState extends State<employeeverefiedpage> {
  bool isSending = false;
  late final FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;

    // Listen to auth changes
    _auth.userChanges().listen((user) async {
      if (user != null) {
        await user.reload();

        if (user.emailVerified) {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DashboardPage()),
          );
        }
      }
    });
  }

  Future<void> resendVerificationEmail() async {
    try {
      setState(() => isSending = true);

      final user = _auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No user logged in"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await user.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("📩 Verification email sent successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error sending verification email."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_unread, size: 80),
            const SizedBox(height: 15),
            const Text("Verify your email and come back"),
            const SizedBox(height: 20),
            isSending
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: resendVerificationEmail,
                    child: const Text("Resend Email"),
                  ),
          ],
        ),
      ),
    );
  }
}
 */
// claude ai
import 'package:appweb/AppState.dart';
import 'package:appweb/employee/dashboardpage.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class employeeverefiedpage extends StatefulWidget {
  const employeeverefiedpage({super.key});

  @override
  State<employeeverefiedpage> createState() => _employeeverefiedpageState();
}

class _employeeverefiedpageState extends State<employeeverefiedpage> {
  bool isSending = false;
  late final FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;

    _auth.userChanges().listen((user) async {
      if (user != null) {
        await user.reload();

        if (user.emailVerified) {
          if (!mounted) return;

          // ✅ FIX: زدنا userId: user.uid باش يوصل للـ DashboardPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(
                userId: user.uid,
                firebaseUid: AppState.currentUserFirebaseUid,
              ),
            ),
          );
        }
      }
    });
  }

  Future<void> resendVerificationEmail() async {
    try {
      setState(() => isSending = true);

      final user = _auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No user logged in"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await user.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("📩 Verification email sent successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error sending verification email."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_unread, size: 80),
            const SizedBox(height: 15),
            const Text("Verify your email and come back"),
            const SizedBox(height: 20),
            isSending
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: resendVerificationEmail,
                    child: const Text("Resend Email"),
                  ),
          ],
        ),
      ),
    );
  }
}
