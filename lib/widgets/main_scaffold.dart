import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constants/app_colors.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final String location;

  const MainScaffold({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _getSelectedIndexFromLocation(widget.location);
  }

  @override
  void didUpdateWidget(MainScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _selectedIndex = _getSelectedIndexFromLocation(widget.location);
    }
  }

  int _getSelectedIndexFromLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/team')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/calendar');
        break;
      case 2:
        context.go('/team');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  Widget _buildNavItem(IconData icon, String label, int index, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (index == _selectedIndex) {
      // Active item: White icon only (inside the bubble)
      return Icon(
        icon,
        size: 30,
        color: Colors.white,
      );
    } else {
      // Inactive item: Grey icon with label (on the bar)
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: isDark ? const Color(0xFF252F48) : Colors.white, // Dark card color in dark mode, white in light
        buttonBackgroundColor: isDark ? AppColors.secondary : AppColors.primary, // Amber in dark, Navy in light
        height: 75.0,
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          _buildNavItem(Icons.home, tr('nav_home'), 0, context),
          _buildNavItem(Icons.calendar_month, tr('nav_calendar'), 1, context),
          _buildNavItem(Icons.people, tr('nav_team'), 2, context),
          _buildNavItem(Icons.person, tr('nav_profile'), 3, context),
        ],
      ),
    );
  }
}

