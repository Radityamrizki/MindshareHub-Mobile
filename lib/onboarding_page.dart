import 'package:flutter/material.dart';
import 'onboarding_page_2.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Lingkaran kuning di belakang karakter
              Positioned(
                right: -80,
                top: 220,
                child: Container(
                  width: 270,
                  height: 282,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9FF00),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Gambar karakter overlap dengan lingkaran
              Positioned(
                right: 24,
                top: 126,
                child: Image.asset(
                  'assets/images/orang.png',
                  width: 196,
                  height: 403,
                  fit: BoxFit.contain,
                ),
              ),
              // Judul Discover
              Positioned(
                left: 32,
                top: 214,
                width: 185,
                height: 48,
                child: const Text(
                  'Discover',
                  style: TextStyle(
                    color: Color(0xFFB5E61D),
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                  ),
                ),
              ),
              // Judul Your
              Positioned(
                left: 70,
                top: 245,
                width: 185,
                height: 53,
                child: const Text(
                  'Your',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                  ),
                ),
              ),
              // Judul Joy.
              Positioned(
                left: 105,
                top: 275,
                width: 185,
                height: 53,
                child: const Text(
                  'Joy.',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                  ),
                ),
              ),
              // Deskripsi
              Positioned(
                left: 28,
                bottom: 220,
                right: 120,
                child: const Text(
                  'Everyone deserves to find\nhappiness in their own way',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
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
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(51),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingPage2(),
                      ),
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
