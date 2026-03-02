import 'calendar_service.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

class MockCalendarService implements CalendarService {
  final List<EventModel> _events = [];
  final List<UserModel> _teamMembers = [];

  MockCalendarService() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Initialize team members
    _teamMembers.addAll([
      UserModel(
        id: 'user_1',
        email: 'john@company.com',
        name: 'John Doe',
        department: 'Engineering',
        position: 'Senior Developer',
      ),
      UserModel(
        id: 'user_2',
        email: 'jane@company.com',
        name: 'Jane Smith',
        department: 'Marketing',
        position: 'Marketing Manager',
      ),
      UserModel(
        id: 'user_3',
        email: 'bob@company.com',
        name: 'Bob Johnson',
        department: 'Sales',
        position: 'Sales Representative',
      ),
      UserModel(
        id: 'user_4',
        email: 'alice@company.com',
        name: 'Alice Williams',
        department: 'HR',
        position: 'HR Manager',
      ),
    ]);

    // Initialize mock events
    _events.addAll([
      EventModel(
        id: 'event_1',
        title: 'Team Standup',
        description: 'Daily team synchronization meeting',
        startTime: today.add(const Duration(hours: 9)),
        endTime: today.add(const Duration(hours: 9, minutes: 30)),
        userId: 'user_1',
        userName: 'John Doe',
        type: EventType.meeting,
        location: 'Conference Room A',
      ),
      EventModel(
        id: 'event_2',
        title: 'Code Review',
        description: 'Review pull requests',
        startTime: today.add(const Duration(hours: 14)),
        endTime: today.add(const Duration(hours: 15)),
        userId: 'user_1',
        userName: 'John Doe',
        type: EventType.task,
      ),
      EventModel(
        id: 'event_3',
        title: 'Client Presentation',
        description: 'Present Q4 results to client',
        startTime: today.add(const Duration(days: 1, hours: 10)),
        endTime: today.add(const Duration(days: 1, hours: 11, minutes: 30)),
        userId: 'user_2',
        userName: 'Jane Smith',
        type: EventType.meeting,
        location: 'Conference Room B',
      ),
      EventModel(
        id: 'event_4',
        title: 'Sprint Planning',
        description: 'Plan next sprint tasks',
        startTime: today.add(const Duration(days: 2, hours: 13)),
        endTime: today.add(const Duration(days: 2, hours: 15)),
        userId: 'user_1',
        userName: 'John Doe',
        type: EventType.meeting,
      ),
      EventModel(
        id: 'event_5',
        title: 'Documentation Update',
        description: 'Update API documentation',
        startTime: today.add(const Duration(days: -1, hours: 16)),
        endTime: today.add(const Duration(days: -1, hours: 17)),
        userId: 'user_1',
        userName: 'John Doe',
        type: EventType.task,
      ),
      EventModel(
        id: 'event_6',
        title: 'Team Lunch',
        description: 'Monthly team lunch',
        startTime: today.add(const Duration(days: 3, hours: 12)),
        endTime: today.add(const Duration(days: 3, hours: 13, minutes: 30)),
        userId: 'user_4',
        userName: 'Alice Williams',
        type: EventType.personal,
        location: 'Restaurant',
      ),
    ]);
  }

  @override
  Future<List<EventModel>> getEventsForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _events.where((event) => event.userId == userId).toList();
  }

  @override
  Future<List<EventModel>> getEventsForDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _events.where((event) => event.isOnDate(date)).toList();
  }

  @override
  Future<List<EventModel>> getEventsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _events.where((event) {
      return event.startTime.isAfter(start.subtract(const Duration(days: 1))) &&
          event.startTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<List<UserModel>> getTeamMembers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_teamMembers);
  }

  @override
  Future<EventModel?> createEvent(EventModel event) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _events.add(event);
    return event;
  }

  @override
  Future<bool> deleteEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      _events.removeAt(index);
      return true;
    }
    return false;
  }
}

