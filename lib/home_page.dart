import 'package:flutter/material.dart';
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
                  onEdit:
                      isMine
                          ? () async {
                            final controller = TextEditingController(
                              text: p['content'],
                            );
                            List<String> tempMedia = List<String>.from(
                              p['media'] ?? [],
                            );
                            final result = await showDialog<
                              Map<String, dynamic>
                            >(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Edit Post'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: controller,
                                        maxLines: 3,
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 56,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: [
                                            ...[
                                              'assets/images/orang.png',
                                              'assets/images/tangan.png',
                                            ].map(
                                              (m) => GestureDetector(
                                                onTap: () {
                                                  if (tempMedia.contains(m)) {
                                                    tempMedia.remove(m);
                                                  } else {
                                                    tempMedia.add(m);
                                                  }
                                                  (context as Element)
                                                      .markNeedsBuild();
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                    right: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          tempMedia.contains(m)
                                                              ? const Color(
                                                                0xFF7C3AED,
                                                              )
                                                              : Colors
                                                                  .grey
                                                                  .shade300,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    child: Image.asset(
                                                      m,
                                                      width: 56,
                                                      height: 56,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
                                        Navigator.pop(context, {
                                          'content': controller.text,
                                          'media': tempMedia,
                                        });
                                      },
                                      child: const Text('Simpan'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (result != null) {
                              PostRepository.editPost(
                                index,
                                result['content'],
                                List<String>.from(result['media']),
                              );
                            }
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

class _PostItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
              CircleAvatar(backgroundImage: AssetImage(avatar), radius: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ':$time',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    if (likedBy.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          '$likedBy liked',
                          style: const TextStyle(
                            color: Color(0xFF7C3AED),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) onEdit!();
                    if (value == 'delete' && onDelete != null) onDelete!();
                  },
                  itemBuilder:
                      (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus'),
                          ),
                      ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 15)),
          if (media.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      media
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
          if (showThread)
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
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey[600],
                  size: 20,
                ),
                onPressed: onLike,
              ),
              Text('$likeCount', style: const TextStyle(fontSize: 13)),
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
                      builder: (context) => CommentPage(postIndex: index),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              Text('$commentCount', style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 16),
              Icon(Icons.repeat_rounded, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('$shareCount', style: const TextStyle(fontSize: 13)),
              const Spacer(),
              Icon(Icons.share_outlined, size: 18, color: Colors.grey[600]),
            ],
          ),
        ],
      ),
    );
  }
}
