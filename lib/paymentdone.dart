import 'package:appweb/type_of_works.dart';
import 'package:appweb/user_session.dart';
import 'package:flutter/material.dart';

class Paymentdone extends StatelessWidget {
  const Paymentdone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EEE3), // الخلفية الكريمية الراقية
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 50),

              // شعار التطبيق بتنسيق أنيق
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AT YOUR\nDOOR',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      height: 1.1,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // الكارد المركزي الأبيض بتصميم "Minimalist"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 30,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // أيقونة النجاح بتصميم متدرج ناعم
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFE8F5E9,
                        ), // أخضر خفيف جداً أو كريمي
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        size: 80,
                        color: Color(0xFF4CAF50), // لون النجاح الهادئ
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Success!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your payment has been\nprocessed successfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // زر Done الأنيق
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D2D2D),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // زر التقييم في الأسفل بتصميم شفاف وراقي
              TextButton.icon(
                onPressed: () {
                  print(
                    "⭐⭐⭐⭐⭐ employeidforrating = ${UserSession.employeidforrating}",
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RatingPage(
                        employeeId: UserSession.employeidforrating!,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.star_rounded,
                  color: Colors.orangeAccent,
                ),
                label: const Text(
                  'Rate your experience',
                  style: TextStyle(
                    color: Color(0xFF2D2D2D),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
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
}
