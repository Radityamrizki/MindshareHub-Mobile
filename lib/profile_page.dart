import 'package:flutter/material.dart';
import 'post_repository.dart';
import 'user_repository.dart';
import 'comment_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = UserRepository.currentUser;
  String bio =
      'Digital Goodies Team - Web & Mobile UI/UX development; Graphics; Illustrations';
  String profileImage = 'assets/images/Profile.png';

  void _editProfile() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        final TextEditingController bioController = TextEditingController(
          text: bio,
        );
        String tempImage = profileImage;
        return AlertDialog(
          title: const Text('Edit Profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    tempImage =
                        tempImage == 'assets/images/Profile.png'
                            ? 'assets/images/Profile2.png'
                            : 'assets/images/Profile.png';
                  });
                },
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage: AssetImage(tempImage),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
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
                  'bio': bioController.text,
                  'profileImage': tempImage,
                });
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        bio = result['bio'] ?? bio;
        profileImage = result['profileImage'] ?? profileImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF7C3AED)),
              onPressed: _editProfile,
            ),
          ],
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: AssetImage(profileImage),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      user['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      user['username']!,
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    bio,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const TabBar(
              labelColor: Color(0xFF7C3AED),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF7C3AED),
              tabs: [
                Tab(text: 'Postingan'),
                Tab(text: 'Balasan'),
                Tab(text: 'Media'),
                Tab(text: 'Suka'),
              ],
            ),
            SizedBox(
              height: 400,
              child: TabBarView(
                children: [
                  // Postingan
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: PostRepository.posts,
                    builder: (context, posts, _) {
                      final userPosts =
                          posts
                              .where((p) => p['username'] == user['username'])
                              .toList();
                      if (userPosts.isEmpty) {
                        return const Center(child: Text('Belum ada postingan'));
                      }
                      return ListView.builder(
                        itemCount: userPosts.length,
                        itemBuilder: (context, idx) {
                          final p = userPosts[idx];
                          final postIndex = posts.indexOf(p);
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: AssetImage(
                                          p['avatar'],
                                        ),
                                        radius: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        p['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        p['username'],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        ':${p['time']}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const Spacer(),
                                      PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          if (value == 'edit') {
                                            final controller =
                                                TextEditingController(
                                                  text: p['content'],
                                                );
                                            List<String> tempMedia =
                                                List<String>.from(
                                                  p['media'] ?? [],
                                                );
                                            final result = await showDialog<
                                              Map<String, dynamic>
                                            >(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    'Edit Post',
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      TextField(
                                                        controller: controller,
                                                        maxLines: 3,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      SizedBox(
                                                        height: 56,
                                                        child: ListView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          children: [
                                                            ...[
                                                              'assets/images/orang.png',
                                                              'assets/images/tangan.png',
                                                            ].map(
                                                              (
                                                                m,
                                                              ) => GestureDetector(
                                                                onTap: () {
                                                                  if (tempMedia
                                                                      .contains(
                                                                        m,
                                                                      )) {
                                                                    tempMedia
                                                                        .remove(
                                                                          m,
                                                                        );
                                                                  } else {
                                                                    tempMedia
                                                                        .add(m);
                                                                  }
                                                                  (context
                                                                          as Element)
                                                                      .markNeedsBuild();
                                                                },
                                                                child: Container(
                                                                  margin:
                                                                      const EdgeInsets.only(
                                                                        right:
                                                                            8,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                      color:
                                                                          tempMedia.contains(m)
                                                                              ? const Color(
                                                                                0xFF7C3AED,
                                                                              )
                                                                              : Colors.grey.shade300,
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
                                                                      height:
                                                                          56,
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
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
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text(
                                                        'Batal',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context, {
                                                          'content':
                                                              controller.text,
                                                          'media': tempMedia,
                                                        });
                                                      },
                                                      child: const Text(
                                                        'Simpan',
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                            if (result != null) {
                                              PostRepository.editPost(
                                                postIndex,
                                                result['content'],
                                                List<String>.from(
                                                  result['media'],
                                                ),
                                              );
                                            }
                                          } else if (value == 'delete') {
                                            PostRepository.deletePost(
                                              postIndex,
                                            );
                                          }
                                        },
                                        itemBuilder:
                                            (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Hapus'),
                                              ),
                                            ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    p['content'],
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  if ((p['media'] as List).isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: SizedBox(
                                        height: 80,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children:
                                              (p['media'] as List)
                                                  .map(
                                                    (m) => Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            right: 8,
                                                          ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
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
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          p['isLiked']
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              p['isLiked']
                                                  ? Colors.red
                                                  : Colors.grey[600],
                                          size: 20,
                                        ),
                                        onPressed:
                                            () => PostRepository.toggleLike(
                                              postIndex,
                                            ),
                                      ),
                                      Text(
                                        '${p['likeCount']}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
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
                                              builder:
                                                  (context) => CommentPage(
                                                    postIndex: postIndex,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${p['commentCount']}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.repeat_rounded,
                                        size: 18,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${p['shareCount']}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.share_outlined,
                                        size: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Balasan
                  const Center(child: Text('Belum ada balasan')), // Dummy
                  // Media
                  const Center(child: Text('Belum ada media')), // Dummy
                  // Suka
                  const Center(child: Text('Belum ada yang disukai')), // Dummy
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
