import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';
import 'features/onboarding/presentation/pages/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GoodTooGrabApp());
}

class GoodTooGrabApp extends StatelessWidget {
  const GoodTooGrabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoodTooGrab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.background,
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).copyWith(
          displayLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          titleLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          bodyMedium: GoogleFonts.inter(color: AppColors.textPrimary),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
