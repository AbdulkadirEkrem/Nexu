import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/foundation.dart';
import '../core/secrets/app_secrets.dart';

/// Service for sending push notifications via FCM HTTP v1 API
class FCMSenderService {
  static final FCMSenderService _instance = FCMSenderService._internal();
  factory FCMSenderService() => _instance;
  FCMSenderService._internal();

  AutoRefreshingAuthClient? _authClient;

  /// Initialize the service with service account credentials
  Future<void> initialize() async {
    if (!AppSecrets.isConfigured) {
      print('⚠️ UYARI: AppSecrets ayarlanmamış. Bildirimler çalışmayacak.');
      return;
    }

    try {
      final correctedKey = AppSecrets.privateKey.replaceAll(r'\n', '\n');
      final accountCredentials = ServiceAccountCredentials(
        AppSecrets.clientEmail,
        ClientId(AppSecrets.clientEmail, null),
        AppSecrets.privateKey,
      );

      _authClient = await clientViaServiceAccount(
        accountCredentials,
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );

      print('✅ FCM Sender Service (Yetkili İstemci) başarıyla başlatıldı.');
    } catch (e) {
      print('❌ FCM Başlatma Hatası: $e');
      rethrow;
    }
  }

  /// Send a push notification to a specific device token
  Future<void> sendNotification({
    required String deviceToken,
    required String title,
    required String body,
  }) async {
    // 1. Kontroller
    if (!AppSecrets.isConfigured) {
      print('❌ HATA: AppSecrets eksik, bildirim gönderilemiyor.');
      return;
    }

    if (_authClient == null) {
      print('🔄 Auth Client henüz yok, başlatılıyor...');
      await initialize();
    }

    if (_authClient == null) {
      throw Exception('FCM auth client başlatılamadı!');
    }

    try {
      // 2. URL ve Gövde Hazırlığı
      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/${AppSecrets.projectId}/messages:send',
      );

      final bodyJson = {
        'message': {
          'token': deviceToken,
          'notification': {
            'title': title,
            'body': body,
          },
        },
      };

      print('📤 Bildirim Gönderiliyor... (Token: ${deviceToken.substring(0, 10)}...)');

      // 3. İsteği Gönder (POST)
      final response = await _authClient!.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyJson),
      );

      // 4. SONUÇ ANALİZİ (Dedektif Kısmı 🕵️‍♂️)
      if (response.statusCode == 200) {
        print("✅✅✅ BAŞARILI! Bildirim sunucuya teslim edildi. (HTTP 200) ✅✅✅");
        debugPrint('Detay: $bodyJson');
      } else {
        print("❌❌❌ BİLDİRİM HATASI OLUŞTU! (KOD: ${response.statusCode}) ❌❌❌");
        print("❌ HATA DETAYI: ${response.body}");
        
        throw Exception(
          'Failed to send notification: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ KRİTİK HATA (Exception): $e');
      rethrow;
    }
  }

  /// Dispose the auth client
  void dispose() {
    _authClient?.close();
    _authClient = null;
  }
}