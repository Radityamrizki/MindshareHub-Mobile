import 'package:flutter/material.dart';

class CommentPage extends StatefulWidget {
  final String postId;
  final String postContent;
  const CommentPage({
    super.key,
    required this.postId,
    required this.postContent,
  });

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final List<Map<String, String>> comments = [
    {
      'user': 'user123',
      'comment': 'Semangat ya!',
      'avatar': 'assets/images/profile.png',
    },
    {
      'user': 'user456',
      'comment': 'Keren banget!',
      'avatar': 'assets/images/profile.png',
    },
    {
      'user': 'user789',
      'comment': 'Aku juga pernah ngerasain',
      'avatar': 'assets/images/profile.png',
    },
  ];
  final TextEditingController _controller = TextEditingController();

  void _addComment(String text) {
    setState(() {
      comments.add({
        'user': 'You',
        'comment': text,
        'avatar': 'assets/images/profile.png',
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Comments',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.postContent,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final c = comments[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(c['avatar']!),
                  ),
                  title: Text(
                    c['user']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(c['comment']!),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF7C3AED),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _addComment(_controller.text.trim());
                    }
                  },
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
