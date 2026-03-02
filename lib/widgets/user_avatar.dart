import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/utils/avatar_utils.dart';

/// Reusable widget for displaying user avatars
/// Shows initials with a consistent color based on the user's name
class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double radius;
  final double? fontSize;
  final bool twoLetters;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 30,
    this.fontSize,
    this.twoLetters = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = AvatarUtils.getAvatarColor(user.name);
    final initials = AvatarUtils.getInitials(user.name, twoLetters: twoLetters);

    return CircleAvatar(
      radius: radius,
      backgroundColor: avatarColor,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: fontSize ?? radius * 0.7,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

