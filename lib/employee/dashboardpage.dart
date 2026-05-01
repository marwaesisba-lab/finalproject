// **************************************regular page ***************************************************
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:appweb/AppState.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ====================== DashboardPage ======================
class DashboardPage extends StatefulWidget {
  final String userId;
  final String firebaseUid;
  const DashboardPage({
    Key? key,
    required this.userId,
    required this.firebaseUid,
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 1;
  late IO.Socket socket;

  late final String employeeDbId;
  late final String employeeFirebaseUid;

  String targetUserId = "";
  String targetUserName = "Customer";

  final GlobalKey<_DirectChatSectionState> _chatKey = GlobalKey();

  List<dynamic> _cachedClients = [];
  bool _clientsLoaded = false;
  Map<String, String> _clientStatuses = {};

  String? _mapClientAddress;
  String? _mapClientName;

  late Function(dynamic) _onReceive;
  late Function(dynamic) _onHistory;

  static const List<String> _titles = ["Chat", "Clients", "Map", "Earnings"];

  @override
  void initState() {
    super.initState();
    employeeDbId = widget.userId;
    employeeFirebaseUid = widget.firebaseUid;
    debugPrint("✅ employeeDbId: $employeeDbId");
    debugPrint("✅ employeeFirebaseUid: $employeeFirebaseUid");
    _saveWorkerToStorage();
    initSocket();
    _loadClientsFromCache();
  }

  @override
  void dispose() {
    socket.off('receive_message', _onReceive);
    socket.off('history', _onHistory);
    socket.dispose();
    super.dispose();
  }

  Future<void> _saveWorkerToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (AppState.selectedWorker != null) {
      await prefs.setString('worker_name', AppState.selectedWorker!.fullname);
    }
  }

  Future<void> _loadClientsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_clients');
    final statusesJson = prefs.getString('client_statuses');
    if (statusesJson != null) {
      final decoded = jsonDecode(statusesJson) as Map<String, dynamic>;
      setState(() {
        _clientStatuses = decoded.map((k, v) => MapEntry(k, v.toString()));
      });
    }
    await _loadClientsFromApi();
  }

  Future<void> _loadClientsFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    String? workerName =
        AppState.selectedWorker?.fullname ??
        prefs.getString('worker_name') ??
        "";
    if (workerName.isEmpty) return;
    try {
      final url = Uri.parse(
        "http://10.229.109.205:5500/getusers/${Uri.encodeComponent(workerName)}",
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final fresh = jsonDecode(response.body) as List<dynamic>;
        await prefs.setString('cached_clients', response.body);
        setState(() {
          _cachedClients = fresh;
          _clientsLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("❌ API Error: $e");
      setState(() => _clientsLoaded = true);
    }
  }

  Future<void> _setClientStatus(String clientId, String status) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() => _clientStatuses[clientId] = status);
    await prefs.setString('client_statuses', jsonEncode(_clientStatuses));

    // 🔔 إرسال notification للباك
    try {
      final url = Uri.parse("http://10.229.109.205:5500/notificationssend");
      String content;
      switch (status) {
        case "pending":
          content = "wait";
          break;
        case "in_progress":
          content = "accepted";
          break;
        case "completed":
          content = "accepted";
          break;
        case "cancelled":
          content = "refused";
          break;
        default:
          content = "wait";
      }

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "content": content,
          "user_id": clientId,
          "employee_id": employeeDbId,
        }),
      );

      debugPrint("📩 Notification response: ${res.body}");
    } catch (e) {
      debugPrint("❌ Notification error: $e");
    }
  }

  void initSocket() {
    socket = IO.io('http://10.229.109.205:5500', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _onReceive = (data) {
      if (!mounted) return;
      final fromId = data['fromId']?.toString() ?? '';
      final toId = data['toId']?.toString() ?? '';
      if (toId != employeeFirebaseUid) return;
      _chatKey.currentState?.addMessage({
        'text': data['text'] ?? '',
        'isMe': false,
        'fromId': fromId,
      });
    };

    _onHistory = (data) {
      if (!mounted || data['messages'] == null) return;
      final List<Map<String, dynamic>> loaded = List<Map<String, dynamic>>.from(
        (data['messages'] as List).map(
          (m) => {
            'text': m['message'] ?? '',
            'isMe': m['sender_id'].toString() == employeeFirebaseUid,
          },
        ),
      );
      _chatKey.currentState?.loadMessages(loaded);
    };

    socket.on('receive_message', _onReceive);
    socket.on('history', _onHistory);

    socket.onConnect((_) {
      socket.emit('join', {'userId': employeeFirebaseUid});
      debugPrint("✅ Socket connected: $employeeFirebaseUid");
    });
  }

  void _loadChatHistory(String clientFirebaseUid) {
    if (employeeFirebaseUid.isEmpty || clientFirebaseUid.isEmpty) return;
    socket.emit('get_history', {
      'user1Id': employeeFirebaseUid,
      'user2Id': clientFirebaseUid,
    });
  }

  void startChatWithClient(String clientFirebaseUid, String name) {
    debugPrint("🟢 Starting chat: $clientFirebaseUid - $name");
    setState(() {
      targetUserId = clientFirebaseUid;
      targetUserName = name;
      _selectedIndex = 0;
    });
    _chatKey.currentState?.loadMessages([]);
    _loadChatHistory(clientFirebaseUid);
  }

  void _openMapForClient(String address, String name) {
    setState(() {
      _mapClientAddress = address;
      _mapClientName = name;
      _selectedIndex = 2;
    });
  }

  String get _appBarTitle {
    if (_selectedIndex == 0) return "Chat: $targetUserName";
    return _titles[_selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _appBarTitle,
          style: const TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF4A4A4A)),
              onPressed: _loadClientsFromApi,
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DirectChatSection(
            key: _chatKey,
            socket: socket,
            employeeFirebaseUid: employeeFirebaseUid,
            targetId: targetUserId,
          ),
          ClientsSection(
            onChatTap: startChatWithClient,
            onMapTap: _openMapForClient,
            clients: _cachedClients,
            isLoaded: _clientsLoaded,
            onRefresh: _loadClientsFromApi,
            clientStatuses: _clientStatuses,
            onStatusChange: _setClientStatus,
          ),
          MapPage(clientAddress: _mapClientAddress, clientName: _mapClientName),
          EarningsSection(employeeId: employeeDbId),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFFF5F1E6),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: "Clients"),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
            BottomNavigationBarItem(
              icon: Icon(Icons.payments),
              label: "Earnings",
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== ClientsSection ======================
class ClientsSection extends StatelessWidget {
  final Function(String, String) onChatTap;
  final Function(String, String) onMapTap;
  final List<dynamic> clients;
  final bool isLoaded;
  final VoidCallback onRefresh;
  final Map<String, String> clientStatuses;
  final Function(String, String) onStatusChange;

  const ClientsSection({
    super.key,
    required this.onChatTap,
    required this.onMapTap,
    required this.clients,
    required this.isLoaded,
    required this.onRefresh,
    required this.clientStatuses,
    required this.onStatusChange,
  });

  static const List<String> _statusOptions = [
    'pending',
    'in_progress',
    'completed',
    'cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) return const Center(child: CircularProgressIndicator());
    if (clients.isEmpty) return const Center(child: Text("No clients found."));

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final item = clients[index];
          final name =
              "${item["first_name"] ?? ''} ${item["family_name"] ?? ''}".trim();

          final clientDbId = item["user_id"]?.toString() ?? "";
          final clientFirebaseUid = item["firebase_uid"]?.toString() ?? "";

          final status = clientStatuses[clientDbId] ?? "pending";
          final address =
              item["address"]?.toString() ?? item["location"]?.toString() ?? "";
          final appointmentType =
              item["appointemet"]?.toString() ??
              item["service"]?.toString() ??
              "غير محدد";
          final date = item["date"]?.toString() ?? "";
          final time = item["timer"]?.toString() ?? "";

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF4A4A4A),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          color: Color(0xFF4A4A4A),
                        ),
                        onPressed: () {
                          onChatTap(clientDbId, name);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.location_on,
                          color: address.isNotEmpty
                              ? const Color(0xFFE53935)
                              : Colors.grey,
                        ),
                        onPressed: address.isNotEmpty
                            ? () => onMapTap(address, name)
                            : null,
                      ),
                    ],
                  ),
                  if (date.isNotEmpty ||
                      time.isNotEmpty ||
                      appointmentType != "غير محدد")
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (appointmentType != "غير محدد")
                            Text(
                              "The Type of work : $appointmentType",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (date.isNotEmpty) Text("date: $date"),
                          if (time.isNotEmpty) Text("Time : $time"),
                        ],
                      ),
                    ),
                  if (address.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.place, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              address,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  DropdownButtonFormField<String>(
                    value: _statusOptions.contains(status) ? status : 'pending',
                    decoration: InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: _statusOptions
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) =>
                        v != null ? onStatusChange(clientDbId, v) : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ====================== DirectChatSection ======================
class DirectChatSection extends StatefulWidget {
  final IO.Socket socket;
  final String employeeFirebaseUid;
  final String targetId;

  const DirectChatSection({
    super.key,
    required this.socket,
    required this.employeeFirebaseUid,
    required this.targetId,
  });

  @override
  State<DirectChatSection> createState() => _DirectChatSectionState();
}

class _DirectChatSectionState extends State<DirectChatSection> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  late String _currentTargetId;

  @override
  void initState() {
    super.initState();
    _currentTargetId = widget.targetId;
  }

  @override
  void didUpdateWidget(DirectChatSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetId != widget.targetId) {
      setState(() => _currentTargetId = widget.targetId);
    }
  }

  void addMessage(Map<String, dynamic> msg) {
    if (!mounted) return;
    if (msg.containsKey('fromId') &&
        _currentTargetId.isNotEmpty &&
        msg['fromId'].toString() != _currentTargetId)
      return;
    setState(() => _messages.add(msg));
    _scrollToBottom();
  }

  void loadMessages(List<Map<String, dynamic>> msgs) {
    if (!mounted) return;
    setState(() {
      _messages.clear();
      _messages.addAll(msgs);
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty ||
        widget.employeeFirebaseUid.isEmpty ||
        _currentTargetId.isEmpty)
      return;

    widget.socket.emit('send_message', {
      'fromId': widget.employeeFirebaseUid,
      'toId': _currentTargetId,
      'text': text,
    });

    addMessage({'text': text, 'isMe': true});
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_currentTargetId.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                "Select a client from Clients tab\nto start chatting.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text("No messages yet."))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['isMe'] == true;
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.72,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFF4A4A4A)
                                : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 16),
                            ),
                          ),
                          child: Text(
                            msg['text'] ?? "",
                            style: TextStyle(
                              color: isMe
                                  ? Colors.white
                                  : const Color(0xFF4A4A4A),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: _currentTargetId.isEmpty
                        ? "Select a client first..."
                        : "Type a message…",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF5F1E6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _currentTargetId.isEmpty
                        ? Colors.grey
                        : const Color(0xFF4A4A4A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ====================== MapPage ======================
class MapPage extends StatefulWidget {
  final String? clientAddress;
  final String? clientName;
  const MapPage({Key? key, this.clientAddress, this.clientName})
    : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  LatLng? _searchedLocation;
  bool _isSearching = false;

  static const LatLng _tiaretCenter = LatLng(35.3711, 1.3170);
  static const double _initialZoom = 10.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_tiaretCenter, _initialZoom);
    });
    if (widget.clientAddress != null && widget.clientAddress!.isNotEmpty) {
      _searchController.text = widget.clientAddress!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _searchAddress());
    }
  }

  @override
  void didUpdateWidget(MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clientAddress != oldWidget.clientAddress &&
        widget.clientAddress != null &&
        widget.clientAddress!.isNotEmpty) {
      _searchController.text = widget.clientAddress!;
      _searchAddress();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    _searchFocus.unfocus();
    setState(() => _isSearching = true);
    try {
      final proxy = 'https://api.allorigins.win/get?url=';
      final nominatim =
          'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=1';
      final response = await http.get(
        Uri.parse(proxy + Uri.encodeComponent(nominatim)),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final contents = jsonDecode(jsonData['contents']) as List<dynamic>;
        if (contents.isNotEmpty) {
          final lat = double.parse(contents[0]['lat'].toString());
          final lon = double.parse(contents[0]['lon'].toString());
          setState(() => _searchedLocation = LatLng(lat, lon));
          _mapController.move(_searchedLocation!, 15.0);
          return;
        }
      }
      _showError("لم نجد الموقع");
    } catch (e) {
      _showError("فشل البحث");
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _tiaretCenter,
            initialZoom: _initialZoom,
            minZoom: 7.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.appweb',
            ),
            if (_searchedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _searchedLocation!,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                ],
              ),
          ],
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF4A4A4A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onSubmitted: (_) => _searchAddress(),
                      decoration: const InputDecoration(
                        hintText: "ابحث داخل تيارت...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_isSearching)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _searchAddress,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (widget.clientName != null && widget.clientName!.isNotEmpty)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF4A4A4A),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      widget.clientName!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ====================== EarningsSection ======================
class EarningsSection extends StatefulWidget {
  final String employeeId;
  const EarningsSection({super.key, required this.employeeId});

  @override
  State<EarningsSection> createState() => _EarningsSectionState();
}

class _EarningsSectionState extends State<EarningsSection> {
  List<dynamic> payments = [];
  bool loading = true;
  double totalEarnings = 0;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    final url = Uri.parse(
      "http://10.229.109.205:5500/seevalueofpayed/${widget.employeeId}",
    );
    try {
      final res = await http.get(url);
      debugPrint("📦 RAW RESPONSE: ${res.body}");
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        double total = 0;
        for (final p in data) {
          debugPrint("💰 payement value: ${p['payement']}");
          debugPrint(
            "💰 parsed: ${double.tryParse(p['payement']?.toString() ?? '0')}",
          );
          total += double.tryParse(p['payement']?.toString() ?? '0') ?? 0;
        }
        setState(() {
          payments = data;
          totalEarnings = total;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.payments_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              "No payments yet",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchPayments,
      child: Column(
        children: [
          // ── Total Card ──────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF4A4A4A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Earnings",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      "${totalEarnings.toStringAsFixed(0)} DZD",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  "${payments.length} client${payments.length != 1 ? 's' : ''}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          // ── List ────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final p = payments[index];
                final name =
                    "${p['first_name'] ?? ''} ${p['family_name'] ?? ''}".trim();
                final amount =
                    double.tryParse(p['payment']?.toString() ?? '0') ?? 0;
                final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF4A4A4A),
                      child: Text(
                        initial,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F1E6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4A4A4A),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "${amount.toStringAsFixed(0)} DZD",
                        style: const TextStyle(
                          color: Color(0xFF4A4A4A),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
