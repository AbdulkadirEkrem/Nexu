import '../models/event_model.dart';
import '../models/user_model.dart';

abstract class CalendarService {
  Future<List<EventModel>> getEventsForUser(String userId);
  Future<List<EventModel>> getEventsForDate(DateTime date);
  Future<List<EventModel>> getEventsForDateRange(DateTime start, DateTime end);
  Future<List<UserModel>> getTeamMembers();
  Future<EventModel?> createEvent(EventModel event);
  Future<bool> deleteEvent(String eventId);
}

