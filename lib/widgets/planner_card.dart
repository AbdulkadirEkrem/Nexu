import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class PlannerCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const PlannerCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getEventTypeColor(event.type).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getEventTypeLabel(event.type),
                      style: AppTextStyles.caption.copyWith(
                        color: _getEventTypeColor(event.type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${event.formattedStartTime} - ${event.formattedEndTime}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.title,
                style: AppTextStyles.h4,
              ),
              if (event.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (event.location != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.location!,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event.userName,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.meeting:
        return AppColors.primary;
      case EventType.task:
        return AppColors.warning;
      case EventType.reminder:
        return AppColors.info;
      case EventType.personal:
        return AppColors.success;
    }
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.meeting:
        return 'Meeting';
      case EventType.task:
        return 'Task';
      case EventType.reminder:
        return 'Reminder';
      case EventType.personal:
        return 'Personal';
    }
  }
}

