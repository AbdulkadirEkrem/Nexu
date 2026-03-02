## Nexu Planner

![Nexu Planner ekran görüntüsü](Nexu.png)

Takım takvimi, mesai planlama ve toplantı isteklerini yönetmek için geliştirilen Flutter tabanlı bir mobil uygulama.

Uygulama ile:
- Aynı şirket domain’ine sahip ekip arkadaşlarını görebilir
- Kendi takviminize etkinlik ekleyip yönetebilir
- Ekip arkadaşlarınızın uygunluk durumunu (Busy/Available) görebilir
- Uygun slotlar üzerinden toplantı isteği gönderebilir, gelen istekleri onaylayıp/reddedebilir
- Firebase Cloud Messaging (FCM) ile anlık bildirim alabilirsiniz.

### Teknik Özellikler (Özet)
- **State Management**: `provider`
- **Routing**: `go_router`
- **Veritabanı**: `cloud_firestore`
- **Kimlik Doğrulama**: `firebase_auth`
- **Push Bildirimleri**: `firebase_messaging` + `flutter_local_notifications`
- **Takvim**: `table_calendar`

Ayrıntılı modül ve mimari özeti için `PROJECT_FEATURE_SUMMARY.md` dosyasına bakabilirsiniz.

### Kurulum
1. Flutter SDK kurulu olduğundan emin olun.
2. Depoyu klonlayın:
   ```bash
   git clone <REPO_URL>
   cd nexu_planner
   ```
3. Paketleri indirin:
   ```bash
   flutter pub get
   ```
4. Çalıştırın:
   ```bash
   flutter run
   ```

### Gizli Bilgiler ve Ortam Değişkenleri
Bu repo **açık kaynak** olarak GitHub’a yüklenecekse aşağıdaki dosyalar **KESİNLİKLE commit edilmemelidir**:
- `lib/core/secrets/app_secrets.dart` → Firebase Service Account `projectId`, `clientEmail`, `privateKey`
- `android/app/google-services.json` → Android Firebase konfigürasyonu ve API key
- (Varsa) `ios/Runner/GoogleService-Info.plist`
- (Varsa) imzalama/keystore dosyaları: `android/app/*.jks`, `android/app/key.properties` vb.

Önerilen yaklaşım:
- Gerçek gizli dosyaları lokalinizde tutun.
- Repoda sadece örnek dosyalar bulundurun:
  - `lib/core/secrets/app_secrets.example.dart`
  - `android/app/google-services.example.json`
- CI/production ortamında bu dosyaları manuel veya gizli değişkenler üzerinden sağlayın.

### Geliştirme Notları
- Gerçek FCM/servis hesap bilgilerini **asla** Git history’sine koymayın.
- Eğer daha önce commit ettiyseniz, GitHub’a push etmeden önce:
  - Dosyadaki gerçek anahtarları silin veya dummy değerler ile değiştirin.
  - İlgili dosyaları `.gitignore` içine ekleyin.

### Lisans
Bu proje için uygun gördüğünüz lisansı (`MIT`, `Apache-2.0` vb.) ekleyebilirsiniz.
