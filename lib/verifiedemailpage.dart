import 'dart:async';
import 'dart:ui';
import 'package:appweb/regiter.dart';

import 'package:appweb/workers/modelworkers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import './homepage_dummy.dart';

class VerifiedEmailPage extends StatefulWidget {
  final User user; // ✅ استقبل user مباشرة

  const VerifiedEmailPage({super.key, required this.user});

  @override
  State<VerifiedEmailPage> createState() => _VerifiedEmailPageState();
}

class _VerifiedEmailPageState extends State<VerifiedEmailPage> {
  bool isSending = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // تحقق أول مرة
    checkEmailVerified();

    // 🔄 تحقق تلقائي كل 3 ثواني
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      checkEmailVerified();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await widget.user.reload();

    if (widget.user.emailVerified) {
      timer?.cancel();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      setState(() => isSending = true);

      await widget.user.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("📩 تم إرسال رابط التحقق بنجاح"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ حدث خطأ أثناء إرسال الإيميل"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74ABE2), Color(0xFF5563DE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mark_email_unread,
                  size: 90,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Verify your email",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Check your inbox and click on the verification link.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 25),
                isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                        onPressed: resendVerificationEmail,
                        child: const Text("Resend Email"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
