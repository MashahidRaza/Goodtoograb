import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    // Snappy launch: 1.5 seconds total for branding without being annoying
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Professional cross-fade transition
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Animation: Beyond Imagination
            // Elastic Pop-in + Subtle Rotation + Shimmer
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            )
                .animate()
                .scale(
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1.0, 1.0),
                )
                .rotate(
                  duration: 800.ms,
                  begin: -0.1,
                  end: 0,
                )
                .fadeIn(duration: 400.ms)
                .then(delay: 100.ms)
                .shimmer(duration: 1200.ms, color: AppColors.primary.withOpacity(0.2)),
            
            const SizedBox(height: 30),
            
            // Text Animation: Elegant Slide + Fade
            const Text(
              'GoodTooGrab',
              style: TextStyle(
                color: Color(0xFF006A4E), // Professional Primary Green
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}
