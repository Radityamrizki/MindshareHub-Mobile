import 'package:flutter/material.dart';
import 'home_page.dart';

class TanganPage extends StatelessWidget {
  const TanganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Lingkaran kuning kanan bawah
              Positioned(
                right: -80,
                bottom: -60,
                child: Container(
                  width: 270,
                  height: 282,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9FF00),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Gambar tangan
              Positioned(
                top: 60,
                right: 40,
                child: Image.asset(
                  'assets/images/tangan.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              // Teks judul
              const Positioned(
                left: 28,
                top: 220,
                child: SizedBox(
                  width: 220,
                  child: Text(
                    'Your Safe\nSpace to\nShare',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              // Indikator dan Skip
              Positioned(
                left: 28,
                bottom: 100,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(51),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Text(
                      'Skip',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol panah kanan bawah
              Positioned(
                right: 32,
                bottom: 80,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Color(0xFF7C3AED),
                    elevation: 0,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              // Tombol back di kiri atas
              Positioned(
                left: 8,
                top: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 28),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
