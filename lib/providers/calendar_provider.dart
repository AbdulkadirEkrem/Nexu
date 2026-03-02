import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class CalendarProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<EventModel> _events = [];
  List<UserModel> _teamMembers = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<EventModel>>? _eventsSubscription;
  String? _currentUserId;

  List<EventModel> get events => _events;
  List<UserModel> get teamMembers => _teamMembers;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CalendarProvider() {
    // Initial data will be loaded when userId is set
  }

  /// Initialize the provider with a user ID to start listening to events
  void initialize(String userId) {
    if (_currentUserId == userId) return; // Already initialized
    
    _currentUserId = userId;
    _loadInitialData();
    _listenToEvents();
  }

  void _listenToEvents() {
    if (_currentUserId == null) return;

    _eventsSubscription?.cancel();
    _eventsSubscription = _firestoreService
        .streamEvents(_currentUserId!)
        .listen(
          (events) {
            _events = events;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Failed to stream events: ${error.toString()}';
            notifyListeners();
          },
        );
  }

  Future<void> _loadInitialData() async {
    if (_currentUserId == null) return;

    await Future.wait([
      loadTeamMembers(),
      loadEventsForDate(_selectedDate),
    ]);
    // Also load events for current month to ensure calendar markers work
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    await loadEventsForDateRange(firstDayOfMonth, lastDayOfMonth);
  }

  Future<void> loadEventsForUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Events are already loaded via stream, but we can refresh if needed
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load events: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEventsForDate(DateTime date) async {
    if (_currentUserId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateEvents = await _firestoreService.getEventsForDate(date, _currentUserId!);
      // Merge with existing events, avoiding duplicates
      for (final event in dateEvents) {
        if (!_events.any((e) => e.id == event.id)) {
          _events.add(event);
        }
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load events: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEventsForDateRange(DateTime start, DateTime end) async {
    if (_currentUserId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rangeEvents = await _firestoreService.getEventsForDateRange(
        start,
        end,
        _currentUserId!,
      );
      // Merge with existing events, avoiding duplicates
      for (final event in rangeEvents) {
        if (!_events.any((e) => e.id == event.id)) {
          _events.add(event);
        }
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load events: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTeamMembers() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current user to extract company domain
      final currentUser = await _firestoreService.getUser(_currentUserId!);
      if (currentUser != null) {
        // Extract company domain from email
        final emailParts = currentUser.email.split('@');
        final companyDomain = emailParts.length > 1 ? emailParts[1] : '';
        
        // Get all users with the same company domain
        _teamMembers = await _firestoreService.getUsersByCompanyDomain(companyDomain);
        // Remove current user from team members list
        _teamMembers.removeWhere((user) => user.id == _currentUserId);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load team members: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEvent(EventModel event) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.addEvent(event);
      // Event will be automatically added to _events via the stream listener
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create event: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent(EventModel event) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateEvent(event);
      // Event will be automatically updated in _events via the stream listener
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update event: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteEvent(eventId);
      // Event will be automatically removed from _events via the stream listener
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete event: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadEventsForDate(date);
  }

  List<EventModel> getEventsForDate(DateTime date) {
    return _events.where((event) => event.isOnDate(date)).toList();
  }

  List<EventModel> getEventsForUser(String userId) {
    return _events.where((event) => event.userId == userId).toList();
  }

  /// Gets all upcoming events (future events only, sorted chronologically)
  List<EventModel> getUpcomingEvents(String userId) {
    final now = DateTime.now();
    return _events
        .where((event) => event.userId == userId && event.startTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}

