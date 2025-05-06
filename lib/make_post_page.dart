import 'package:flutter/material.dart';
import 'user_repository.dart';

class MakePostPage extends StatefulWidget {
  final Function({
    required String content,
    required String avatar,
    required String name,
    required String username,
    required List<String> media,
  })
  onPost;
  const MakePostPage({super.key, required this.onPost});

  @override
  State<MakePostPage> createState() => _MakePostPageState();
}

class _MakePostPageState extends State<MakePostPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> availableMedia = [
    'assets/images/orang.png',
    'assets/images/tangan.png',
    // Tambahkan asset media lain di sini jika ada
  ];
  List<String> selectedMedia = [];

  @override
  Widget build(BuildContext context) {
    final user = UserRepository.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'make post',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(user['avatar']!),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "What's happening?",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Pilih media
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...availableMedia.map(
                    (m) => GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selectedMedia.contains(m)) {
                            selectedMedia.remove(m);
                          } else {
                            selectedMedia.add(m);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                selectedMedia.contains(m)
                                    ? const Color(0xFF7C3AED)
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.image, color: Color(0xFF7C3AED)),
                const SizedBox(width: 16),
                Icon(Icons.gif_box, color: Color(0xFF7C3AED)),
                const SizedBox(width: 16),
                Icon(Icons.flag, color: Color(0xFF7C3AED)),
                const SizedBox(width: 16),
                Icon(Icons.location_on, color: Color(0xFF7C3AED)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      widget.onPost(
                        content: _controller.text.trim(),
                        avatar: user['avatar']!,
                        name: user['name']!,
                        username: user['username']!,
                        media: List<String>.from(selectedMedia),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
