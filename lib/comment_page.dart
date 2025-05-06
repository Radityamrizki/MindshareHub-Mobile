import 'package:flutter/material.dart';
import 'post_repository.dart';
import 'user_repository.dart';

class CommentPage extends StatefulWidget {
  final int postIndex;
  const CommentPage({super.key, required this.postIndex});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final post = PostRepository.posts.value[widget.postIndex];
    final comments = List<Map<String, String>>.from(post['comments'] ?? []);
    final user = UserRepository.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komentar', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(post['avatar']),
                  ),
                  title: Text(post['name']),
                  subtitle: Text(post['content']),
                ),
                const Divider(),
                ...comments.map(
                  (c) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(c['avatar']!),
                    ),
                    title: Text(c['name']!),
                    subtitle: Text(c['content']!),
                    trailing: Text(c['time'] ?? ''),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(user['avatar']!),
                  radius: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Tulis komentar...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF7C3AED)),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      PostRepository.addComment(widget.postIndex, {
                        'name': user['name']!,
                        'username': user['username']!,
                        'avatar': user['avatar']!,
                        'content': _controller.text.trim(),
                        'time': 'now',
                      });
                      setState(() {
                        _controller.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
