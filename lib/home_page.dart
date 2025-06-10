import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_page.dart';
import 'comment_page.dart';
import 'profile_page.dart';
import 'make_post_page.dart';
import 'repositories/post_repository.dart';
import 'providers/auth_provider.dart';
import 'notification_page.dart';
import 'diary_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _selectedReason;
  final List<String> _reportReasons = [
    'Spam',
    'Kekerasan',
    'Penyebaran hoax',
    'Pelecehan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      await PostRepository.fetchPosts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading posts: $e')),
        );
      }
    }
  }

  void _showReportDialog(BuildContext context, Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Laporkan Postingan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih alasan Anda melaporkan postingan ini:'),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Postingan berhasil dilaporkan: $_selectedReason'),
                ),
              );
            },
            child: const Text('Laporkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser == null) return const SizedBox();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Home',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      NetworkImage(currentUser['profile_picture'] ?? ''),
                  onBackgroundImageError: (e, s) {
                    setState(() {});
                  },
                  child: currentUser['profile_picture'] == null ||
                          currentUser['profile_picture'].isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                  backgroundColor: const Color(0xFF7C3AED),
                ),
              ),
            ),
          ],
          automaticallyImplyLeading: false,
        ),
        body: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: PostRepository.posts,
          builder: (context, posts, _) {
            if (posts.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return RefreshIndicator(
              onRefresh: _loadPosts,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final isMine = post['user']['id'].toString() ==
                      currentUser['id'].toString();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFF7C3AED),
                                child: post['user']?['profile_picture'] != null
                                    ? ClipOval(
                                        child: Image.network(
                                          post['user']?['profile_picture'] ??
                                              '',
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(Icons.person,
                                                      color: Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.person,
                                        color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post['user']['name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '@${post['user']['username'] ?? ''}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          post['created_at'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_horiz),
                                onSelected: (value) async {
                                  if (value == 'edit' && isMine) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditPage(
                                          initialContent: post['content'] ?? '',
                                          initialMedia:
                                              post['image_path'] != null
                                                  ? [post['image_path']]
                                                  : [],
                                          onSave:
                                              (updatedContent, updatedMedia) {
                                            PostRepository.editPost(
                                              post['id'].toString(),
                                              updatedContent,
                                              updatedMedia.isNotEmpty
                                                  ? updatedMedia.first
                                                  : null,
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  } else if (value == 'delete' && isMine) {
                                    try {
                                      await PostRepository.deletePost(
                                          post['id'].toString());
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Post deleted successfully')),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error deleting post: $e')),
                                        );
                                      }
                                    }
                                  } else if (value == 'report' && !isMine) {
                                    _showReportDialog(context, post);
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (isMine) ...[
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Edit Postingan'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Hapus Postingan'),
                                    ),
                                  ],
                                  if (!isMine)
                                    const PopupMenuItem<String>(
                                      value: 'report',
                                      child: Text('Laporkan Postingan'),
                                    ),
                                  const PopupMenuItem<String>(
                                    value: 'cancel',
                                    child: Text('Batal'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (post['content'] != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 12,
                              bottom: 12,
                            ),
                            child: Text(post['content']!),
                          ),
                        if (post['image_path'] != null)
                          Container(
                            width: double.infinity,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                post['image_path'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 12,
                            bottom: 12,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    await PostRepository.toggleLike(
                                        post['id'].toString());
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Error toggling like: $e')),
                                      );
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      post['is_liked']
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 20,
                                      color: post['is_liked']
                                          ? Colors.red
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${post['likes_count'] ?? 0}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CommentPage(postIndex: index),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.mode_comment_outlined,
                                      size: 20,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${post['total_comments'] ?? 0}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MakePostPage(
                  onPost: ({
                    required String content,
                    required String avatar,
                    required String name,
                    required String username,
                    required List<String> media,
                  }) async {
                    try {
                      await PostRepository.addPost(
                        content: content,
                        imagePath: media.isNotEmpty ? media.first : null,
                      );
                      await _loadPosts();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error creating post: $e')),
                        );
                      }
                    }
                  },
                ),
              ),
            );
          },
          backgroundColor: const Color(0xFF7C3AED),
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF7C3AED),
          unselectedItemColor: Colors.black54,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == _selectedIndex) return;
            setState(() {
              _selectedIndex = index;
            });

            switch (index) {
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DiaryPage(),
                  ),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_rounded),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Diary',
            ),
          ],
        ),
      ),
    );
  }
}
