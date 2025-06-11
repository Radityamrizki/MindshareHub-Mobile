import 'package:flutter/material.dart';
import 'home_page.dart';
import 'notification_page.dart';
import 'diary_page.dart';
import 'settings_page.dart';
import 'repositories/post_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, int> _trendingWords = {};

  @override
  void initState() {
    super.initState();
    _calculateTrendingWords();
  }

  void _calculateTrendingWords() {
    final posts = PostRepository.posts.value;
    final Map<String, int> wordFrequency = {};

    for (var post in posts) {
      final content = post['content'] as String? ?? '';
      final words = content.toLowerCase().split(' ');

      for (var word in words) {
        word = word.replaceAll(RegExp(r'[^\w\s]'), '');
        if (word.length >= 3) {
          wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
        }
      }
    }

    final sortedWords = wordFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    _trendingWords = Map.fromEntries(
        sortedWords.take(10).map((e) => MapEntry(e.key, e.value)));
    setState(() {});
  }

  void _performSearch(String query) {
    final posts = PostRepository.posts.value;
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = posts.where((post) {
          final content = (post['content'] as String? ?? '').toLowerCase();
          final username =
              (post['user']['username'] as String? ?? '').toLowerCase();
          final name = (post['user']['name'] as String? ?? '').toLowerCase();
          return content.contains(_searchQuery) ||
              username.contains(_searchQuery) ||
              name.contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _performSearch,
            decoration: InputDecoration(
              hintText: 'Cari...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: kGreyColor),
              prefixIcon: Icon(Icons.search, color: kGreyColor),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: kGreyColor),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding,
                vertical: 10,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchQuery.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: const Text(
                'Trending',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _trendingWords.entries.map((entry) {
                  return Container(
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      '${entry.key} (${entry.value})',
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ] else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(kDefaultPadding),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final post = _searchResults[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: kDefaultPadding),
                    elevation: 0,
                    color: kCardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(kDefaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  post['user']['profile_picture'] ?? '',
                                ),
                                backgroundColor: kPrimaryColor,
                                child: post['user']['profile_picture'] == null
                                    ? const Icon(Icons.person,
                                        color: Colors.white)
                                    : null,
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
                                        color: kTextColor,
                                      ),
                                    ),
                                    Text(
                                      '@${post['user']['username'] ?? ''}',
                                      style: const TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            post['content'] ?? '',
                            style: const TextStyle(
                              color: kTextColor,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: kGreyColor,
        backgroundColor: kBackgroundColor,
        elevation: 8,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DiaryPage()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
