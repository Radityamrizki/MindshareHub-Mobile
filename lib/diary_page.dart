import 'package:flutter/material.dart';
import 'notification_page.dart';
import 'home_page.dart';
// import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class DiaryEntry {
  final String title;
  final String content;
  DiaryEntry({required this.title, required this.content});
}

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  int _selectedIndex = 3; // Set to 3 since this is the diary tab
  List<DiaryEntry> diaryList = [
    DiaryEntry(title: 'Liburan ke Bali', content: 'Hari yang sangat seru di pantai Kuta bersama teman-teman!'),
    DiaryEntry(title: 'Belajar Flutter', content: 'Hari ini aku belajar membuat aplikasi diary dengan Flutter.'),
    DiaryEntry(title: 'Makan Enak', content: 'Makan bakso di warung langganan, rasanya mantap!'),
    DiaryEntry(title: 'Nonton Film', content: 'Nonton film favorit di bioskop bareng keluarga.'),
  ];
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(text: 'Your Diary');

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _addDiary(String title, String content) {
    setState(() {
      diaryList.insert(0, DiaryEntry(title: title, content: content));
      _contentController.clear();
      _titleController.text = 'Title';
    });
  }

  void _deleteDiary(int index) {
    setState(() {
      diaryList.removeAt(index);
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Don't do anything if tapping current tab
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        // Search page - TODO: Implement when available
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NotificationPage()),
        );
        break;
      case 3:
        // Already on diary page
        break;
    }
  }

  Widget _buildBody() {
    // Since this is the diary page, we only show diary content
    return _buildDiaryContent();
  }

  Widget _buildDiaryContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Isi Diary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF7B1FA2)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: 'Tuang isi diary kamu di sini...',
                hintStyle: const TextStyle(color: Color(0xFFB39DDB)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
              style: const TextStyle(fontSize: 18, color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double drawerWidth = MediaQuery.of(context).size.width * 0.7;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black, size: 32),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: SizedBox(
          height: 48,
          child: TextField(
            controller: _titleController,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      drawer: Row(
        children: [
          Container(
            width: drawerWidth,
            color: Colors.white,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 24, left: 8, right: 24, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 24),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Your Diary',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                      itemCount: diaryList.length,
                      itemBuilder: (context, index) {
                        final entry = diaryList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          alignment: Alignment.centerLeft,
                          child: Material(
                            color: const Color(0xFFF5EFFF),
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                final deleted = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiaryDetailPage(
                                      entry: entry,
                                      onDelete: () {
                                        Navigator.pop(context, true);
                                      },
                                    ),
                                  ),
                                );
                                if (deleted == true) {
                                  _deleteDiary(index);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                                child: Text(
                                  entry.title.length > 30
                                      ? entry.title.substring(0, 30) + '...'
                                      : entry.title,
                                  style: const TextStyle(
                                    color: Color(0xFF22223B),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side overlay
          Expanded(
            child: Container(
              color: const Color(0xFFF5F0FF),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 3 ? FloatingActionButton(
        backgroundColor: const Color(0xFF7B1FA2),
        shape: const CircleBorder(),
        onPressed: () {
          if (_contentController.text.trim().isNotEmpty && _titleController.text.trim().isNotEmpty) {
            _addDiary(_titleController.text.trim(), _contentController.text.trim());
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.edit_note, color: Colors.white, size: 28),
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(1.5),
                child: const Icon(Icons.add, size: 14, color: Color(0xFF7B1FA2)),
              ),
            ),
          ],
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            // Search page - TODO: Implement when available
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );
          } else if (index == 3) {
            // Already on diary page
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
    );
  }
}

class DiaryDetailPage extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onDelete;
  const DiaryDetailPage({super.key, required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF7B1FA2)),
        title: Text(
          entry.title,
          style: const TextStyle(color: Color(0xFF7B1FA2), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // Confirm delete
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Diary?'),
                  content: const Text('Yakin ingin menghapus diary ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onDelete();
                      },
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul diary
            Text(
              entry.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  entry.content,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
