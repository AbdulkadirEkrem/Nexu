import '../models/meeting_request_model.dart';

abstract class RequestService {
  Future<List<MeetingRequestModel>> getIncomingRequests(String userId);
  Future<List<MeetingRequestModel>> getOutgoingRequests(String userId);
  Future<MeetingRequestModel?> sendRequest(MeetingRequestModel request);
  Future<bool> acceptRequest(String requestId);
  Future<bool> declineRequest(String requestId);
}

