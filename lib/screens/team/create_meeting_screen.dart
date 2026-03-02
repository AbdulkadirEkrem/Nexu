import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/meeting_request_model.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/user_avatar.dart';

class CreateMeetingScreen extends StatefulWidget {
  final UserModel recipient;

  const CreateMeetingScreen({
    super.key,
    required this.recipient,
  });

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Duration _selectedDuration = const Duration(minutes: 30);
  MeetingType _meetingType = MeetingType.online;

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _sendRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Combine date and time
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final endDateTime = startDateTime.add(_selectedDuration);

      final request = MeetingRequestModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        date: _selectedDate,
        startTime: startDateTime,
        endTime: endDateTime,
        duration: _selectedDuration,
        requesterId: currentUser.id,
        requesterName: currentUser.name,
        recipientId: widget.recipient.id,
        recipientName: widget.recipient.name,
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
        recurrence: RecurrenceType.none,
      );

      final firestoreService = FirestoreService();
      await firestoreService.sendMeetingRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${tr('meeting_request_sent_param')} ${widget.recipient.name}',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${tr('failed_to_send_request_param')} ${e.toString()}',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background uses theme
      appBar: AppBar(
        // AppBar uses theme
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      // Header: Recipient Avatar and Name
                      Center(
                        child: Column(
                          children: [
                            UserAvatar(
                              user: widget.recipient,
                              radius: 40,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.recipient.name,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr('new_meeting_request'),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title Input Section
                      _FormSection(
                        title: tr('meeting_subject'),
                        child: TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: tr('meeting_subject_hint'),
                            hintStyle: GoogleFonts.inter(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return tr('please_enter_meeting_subject');
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Date & Time Section
                      _FormSection(
                        title: tr('date_time'),
                        child: Column(
                          children: [
                            _DateTimeRow(
                              label: tr('date'),
                              value: DateFormat('EEE, MMM dd, yyyy')
                                  .format(_selectedDate),
                              icon: Icons.calendar_today,
                              onTap: _selectDate,
                            ),
                            const SizedBox(height: 12),
                            _DateTimeRow(
                              label: tr('time'),
                              value: _selectedTime.format(context),
                              icon: Icons.access_time,
                              onTap: _selectTime,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Duration Selector
                      _FormSection(
                        title: tr('duration'),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _DurationChip(
                              label: '15m',
                              duration: const Duration(minutes: 15),
                              selected: _selectedDuration ==
                                  const Duration(minutes: 15),
                              onTap: () {
                                setState(() {
                                  _selectedDuration =
                                      const Duration(minutes: 15);
                                });
                              },
                            ),
                            _DurationChip(
                              label: '30m',
                              duration: const Duration(minutes: 30),
                              selected: _selectedDuration ==
                                  const Duration(minutes: 30),
                              onTap: () {
                                setState(() {
                                  _selectedDuration =
                                      const Duration(minutes: 30);
                                });
                              },
                            ),
                            _DurationChip(
                              label: '45m',
                              duration: const Duration(minutes: 45),
                              selected: _selectedDuration ==
                                  const Duration(minutes: 45),
                              onTap: () {
                                setState(() {
                                  _selectedDuration =
                                      const Duration(minutes: 45);
                                });
                              },
                            ),
                            _DurationChip(
                              label: '1h',
                              duration: const Duration(hours: 1),
                              selected: _selectedDuration ==
                                  const Duration(hours: 1),
                              onTap: () {
                                setState(() {
                                  _selectedDuration = const Duration(hours: 1);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Meeting Type
                      _FormSection(
                        title: tr('meeting_type'),
                        child: Row(
                          children: [
                            Expanded(
                              child: _MeetingTypeChip(
                                label: tr('online'),
                                icon: Icons.videocam,
                                type: MeetingType.online,
                                selected: _meetingType == MeetingType.online,
                                onTap: () {
                                  setState(() {
                                    _meetingType = MeetingType.online;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MeetingTypeChip(
                                label: tr('in_person'),
                                icon: Icons.location_on,
                                type: MeetingType.inPerson,
                                selected: _meetingType == MeetingType.inPerson,
                                onTap: () {
                                  setState(() {
                                    _meetingType = MeetingType.inPerson;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      _FormSection(
                        title: tr('description_agenda'),
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: tr('description_agenda_hint'),
                            hintStyle: GoogleFonts.inter(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Bottom Action Button
              Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              tr('send_request'),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum MeetingType { online, inPerson }

class _FormSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FormSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimeRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit,
              color: Theme.of(context).iconTheme.color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final Duration duration;
  final bool selected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.duration,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.secondary,
      backgroundColor: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _MeetingTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final MeetingType type;
  final bool selected;
  final VoidCallback onTap;

  const _MeetingTypeChip({
    required this.label,
    required this.icon,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.secondary : Theme.of(context).cardColor,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Theme.of(context).iconTheme.color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

