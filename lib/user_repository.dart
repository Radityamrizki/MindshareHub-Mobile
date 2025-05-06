class UserRepository {
  static final List<Map<String, String>> users = [
    {
      'name': 'User 766',
      'username': '@user766',
      'avatar': 'assets/images/Profile.png',
    },
    {
      'name': 'User 5234',
      'username': '@user5234',
      'avatar': 'assets/images/Profile2.png',
    },
    // Tambahkan user lain jika perlu
  ];

  // Untuk demo, user yang sedang login adalah User 766
  static Map<String, String> get currentUser => users[0];
}
