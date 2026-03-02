import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/user_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/request_provider.dart';
import '../../models/event_model.dart';
// import '../../widgets/user_avatar.dart'; // Eğer bu dosya yoksa hata vermemesi için kapattım, aşağıda CircleAvatar kullandım.
import '../../core/constants/app_colors.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDataInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Kullanıcı verisi geldiği an takvimi ve istekleri yükle
    final userProvider = Provider.of<UserProvider>(context);
    if (userProvider.currentUser != null && !_isDataInitialized) {
      print("🚀 Home: Kullanıcı tespit edildi, veriler çekiliyor...");
      final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
      final requestProvider = Provider.of<RequestProvider>(context, listen: false);
      
      calendarProvider.initialize(userProvider.currentUser!.id);
      requestProvider.initialize(userProvider.currentUser!.id);
      
      setState(() {
        _isDataInitialized = true;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return tr('good_morning');
    if (hour < 17) return tr('good_afternoon');
    return tr('good_evening');
  }

  int _getTodayEventsCount(List<EventModel> events) {
    final today = DateTime.now();
    return events.where((event) {
      return event.startTime.year == today.year &&
          event.startTime.month == today.month &&
          event.startTime.day == today.day;
    }).length;
  }

  List<EventModel> _getUpcomingEvents(List<EventModel> events) {
    final now = DateTime.now();
    final upcoming = events
        .where((event) => event.startTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming.take(3).toList();
  }

  // Güvenli saat formatı (Model'e ihtiyaç duymadan)
  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    // Durum 1: Kullanıcı yükleniyor
    if (userProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Durum 2: Kullanıcı verisi hala yok (Hata veya Gecikme)
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(tr('user_data_error')),
        ),
      );
    }

    // Durum 3: Her şey yolunda, Dashboard'u çiz
    return Scaffold(
      // Background uses theme (dark navy)
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.name,
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // UserAvatar widget'ın varsa onu aç, yoksa bu çalışır:
                    InkWell(
                      onTap: () => context.go('/profile'),
                      borderRadius: BorderRadius.circular(28),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontSize: 20), // Avatar text stays white
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. STATS GRID
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Consumer<CalendarProvider>(
                        builder: (context, calendarProvider, _) {
                          final todayCount = _getTodayEventsCount(calendarProvider.events);
                          return _StatCard(
                            title: tr('events_today'),
                            count: todayCount,
                            icon: Icons.calendar_today_rounded,
                            color: AppColors.primary,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer<RequestProvider>(
                        builder: (context, requestProvider, _) {
                          return _StatCard(
                            title: tr('pending_requests'),
                            count: requestProvider.incomingRequests.length,
                            icon: Icons.notifications_rounded,
                            color: AppColors.secondary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationsScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // 3. UP NEXT TITLE
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  tr('upcoming_schedule'),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 4. UPCOMING LIST
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: Consumer<CalendarProvider>(
                builder: (context, calendarProvider, _) {
                  final upcomingEvents = _getUpcomingEvents(calendarProvider.events);
                  
                  if (upcomingEvents.isEmpty) {
                    return SliverToBoxAdapter(child: _EmptyUpcomingState());
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = upcomingEvents[index];
                        // Saat formatını burada güvenli yapıyoruz
                        final startTime = _formatTime(event.startTime);
                        final endTime = _formatTime(event.endTime);
                        
                        return _UpcomingEventCard(
                          event: event, 
                          timeString: "$startTime - $endTime",
                          startTimeOnly: startTime,
                        );
                      },
                      childCount: upcomingEvents.length,
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// --- YARDIMCI WIDGETLAR ---

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondary, size: 30),
          const SizedBox(height: 20),
          Text(
            count.toString(),
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

class _UpcomingEventCard extends StatelessWidget {
  final EventModel event;
  final String timeString;
  final String startTimeOnly;

  const _UpcomingEventCard({
    required this.event,
    required this.timeString,
    required this.startTimeOnly,
  });

  /// Helper function to get icon based on event type
  /// Returns Icons.edit_note for notes/tasks, Icons.calendar_month for meetings
  IconData _getEventIcon(EventType type) {
    // Check if type is note (as string) or task/reminder (as enum)
    final typeString = type.toString().toLowerCase();
    if (typeString.contains('note') || type == EventType.task || type == EventType.reminder) {
      return Icons.edit_note; // Note icon for tasks/notes
    }
    // Default to calendar icon for meetings and personal events
    return Icons.calendar_month; // Calendar icon for meetings
  }

  /// Helper function to get icon color based on event type
  /// Returns Orange/Amber for notes, Navy for meetings
  Color _getEventIconColor(EventType type) {
    // Check if type is note (as string) or task/reminder (as enum)
    final typeString = type.toString().toLowerCase();
    if (typeString.contains('note') || type == EventType.task || type == EventType.reminder) {
      return AppColors.secondary; // Amber/Orange for tasks/notes
    }
    // Default to Navy for meetings and personal events
    return AppColors.primary; // Navy for meetings
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Event Type Icon
          Icon(
            _getEventIcon(event.type),
            color: _getEventIconColor(event.type),
            size: 24,
          ),
          const SizedBox(width: 12),
          // Time
          Text(
            startTimeOnly,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary, // Amber for visibility
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: Theme.of(context).iconTheme.color),
                    const SizedBox(width: 4),
                    Text(
                      event.userName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyUpcomingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.event_available_rounded, size: 64, color: Theme.of(context).iconTheme.color),
          const SizedBox(height: 16),
          Text(
            tr('no_upcoming_events'),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr('enjoy_your_day'),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}