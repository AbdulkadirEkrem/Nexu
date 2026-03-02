import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/user_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/user_avatar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Helper function to localize user role/position
  static String _getLocalizedRole(String role) {
    final roleLower = role.toLowerCase();
    if (roleLower.contains('employee') || roleLower == 'employee') {
      return tr('role_employee');
    } else if (roleLower.contains('manager') || roleLower == 'manager') {
      return tr('role_manager');
    }
    // Fallback: return original role if no match
    return role;
  }

  /// Helper function to localize department strings
  static String _getLocalizedDepartment(String department) {
    final deptLower = department.toLowerCase();
    if (deptLower == 'general') {
      return tr('dept_general');
    } else if (deptLower == 'sales') {
      return tr('dept_sales');
    } else if (deptLower == 'engineering') {
      return tr('dept_engineering');
    } else if (deptLower == 'marketing') {
      return tr('dept_marketing');
    } else if (deptLower == 'hr' || deptLower == 'human resources') {
      return tr('dept_hr');
    } else if (deptLower == 'management') {
      return tr('dept_management');
    }
    return department; // Fallback to original if no match
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background uses theme (dark navy)
      body: SafeArea(
        child: Consumer4<UserProvider, CalendarProvider, RequestProvider, TeamProvider>(
          builder: (context, userProvider, calendarProvider, requestProvider, teamProvider, _) {
            final user = userProvider.currentUser;

            if (user == null) {
              return Center(
                child: Text(tr('no_user_data')),
              );
            }

            // Calculate stats
            final eventsCount = calendarProvider.events.length;
            final requestsCount = requestProvider.incomingRequests.length + requestProvider.outgoingRequests.length;
            final teamCount = teamProvider.colleagues.length;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  
                  // Header Section: Avatar, Name, Position, Edit Button
                  _HeaderSection(
                    user: user,
                    onEditTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Stats Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            count: eventsCount.toString(),
                            label: tr('stat_events'),
                            icon: Icons.event,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            count: requestsCount.toString(),
                            label: tr('stat_requests'),
                            icon: Icons.mark_chat_unread,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            count: teamCount > 0 ? teamCount.toString() : '12',
                            label: tr('stat_team'),
                            icon: Icons.people,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Contact Information Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _InfoSection(
                      title: tr('contact_info'),
                      children: [
                        _InfoListTile(
                          icon: Icons.email,
                          title: tr('email'),
                          subtitle: user.email,
                          subtitleFontSize: 15.0,
                        ),
                        Divider( 
                          height: 1,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white10
                              : Colors.grey[300],
                        ),
                        _InfoListTile(
                          icon: Icons.business,
                          title: tr('department'),
                          subtitle: ProfileScreen._getLocalizedDepartment(user.department),
                        ),
                        if (user.companyDomain != null && user.companyDomain!.isNotEmpty) ...[
                          Divider(
                          height: 1,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white10
                              : Colors.grey[300],
                        ),
                          _InfoListTile(
                            icon: Icons.domain,
                            title: tr('company_domain'),
                            subtitle: user.companyDomain!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App Settings Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _InfoSection(
                      title: tr('app_settings'),
                      children: [
                        _SettingsListTile(
                          icon: Icons.notifications_outlined,
                          title: tr('notifications'),
                          trailing: Switch(
                            value: true, // Dummy value
                            onChanged: (value) {
                              // Dummy action
                            },
                            activeColor: AppColors.primary,
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white10
                              : Colors.grey[300],
                        ),
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            final isDark = themeProvider.isDarkMode(context);
                            return _SettingsListTile(
                              icon: Icons.dark_mode_outlined,
                              title: tr('dark_mode'),
                              trailing: Switch(
                                value: isDark,
                                onChanged: (value) {
                                  themeProvider.toggleTheme(value);
                                },
                                activeColor: AppColors.secondary,
                              ),
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white10
                              : Colors.grey[300],
                        ),
                        _SettingsListTile(
                          icon: Icons.language,
                          title: tr('language'),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          onTap: () {
                            _showLanguageDialog(context);
                          },
                        ),
                        Divider(
                          height: 1,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white10
                              : Colors.grey[300],
                        ),
                        _SettingsListTile(
                          icon: Icons.help_outline,
                          title: tr('help_support'),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          onTap: () {
                            // Dummy action
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  tr('help_support_coming_soon'),
                                  style: GoogleFonts.inter(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextButton(
                      onPressed: () async {
                        // Show confirmation dialog
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              tr('log_out_confirm'),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            content: Text(
                              tr('log_out_question'),
                              style: GoogleFonts.inter(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  tr('cancel'),
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                ),
                                child: Text(
                                  tr('log_out_confirm'),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          await userProvider.logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        }
                      },
                      child: Text(
                        tr('logout'),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                  
                  // Version Text
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      tr('version'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final currentLocale = context.locale;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          tr('language'),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                'English',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              trailing: currentLocale.languageCode == 'en'
                  ? Icon(
                      Icons.check,
                      color: AppColors.secondary,
                    )
                  : null,
              onTap: () {
                context.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            Divider(
              height: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.grey[300],
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                'Türkçe',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              trailing: currentLocale.languageCode == 'tr'
                  ? Icon(
                      Icons.check,
                      color: AppColors.secondary,
                    )
                  : null,
              onTap: () {
                context.setLocale(const Locale('tr'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

}

class _HeaderSection extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEditTap;

  const _HeaderSection({
    required this.user,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar with Camera Badge
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: UserAvatar(
                user: user,
                radius: 50,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).cardColor,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          user.name,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        // Position
        Text(
          ProfileScreen._getLocalizedRole(user.position),
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        // Edit Profile Button
        OutlinedButton(
          onPressed: onEditTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            tr('edit_profile_title'),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.count,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.secondary,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _InfoListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double? subtitleFontSize;

  const _InfoListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.secondary,
        size: 22,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: subtitleFontSize ?? 15.0,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}

class _SettingsListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsListTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.secondary,
        size: 22,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}
