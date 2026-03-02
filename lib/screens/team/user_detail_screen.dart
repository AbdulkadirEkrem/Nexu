import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../models/user_model.dart';
import '../../models/event_model.dart';
import '../../models/meeting_request_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/request_provider.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/user_avatar.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel? user;
  
  const UserDetailScreen({super.key, this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final FirestoreService _firestoreService = FirestoreService();
  List<EventModel> _targetUserEvents = [];
  StreamSubscription<List<EventModel>>? _eventsSubscription;
  UserModel? _targetUser;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData = widget.user ?? GoRouterState.of(context).extra as UserModel?;
    if (userData != null && _targetUser?.id != userData.id) {
      _targetUser = userData;
      _listenToUserEvents(userData.id);
    }
  }

  void _listenToUserEvents(String userId) {
    _eventsSubscription?.cancel();
    _eventsSubscription = _firestoreService
        .streamUserEvents(userId)
        .listen(
          (events) {
            if (mounted) {
              setState(() {
                _targetUserEvents = events;
              });
            }
          },
          onError: (error) {
            // Handle error silently or show a message
          },
        );
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = widget.user ?? GoRouterState.of(context).extra as UserModel?;
    
    if (userData == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    // Use events from stream (target user's events)
    final eventsForSelectedDay = _targetUserEvents
        .where((event) => event.isOnDate(_selectedDay))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(userData.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(
              user: userData,
              radius: 60,
              fontSize: 48,
            ),
            const SizedBox(height: 24),
            Text(
              userData.name,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              userData.position,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: userData.email,
                    ),
                    const Divider(),
                    _DetailRow(
                      icon: Icons.business,
                      label: 'Department',
                      value: userData.department,
                    ),
                    const Divider(),
                    _DetailRow(
                      icon: Icons.work,
                      label: 'Position',
                      value: userData.position,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Availability',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: TableCalendar<EventModel>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: (day) {
                  return _targetUserEvents.where((event) => event.isOnDate(day)).toList();
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                  markerSize: 6,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  formatButtonTextStyle: const TextStyle(color: Colors.white),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Schedule for ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 16),
            _HourlyAvailabilityList(
              date: _selectedDay,
              userEvents: eventsForSelectedDay,
              userName: userData.name,
              onSlotTap: (startTime, endTime) {
                _showRequestForm(
                  context,
                  userData,
                  _selectedDay,
                  startTime,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showRequestForm(
    BuildContext context,
    UserModel recipient,
    DateTime date,
    TimeOfDay startTime,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MeetingRequestForm(
        recipient: recipient,
        date: date,
        initialTime: startTime,
        targetUserEvents: _targetUserEvents,
      ),
    );
  }
}

class _HourlyAvailabilityList extends StatelessWidget {
  final DateTime date;
  final List<EventModel> userEvents;
  final String userName;
  final void Function(TimeOfDay startTime, TimeOfDay endTime) onSlotTap;

  const _HourlyAvailabilityList({
    required this.date,
    required this.userEvents,
    required this.userName,
    required this.onSlotTap,
  });

  List<_TimeSlot> _generateHourlySlots() {
    final slots = <_TimeSlot>[];
    const startHour = 9;
    const endHour = 17;

    for (int hour = startHour; hour < endHour; hour++) {
      final startTime = TimeOfDay(hour: hour, minute: 0);
      final endTime = TimeOfDay(hour: hour + 1, minute: 0);

      // Check if this slot overlaps with any event
      final slotStart = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        0,
      );
      final slotEnd = DateTime(
        date.year,
        date.month,
        date.day,
        hour + 1,
        0,
      );

      bool isBusy = userEvents.any((event) {
        return (event.startTime.isBefore(slotEnd) &&
                event.endTime.isAfter(slotStart));
      });

      slots.add(_TimeSlot(
        startTime: startTime,
        endTime: endTime,
        isBusy: isBusy,
      ));
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final slots = _generateHourlySlots();

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...slots.map((slot) => _AvailabilitySlotItem(
                slot: slot,
                onTap: slot.isBusy ? null : () => onSlotTap(slot.startTime, slot.endTime),
              )),
        ],
      ),
    );
  }
}

class _TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isBusy;

  _TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isBusy,
  });
}

class _AvailabilitySlotItem extends StatelessWidget {
  final _TimeSlot slot;
  final VoidCallback? onTap;

  const _AvailabilitySlotItem({
    required this.slot,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              slot.isBusy ? Icons.block : Icons.check_circle,
              color: slot.isBusy ? AppColors.error : AppColors.success,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${slot.startTime.format(context)} - ${slot.endTime.format(context)}: ${slot.isBusy ? 'Busy' : 'Available'}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: slot.isBusy ? AppColors.error : AppColors.success,
                ),
              ),
            ),
            if (!slot.isBusy)
              TextButton(
                onPressed: onTap,
                child: const Text('Request'),
              ),
          ],
        ),
      ),
    );
  }
}

class _MeetingRequestForm extends StatefulWidget {
  final UserModel recipient;
  final DateTime date;
  final TimeOfDay initialTime;
  final List<EventModel> targetUserEvents;

  const _MeetingRequestForm({
    required this.recipient,
    required this.date,
    required this.initialTime,
    required this.targetUserEvents,
  });

  @override
  State<_MeetingRequestForm> createState() => _MeetingRequestFormState();
}

class _MeetingRequestFormState extends State<_MeetingRequestForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late TimeOfDay _selectedTime;
  Duration _selectedDuration = const Duration(hours: 1);
  RecurrenceType _selectedRecurrence = RecurrenceType.none;
  String? _conflictError;

  final List<Duration> _durationOptions = [
    const Duration(minutes: 30),
    const Duration(hours: 1),
    const Duration(hours: 1, minutes: 30),
    const Duration(hours: 2),
  ];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _checkForConflicts();
    _validatePastDateTime();
  }

  void _validatePastDateTime() {
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      setState(() {
        _conflictError = 'Cannot select past time';
      });
    }
  }

  bool _timesOverlap(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    // Check if two time ranges overlap
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  void _checkForConflicts() {
    final now = DateTime.now();
    final startDateTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final endDateTime = startDateTime.add(_selectedDuration);

    // Check if the selected time is in the past
    if (startDateTime.isBefore(now)) {
      setState(() {
        _conflictError = 'Cannot select past time';
      });
      return;
    }

    // Check if the selected time overlaps with any existing event
    final hasConflict = widget.targetUserEvents.any((event) {
      // Only check events on the same date
      if (!event.isOnDate(widget.date)) return false;
      
      return _timesOverlap(
        startDateTime,
        endDateTime,
        event.startTime,
        event.endTime,
      );
    });

    setState(() {
      _conflictError = hasConflict
          ? '${widget.recipient.name} is busy at this time'
          : null;
    });
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
            'Request Meeting with ${widget.recipient.name}',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Title',
            hint: 'e.g., Project Review',
            controller: _titleController,
            prefixIcon: Icons.title,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Description / Meeting Link',
            hint: 'e.g., Google Meet link: https://meet.google.com/...',
            controller: _descriptionController,
            prefixIcon: Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date'),
            subtitle: Text(
              DateFormat('MMM dd, yyyy').format(widget.date),
              style: AppTextStyles.bodyMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Start Time'),
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
                _checkForConflicts();
                _validatePastDateTime();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Duration'),
            subtitle: DropdownButton<Duration>(
              value: _selectedDuration,
              isExpanded: true,
              items: _durationOptions.map((duration) {
                String label;
                if (duration.inHours > 0) {
                  label = '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
                } else {
                  label = '${duration.inMinutes} minutes';
                }
                return DropdownMenuItem(
                  value: duration,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDuration = value;
                  });
                  _checkForConflicts();
                  _validatePastDateTime();
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Repeat'),
            subtitle: DropdownButton<RecurrenceType>(
              value: _selectedRecurrence,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: RecurrenceType.none,
                  child: Text('Does not repeat'),
                ),
                DropdownMenuItem(
                  value: RecurrenceType.daily,
                  child: Text('Daily (5 days)'),
                ),
                DropdownMenuItem(
                  value: RecurrenceType.weekly,
                  child: Text('Weekly (4 weeks)'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRecurrence = value;
                  });
                }
              },
            ),
          ),
          if (_conflictError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _conflictError!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Consumer<RequestProvider>(
            builder: (context, requestProvider, _) {
              return Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  final hasConflict = _conflictError != null;
                  return CustomButton(
                    text: 'Send Request',
                    onPressed: (requestProvider.isLoading || hasConflict)
                        ? null
                        : () async {
                            if (_titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a title'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Validate past date/time
                            final now = DateTime.now();
                            final startDateTime = DateTime(
                              widget.date.year,
                              widget.date.month,
                              widget.date.day,
                              _selectedTime.hour,
                              _selectedTime.minute,
                            );

                            if (startDateTime.isBefore(now)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cannot select past time'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final user = userProvider.currentUser;
                            if (user == null) return;

                            // 👇 GÜNCELLENEN KISIM: MeetingRequestModel artık eksiksiz!
                            final request = MeetingRequestModel(
                              id: 'req_${DateTime.now().millisecondsSinceEpoch}',
                              title: _titleController.text.trim(),
                              description: _descriptionController.text.trim().isEmpty
                                  ? null
                                  : _descriptionController.text.trim(),
                              date: widget.date,
                              startTime: startDateTime,
                              endTime: startDateTime.add(_selectedDuration), // ✅ Eklendi
                              duration: _selectedDuration,
                              requesterId: user.id,
                              requesterName: user.name,
                              recipientId: widget.recipient.id,
                              recipientName: widget.recipient.name,
                              status: RequestStatus.pending, // ✅ Eklendi
                              createdAt: DateTime.now(),     // ✅ Eklendi
                              recurrence: _selectedRecurrence, // ✅ Recurrence eklendi
                            );

                            final success = await requestProvider.sendRequest(request);

                            if (!context.mounted) return;

                            // Always close the bottom sheet first
                            Navigator.pop(context);
                            
                            if (success) {
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Request sent successfully!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              // Navigate back to previous screen (team list or home)
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    requestProvider.errorMessage ??
                                        'Failed to send request',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    isLoading: requestProvider.isLoading,
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
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}