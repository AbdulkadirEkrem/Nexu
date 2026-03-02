import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to login after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.primary : AppColors.background,
      body: Center(
        child: SizedBox(
          width: 200, // Adjust height/width as needed, e.g., 200 for a balanced look
          height: 200,
          child: Image.asset(
            'assets/images/logo_transparent.png',
            fit: BoxFit.contain, // This ensures the entire logo is visible within the 200x200 box
          ),
        ),
      ),
    );
  }
}

