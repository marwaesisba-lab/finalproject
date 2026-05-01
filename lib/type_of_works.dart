import 'package:appweb/allidsusedtologin.dart';
import 'package:appweb/notification.dart';
import 'package:appweb/selectedworker.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// استيرادات ملفاتك (تأكد من صحة المسارات في مشروعك)
import 'package:appweb/AppState.dart';
import 'package:appweb/globalwork.dart';
import 'package:appweb/user_session.dart';

// ------------------ 1. Find Page ------------------
class Find extends StatefulWidget {
  const Find({super.key});

  @override
  State<Find> createState() => _FindState();
}

class _FindState extends State<Find> {
  String? selectedService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECDD),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Text(
                "Find a Service:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
              const SizedBox(height: 100),

              /// Consultation Button
              buildServiceButton("Consultation"),
              const SizedBox(height: 50),

              /// Major Work Button
              buildServiceButton("Major work"),
              const SizedBox(height: 50),

              /// Appointment Button
              ElevatedButton(
                onPressed: selectedService == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AppointmentPage(serviceType: selectedService!),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: 15,
                  ),
                  backgroundColor: const Color(0xFF4A4A4A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Appointment",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildServiceButton(String serviceName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedService = serviceName;
          selectedServiceforemployee = serviceName; // تحديث المتغير العالمي
        });
      },
      child: Container(
        width: 361,
        height: 120,
        decoration: BoxDecoration(
          color: selectedService == serviceName
              ? Colors.blue.shade100
              : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.black, width: 1.0),
        ),
        child: Center(
          child: Text(
            serviceName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// ------------------ 2. Appointment Page ------------------
class AppointmentPage extends StatefulWidget {
  final String serviceType;
  const AppointmentPage({super.key, required this.serviceType});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTime;
  TextEditingController addressController = TextEditingController();

  Future<void> pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> saveAppointmentToServer() async {
    final url = Uri.parse("http://127.0.0.1:5500/showusers");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": UserSession.firstname,
          "family_name": UserSession.familyname,
          "date": _selectedDay != null
              ? "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}"
              : "",
          "timer": _selectedTime != null
              ? "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}"
              : "",
          "appointemet": widget.serviceType,
          "workerSelect": AppState.selectedWorker?.fullname ?? "KARIM ELC",
          "user_id": UserSession.userId,
        }),
      );
      if (response.statusCode == 200) {
        print("✅ Success");
      }
    } catch (e) {
      print("❌ Connection Error: $e");
    }
  }

  void confirmAppointment() async {
    if (_selectedDay == null ||
        _selectedTime == null ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Missing info!")));
      return;
    }

    // تحديث المتغيرات العالمية
    globalDate = _selectedDay;
    globalTime = _selectedTime;
    globalAddress = addressController.text;

    await saveAppointmentToServer();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StatusPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E9D8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Appointment", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 10),
            Text(
              SelectedWorkerService.instance.name.toUpperCase(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                  ListTile(
                    title: const Text("Time"),
                    trailing: TextButton(
                      onPressed: pickTime,
                      child: Text(
                        _selectedTime == null
                            ? "Select Time"
                            : _selectedTime!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                hintText: "Address",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: confirmAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A4A4A),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ 3. Rating Page ------------------
/* 
class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _rating = 5;

  Map<String, String> _getRatingData() {
    switch (_rating) {
      case 1:
        return {"text": "Bad 1/5", "emoji": "😞"};
      case 2:
        return {"text": "Nah 2/5", "emoji": "😐"};
      case 3:
        return {"text": "Good 3/5", "emoji": "😊"};
      case 4:
        return {"text": "Super good 4/5", "emoji": "😎"};
      case 5:
        return {"text": "Perfect 5/5", "emoji": "🤩"};
      default:
        return {"text": "", "emoji": ""};
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingData = _getRatingData();

    return Scaffold(
      backgroundColor: const Color(0xFFF7EEE3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black87,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "RATING",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const Spacer(),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Text(
                  ratingData["emoji"]!,
                  key: ValueKey(_rating),
                  style: const TextStyle(fontSize: 100), // إيموجي كبير وواضح
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "How was your\nexperience?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                ratingData["text"]!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 40),

              //
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      icon: Icon(
                        index < _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 45,
                      ),
                      onPressed: () => setState(() => _rating = index + 1),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              //
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D2D2D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Submit Review",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
 */

///////********* ********************* Rating page corrected form **************** */

class RatingPage extends StatefulWidget {
  final int employeeId; // ✅ استقبال employeeId

  const RatingPage({super.key, required this.employeeId});

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _rating = 5;
  bool _isLoading = false;

  Map<String, String> _getRatingData() {
    switch (_rating) {
      case 1:
        return {"text": "Bad 1/5", "emoji": "😞"};
      case 2:
        return {"text": "Nah 2/5", "emoji": "😐"};
      case 3:
        return {"text": "Good 3/5", "emoji": "😊"};
      case 4:
        return {"text": "Super good 4/5", "emoji": "😎"};
      case 5:
        return {"text": "Perfect 5/5", "emoji": "🤩"};
      default:
        return {"text": "", "emoji": ""};
    }
  }

  Future<void> _submitRating() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.229.109.205:5500/submitratting"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "RateStars": _rating,
          "employee_id": widget.employeeId, // ✅ يستخدم employeeId المرسل
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"]),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${data["error"]}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingData = _getRatingData();

    return Scaffold(
      backgroundColor: const Color(0xFFF7EEE3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black87,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "RATING",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const Spacer(),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Text(
                  ratingData["emoji"]!,
                  key: ValueKey(_rating),
                  style: const TextStyle(fontSize: 100),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "How was your\nexperience?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                ratingData["text"]!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      icon: Icon(
                        index < _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 45,
                      ),
                      onPressed: () => setState(() => _rating = index + 1),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D2D2D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Review",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
