import 'dart:async';
import 'package:appweb/AppState.dart';
import 'package:appweb/chat_page.dart';
import 'package:appweb/comment_page.dart';
import 'package:appweb/loadstatusfornotifications.dart';
import 'package:appweb/payementwidget.dart';
import 'package:appweb/regiter.dart';
import 'package:appweb/selectedworker.dart';
import 'package:appweb/type_of_works.dart';
import 'package:appweb/user_session.dart';
import 'package:flutter/material.dart';
import 'package:appweb/workers/modelworkers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Worker> workers = [];
  List<Worker> filteredWorkers = [];
  bool isLoading = true;

  late IO.Socket socket;

  Map<String, String> _workerStatuses = {};

  static const String serverUrl = "http://10.229.109.205:5500";

  Future<void> loadStatusesFromApi() async {
    final statuses = await NotificationService.fetchWorkerStatuses(
      widget.userId,
    );
    if (!mounted) return;
    setState(() {
      _workerStatuses = Map<String, String>.from(statuses);
    });
  }

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    loadWorkers();
    initSocket();
    loadStatusesFromApi();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      loadStatusesFromApi();
    });
  }

  void initSocket() {
    socket = IO.io(serverUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      socket.emit('join', {'userId': widget.userId});
    });

    socket.on('booking_status', (data) {
      final employeeId = data['employeeId']?.toString() ?? '';
      final status = data['status']?.toString() ?? 'wait';
      if (employeeId.isEmpty) return;
      if (!mounted) return;
      setState(() {
        _workerStatuses[employeeId] = status;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    socket.dispose();
    super.dispose();
  }

  Future<void> callNumber(String phone) async {
    final Uri uri = Uri.parse("tel:$phone");
    if (!await launchUrl(uri)) throw Exception('Could not launch dialer');
  }

  void loadWorkers() async {
    try {
      final fetchedWorkers = await fetchWorkers();
      setState(() {
        workers = fetchedWorkers ?? [];
        filteredWorkers = workers;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void searchWorker(String query) {
    if (query.isEmpty) {
      setState(() => filteredWorkers = workers);
      return;
    }
    query = query.toLowerCase();
    setState(() {
      filteredWorkers = workers.where((w) {
        return w.fullname.toLowerCase().contains(query) ||
            w.job.toLowerCase().contains(query);
      }).toList();
    });
  }

  // ✅ هنا الإصلاح — confirmAndNavigate مصحح بالكامل
  void confirmAndNavigate(BuildContext context, Worker worker) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text(
          "Confirm Selection",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text("Do you want to book ${worker.fullname}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "CANCEL",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              SelectedWorkerService.instance.select(worker);
              AppState.selectedWorker = worker;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Find()),
              );
            },
            child: const Text(
              "CONFIRM",
              style: TextStyle(
                color: Color(0xFF2D2D2D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EEE3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "PROFESSIONALS",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Available\nExperts Nearby",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D2D2D),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: searchWorker,
                decoration: const InputDecoration(
                  hintText: "Search for a name or service...",
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    )
                  : filteredWorkers.isEmpty
                  ? const Center(
                      child: Text(
                        "No workers found",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredWorkers.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) =>
                          _buildWorkerItem(filteredWorkers[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerItem(Worker w) {
    String firstLetter = (w.fullname.trim().isNotEmpty)
        ? w.fullname.trim()[0].toUpperCase()
        : "?";

    final String workerKey = w.id.toString();
    final String status = _workerStatuses[workerKey] ?? 'wait';

    Color statusColor;
    IconData statusIcon;
    String statusLabel;
    Color statusBg;

    switch (status) {
      case 'accepted':
        statusColor = Colors.green.shade700;
        statusBg = Colors.green.shade50;
        statusIcon = Icons.check_circle_rounded;
        statusLabel = 'Accepted';
        break;
      case 'refused':
        statusColor = Colors.red.shade700;
        statusBg = Colors.red.shade50;
        statusIcon = Icons.cancel_rounded;
        statusLabel = 'Refused';
        break;
      default:
        statusColor = Colors.grey.shade600;
        statusBg = Colors.grey.shade100;
        statusIcon = Icons.hourglass_empty_rounded;
        statusLabel = 'Wait for response';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EADC),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => confirmAndNavigate(context, w),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.fullname.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Color(0xFF2D2D2D),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          w.job.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Colors.brown.shade800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.fmd_good_rounded,
                              size: 14,
                              color: Colors.black45,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                w.address,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.orange,
                          size: 18,
                        ),
                        Text(
                          "${w.rating.toStringAsFixed(1)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Booking Status:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Divider(color: Colors.black12, thickness: 1.2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionButton(
                    Icons.phone_in_talk_rounded,
                    "CALL",
                    Colors.green.shade700,
                    () => callNumber(w.phoneNumber),
                  ),
                  _actionButton(
                    Icons.chat_bubble_rounded,
                    "CHAT",
                    Colors.blue.shade700,
                    () {
                      SelectedWorkerService.instance.select(w);
                      AppState.selectedWorker = w;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            currentUserId: widget.userId,
                            currentUserDbId: widget.userId,
                            targetUserId: w.firebaseUid ?? w.id.toString(),
                            socket: socket,
                          ),
                        ),
                      );
                    },
                  ),
                  _actionButton(
                    Icons.stars_rounded,
                    "REVIEW",
                    Colors.orange.shade800,
                    () {
                      SelectedWorkerService.instance.select(w);
                      AppState.selectedWorker = w;
                      UserSession.employeeid = w.id;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CommentPage(userId: widget.userId, postId: w.id),
                        ),
                      );
                    },
                  ),
                  _actionButton(
                    Icons.account_balance_wallet_rounded,
                    "PAY",
                    const Color(0xFF2D2D2D),
                    () {
                      print("💰 w.id = ${w.id}");
                      SelectedWorkerService.instance.select(w);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentPagePerfect(userid: w.id),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D2D2D),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
