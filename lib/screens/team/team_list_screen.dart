import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/team_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/user_avatar.dart';

class TeamListScreen extends StatefulWidget {
  const TeamListScreen({super.key});

  @override
  State<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize team provider when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);
      final user = userProvider.currentUser;
      if (user != null) {
        teamProvider.initialize(user.id);
      }
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    return Scaffold(
      // Background uses theme (dark navy)
      body: Consumer<TeamProvider>(
        builder: (context, teamProvider, _) {
          // Filter out current user and apply search filter
          final filteredColleagues = teamProvider.colleagues
              .where((member) {
                if (currentUser != null && member.id == currentUser.id) {
                  return false;
                }
                if (_searchQuery.isEmpty) return true;
                return member.name.toLowerCase().contains(_searchQuery) ||
                    member.position.toLowerCase().contains(_searchQuery) ||
                    member.department.toLowerCase().contains(_searchQuery);
              })
              .toList();

          return CustomScrollView(
            slivers: [
              // SliverAppBar - Large title, floating
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: false,
                // Background uses theme
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    tr('team'),
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: tr('search_colleagues'),
                        hintStyle: GoogleFonts.inter(
                          color: AppColors.textHint,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                ),
              ),

              // Loading State
              if (teamProvider.isLoading && teamProvider.colleagues.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),

              // Empty State
              if (!teamProvider.isLoading && filteredColleagues.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? tr('no_team_members')
                              : tr('no_results'),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? tr('colleagues_will_appear')
                              : tr('try_different_search'),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              // Team Members List
              if (!teamProvider.isLoading && filteredColleagues.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final member = filteredColleagues[index];
                        return TeamMemberCard(
                          member: member,
                          onTap: () {
                            context.push('/create-meeting', extra: member);
                          },
                        );
                      },
                      childCount: filteredColleagues.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class TeamMemberCard extends StatelessWidget {
  final UserModel member;
  final VoidCallback onTap;

  const TeamMemberCard({
    super.key,
    required this.member,
    required this.onTap,
  });

  /// Helper function to localize role/position strings
  static String _getLocalizedRole(String role) {
    final roleLower = role.toLowerCase();
    if (roleLower.contains('employee') || roleLower == 'employee') {
      return tr('role_employee');
    } else if (roleLower.contains('manager') || roleLower == 'manager') {
      return tr('role_manager');
    }
    return role; // Fallback to original if no match
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left: Large Avatar
                UserAvatar(
                  user: member,
                  radius: 28,
                ),
                const SizedBox(width: 16),
                // Middle: Name, Position, Department
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        TeamMemberCard._getLocalizedRole(member.position),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      if (member.department.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            TeamMemberCard._getLocalizedDepartment(member.department),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Right: Calendar/Request Button
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: AppColors.secondary, // Amber for visibility
                    size: 24,
                  ),
                  onPressed: onTap,
                  tooltip: tr('request_meeting'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
