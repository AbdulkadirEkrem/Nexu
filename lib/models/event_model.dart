import 'package:intl/intl.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String userId;
  final String userName;
  final EventType type;
  final String? location;
  final String? requestId; // Links recurring events together

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.userId,
    required this.userName,
    required this.type,
    this.location,
    this.requestId,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      type: EventType.values.firstWhere(
        (e) => e.toString() == 'EventType.${json['type']}',
        orElse: () => EventType.meeting,
      ),
      location: json['location'] as String?,
      requestId: json['requestId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'type': type.toString().split('.').last,
      'location': location,
      'requestId': requestId,
    };
  }

  String get formattedStartTime {
    return DateFormat('HH:mm').format(startTime);
  }

  String get formattedEndTime {
    return DateFormat('HH:mm').format(endTime);
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(startTime);
  }

  bool isOnDate(DateTime date) {
    return startTime.year == date.year &&
        startTime.month == date.month &&
        startTime.day == date.day;
  }
}

enum EventType {
  meeting,
  task,
  reminder,
  personal,
}

