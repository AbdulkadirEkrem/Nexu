import 'request_service.dart';
import '../models/meeting_request_model.dart';
import '../models/user_model.dart';

class MockRequestService implements RequestService {
  final List<MeetingRequestModel> _requests = [];

  MockRequestService() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    // Add some dummy incoming requests
    _requests.addAll([
      MeetingRequestModel(
        id: 'req_1',
        title: 'Project Review',
        date: tomorrow,
        startTime: DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          14,
          0,
        ),
        duration: const Duration(hours: 1),
        requesterId: 'user_2',
        requesterName: 'Jane Smith',
        recipientId: 'user_1',
        recipientName: 'John Doe',
        status: RequestStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      MeetingRequestModel(
        id: 'req_2',
        title: 'Team Sync',
        date: tomorrow,
        startTime: DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          10,
          30,
        ),
        duration: const Duration(minutes: 30),
        requesterId: 'user_3',
        requesterName: 'Bob Johnson',
        recipientId: 'user_1',
        recipientName: 'John Doe',
        status: RequestStatus.pending,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
    ]);
  }

  @override
  Future<List<MeetingRequestModel>> getIncomingRequests(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _requests
        .where((req) =>
            req.recipientId == userId && req.status == RequestStatus.pending)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<MeetingRequestModel>> getOutgoingRequests(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _requests
        .where((req) =>
            req.requesterId == userId && req.status == RequestStatus.pending)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<MeetingRequestModel?> sendRequest(MeetingRequestModel request) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _requests.add(request);
    return request;
  }

  @override
  Future<bool> acceptRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requests.indexWhere((req) => req.id == requestId);
    if (index != -1) {
      final request = _requests[index];
      _requests[index] = MeetingRequestModel(
        id: request.id,
        title: request.title,
        date: request.date,
        startTime: request.startTime,
        duration: request.duration,
        requesterId: request.requesterId,
        requesterName: request.requesterName,
        recipientId: request.recipientId,
        recipientName: request.recipientName,
        status: RequestStatus.accepted,
        createdAt: request.createdAt,
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> declineRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requests.indexWhere((req) => req.id == requestId);
    if (index != -1) {
      final request = _requests[index];
      _requests[index] = MeetingRequestModel(
        id: request.id,
        title: request.title,
        date: request.date,
        startTime: request.startTime,
        duration: request.duration,
        requesterId: request.requesterId,
        requesterName: request.requesterName,
        recipientId: request.recipientId,
        recipientName: request.recipientName,
        status: RequestStatus.declined,
        createdAt: request.createdAt,
      );
      return true;
    }
    return false;
  }
}

