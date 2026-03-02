import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/meeting_request_model.dart';
import '../services/firestore_service.dart';

class RequestProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<MeetingRequestModel> _incomingRequests = [];
  List<MeetingRequestModel> _outgoingRequests = []; // Hem gidenleri hem feedbackleri tutar

  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;

  StreamSubscription<List<MeetingRequestModel>>? _incomingRequestsSubscription;
  StreamSubscription<List<MeetingRequestModel>>? _outgoingRequestsSubscription;

  List<MeetingRequestModel> get incomingRequests => _incomingRequests;
  List<MeetingRequestModel> get outgoingRequests => _outgoingRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _incomingRequests.length;

  /// HAFIZA TEMİZLEYİCİ
  void clearData() {
    _incomingRequests = [];
    _outgoingRequests = [];
    _errorMessage = null;
    _currentUserId = null;
    _isLoading = false;

    _incomingRequestsSubscription?.cancel();
    _outgoingRequestsSubscription?.cancel();
    _incomingRequestsSubscription = null;
    _outgoingRequestsSubscription = null;

    notifyListeners();
  }

  /// Provider Başlatıcı
  void initialize(String userId) {
    if (_currentUserId == userId) return;

    clearData();

    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    _listenToIncomingRequests();
    _listenToOutgoingRequests();
  }

  void _listenToIncomingRequests() {
    if (_currentUserId == null) return;

    _incomingRequestsSubscription?.cancel();
    _incomingRequestsSubscription = _firestoreService
        .streamIncomingRequests(_currentUserId!)
        .listen(
          (requests) {
            _incomingRequests = requests;
            _errorMessage = null;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Failed to load incoming requests: ${error.toString()}';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void _listenToOutgoingRequests() {
    if (_currentUserId == null) return;

    _outgoingRequestsSubscription?.cancel();
    _outgoingRequestsSubscription = _firestoreService
        .streamAllOutgoingRequests(_currentUserId!)
        .listen(
          (requests) {
            _outgoingRequests = requests;
            _errorMessage = null;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Failed to load outgoing requests: ${error.toString()}';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<bool> sendRequest(MeetingRequestModel request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.sendMeetingRequest(request);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send request: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 👇 SİHİRLİ DOKUNUŞ BURADA BAŞLIYOR 👇

  Future<bool> acceptRequest(String requestId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Önce veritabanına işle
      await _firestoreService.respondToRequest(requestId, true);
      
      // 2. ANLIK TEPKİ: Veritabanından cevap gelmesini bekleme, LİSTEDEN HEMEN SİL!
      _incomingRequests.removeWhere((r) => r.id == requestId);
      
      _errorMessage = null;
      _isLoading = false;
      notifyListeners(); // Ekranı hemen yenile
      return true;
    } catch (e) {
      _errorMessage = 'Failed to accept request: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> declineRequest(String requestId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Veritabanına işle
      await _firestoreService.respondToRequest(requestId, false);
      
      // 2. ANLIK TEPKİ: LİSTEDEN HEMEN SİL!
      _incomingRequests.removeWhere((r) => r.id == requestId);
      
      _errorMessage = null;
      _isLoading = false;
      notifyListeners(); // Ekranı hemen yenile
      return true;
    } catch (e) {
      _errorMessage = 'Failed to decline request: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> dismissRequest(String requestId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.dismissRequest(requestId);
      
      // 2. ANLIK TEPKİ: LİSTEDEN HEMEN SİL! (Feedback kutusu için)
      _outgoingRequests.removeWhere((r) => r.id == requestId);

      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to dismiss request: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _incomingRequestsSubscription?.cancel();
    _outgoingRequestsSubscription?.cancel();
    super.dispose();
  }
}