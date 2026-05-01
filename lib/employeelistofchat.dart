import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:appweb/employeechatpage.dart';

class EmployeeListOfChatPage extends StatefulWidget {
  final String employeeId; // DB ID فقط - مش Firebase UID

  const EmployeeListOfChatPage({super.key, required this.employeeId});

  @override
  State<EmployeeListOfChatPage> createState() => _EmployeeListOfChatPageState();
}

class _EmployeeListOfChatPageState extends State<EmployeeListOfChatPage> {
  late IO.Socket socket;
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  late Function(dynamic) _onAllMessages;
  late Function(dynamic) _onReceive;

  static const String serverUrl = "http://10.229.109.205:5500";

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io(serverUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _onAllMessages = (data) {
      if (!mounted) return;

      if (data['messages'] == null) {
        setState(() => _isLoading = false);
        return;
      }

      // نجمعوا كل المحادثات مع آخر رسالة
      // sender_id و receiver_id = IDs من قاعدة البيانات فقط
      final Map<String, Map<String, dynamic>> convMap = {};

      for (var msg in data['messages']) {
        final sender = msg['sender_id'].toString();
        final receiver = msg['receiver_id'].toString();
        final text = msg['message']?.toString() ?? '';

        // FIX: نتأكدوا الرسالة ليها علاقة بالموظف هذا
        if (sender != widget.employeeId && receiver != widget.employeeId) {
          continue;
        }

        // FIX: الـ ID التاني في المحادثة (مش employeeId)
        final otherId = (sender == widget.employeeId) ? receiver : sender;

        // FIX: ما نضيفوش محادثة الموظف مع نفسو
        if (otherId == widget.employeeId) continue;

        // نحتفظوا بآخر رسالة فقط (الأخيرة في الـ loop)
        convMap[otherId] = {
          'userId': otherId,
          'lastMessage': text,
          'isMe': sender == widget.employeeId,
        };
      }

      setState(() {
        _conversations = convMap.values.toList();
        _isLoading = false;
      });
    };

    _onReceive = (data) {
      if (!mounted) return;

      // FIX: تأكد الـ keys صحيحة - السيرفر يبعث fromId/toId
      final fromId = data['fromId']?.toString() ?? '';
      final toId = data['toId']?.toString() ?? '';
      final text = data['text']?.toString() ?? '';

      // نتأكدوا الرسالة ليها علاقة بالموظف هذا
      if (toId != widget.employeeId && fromId != widget.employeeId) return;

      final otherId = (fromId == widget.employeeId) ? toId : fromId;
      if (otherId.isEmpty || otherId == widget.employeeId) return;

      setState(() {
        final idx = _conversations.indexWhere((c) => c['userId'] == otherId);
        if (idx >= 0) {
          _conversations[idx] = {
            'userId': otherId,
            'lastMessage': text,
            'isMe': fromId == widget.employeeId,
          };
        } else {
          _conversations.insert(0, {
            'userId': otherId,
            'lastMessage': text,
            'isMe': fromId == widget.employeeId,
          });
        }
      });
    };

    socket.on('all_messages', _onAllMessages);
    socket.on('receive_message', _onReceive);

    socket.onConnect((_) {
      debugPrint(
        "✅ EmployeeListOfChatPage connected - DB ID: ${widget.employeeId}",
      );
      // join بـ DB ID فقط - مش Firebase UID أبداً
      socket.emit('join', {'userId': widget.employeeId});
      socket.emit('get_all_messages', {'userId': widget.employeeId});
    });
  }

  void _refresh() {
    setState(() => _isLoading = true);
    socket.emit('get_all_messages', {'userId': widget.employeeId});
  }

  @override
  void dispose() {
    socket.off('all_messages', _onAllMessages);
    socket.off('receive_message', _onReceive);
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Inbox",
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4A4A4A)),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
          ? const Center(
              child: Text(
                "No conversations yet.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conv = _conversations[index];
                final userId = conv['userId'] as String;
                final lastMessage = conv['lastMessage'] as String;
                final isMe = conv['isMe'] as bool;

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
                        '#$userId',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    title: Text(
                      "User #$userId",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    subtitle: lastMessage.isNotEmpty
                        ? Text(
                            "${isMe ? 'You: ' : ''}$lastMessage",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          )
                        : null,
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF4A4A4A),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EmployeeChatPage(
                            // كلهم DB IDs فقط
                            employeeId: widget.employeeId,
                            targetUserId: userId,
                            socket: socket,
                          ),
                        ),
                      ).then((_) => _refresh());
                    },
                  ),
                );
              },
            ),
    );
  }
}
