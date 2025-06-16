import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/post_repository.dart';
import 'providers/auth_provider.dart';
import 'edit_comment_page.dart';
import 'utils/date_formatter.dart';

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

  String getUsernameById(dynamic userId, Map<String, dynamic> post) {
    if (post['user'] != null &&
        post['user']['id'].toString() == userId.toString()) {
      return post['user']['username'] ?? '-';
    }
    // Jika ada daftar user lain, tambahkan pencarian di sini
    return '-';
  }

  String getNameById(dynamic userId, Map<String, dynamic> post) {
    if (post['user'] != null &&
        post['user']['id'].toString() == userId.toString()) {
      return post['user']['name'] ?? post['user']['username'] ?? 'Unknown User';
    }
    // Jika ada daftar user lain, tambahkan pencarian di sini
    return 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    final post = PostRepository.posts.value[widget.postIndex];
    final comments = List<Map<String, dynamic>>.from(post['comments'] ?? []);
    final user = context.read<AuthProvider>().user;
    if (user == null) return const SizedBox();

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
                    backgroundImage:
                        NetworkImage(post['user']?['profile_picture'] ?? ''),
                    onBackgroundImageError: (e, s) {
                      setState(() {});
                    },
                    child: (post['user']?['profile_picture'] == null ||
                            post['user']?['profile_picture'].isEmpty)
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                    backgroundColor: const Color(0xFF7C3AED),
                  ),
                  title: Text(
                    post['user']?['name'] ??
                        post['user']?['username'] ??
                        'Unknown User',
                  ),
                  subtitle: Text(post['content'] ?? ''),
                ),
                const Divider(),
                ...comments.map(
                  (c) {
                    final commentUserId = c['user_id'] ?? c['user']?['id'];
                    final isMine =
                        commentUserId.toString() == user['id'].toString();
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(c['user']?['profile_picture'] ?? ''),
                        onBackgroundImageError: (e, s) {
                          setState(() {});
                        },
                        child: (c['user']?['profile_picture'] == null ||
                                c['user']?['profile_picture'].isEmpty)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                        backgroundColor: const Color(0xFF7C3AED),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${isMine ? user['username'] : getUsernameById(commentUserId, post)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C3AED),
                              fontSize: 14,
                            ),
                          ),
                          if (c['created_at'] != null)
                            Text(
                              getRelativeTime(c['created_at']),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            c['comment'] ?? '',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'report') {
                            _showReportDialog(context, c);
                          } else if (value == 'edit' && isMine) {
                            final editedContent = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCommentPage(
                                    initialContent: c['comment']),
                              ),
                            );
                            if (editedContent != null) {
                              try {
                                await PostRepository.editComment(
                                  postId: post['id'].toString(),
                                  commentId: c['id'].toString(),
                                  comment: editedContent,
                                );
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error editing comment: $e')),
                                  );
                                }
                              }
                            }
                          } else if (value == 'delete' && isMine) {
                            try {
                              await PostRepository.deleteComment(
                                postId: post['id'].toString(),
                                commentId: c['id'].toString(),
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Komentar berhasil dihapus')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error deleting comment: $e')),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            if (isMine) ...[
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit Komentar'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Hapus Komentar'),
                              ),
                            ],
                            if (!isMine)
                              const PopupMenuItem<String>(
                                value: 'report',
                                child: Text('Laporkan Komentar'),
                              ),
                            const PopupMenuItem<String>(
                              value: 'cancel',
                              child: Text('Batal'),
                            ),
                          ];
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user['profile_picture'] ?? ''),
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
                  onPressed: () async {
                    if (_controller.text.trim().isNotEmpty) {
                      try {
                        await PostRepository.addComment(
                          postId: post['id'].toString(),
                          comment: _controller.text.trim(),
                        );
                        _controller.clear();
                        // Refresh the post to get updated comments
                        await PostRepository.fetchPosts();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error adding comment: $e')),
                          );
                        }
                      }
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

  void _showReportDialog(BuildContext context, Map<String, dynamic> comment) {
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
