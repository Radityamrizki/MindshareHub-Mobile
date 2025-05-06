import 'package:flutter/material.dart';
import 'post_repository.dart';
import 'user_repository.dart';
import 'edit_comment_page.dart';

class CommentPage extends StatefulWidget {
  final int postIndex;
  const CommentPage({super.key, required this.postIndex});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedReason;
  final List<String> _reportReasons = [
    'Spam',
    'Kekerasan',
    'Penyebaran hoax',
    'Pelecehan',
    'Lainnya',
  ];

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
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'report') {
                          _showReportDialog(context, c);
                        } else if (value == 'edit' &&
                            c['username'] == user['username']) {
                          final editedContent = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCommentPage(
                                  initialContent: c['content']!),
                            ),
                          );
                          if (editedContent != null) {
                            setState(() {
                              PostRepository.editComment(
                                  widget.postIndex, c, editedContent);
                            });
                          }
                        } else if (value == 'delete' &&
                            c['username'] == user['username']) {
                          setState(() {
                            PostRepository.deleteComment(widget.postIndex, c);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Komentar berhasil dihapus')),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        if (c['username'] == user['username'])
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit Komentar'),
                          ),
                        if (c['username'] == user['username'])
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Hapus Komentar'),
                          ),
                        if (c['username'] != user['username'])
                          const PopupMenuItem<String>(
                            value: 'report',
                            child: Text('Laporkan Komentar'),
                          ),
                        const PopupMenuItem<String>(
                          value: 'cancel',
                          child: Text('Batal'),
                        ),
                      ],
                    ),
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
                      setState(() {
                        PostRepository.addComment(widget.postIndex, {
                          'name': user['name']!,
                          'username': user['username']!,
                          'avatar': user['avatar']!,
                          'content': _controller.text.trim(),
                          'time': 'now',
                        });
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

  void _showReportDialog(BuildContext context, Map<String, String> comment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Laporkan Komentar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih alasan Anda melaporkan komentar ini:'),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedReason,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedReason = newValue!;
                });
              },
              items:
                  _reportReasons.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle the report submission
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Komentar berhasil dilaporkan: $_selectedReason')),
              );
            },
            child: const Text('Laporkan'),
          ),
        ],
      ),
    );
  }
}
