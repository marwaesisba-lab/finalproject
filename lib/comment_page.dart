/* import 'package:flutter/material.dart';
import 'package:appweb/addcomment_lienavecserver.dart'; // دالة addComment

class CommentPage extends StatefulWidget {
  final String userId; // رقم المستخدم
  final int postId; // رقم المنشور أو العامل

  const CommentPage({Key? key, required this.userId, required this.postId})
    : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController commentController = TextEditingController();
  List<Map<String, String>> comments = []; // قائمة التعليقات الحالية

  // إرسال التعليق
  void sendComment() async {
    final commentText = commentController.text.trim();
    if (commentText.isEmpty) return;

    // إضافة التعليق محلياً أولاً
    setState(() {
      comments.insert(0, {
        "user": "You", // لاحقاً ممكن تجيب الاسم الحقيقي من userId
        "comment": commentText,
        "time": "Just now",
      });
      commentController.clear();
    });

    // إرسال التعليق للسيرفر
    try {
      await addComment(widget.userId, widget.postId, commentText);
    } catch (e) {
      print("Failed to send comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send comment"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1ED), // بني فاتح
      appBar: AppBar(
        backgroundColor: const Color(0xFF8D6E63), // بني داكن
        title: const Text("Comments"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // قائمة التعليقات
          Expanded(
            child: comments.isEmpty
                ? Center(
                    child: Text(
                      "No comments yet. Be the first!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown.shade300,
                      ),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final c = comments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.brown.shade100,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c["user"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c["comment"]!,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c["time"]!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.brown.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // حقل كتابة التعليق وزر الإرسال
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                        filled: true,
                        fillColor: Colors.brown.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: sendComment,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8D6E63),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 */
/* import 'package:appweb/addcomment_linkwithbackend.dart';
import 'package:flutter/material.dart';
import 'package:appweb/payementwidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "./user_session.dart";

Future<List<Map<String, dynamic>>> fetchComments(int postId) async {
  final url = Uri.parse("http://127.0.0.1:5500/comments/$postId");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data is Map<String, dynamic> && data.containsKey("comments")) {
      return List<Map<String, dynamic>>.from(data["comments"]);
    } else if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Invalid JSON format");
    }
  } else {
    throw Exception("Failed to load comments");
  }
}

class CommentPage extends StatefulWidget {
  final String userId;
  final int postId;

  const CommentPage({Key? key, required this.userId, required this.postId})
    : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController commentController = TextEditingController();
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    try {
      final data = await fetchComments(widget.postId);

      setState(() {
        comments = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void sendComment() async {
    final commentText = commentController.text.trim();
    if (commentText.isEmpty) return;

    await addComment(widget.userId, widget.postId, commentText);

    commentController.clear();

    await loadComments(); // load comment  ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                ? const Center(child: Text("No comments"))
                : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final c = comments[index];

                      return ListTile(
                        title: Text(c["user_name"] ?? "anonyme"),
                        subtitle: Text(c["content"]),
                        trailing: Text(
                          c["created_at"] ?? "",
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: "Write a comment",
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: sendComment),
            ],
          ),
        ],
      ),
    );
  }
}
 */
import 'package:appweb/addcomment_linkwithbackend.dart';
import 'package:flutter/material.dart';
import 'package:appweb/payementwidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "./user_session.dart";

// الدالة تبقى كما هي بدون تغيير في المنطق
Future<List<Map<String, dynamic>>> fetchComments(int postId) async {
  final url = Uri.parse("http://127.0.0.1:5500/comments/$postId");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic> && data.containsKey("comments")) {
      return List<Map<String, dynamic>>.from(data["comments"]);
    } else if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Invalid JSON format");
    }
  } else {
    throw Exception("Failed to load comments");
  }
}

class CommentPage extends StatefulWidget {
  final String userId;
  final int postId;

  const CommentPage({Key? key, required this.userId, required this.postId})
    : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController commentController = TextEditingController();
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    try {
      final data = await fetchComments(widget.postId);
      setState(() {
        comments = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  void sendComment() async {
    final commentText = commentController.text.trim();
    if (commentText.isEmpty) return;

    await addComment(widget.userId, widget.postId, commentText);
    commentController.clear();
    await loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EEE3), // خلفية بيج دافئة
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "REVIEWS",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          // عرض عدد التعليقات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              children: [
                Text(
                  "${comments.length} Comments",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.brown),
                  )
                : comments.isEmpty
                ? const Center(
                    child: Text(
                      "No reviews yet.\nBe the first to share your experience!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    physics: const BouncingScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final c = comments[index];
                      return _buildCommentCard(c);
                    },
                  ),
          ),

          // حقل الإدخال السفلي بتصميم عصري
          _buildCommentInput(),
        ],
      ),
    );
  }

  // ودجت كارت التعليق الاحترافي
  Widget _buildCommentCard(Map<String, dynamic> c) {
    String name = c["user_name"] ?? "Anonyme";
    String initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة الرمزية (Avatar)
          CircleAvatar(
            backgroundColor: const Color(0xFFF2EADC),
            child: Text(
              initial,
              style: const TextStyle(
                color: Color(0xFF8D6E63),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // تفاصيل التعليق
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      c["created_at"]?.toString().split(' ')[0] ??
                          "", // عرض التاريخ فقط
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  c["content"] ?? "",
                  style: const TextStyle(color: Colors.black87, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ودجت حقل الإدخال بتصميم عائم
  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: "Write a comment...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: sendComment,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF2D2D2D), // أسود داكن كما في HomePage
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
