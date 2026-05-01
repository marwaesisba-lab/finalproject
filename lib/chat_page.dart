/* import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late IO.Socket socket;
  final int currentUserId = 59;
  final int targetUserId = 2; // ID الموظف

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() {
    socket = IO.io('http://10.0.2.2:5500', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('✅ Connected to Server');
      socket.emit('join', {'userId': currentUserId});
      socket.emit('get_history', {
        'user1Id': currentUserId,
        'user2Id': targetUserId,
      });
    });

    socket.on('history', (data) {
      if (mounted) {
        setState(() {
          _messages.clear();
          for (var m in data['messages']) {
            _messages.add({
              'text': m['message'],
              'isMe': int.parse(m['sender_id'].toString()) == currentUserId,
            });
          }
        });
      }
    });

    socket.on('receive_message', (data) {
      if (mounted) {
        setState(() => _messages.add({'text': data['text'], 'isMe': false}));
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    socket.emit('send_message', {
      'fromId': currentUserId,
      'toId': targetUserId,
      'text': _controller.text.trim(),
    });
    setState(
      () => _messages.add({'text': _controller.text.trim(), 'isMe': true}),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E6), // الخلفية الكريمية
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4A4A4A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Customer Support",
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // منطقة الرسائل
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[(_messages.length - 1) - index];
                bool isMe = msg['isMe'];

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF4A4A4A) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: Radius.circular(isMe ? 15 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isMe ? Colors.white : const Color(0xFF4A4A4A),
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // حقل إدخال الرسالة (Input Area)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Write a message...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
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
 */
/* import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CustomerChatPage extends StatefulWidget {
  const CustomerChatPage({super.key});

  @override
  State<CustomerChatPage> createState() => _CustomerChatPageState();
}

class _CustomerChatPageState extends State<CustomerChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late IO.Socket socket;

  final int currentUserId = 59;
  final int targetUserId = 2; // Employee ID

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() {
    socket = IO.io('http://10.0.2.2:5500', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('✅ Customer Connected to Server');
      socket.emit('join', {'userId': currentUserId});
      socket.emit('get_history', {
        'user1Id': currentUserId,
        'user2Id': targetUserId,
      });
    });

    socket.on('history', (data) {
      if (mounted) {
        setState(() {
          _messages.clear();
          for (var m in data['messages'] ?? []) {
            _messages.add({
              'text': m['message'],
              'isMe': int.parse(m['sender_id'].toString()) == currentUserId,
            });
          }
        });
      }
    });

    socket.on('receive_message', (data) {
      if (mounted) {
        setState(() {
          _messages.add({'text': data['text'], 'isMe': false});
        });
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();

    socket.emit('send_message', {
      'fromId': currentUserId,
      'toId': targetUserId,
      'text': text,
    });

    setState(() {
      _messages.add({'text': text, 'isMe': true});
    });

    _controller.clear();
  }

  @override
  void dispose() {
    socket.disconnect();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // نفس الـ UI الذي كان موجوداً بدون تغيير
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4A4A4A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Customer Support",
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                bool isMe = msg['isMe'];

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF4A4A4A) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: Radius.circular(isMe ? 15 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isMe ? Colors.white : const Color(0xFF4A4A4A),
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Write a message...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
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
}e extends StatefulWidget {
  const CustomerChatPage({super.key});

  @override
  State<CustomerChatPage> createState() => _CustomerChatPageState();
}

class _CustomerChatPageState extends State<CustomerChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late IO.Socket socket;

  final int currentUserId = 59;
  final int targetUserId = 2; // Employee ID

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() {
    socket = IO.io('http://10.0.2.2:5500', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('✅ Customer Connected to Server');
      socket.emit('join', {'userId': currentUserId});
      socket.emit('get_history', {
        'user1Id': currentUserId,
        'user2Id': targetUserId,
      });
    });

    socket.on('history', (data) {
      if (mounted) {
        setState(() {
          _messages.clear();
          for (var m in data['messages'] ?? []) {
            _messages.add({
              'text': m['message'],
              'isMe': int.parse(m['sender_id'].toString()) == currentUserId,
            });
          }
        });
      }
    });

    socket.on('receive_message', (data) {
      if (mounted) {
        setState(() {
          _messages.add({'text': data['text'], 'isMe': false});
        });
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();

    socket.emit('send_message', {
      'fromId': currentUserId,
      'toId': targetUserId,
      'text': text,
    });

    setState(() {
      _messages.add({'text': text, 'isMe': true});
    });

    _controller.clear();
  }

  @override
  void dispose() {
    socket.disconnect();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // نفس الـ UI الذي كان موجوداً بدون تغيير
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4A4A4A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Customer Support",
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                bool isMe = msg['isMe'];

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF4A4A4A) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: Radius.circular(isMe ? 15 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isMe ? Colors.white : const Color(0xFF4A4A4A),
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: Box
 */
// page 1
// claude ai
/* import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String targetUserId;
  final String currentUserDbId; // ✅ id تاع المستخدم في قاعدة البيانات
  final IO.Socket socket;

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.targetUserId,
    required this.currentUserDbId,
    required this.socket,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  late Function(dynamic) _onHistory;
  late Function(dynamic) _onReceive;

  @override
  void initState() {
    super.initState();
    _registerListeners();
    _requestHistory();
  }

  void _requestHistory() {
    widget.socket.emit('join', {'userId': widget.currentUserId});
    widget.socket.emit('get_history', {
      'user1Id': widget.currentUserId, // ✅
      'user2Id': widget.targetUserId,
    });

    if (!widget.socket.connected) {
      widget.socket.onConnect((_) {
        widget.socket.emit('join', {'userId': widget.currentUserId});
        widget.socket.emit('get_history', {
          'user1Id': widget.currentUserDbId, // ✅
          'user2Id': widget.targetUserId,
        });
      });
    }
  }

  void _registerListeners() {
    _onHistory = (data) {
      if (!mounted) return;
      setState(() {
        _messages.clear();
        for (var m in (data['messages'] as List)) {
          _messages.add({
            'text': m['message'] ?? '',
            'isMe': m['sender_id'].toString() == widget.currentUserId, // ✅
          });
        }
      });
      _scrollToBottom();
    };

    _onReceive = (data) {
      if (!mounted) return;
      final fromId = data['fromId'].toString();
      final toId = data['toId'].toString();

      final bool relevant =
          (fromId == widget.targetUserId && toId == widget.currentUserDbId) ||
          (fromId == widget.currentUserDbId && toId == widget.targetUserId);

      if (!relevant) return;
      if (fromId == widget.currentUserDbId) return;

      setState(() {
        _messages.add({'text': data['text'] ?? '', 'isMe': false});
      });
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

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.socket.emit('join', {'userId': widget.currentUserId});

    widget.socket.emit('send_message', {
      'fromId': widget.currentUserId, // ✅
      'toId': widget.targetUserId,
      'text': text,
    });

    setState(() => _messages.add({'text': text, 'isMe': true}));
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
        title: const Text(
          "Chat",
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                    onSubmitted: (_) => _sendMessage(),
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
                  onTap: _sendMessage,
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
 */

// deepseek
/* import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  final String currentUserId; // هذا الـ firebase UID
  final String targetUserId; // ID تاع العامل من جدول employee
  final String currentUserDbId; // ID الرقمي تاع client من جدول person
  final IO.Socket socket;

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.targetUserId,
    required this.currentUserDbId,
    required this.socket,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  late Function(dynamic) _onHistory;
  late Function(dynamic) _onReceive;

  @override
  void initState() {
    super.initState();
    _registerListeners();
    _requestHistory();
  }

  void _requestHistory() {
    // ✅ currentUserDbId هو ID الرقمي تاع client (من جدول person)
    // ✅ targetUserId هو ID الرقمي تاع employee (من جدول employee)
    print(
      '📱 Client DB ID: ${widget.currentUserDbId} (${widget.currentUserDbId.runtimeType})',
    );
    print(
      '📱 Target Employee ID: ${widget.targetUserId} (${widget.targetUserId.runtimeType})',
    );

    widget.socket.emit('join', {'userId': widget.currentUserId});
    widget.socket.emit('get_history', {
      'user1Id': widget.currentUserDbId, // ID client
      'user2Id': widget.targetUserId, // ID employee
    });
  }

  void _registerListeners() {
    _onHistory = (data) {
      if (!mounted) return;
      setState(() {
        _messages.clear();
        for (var m in (data['messages'] as List)) {
          final senderId = m['sender_id'].toString();
          final isMe = senderId == widget.currentUserDbId;
          print(
            'Message: sender=$senderId, isMe=$isMe, myId=${widget.currentUserDbId}',
          );
          _messages.add({'text': m['message'] ?? '', 'isMe': isMe});
        }
      });
      _scrollToBottom();
    };

    _onReceive = (data) {
      if (!mounted) return;

      final fromId = data['fromId'].toString();
      final toId = data['toId'].toString();

      print('📨 Received message: from=$fromId, to=$toId');
      print('   My DB ID: ${widget.currentUserDbId}');
      print('   Target ID: ${widget.targetUserId}');

      // ✅ التحقق: هل الرسالة موجهة لي؟
      final bool isForMe =
          (toId == widget.currentUserDbId && fromId == widget.targetUserId);

      if (!isForMe) {
        print('   Message not for me, ignoring');
        return;
      }

      print('✅ Adding message to UI');
      setState(() {
        _messages.add({'text': data['text'] ?? '', 'isMe': false});
      });
      _scrollToBottom();
    };

    widget.socket.on('history', _onHistory);
    widget.socket.on('receive_message', _onReceive);
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    print('💬 Sending message:');
    print('   fromId (client DB): ${widget.currentUserDbId}');
    print('   toId (employee DB): ${widget.targetUserId}');
    print('   text: $text');

    widget.socket.emit('send_message', {
      'fromId': widget.currentUserDbId, // ✅ ID client من جدول person
      'toId': widget.targetUserId, // ✅ ID employee من جدول employee
      'text': text,
    });

    setState(() => _messages.add({'text': text, 'isMe': true}));
    _controller.clear();
    _scrollToBottom();
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
        title: const Text(
          "Chat",
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                    onSubmitted: (_) => _sendMessage(),
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
                  onTap: _sendMessage,
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
 */
/* import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  final String currentUserId; // Firebase UID للعميل (المهم)
  final String targetUserId; // Firebase UID للعامل   (المهم)
  final String? currentUserDbId; // اختياري

  final IO.Socket socket;

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.targetUserId,
    this.currentUserDbId,
    required this.socket,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  late Function(dynamic) _onHistory;
  late Function(dynamic) _onReceive;

  @override
  void initState() {
    super.initState();
    _registerListeners();
    _requestHistory();
  }

  void _requestHistory() {
    print(
      '📡 Requesting history between: ${widget.currentUserId} <-> ${widget.targetUserId}',
    );

    widget.socket.emit('join', {'userId': widget.currentUserId});

    widget.socket.emit('get_history', {
      'user1Id': widget.currentUserId, // Firebase UID
      'user2Id': widget.targetUserId, // Firebase UID
    });
  }

  void _registerListeners() {
    _onHistory = (data) {
      if (!mounted) return;
      setState(() {
        _messages.clear();
        for (var m in (data['messages'] as List)) {
          final senderId = m['sender_id'].toString();
          final isMe = senderId == widget.currentUserId;
          _messages.add({'text': m['message'] ?? '', 'isMe': isMe});
        }
      });
      _scrollToBottom();
    };

    _onReceive = (data) {
      if (!mounted) return;

      final fromId = data['fromId'].toString();
      final toId = data['toId'].toString();

      // الرسالة موجهة لي فقط إذا كان toId = UID الخاص بي
      final bool isForMe =
          (toId == widget.currentUserId && fromId == widget.targetUserId);

      if (!isForMe) {
        print('Message ignored - not for me');
        return;
      }

      setState(() {
        _messages.add({'text': data['text'] ?? '', 'isMe': false});
      });
      _scrollToBottom();
    };

    widget.socket.on('history', _onHistory);
    widget.socket.on('receive_message', _onReceive);
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.socket.emit('send_message', {
      'fromId': widget.currentUserId, // Firebase UID
      'toId': widget.targetUserId, // Firebase UID
      'text': text,
    });

    setState(() => _messages.add({'text': text, 'isMe': true}));
    _controller.clear();
    _scrollToBottom();
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
        title: const Text(
          "Chat",
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text("No messages yet. Start chatting!"))
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
                    onSubmitted: (_) => _sendMessage(),
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
                  onTap: _sendMessage,
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
 */

// chat again
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  final String currentUserId; // firebase_uid تاع الـ client
  final String targetUserId; // firebase_uid تاع الـ employee
  final String? currentUserDbId;
  final IO.Socket socket;

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.targetUserId,
    this.currentUserDbId,
    required this.socket,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  late Function(dynamic) _onHistory;
  late Function(dynamic) _onReceive;

  @override
  void initState() {
    super.initState();
    _registerListeners();
    _requestHistory();
  }

  void _requestHistory() {
    // ✅ join بـ firebase_uid تاع الـ client
    widget.socket.emit('join', {'userId': widget.currentUserId});

    // ✅ get_history بـ firebase_uids
    widget.socket.emit('get_history', {
      'user1Id': widget.currentUserId, // firebase_uid client
      'user2Id': widget.targetUserId, // firebase_uid employee
    });
  }

  void _registerListeners() {
    _onHistory = (data) {
      if (!mounted) return;
      setState(() {
        _messages.clear();
        for (var m in (data['messages'] as List)) {
          final senderId = m['sender_id'].toString();
          // ✅ مقارنة بـ firebase_uid
          final isMe = senderId == widget.currentUserId;
          _messages.add({'text': m['message'] ?? '', 'isMe': isMe});
        }
      });
      _scrollToBottom();
    };

    _onReceive = (data) {
      if (!mounted) return;

      final fromId = data['fromId'].toString();
      final toId = data['toId'].toString();

      // ✅ الرسالة لي فقط إذا toId = firebase_uid تاعي
      final bool isForMe =
          toId == widget.currentUserId && fromId == widget.targetUserId;

      if (!isForMe) return;

      setState(() {
        _messages.add({'text': data['text'] ?? '', 'isMe': false});
      });
      _scrollToBottom();
    };

    widget.socket.on('history', _onHistory);
    widget.socket.on('receive_message', _onReceive);
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // ✅ fromId = firebase_uid client, toId = firebase_uid employee
    widget.socket.emit('send_message', {
      'fromId': widget.currentUserId, // firebase_uid client
      'toId': widget.targetUserId, // firebase_uid employee
      'text': text,
    });

    setState(() => _messages.add({'text': text, 'isMe': true}));
    _controller.clear();
    _scrollToBottom();
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
        title: const Text(
          "Chat",
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text("No messages yet. Start chatting!"))
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
                    onSubmitted: (_) => _sendMessage(),
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
                  onTap: _sendMessage,
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
