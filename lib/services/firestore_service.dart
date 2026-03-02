import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/meeting_request_model.dart';
import 'fcm_sender_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Methods

  /// Creates a new user document in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      final emailParts = user.email.split('@');
      final companyDomain = emailParts.length > 1 ? emailParts[1] : '';

      // Use toJson() and add additional Firestore-specific fields
      final userData = user.toJson();
      userData['companyDomain'] = companyDomain;
      userData['createdAt'] = FieldValue.serverTimestamp();
      userData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(user.id).set(userData);
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  /// Saves user data to Firestore
  Future<void> saveUser(UserModel user) async {
    try {
      final emailParts = user.email.split('@');
      final companyDomain = emailParts.length > 1 ? emailParts[1] : '';

      await _firestore.collection('users').doc(user.id).set({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'department': user.department,
        'position': user.position,
        'companyDomain': companyDomain,
        'avatarUrl': user.avatarUrl,
        'avatarId': user.avatarId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user: ${e.toString()}');
    }
  }

  /// Fetches user data from Firestore
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return UserModel(
          id: data['id'] as String? ?? uid,
          email: data['email'] as String? ?? '',
          name: data['name'] as String? ?? 'User',
          department: data['department'] as String? ?? 'General',
          position: data['position'] as String? ?? 'Employee',
          avatarUrl: data['avatarUrl'] as String?,
          avatarId: data['avatarId'] as int?,
          companyDomain: data['companyDomain'] as String?,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  /// Updates user profile data
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'name': user.name,
        'department': user.department,
        'position': user.position,
        'avatarId': user.avatarId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  /// Updates FCM token
  Future<void> updateFCMToken(String userId, String fcmToken) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update FCM token: ${e.toString()}');
    }
  }

  /// Gets all users with the same company domain
  Future<List<UserModel>> getUsersByCompanyDomain(String companyDomain) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('companyDomain', isEqualTo: companyDomain)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel(
          id: data['id'] as String? ?? doc.id,
          email: data['email'] as String? ?? '',
          name: data['name'] as String? ?? 'User',
          department: data['department'] as String? ?? 'General',
          position: data['position'] as String? ?? 'Employee',
          avatarUrl: data['avatarUrl'] as String?,
          avatarId: data['avatarId'] as int?,
          companyDomain: data['companyDomain'] as String?,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get users by domain: ${e.toString()}');
    }
  }

  /// Streams colleagues
  Stream<List<UserModel>> streamColleagues(String currentUserId) async* {
    try {
      final currentUser = await getUser(currentUserId);
      if (currentUser == null) {
        yield [];
        return;
      }

      final emailParts = currentUser.email.split('@');
      final companyDomain = emailParts.length > 1 ? emailParts[1] : '';

      if (companyDomain.isEmpty) {
        yield [];
        return;
      }

      yield* _firestore
          .collection('users')
          .where('companyDomain', isEqualTo: companyDomain)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .where((doc) => doc.id != currentUserId)
            .map((doc) {
          final data = doc.data();
          return UserModel(
            id: data['id'] as String? ?? doc.id,
            email: data['email'] as String? ?? '',
            name: data['name'] as String? ?? 'User',
            department: data['department'] as String? ?? 'General',
            position: data['position'] as String? ?? 'Employee',
            avatarUrl: data['avatarUrl'] as String?,
          );
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to stream colleagues: ${e.toString()}');
    }
  }

  // Event Methods

  /// Saves an event
  Future<void> addEvent(EventModel event) async {
    try {
      await _firestore.collection('events').doc(event.id).set({
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'startTime': event.startTime.toIso8601String(),
        'endTime': event.endTime.toIso8601String(),
        'userId': event.userId,
        'userName': event.userName,
        'type': event.type.toString().split('.').last,
        'location': event.location,
        'requestId': event.requestId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add event: ${e.toString()}');
    }
  }

  /// Updates an existing event
  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore.collection('events').doc(event.id).update({
        'title': event.title,
        'description': event.description,
        'startTime': event.startTime.toIso8601String(),
        'endTime': event.endTime.toIso8601String(),
        'type': event.type.toString().split('.').last,
        'location': event.location,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update event: ${e.toString()}');
    }
  }

  /// Streams events for a specific user
  Stream<List<EventModel>> streamEvents(String userId) {
    try {
      return _firestore
          .collection('events')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return EventModel(
            id: data['id'] as String? ?? doc.id,
            title: data['title'] as String? ?? '',
            description: data['description'] as String? ?? '',
            startTime: DateTime.parse(data['startTime'] as String),
            endTime: DateTime.parse(data['endTime'] as String),
            userId: data['userId'] as String? ?? userId,
            userName: data['userName'] as String? ?? '',
            type: EventType.values.firstWhere(
              (e) => e.toString() == 'EventType.${data['type']}',
              orElse: () => EventType.task,
            ),
            location: data['location'] as String?,
            requestId: data['requestId'] as String?,
          );
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to stream events: ${e.toString()}');
    }
  }

  Stream<List<EventModel>> streamUserEvents(String userId) => streamEvents(userId);

  /// Gets events for a specific date
  Future<List<EventModel>> getEventsForDate(DateTime date, String userId) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: userId)
          .where('startTime', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('startTime', isLessThan: endOfDay.toIso8601String())
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return EventModel(
          id: data['id'] as String? ?? doc.id,
          title: data['title'] as String? ?? '',
          description: data['description'] as String? ?? '',
          startTime: DateTime.parse(data['startTime'] as String),
          endTime: DateTime.parse(data['endTime'] as String),
          userId: data['userId'] as String? ?? userId,
          userName: data['userName'] as String? ?? '',
          type: EventType.values.firstWhere(
            (e) => e.toString() == 'EventType.${data['type']}',
            orElse: () => EventType.task,
          ),
          location: data['location'] as String?,
          requestId: data['requestId'] as String?,
        );
      }).toList();
    } catch (e) {
       // Fallback logic omitted for brevity, keeping simple query
      throw Exception('Failed to get events for date: ${e.toString()}');
    }
  }

  /// Gets events for a date range
  Future<List<EventModel>> getEventsForDateRange(DateTime start, DateTime end, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: userId)
          .where('startTime', isGreaterThanOrEqualTo: start.toIso8601String())
          .where('startTime', isLessThanOrEqualTo: end.toIso8601String())
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return EventModel(
          id: data['id'] as String? ?? doc.id,
          title: data['title'] as String? ?? '',
          description: data['description'] as String? ?? '',
          startTime: DateTime.parse(data['startTime'] as String),
          endTime: DateTime.parse(data['endTime'] as String),
          userId: data['userId'] as String? ?? userId,
          userName: data['userName'] as String? ?? '',
          type: EventType.values.firstWhere(
            (e) => e.toString() == 'EventType.${data['type']}',
            orElse: () => EventType.task,
          ),
          location: data['location'] as String?,
          requestId: data['requestId'] as String?,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get events for date range: ${e.toString()}');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  /// Deletes all events in a recurring series (by requestId)
  Future<void> deleteEventSeries(String requestId) async {
    try {
      // Find all events with this requestId
      final querySnapshot = await _firestore
          .collection('events')
          .where('requestId', isEqualTo: requestId)
          .get();

      // Delete all events in the series
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete event series: ${e.toString()}');
    }
  }

  // Meeting Request Methods

  Future<void> sendMeetingRequest(MeetingRequestModel request) async {
    try {
      await _firestore.collection('requests').doc(request.id).set({
        'id': request.id,
        'title': request.title,
        'description': request.description,
        'date': request.date.toIso8601String(),
        'startTime': request.startTime.toIso8601String(),
        'endTime': request.endTime.toIso8601String(),
        'durationMinutes': request.duration.inMinutes,
        'requesterId': request.requesterId,
        'requesterName': request.requesterName,
        'recipientId': request.recipientId,
        'recipientName': request.recipientName,
        'status': request.status.toString().split('.').last,
        'recurrence': request.recurrence.toString().split('.').last,
        'createdAt': request.createdAt.toIso8601String(),
        'createdAtTimestamp': Timestamp.fromDate(request.createdAt),
      });

      try {
        final recipientUser = await getUser(request.recipientId);
        if (recipientUser != null) {
          final recipientDoc = await _firestore.collection('users').doc(request.recipientId).get();
          if (recipientDoc.exists) {
            final fcmToken = recipientDoc.data()?['fcmToken'] as String?;
            if (fcmToken != null && fcmToken.isNotEmpty) {
              final fcmSender = FCMSenderService();
              await fcmSender.sendNotification(
                deviceToken: fcmToken,
                title: 'New Meeting Request',
                body: 'You have a new request from ${request.requesterName}.',
              );
            }
          }
        }
      } catch (e) {
        print('Notification error: $e');
      }
    } catch (e) {
      throw Exception('Failed to send meeting request: ${e.toString()}');
    }
  }

  /// Streams incoming meeting requests (PARANOID MODE)
  /// Sadece RecipientID (Alıcı) filtresi kullanır.
  /// Status filtresini Dart tarafında yaparız ki anlık güncellensin.
  Stream<List<MeetingRequestModel>> streamIncomingRequests(String userId) {
    try {
      return _firestore
          .collection('requests')
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAtTimestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MeetingRequestModel.fromMap(doc.data(), doc.id))
            // 👇 KRİTİK FİLTRE: Sadece 'pending' olanları Dart tarafında seçiyoruz.
            // Bu sayede statü 'accepted' olduğu an listeden %100 düşer.
            .where((request) => request.status == RequestStatus.pending)
            .toList();
      });
    } catch (e) {
      print("Stream incoming error: $e");
      return Stream.value([]);
    }
  }

  /// Streams all outgoing requests
  /// Burada filtre yok, gönderdiğim her şeyi göreyim.
  Stream<List<MeetingRequestModel>> streamAllOutgoingRequests(String userId) {
    try {
      return _firestore
          .collection('requests')
          .where('requesterId', isEqualTo: userId)
          .orderBy('createdAtTimestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MeetingRequestModel.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
       print("Stream outgoing error: $e");
       return Stream.value([]);
    }
  }

  // streamOutgoingRequests (Sadece feedback için) metodunu kaldırdık veya kullanmıyoruz,
  // çünkü streamAllOutgoingRequests zaten hepsini getiriyor ve UI'da filtreliyoruz.
  // Ama kodun kırılmaması için boş bırakabiliriz veya aynısını döndürebiliriz.
  Stream<List<MeetingRequestModel>> streamOutgoingRequests(String userId) {
     return streamAllOutgoingRequests(userId);
  }

  Future<void> respondToRequest(String requestId, bool accept) async {
    try {
      final requestDoc = await _firestore.collection('requests').doc(requestId).get();
      if (!requestDoc.exists) throw Exception('Request not found');

      final data = requestDoc.data()!;
      final newStatus = accept ? 'accepted' : 'declined';

      await _firestore.collection('requests').doc(requestId).update({
        'status': newStatus,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      if (accept) {
        final requesterId = data['requesterId'] as String;
        final recipientId = data['recipientId'] as String;
        final requesterName = data['requesterName'] as String;
        final recipientName = data['recipientName'] as String;
        final title = data['title'] as String;
        final requestDescription = data['description'] as String?;
        final startTime = DateTime.parse(data['startTime'] as String);
        final endTime = DateTime.parse(data['endTime'] as String);
        
        // Get recurrence type (default to 'none' if not present for backward compatibility)
        final recurrenceString = data['recurrence'] as String? ?? 'none';
        final recurrence = RecurrenceType.values.firstWhere(
          (e) => e.toString().split('.').last == recurrenceString,
          orElse: () => RecurrenceType.none,
        );

        final requesterUser = await getUser(requesterId);
        final recipientUser = await getUser(recipientId);

        // Calculate duration from start and end time
        final duration = endTime.difference(startTime);

        // Determine how many events to create based on recurrence
        int eventCount = 1;
        Duration increment = const Duration(days: 0);
        
        if (recurrence == RecurrenceType.daily) {
          eventCount = 5; // Today + next 4 days
          increment = const Duration(days: 1);
        } else if (recurrence == RecurrenceType.weekly) {
          eventCount = 4; // Today + next 3 weeks
          increment = const Duration(days: 7);
        }

        // Build description: use request description if available, otherwise default
        final requesterDescription = requestDescription ?? 'Meeting with ${recipientUser?.name ?? recipientName}';
        final recipientDescription = requestDescription ?? 'Meeting with ${requesterUser?.name ?? requesterName}';

        // Create events for each occurrence
        for (int i = 0; i < eventCount; i++) {
          final eventStartTime = startTime.add(increment * i);
          final eventEndTime = eventStartTime.add(duration);

          // Create event for requester
          final requesterEvent = EventModel(
            id: 'event_${requestId}_requester_${i + 1}',
            title: title,
            description: requesterDescription,
            startTime: eventStartTime,
            endTime: eventEndTime,
            userId: requesterId,
            userName: requesterUser?.name ?? requesterName,
            type: EventType.meeting,
            requestId: requestId, // Link recurring events together
          );
          await addEvent(requesterEvent);

          // Create event for recipient
          final recipientEvent = EventModel(
            id: 'event_${requestId}_recipient_${i + 1}',
            title: title,
            description: recipientDescription,
            startTime: eventStartTime,
            endTime: eventEndTime,
            userId: recipientId,
            userName: recipientUser?.name ?? recipientName,
            type: EventType.meeting,
            requestId: requestId, // Link recurring events together
          );
          await addEvent(recipientEvent);
        }
      }
    } catch (e) {
      throw Exception('Failed to respond: $e');
    }
  }

  Future<void> dismissRequest(String requestId) async {
    await _firestore.collection('requests').doc(requestId).delete();
  }
}