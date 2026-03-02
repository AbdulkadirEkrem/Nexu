import 'package:flutter/material.dart';

/// Predefined avatar configurations
class AppAvatar {
  final int id;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const AppAvatar({
    required this.id,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}

/// List of predefined avatars
class AppAvatars {
  static const List<AppAvatar> avatars = [
    AppAvatar(
      id: 0,
      icon: Icons.person,
      backgroundColor: Color(0xFF2196F3), // Blue
      iconColor: Colors.white,
    ),
    AppAvatar(
      id: 1,
      icon: Icons.person_outline,
      backgroundColor: Color(0xFF4CAF50), // Green
      iconColor: Colors.white,
    ),
    AppAvatar(
      id: 2,
      icon: Icons.account_circle,
      backgroundColor: Color(0xFFFF9800), // Orange
      iconColor: Colors.white,
    ),
    AppAvatar(
      id: 3,
      icon: Icons.face,
      backgroundColor: Color(0xFF9C27B0), // Purple
      iconColor: Colors.white,
    ),
    AppAvatar(
      id: 4,
      icon: Icons.person_pin,
      backgroundColor: Color(0xFFF44336), // Red
      iconColor: Colors.white,
    ),
    AppAvatar(
      id: 5,
      icon: Icons.account_box,
      backgroundColor: Color(0xFF00BCD4), // Cyan
      iconColor: Colors.white,
    ),
    AppAvatar(
      id: 6,
      icon: Icons.sentiment_satisfied,
      backgroundColor: Color(0xFFFFEB3B), // Yellow
      iconColor: Colors.black87,
    ),
    AppAvatar(
      id: 7,
      icon: Icons.verified_user,
      backgroundColor: Color(0xFF795548), // Brown
      iconColor: Colors.white,
    ),
  ];

  /// Get avatar by ID, returns null if not found
  static AppAvatar? getAvatarById(int? id) {
    if (id == null) return null;
    try {
      return avatars.firstWhere((avatar) => avatar.id == id);
    } catch (e) {
      return null;
    }
  }
}

