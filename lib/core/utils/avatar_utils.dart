import 'package:flutter/material.dart';

/// Utility class for generating consistent avatar colors based on names
class AvatarUtils {
  /// Predefined color palette for avatars
  /// These colors are vibrant and work well with white text
  static const List<Color> _avatarColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFFF44336), // Red
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE91E63), // Pink
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF3F51B5), // Indigo
    Color(0xFF009688), // Teal
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF00ACC1), // Light Blue
    Color(0xFF8BC34A), // Light Green
    Color(0xFFFFC107), // Amber
  ];

  /// Generates a consistent color for a given name
  /// The same name will always return the same color
  static Color getAvatarColor(String name) {
    if (name.isEmpty) {
      return _avatarColors[0];
    }

    // Generate a hash from the name
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }

    // Use the hash to select a color from the palette
    // Make sure the index is positive
    final index = hash.abs() % _avatarColors.length;
    return _avatarColors[index];
  }

  /// Gets the initials from a name (first letter, optionally second letter)
  static String getInitials(String name, {bool twoLetters = false}) {
    if (name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    
    if (twoLetters && parts.length > 1) {
      // Return first letter of first and last name
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    
    // Return first letter of first name
    return parts.first[0].toUpperCase();
  }
}

