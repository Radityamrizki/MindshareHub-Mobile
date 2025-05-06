import 'package:flutter/material.dart';
import 'package:mindshare_hub/edit_page.dart';
import 'comment_page.dart';
import 'profile_page.dart';
import 'make_post_page.dart';
import 'post_repository.dart';
import 'user_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = UserRepository.currentUser;
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
                  backgroundImage: AssetImage(currentUser['avatar']!),
                ),
              ),
            ),
          ],
          automaticallyImplyLeading: false,
        ),
        body: ValueListenableBuilder<List<Map<String, dynamic>>>( 
          valueListenable: PostRepository.posts,
          builder: (context, posts, _) {
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final p = posts[index];
                final isMine = p['username'] == currentUser['username'];
                return _PostItem(
                  index: index,
                  avatar: p['avatar'],
                  name: p['name'],
                  username: p['username'],
                  time: p['time'],
                  content: p['content'],
                  media: List<String>.from(p['media'] ?? []),
                  likeCount: p['likeCount'],
                  commentCount: p['commentCount'],
                  shareCount: p['shareCount'],
                  likedBy: p['likedBy'],
                  isLiked: p['isLiked'],
                  showThread: p['showThread'],
                  onLike: () => PostRepository.toggleLike(index),
                  onDelete:
                      isMine ? () => PostRepository.deletePost(index) : null,
                  onEdit: isMine
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditPage(
                              initialContent: p['content'],
                              initialMedia: List<String>.from(p['media']),
                              onSave: (updatedContent, updatedMedia) {
                                PostRepository.editPost(
                                  index,
                                  updatedContent,
                                  updatedMedia,
                                );
                              },
                            ),
                          ),
                        );
                      }
                    : null,
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MakePostPage(
                      onPost: ({
                        required content,
                        required avatar,
                        required name,
                        required username,
                        required media,
                      }) {
                        PostRepository.addPost(
                          content: content,
                          avatar: avatar,
                          name: name,
                          username: username,
                          media: media,
                        );
                      },
                    ),
              ),
            );
          },
          backgroundColor: const Color(0xFF7C3AED),
          child: const Icon(Icons.edit, color: Colors.white),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF7C3AED),
          unselectedItemColor: Colors.black54,
          showSelectedLabels: false,
          showUnselectedLabels: false,
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
              icon: Icon(Icons.menu_rounded),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }
}

class _PostItem extends StatefulWidget {
  final int index;
  final String avatar;
  final String name;
  final String username;
  final String time;
  final String content;
  final List<String> media;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final String likedBy;
  final bool isLiked;
  final bool showThread;
  final VoidCallback? onLike;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const _PostItem({
    required this.index,
    required this.avatar,
    required this.name,
    required this.username,
    required this.time,
    required this.content,
    required this.media,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.likedBy,
    this.isLiked = false,
    this.showThread = false,
    this.onLike,
    this.onDelete,
    this.onEdit,
    super.key,
  });

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<_PostItem> {
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
    final currentUser = UserRepository.currentUser;
    final isMine = widget.username == currentUser['username'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEFEFEF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: AssetImage(widget.avatar), radius: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.username,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ':${widget.time}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit' && widget.onEdit != null) widget.onEdit!();
                  if (value == 'delete' && widget.onDelete != null) widget.onDelete!();
                  if (value == 'report') {
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
                              items: _reportReasons.map<DropdownMenuItem<String>>((String value) {
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
                                SnackBar(content: Text('Postingan berhasil dilaporkan: $_selectedReason')),
                              );
                            },
                            child: const Text('Laporkan'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  if (isMine)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                  if (isMine)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Hapus'),
                    ),
                  if (!isMine)
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Laporkan'),
                    ),
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Text('Batal'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.content, style: const TextStyle(fontSize: 15)),
          if (widget.media.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: widget.media
                      .map(
                        (m) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              m,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          if (widget.showThread)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 36.0),
              child: Text(
                'Show this thread',
                style: const TextStyle(
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  widget.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.isLiked ? Colors.red : Colors.grey[600],
                  size: 20,
                ),
                onPressed: widget.onLike,
              ),
              Text('${widget.likeCount}', style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: Color(0xFF7C3AED),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentPage(postIndex: widget.index),
                    ),
                  );
                },
              ),
              Text('${widget.commentCount}', style: const TextStyle(fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
