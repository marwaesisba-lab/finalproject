import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> addComment(String userId, int postId, String content) async {
  final url = Uri.parse("http://127.0.0.1:5500/comments");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "user_id": userId,
      "post_id": postId,
      "content": content,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(data["message"]); // "comment add successfully"
  } else {
    print("Error: ${response.statusCode}");
  }
}

// fetch any comment
Future<List<Map<String, dynamic>>> fetchComments(int postId) async {
  final url = Uri.parse("http://127.0.0.1:5500/comments_with_names/$postId");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // تحقق واش فيه "comments" ولا مباشرة list
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
