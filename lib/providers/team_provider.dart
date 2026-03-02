import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class TeamProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> _colleagues = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<UserModel>>? _colleaguesSubscription;
  String? _currentUserId;

  List<UserModel> get colleagues => _colleagues;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize the provider with a user ID to start listening to colleagues
  void initialize(String userId) {
    if (_currentUserId == userId) return; // Already initialized

    _currentUserId = userId;
    _listenToColleagues();
  }

  void _listenToColleagues() {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    _colleaguesSubscription?.cancel();
    _colleaguesSubscription = _firestoreService
        .streamColleagues(_currentUserId!)
        .listen(
          (colleagues) {
            _colleagues = colleagues;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Failed to load colleagues: ${error.toString()}';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> refresh() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Re-initialize to refresh the stream
      _listenToColleagues();
    } catch (e) {
      _errorMessage = 'Failed to refresh colleagues: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _colleaguesSubscription?.cancel();
    super.dispose();
  }
}

