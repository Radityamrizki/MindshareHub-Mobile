import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'repositories/post_repository.dart';
import 'comment_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);
      final userData = await ApiService.getUserProfile();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null) {
      return const Scaffold(
        body: Center(child: Text('Error loading profile')),
      );
    }

    return DefaultTabController(
      length: 3,
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
              icon: const Icon(Icons.settings, color: Color(0xFF7C3AED)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadUserData,
          child: ListView(
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
                        backgroundImage:
                            NetworkImage(_userData!['profile_picture'] ?? ''),
                        onBackgroundImageError: (e, s) {},
                        child: _userData!['profile_picture'] == null
                            ? const Icon(Icons.person,
                                size: 48, color: Colors.white)
                            : null,
                        backgroundColor: const Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        _userData!['name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '@${_userData!['username'] ?? ''}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 15),
                      ),
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
                  Tab(text: 'Komentar'),
                  Tab(text: 'Disukai'),
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
                        final userPosts = posts
                            .where((p) =>
                                p['user']['id'].toString() ==
                                _userData!['id'].toString())
                            .toList();
                        if (userPosts.isEmpty) {
                          return const Center(
                              child: Text('Belum ada postingan'));
                        }
                        return ListView.builder(
                          itemCount: userPosts.length,
                          itemBuilder: (context, index) {
                            final post = userPosts[index];
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
                                    Text(
                                      post['content'] ?? '',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    if (post['image_path'] != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Image.network(
                                          post['image_path'],
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            post['is_liked'] ?? false
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: post['is_liked'] ?? false
                                                ? Colors.red
                                                : Colors.grey[600],
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              PostRepository.toggleLike(
                                            post['id'].toString(),
                                          ),
                                        ),
                                        Text(
                                          '${post['likes_count'] ?? 0}',
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
                                                builder: (context) =>
                                                    CommentPage(
                                                  postIndex:
                                                      posts.indexOf(post),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        Text(
                                          '${post['total_comments'] ?? 0}',
                                          style: const TextStyle(fontSize: 13),
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
                    // Komentar
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: ApiService.getComments(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('Belum ada komentar'));
                        }
                        final userComments = snapshot.data!
                            .where((comment) =>
                                comment['user']['id'].toString() ==
                                _userData!['id'].toString())
                            .toList();
                        if (userComments.isEmpty) {
                          return const Center(
                              child: Text('Belum ada komentar'));
                        }
                        return ListView.builder(
                          itemCount: userComments.length,
                          itemBuilder: (context, index) {
                            final comment = userComments[index];
                            return ListTile(
                              title: Text(comment['comment'] ?? ''),
                              subtitle: Text(
                                  'pada postingan ${comment['post']['content'] ?? ''}'),
                            );
                          },
                        );
                      },
                    ),
                    // Disukai
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: PostRepository.posts,
                      builder: (context, posts, _) {
                        final likedPosts = posts
                            .where((post) => post['is_liked'] ?? false)
                            .toList();
                        if (likedPosts.isEmpty) {
                          return const Center(
                              child: Text('Belum ada postingan yang disukai'));
                        }
                        return ListView.builder(
                          itemCount: likedPosts.length,
                          itemBuilder: (context, index) {
                            final post = likedPosts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(post['content'] ?? ''),
                                subtitle:
                                    Text('oleh ${post['user']['name'] ?? ''}'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
