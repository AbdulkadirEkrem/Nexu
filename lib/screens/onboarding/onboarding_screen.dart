import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      icon: Icons.calendar_month_rounded,
      title: 'onboarding_slide1_title',
      description: 'onboarding_slide1_desc',
    ),
    OnboardingSlide(
      icon: Icons.people_alt_rounded,
      title: 'onboarding_slide2_title',
      description: 'onboarding_slide2_desc',
    ),
    OnboardingSlide(
      icon: Icons.notifications_active_rounded,
      title: 'onboarding_slide3_title',
      description: 'onboarding_slide3_desc',
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.primary : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Top Section with Logo and Skip Button
            Stack(
              children: [
                // Logo Section (Fixed at top, centered)
                SizedBox(
                  height: 60, // Fixed height for branding
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/logo_transparent.png',
                    fit: BoxFit.contain,
                  ),
                ),
                // Skip Button (Positioned at top right)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        tr('skip'),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // PageView (Expanded to fill remaining space)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _OnboardingSlideWidget(slide: _slides[index]);
                },
              ),
            ),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => _DotIndicator(isActive: index == _currentPage),
              ),
            ),

            const SizedBox(height: 32),

            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1
                        ? tr('get_started')
                        : tr('next'),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;

  OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _OnboardingSlideWidget extends StatelessWidget {
  final OnboardingSlide slide;

  const _OnboardingSlideWidget({required this.slide});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              size: 64,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            tr(slide.title),
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? Colors.white
                  : Theme.of(context).textTheme.titleLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            tr(slide.description),
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark
                  ? Colors.white70
                  : Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final bool isActive;

  const _DotIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey[400],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

