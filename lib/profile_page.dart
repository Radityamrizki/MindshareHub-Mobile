import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'User12345';
  String bio = 'Just a dreamer and a doer.';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool isEditing = false;

  final List<Map<String, String>> posts = [
    {'content': 'alhamdulillah yah', 'time': '12h'},
    {'content': 'Cara agar kuat mental gimana y?', 'time': '3h'},
    {
      'content': 'kalian pernah ga takut kehilangan barang yg diimpikan?',
      'time': '10h',
    },
    {'content': 'pertama kali pake mind min', 'time': '3h'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = name;
    _bioController.text = bio;
  }

  void _saveProfile() {
    setState(() {
      name = _nameController.text;
      bio = _bioController.text;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF7C3AED)),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
          ),
          const SizedBox(height: 16),
          if (isEditing)
            Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            )
          else
            Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  bio,
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          const SizedBox(height: 24),
          const Divider(),
          const Text(
            'My Posts',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...posts.map(
            (p) => ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile.png'),
              ),
              title: Text(p['content']!),
              subtitle: Text(p['time']!),
            ),
          ),
        ],
      ),
    );
  }
}
