import 'package:flutter/material.dart';
import 'comment_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
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
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
              ),
            ),
          ],
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _PostItem(
              avatar: 'assets/images/profile.png',
              username: 'user12345',
              time: '12h',
              content: 'alhamdulillah yah',
              likeCount: 28,
              commentCount: 5,
              shareCount: 21,
              likedBy: 'user123 and user333',
              isLiked: true,
              showThread: true,
            ),
            _PostItem(
              avatar: 'assets/images/profile.png',
              username: 'User5234',
              time: '3h',
              content: 'Cara agar kuat mental gimana y?',
              likeCount: 46,
              commentCount: 18,
              shareCount: 363,
              likedBy: 'User43543',
              isLiked: true,
            ),
            _PostItem(
              avatar: 'assets/images/profile.png',
              username: 'User2352',
              time: '10h',
              content: 'kalian pernah ga takut kehilangan barang yg diimpikan?',
              likeCount: 1906,
              commentCount: 1249,
              shareCount: 7461,
              likedBy: 'User43543',
              isLiked: true,
            ),
            _PostItem(
              avatar: 'assets/images/profile.png',
              username: 'User24356',
              time: '3h',
              content: 'pertama kali pake mind min',
              likeCount: 46,
              commentCount: 18,
              shareCount: 363,
              likedBy: 'User43543',
              isLiked: true,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
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
  final String avatar;
  final String username;
  final String time;
  final String content;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final String likedBy;
  final bool isLiked;
  final bool showThread;

  const _PostItem({
    required this.avatar,
    required this.username,
    required this.time,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.likedBy,
    this.isLiked = false,
    this.showThread = false,
    Key? key,
  }) : super(key: key);

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
                        if (isLiked)
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 24,
                          ),
                        if (isLiked) const SizedBox(width: 4),
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600]),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 15)),
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
              const SizedBox(width: 36),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentPage(
                        postId: username,
                        postContent: content,
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 4),
              Text('$likeCount', style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 16),
              Icon(Icons.repeat_rounded, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('$commentCount', style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 16),
              Icon(
                Icons.favorite_border_rounded,
                size: 18,
                color: Colors.grey[600],
              ),
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
