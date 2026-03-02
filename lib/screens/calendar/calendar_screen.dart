import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/team_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/event_model.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);
      
      final user = userProvider.currentUser;
      if (user != null) {
        calendarProvider.initialize(user.id);
        teamProvider.initialize(user.id);
      }
    });
  }

  void _showAddEventBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEventBottomSheet(
        selectedDate: _selectedDay,
      ),
    );
  }

  void _showEventDetailsSheet(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventDetailsSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = Provider.of<CalendarProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.currentUser?.id;

    if (currentUserId == null) {
      return Scaffold(body: Center(child: Text(tr('please_log_in'))));
    }

    final eventsForSelectedDay = calendarProvider.getEventsForDate(_selectedDay);
    final selectedDayEvents = eventsForSelectedDay
        .where((event) => event.userId == currentUserId)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Layer 1: The Main Content (Calendar & Timeline)
            Column(
              children: [
                _buildCustomHeader(),
                Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TableCalendar<EventModel>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    eventLoader: (day) => calendarProvider.getEventsForDate(day),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    locale: context.locale.languageCode,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      weekendTextStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      markersMaxCount: 1,
                      markerMargin: const EdgeInsets.only(bottom: 4),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isEmpty) return const SizedBox.shrink();
                        return _EventCountBadge(count: events.length);
                      },
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      titleTextStyle: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      calendarProvider.setSelectedDate(selectedDay);
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            DateFormat('d MMMM yyyy', context.locale.toString()).format(_selectedDay),
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: calendarProvider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : selectedDayEvents.isEmpty
                                  ? _EmptyTimelineState()
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      itemCount: selectedDayEvents.length,
                                      itemBuilder: (context, index) {
                                        return _TimelineEventCard(
                                          event: selectedDayEvents[index],
                                          onTap: () => _showEventDetailsSheet(context, selectedDayEvents[index]),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Layer 2: The Floating Action Button (Manually Positioned)
            Positioned(
              bottom: 30, // Push it up slightly to avoid bottom bar overlap
              right: 20,
              child: FloatingActionButton(
                onPressed: () => _showAddEventBottomSheet(context),
                backgroundColor: AppColors.primary,
                elevation: 6, // Higher elevation to pop out
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tr('my_schedule'),
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              side: BorderSide(color: AppColors.secondary),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              tr('today'),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widgets
class _EventCountBadge extends StatelessWidget {
  final int count;

  const _EventCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 18,
      ),
      child: Text(
        count.toString(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TimelineEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const _TimelineEventCard({
    required this.event,
    required this.onTap,
  });

  Color _getEventTypeColor() {
    switch (event.type) {
      case EventType.meeting:
        return AppColors.primary;
      case EventType.task:
        return AppColors.secondary;
      case EventType.reminder:
        return AppColors.secondary;
      case EventType.personal:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getEventTypeColor();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.formattedStartTime} - ${event.formattedEndTime}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        if (event.location != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTimelineState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 64,
            color: Theme.of(context).iconTheme.color,
          ),
          const SizedBox(height: 16),
          Text(
            tr('no_events_scheduled'),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr('tap_to_add_event'),
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

class _EventDetailsSheet extends StatelessWidget {
  final EventModel event;

  const _EventDetailsSheet({required this.event});

  @override
  Widget build(BuildContext context) {
    final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 8,
                    bottom: bottomPadding + 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: AppTextStyles.h2.copyWith(
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditEventSheet(context, event);
                            },
                            tooltip: tr('edit'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.error),
                            onPressed: () => _handleDeleteEvent(context, event, calendarProvider),
                            tooltip: tr('delete'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _EventDetailRow(
                        icon: Icons.calendar_today,
                        label: tr('date'),
                        value: DateFormat('EEE, MMM dd, yyyy', context.locale.toString()).format(event.startTime),
                      ),
                      const SizedBox(height: 16),
                      _EventDetailRow(
                        icon: Icons.access_time,
                        label: tr('time'),
                        value: '${event.formattedStartTime} - ${event.formattedEndTime}',
                      ),
                      if (event.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _EventDetailRow(
                          icon: Icons.description,
                          label: tr('description'),
                          value: event.description,
                          isLinkify: true,
                        ),
                      ],
                      if (event.location != null) ...[
                        const SizedBox(height: 16),
                        _EventDetailRow(
                          icon: Icons.location_on,
                          label: tr('location'),
                          value: event.location!,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _EventDetailRow(
                        icon: Icons.label,
                        label: tr('type'),
                        value: _getEventTypeLabel(event.type),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.meeting:
        return tr('event_type_meeting');
      case EventType.task:
        return tr('event_type_task');
      case EventType.reminder:
        return tr('event_type_reminder');
      case EventType.personal:
        return tr('event_type_personal');
    }
  }

  void _showEditEventSheet(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditEventBottomSheet(event: event),
    );
  }

  Future<void> _handleDeleteEvent(
    BuildContext context,
    EventModel event,
    CalendarProvider calendarProvider,
  ) async {
    if (event.requestId == null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(tr('delete_event')),
          content: Text(tr('delete_event_confirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(tr('delete')),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        final success = await calendarProvider.deleteEvent(event.id);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? tr('event_deleted') : tr('failed_to_delete_event')),
              backgroundColor: success ? AppColors.success : AppColors.error,
            ),
          );
        }
      }
    } else {
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(tr('delete_recurring_event')),
          content: Text(tr('delete_recurring_confirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: Text(tr('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'single'),
              child: Text(tr('this_event_only')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'series'),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(tr('entire_series')),
            ),
          ],
        ),
      );

      if (choice == null || choice == 'cancel' || !context.mounted) return;

      final firestoreService = FirestoreService();
      bool success = false;

      if (choice == 'single') {
        success = await calendarProvider.deleteEvent(event.id);
      } else if (choice == 'series') {
        try {
          await firestoreService.deleteEventSeries(event.requestId!);
          success = true;
        } catch (e) {
          success = false;
        }
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? (choice == 'single' ? tr('event_deleted') : tr('entire_series_deleted'))
                  : tr('failed_to_delete_event'),
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }
}

class _EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLinkify;

  const _EventDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLinkify = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 4),
              isLinkify
                  ? Linkify(
                      text: value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      linkStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondary,
                        decoration: TextDecoration.underline,
                      ),
                      onOpen: (link) async {
                        final uri = Uri.parse(link.url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    )
                  : Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditEventBottomSheet extends StatefulWidget {
  final EventModel event;

  const _EditEventBottomSheet({required this.event});

  @override
  State<_EditEventBottomSheet> createState() => _EditEventBottomSheetState();
}

class _EditEventBottomSheetState extends State<_EditEventBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TimeOfDay _endTime;
  EventType _selectedType = EventType.task;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.event.title;
    _descriptionController.text = widget.event.description;
    _selectedDate = widget.event.startTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.event.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.event.endTime);
    _selectedType = widget.event.type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr('edit_event'),
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: tr('title'),
            hint: tr('enter_event_title'),
            controller: _titleController,
            prefixIcon: Icons.title,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: tr('description'),
            hint: tr('enter_event_description'),
            controller: _descriptionController,
            prefixIcon: Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(tr('date')),
            subtitle: Text(
              DateFormat('MMM dd, yyyy', context.locale.toString()).format(_selectedDate),
              style: AppTextStyles.bodyMedium,
            ),
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(tr('start_time')),
            subtitle: Text(
              _selectedTime.format(context),
              style: AppTextStyles.bodyMedium,
            ),
            onTap: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (pickedTime != null) {
                setState(() {
                  _selectedTime = pickedTime;
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(tr('end_time')),
            subtitle: Text(
              _endTime.format(context),
              style: AppTextStyles.bodyMedium,
            ),
            onTap: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (pickedTime != null) {
                setState(() {
                  _endTime = pickedTime;
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.label),
            title: Text(tr('type')),
            subtitle: DropdownButton<EventType>(
              value: _selectedType,
              isExpanded: true,
              items: EventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getEventTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          Consumer<CalendarProvider>(
            builder: (context, calendarProvider, _) {
              return Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return CustomButton(
                    text: tr('save_changes'),
                    onPressed: calendarProvider.isLoading
                        ? null
                        : () async {
                            if (_titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tr('please_enter_title')),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final user = userProvider.currentUser;
                            if (user == null) return;

                            final startDateTime = DateTime(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day,
                              _selectedTime.hour,
                              _selectedTime.minute,
                            );
                            final endDateTime = DateTime(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day,
                              _endTime.hour,
                              _endTime.minute,
                            );

                            if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tr('end_time_after_start')),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final updatedEvent = EventModel(
                              id: widget.event.id,
                              title: _titleController.text.trim(),
                              description: _descriptionController.text.trim(),
                              startTime: startDateTime,
                              endTime: endDateTime,
                              userId: widget.event.userId,
                              userName: widget.event.userName,
                              type: _selectedType,
                              location: widget.event.location,
                              requestId: widget.event.requestId,
                            );

                            final success = await calendarProvider.updateEvent(updatedEvent);

                            if (context.mounted) {
                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(tr('event_updated_success')),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      calendarProvider.errorMessage ?? tr('failed_to_update_event'),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    isLoading: calendarProvider.isLoading,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.meeting:
        return tr('event_type_meeting');
      case EventType.task:
        return tr('event_type_task');
      case EventType.reminder:
        return tr('event_type_reminder');
      case EventType.personal:
        return tr('event_type_personal');
    }
  }
}

class _AddEventBottomSheet extends StatefulWidget {
  final DateTime selectedDate;

  const _AddEventBottomSheet({required this.selectedDate});

  @override
  State<_AddEventBottomSheet> createState() => _AddEventBottomSheetState();
}

class _AddEventBottomSheetState extends State<_AddEventBottomSheet> {
  final _titleController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  EventType _selectedType = EventType.meeting;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // CRITICAL FIX: Increased bottom padding to +80 to lift the button well above the nav bar
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 80,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr('add_new_event'),
            style: AppTextStyles.h3.copyWith(
              color: Theme.of(context).textTheme.titleLarge?.color, // Adapt to theme
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: tr('title'),
            hint: tr('enter_event_title'),
            controller: _titleController,
            prefixIcon: Icons.title,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(tr('date')),
            subtitle: Text(
              DateFormat('MMM dd, yyyy', context.locale.toString()).format(_selectedDate),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color, // Force readable color
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(tr('start_time')),
            subtitle: Text(
              _selectedTime.format(context),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color, // Force readable color
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (pickedTime != null) {
                setState(() {
                  _selectedTime = pickedTime;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          // Theme-Aware ChoiceChips Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('type'),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  // FIX 1: Use theme text color
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: EventType.values.map((type) {
                  final isSelected = _selectedType == type;
                  final isDark = Theme.of(context).brightness == Brightness.dark;

                  return ChoiceChip(
                    label: Text(
                      _getEventTypeLabel(type),
                      style: TextStyle(
                        // FIX 3: Use white for selected, theme color for unselected
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedType = type);
                      }
                    },
                    selectedColor: AppColors.primary,
                    // FIX 2: Adaptive background color for unselected state
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        // Optional: Add a subtle border definition in dark mode
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.white12 : Colors.transparent),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 32), // More space before button
          Consumer<CalendarProvider>(
            builder: (context, calendarProvider, _) {
              return Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return CustomButton(
                    text: tr('save'),
                    onPressed: calendarProvider.isLoading
                        ? null
                        : () async {
                            if (_titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tr('please_enter_title')),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final user = userProvider.currentUser;
                            if (user == null) return;

                            final startDateTime = DateTime(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day,
                              _selectedTime.hour,
                              _selectedTime.minute,
                            );
                            final endDateTime = startDateTime.add(
                              const Duration(hours: 1),
                            );

                            final newEvent = EventModel(
                              id: 'event_${DateTime.now().millisecondsSinceEpoch}',
                              title: _titleController.text.trim(),
                              description: '',
                              startTime: startDateTime,
                              endTime: endDateTime,
                              userId: user.id,
                              userName: user.name,
                              type: _selectedType,
                            );

                            final success = await calendarProvider.createEvent(newEvent);

                            if (context.mounted) {
                              if (success) {
                                await calendarProvider.loadEventsForDate(_selectedDate);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(tr('event_added_success')),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      calendarProvider.errorMessage ?? tr('failed_to_add_event'),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    isLoading: calendarProvider.isLoading,
                  );
                },
              );
            },
          ),
          // EXTRA SAFETY SPACE at the very bottom
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.meeting:
        return tr('event_type_meeting');
      case EventType.task:
        return tr('event_type_task');
      case EventType.reminder:
        return tr('event_type_reminder');
      case EventType.personal:
        return tr('event_type_personal');
    }
  }
}

