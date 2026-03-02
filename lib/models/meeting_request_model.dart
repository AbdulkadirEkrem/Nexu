enum RequestStatus { pending, accepted, declined }

enum RecurrenceType { none, daily, weekly }

class MeetingRequestModel {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String requesterId;
  final String requesterName;
  final String recipientId;
  final String recipientName;
  final RequestStatus status;
  final DateTime createdAt;
  final RecurrenceType recurrence;

  MeetingRequestModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.requesterId,
    required this.requesterName,
    required this.recipientId,
    required this.recipientName,
    required this.status,
    required this.createdAt,
    this.recurrence = RecurrenceType.none,
  });

  // 👇 İŞTE EKSİK OLAN VE HATAYI ÇÖZECEK KISIM BU:
  factory MeetingRequestModel.fromMap(Map<String, dynamic> data, String documentId) {
    return MeetingRequestModel(
      id: documentId,
      title: data['title'] as String? ?? 'Untitled Meeting',
      description: data['description'] as String?,
      
      // Tarih dönüşümleri (String to DateTime)
      date: data['date'] != null 
          ? DateTime.parse(data['date']) 
          : DateTime.now(),
      
      startTime: data['startTime'] != null 
          ? DateTime.parse(data['startTime']) 
          : DateTime.now(),
      
      endTime: data['endTime'] != null 
          ? DateTime.parse(data['endTime']) 
          : DateTime.now().add(const Duration(hours: 1)),
      
      // Duration (Dakika olarak kaydedilmişti)
      duration: Duration(minutes: data['durationMinutes'] as int? ?? 60),
      
      requesterId: data['requesterId'] as String? ?? '',
      requesterName: data['requesterName'] as String? ?? 'Unknown',
      recipientId: data['recipientId'] as String? ?? '',
      recipientName: data['recipientName'] as String? ?? 'Unknown',
      
      // Status Enum Dönüşümü (String to Enum)
      status: RequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => RequestStatus.pending,
      ),
      
      // Recurrence Enum Dönüşümü (String to Enum)
      recurrence: data['recurrence'] != null
          ? RecurrenceType.values.firstWhere(
              (e) => e.toString().split('.').last == data['recurrence'],
              orElse: () => RecurrenceType.none,
            )
          : RecurrenceType.none,
      
      // CreatedAt (Timestamp veya String gelebilir, garantiye alalım)
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  // Modelden Map'e çevirme (Veritabanına kaydederken lazım olabilir)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationMinutes': duration.inMinutes,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'status': status.toString().split('.').last, // 'pending', 'accepted' vs.
      'recurrence': recurrence.toString().split('.').last, // 'none', 'daily', 'weekly'
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  // Yardımcı Getters (UI için)
  String get formattedDate => "${date.day}/${date.month}/${date.year}";
  String get formattedTime => "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
  String get formattedDuration => "${duration.inMinutes} min";
}