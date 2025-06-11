import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await ApiService.logout();
      if (context.mounted) {
        // Clear auth state
        context.read<AuthProvider>().clearUser();
        // Navigate to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.notifications_outlined,
                color: Color(0xFF7C3AED)),
            title: const Text('Notifikasi'),
            trailing: Switch(
              value: true, // TODO: Implement notification settings
              onChanged: (value) {},
              activeColor: const Color(0xFF7C3AED),
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.dark_mode_outlined, color: Color(0xFF7C3AED)),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: false, // TODO: Implement dark mode
              onChanged: (value) {},
              activeColor: const Color(0xFF7C3AED),
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.language_outlined, color: Color(0xFF7C3AED)),
            title: const Text('Bahasa'),
            trailing: const Text('Indonesia'),
            onTap: () {
              // TODO: Implement language settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFF7C3AED)),
            title: const Text('Bantuan'),
            onTap: () {
              // TODO: Implement help page
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF7C3AED)),
            title: const Text('Tentang'),
            onTap: () {
              // TODO: Implement about page
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}
