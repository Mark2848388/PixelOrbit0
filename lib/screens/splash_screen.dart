import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      final progress = context.read<ProgressService>();
      if (!progress.tutorialCompleted) {
        Navigator.pushReplacementNamed(context, '/tutorial');
      } else {
        Navigator.pushReplacementNamed(context, '/menu');
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.smart_toy,
                        size: 64,
                        color: Colors.cyan,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'PIXEL ORBIT',
                  style: TextStyle(
                    fontSize: 22,
                    letterSpacing: 3,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.cyan.withOpacity(0.8),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Защити орбиту',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}