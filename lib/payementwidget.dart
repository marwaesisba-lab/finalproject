// add api interface
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:appweb/paymentdone.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PaymentPagePerfect(userid: 1),
    );
  }
}

class PaymentPagePerfect extends StatefulWidget {
  final int userid;
  const PaymentPagePerfect({super.key, required this.userid});

  @override
  State<PaymentPagePerfect> createState() => _PaymentPagePerfectState();
}

class _PaymentPagePerfectState extends State<PaymentPagePerfect> {
  String amountDisplay = "0";

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool isLoading = false;

  // 🔥 SEND PAYMENT (مصَحّحة 100%)
  Future<void> sendPayment() async {
    final url = Uri.parse("http://10.229.109.205:5500/payment");

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": _firstNameController.text,
          "family_name": _lastNameController.text,
          "idofuser": widget.userid,
          "paymentvalue": _amountController.text,
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      // ✅ نجاح (أي 2xx)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Paymentdone()),
        );
      } else {
        showError("Server error: ${response.body}");
      }
    } catch (e) {
      showError("Connection error: $e");
    }

    setState(() => isLoading = false);
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EEE3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              const Center(
                child: Text(
                  "Payment Details",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total to Pay",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "$amountDisplay DZD",
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              _buildTextField("First Name", _firstNameController),
              const SizedBox(height: 10),

              _buildTextField("Last Name", _lastNameController),
              const SizedBox(height: 10),

              _buildTextField(
                "Amount",
                _amountController,
                isNumber: true,
                onChanged: (v) {
                  setState(() {
                    amountDisplay = v.isEmpty ? "0" : v;
                  });
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isLoading ? null : sendPayment,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Pay"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

// ***************** gemini *****************************
 

/* import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:appweb/paymentdone.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PaymentPagePerfect(userid: 1),
    );
  }
}

class PaymentPagePerfect extends StatefulWidget {
  final int userid;
  const PaymentPagePerfect({super.key, required this.userid});

  @override
  State<PaymentPagePerfect> createState() => _PaymentPagePerfectState();
}

class _PaymentPagePerfectState extends State<PaymentPagePerfect> {
  // الحقول الأصلية والمضافة
  final _amountController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  String cardNo = "XXXX XXXX XXXX XXXX";
  String expiry = "MM/YY";
  String amountDisplay = "0";
  bool isLoading = false;

  Future<void> sendPayment() async {
    final url = Uri.parse("http://10.38.213.205:5500/payment");
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": _firstNameController.text,
          "family_name": _lastNameController.text,
          "idofuser": widget.userid,
          "paymentvalue": _amountController.text,
          "card_number": _cardNumberController.text,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Paymentdone()),
        );
      } else {
        showError("Server error: ${response.body}");
      }
    } catch (e) {
      showError("Connection error: $e");
    }
    setState(() => isLoading = false);
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EEE3), // لونك الأصلي (الكريمي)
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  "Payment Details",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- البطاقة البنكية بألوان كودك الأصلي (الرمادي الغامق) ---
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A), // لونك الأصلي
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total to Pay",
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "$amountDisplay DZD",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Text(
                      cardNo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardBottomText(
                          "HOLDER",
                          "${_firstNameController.text} ${_lastNameController.text}",
                        ),
                        _cardBottomText("EXPIRES", expiry),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // حقول الاسم
              _buildField("First Name", _firstNameController),
              const SizedBox(height: 10),
              _buildField("Last Name", _lastNameController),
              const SizedBox(height: 10),

              // حقل رقم البطاقة
              _buildField(
                "Card Number",
                _cardNumberController,
                isNumber: true,
                limit: 16,
                onChanged: (v) {
                  setState(
                    () => cardNo = v.isEmpty
                        ? "XXXX XXXX XXXX XXXX"
                        : v.replaceAllMapped(
                            RegExp(r".{4}"),
                            (match) => "${match.group(0)} ",
                          ),
                  );
                },
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      "MM/YY",
                      _expiryController,
                      isNumber: true,
                      limit: 4,
                      onChanged: (v) {
                        setState(() => expiry = v.isEmpty ? "MM/YY" : v);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      "CVV",
                      _cvvController,
                      isNumber: true,
                      limit: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // حقل المبلغ
              _buildField(
                "Amount",
                _amountController,
                isNumber: true,
                onChanged: (v) {
                  setState(() => amountDisplay = v.isEmpty ? "0" : v);
                },
              ),

              const SizedBox(height: 40),

              // زر الدفع بنفس لون البطاقة الأصلي
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isLoading ? null : sendPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Pay Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardBottomText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        Text(
          value.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
    int? limit,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: [
        if (limit != null) LengthLimitingTextInputFormatter(limit),
      ],
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
 */