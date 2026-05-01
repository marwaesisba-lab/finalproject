import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatWithUserPage extends StatefulWidget {
  final String userId; // DB ID ديال اليوزر
  final String employeeId; // DB ID ديال الموظف - مش Firebase UID أبداً
  final IO.Socket socket;

  const ChatWithUserPage({
    super.key,
    required this.userId,
    required this.employeeId,
    required this.socket,
  });

  @override
  State<ChatWithUserPage> createState() => _ChatWithUserPageState();
}

class _ChatWithUserPageState extends State<ChatWithUserPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];

  late Function(dynamic) _onHistory;
  late Function(dynamic) _onReceive;

  @override
  void initState() {
    super.initState();
    _registerListeners();
    // FIX: كلهم DB IDs فقط
    widget.socket.emit('get_history', {
      'user1Id': widget.employeeId,
      'user2Id': widget.userId,
    });
  }

  void _registerListeners() {
    _onHistory = (data) {
      if (!mounted) return;
      setState(() {
        messages = List<Map<String, dynamic>>.from(
          (data['messages'] as List).map(
            (m) => {
              'text': m['message'] ?? '',
              // FIX: مقارنة sender_id (DB ID) بـ employeeId (DB ID)
              'isMe': m['sender_id'].toString() == widget.employeeId.toString(),
            },
          ),
        );
      });
      _scrollToBottom();
    };

    _onReceive = (data) {
      if (!mounted) return;

      // FIX: السيرفر يبعث fromId/toId كـ DB IDs
      final fromId = data['fromId']?.toString() ?? '';
      final toId = data['toId']?.toString() ?? '';

      // نفلترو بالـ DB IDs فقط
      final bool relevant =
          (fromId == widget.userId && toId == widget.employeeId) ||
          (fromId == widget.employeeId && toId == widget.userId);

      if (!relevant) return;
      if (fromId == widget.employeeId) return;

      setState(() => messages.add({'text': data['text'] ?? '', 'isMe': false}));
      _scrollToBottom();
    };

    widget.socket.on('history', _onHistory);
    widget.socket.on('receive_message', _onReceive);
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

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // FIX: fromId و toId = DB IDs فقط - مش Firebase UIDs
    widget.socket.emit('send_message', {
      'fromId': widget.employeeId,
      'toId': widget.userId,
      'text': text,
    });

    setState(() => messages.add({'text': text, 'isMe': true}));
    _controller.clear();
    _scrollToBottom();
  }

  @override
  void dispose() {
    widget.socket.off('history', _onHistory);
    widget.socket.off('receive_message', _onReceive);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "User #${widget.userId}",
          style: const TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text("No messages yet."))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final msg = messages[i];
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg['text'] ?? '',
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
                    onSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Type a message…",
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
                  onTap: sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A4A4A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
