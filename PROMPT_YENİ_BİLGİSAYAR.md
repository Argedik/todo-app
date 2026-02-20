# Notlarım Uygulaması – Yeni Bilgisayarda Devam Etme Rehberi

Bu proje, Flutter ile geliştirilen bir not/görev/toplantı yönetim uygulamasıdır. Firebase, Riverpod, GoRouter kullanılmaktadır.

---

## ✅ TAMAMLANAN İŞLER

### 1. Proje Yapısı
- Clean Architecture (presentation / domain / data)
- Feature tabanlı klasör yapısı
- Tüm ekranlar ve modeller yazıldı

### 2. Kurulmuş Özellikler
- Google Sign-In ile giriş
- Görevler (Yapacaklarım / Yaptıklarım, checkbox, reminder)
- Aktiviteler
- AI Kural Setleri
- Takvim ve etkinlik yönetimi
- AI ile üretilen mesajlar listesi
- Ayarlar ekranı
- 5’li bottom navigation (ortada animasyonlu FAB)
- 2 aşamalı tarih+saat reminder picker

### 3. Firebase / FlutterFire
- `flutterfire configure` çalıştırıldı
- `lib/firebase_options.dart` oluşturuldu
- Platformlar: android, ios, macos, web, windows

### 4. Backend (Cloud Functions)
- TypeScript kuruldu
- `generateMeetingMessage`, `exportToSheets`, `exportToDrive`, `sendScheduledReminders` fonksiyonları yazıldı
- `backend/functions/node_modules` yüklendi
- `node_modules` `.gitignore` içinde

### 5. Diğer
- `.gitignore` güncellendi (node_modules, firebase debug log, vb.)
- Unit ve widget testler yazıldı (23 test geçiyor)

---

## 🔜 YAPILACAKLAR (Sırayla)

### Adım 1: Yeni PC’de Projeyi Clone Et
```bash
git clone <repo_url> todo_app
cd todo_app
```

### Adım 2: Flutter Bağımlılıkları
```bash
flutter pub get
```

### Adım 3: Firebase Options Kontrolü
`lib/firebase_options.dart` varsa bir şey yapma.  
Yoksa veya hata alıyorsan:
```bash
# PATH’e pub-cache ekle (gerekirse)
export PATH="$PATH:$HOME/.pub-cache/bin"

# FlutterFire CLI kur
dart pub global activate flutterfire_cli

# Yapılandır
flutterfire configure
```
- Firebase projesi: `todo-app-bbd0d (todo-app)`
- Platformlar: android, ios, macos, web (veya istediğin platformlar)

### Adım 4: main.dart Firebase Başlatma Kontrolü
`lib/main.dart` içinde mutlaka şu satır olmalı:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Adım 5: Backend Bağımlılıkları (Cloud Functions)
```bash
cd backend/functions
npm install
cd ../..
```

### Adım 6: Firebase Console Ayarları
- [Firebase Console](https://console.firebase.google.com/) → `todo-app-bbd0d`
- **Authentication** → Sign-in method → **Google**’ı aktifleştir
- **Firestore Database** → Veritabanı oluştur (test modunda başlayabilirsin)
- **Cloud Messaging** → (Bildirimler için, sonra yapılabilir)

### Adım 7: Emülatörde Çalıştırma
```bash
# Emülatörleri listele
flutter emulators

# Bir emülatör başlat
flutter emulators --launch <emülatör_adı>

# Uygulamayı çalıştır
flutter run
```

### Adım 8: (İsteğe Bağlı) Cloud Functions Deploy
```bash
cd backend/functions
npm run build
firebase deploy --only functions
```
`OPENAI_API_KEY` için: `firebase functions:config:set openai.key="sk-..."`

---

## 📁 ÖNEMLİ DOSYA YOLLARI

| Dosya | Açıklama |
|-------|----------|
| `lib/main.dart` | Uygulama girişi, Firebase init |
| `lib/firebase_options.dart` | FlutterFire config (gitignore’da olabilir) |
| `lib/app/router.dart` | GoRouter tanımları |
| `lib/shared/providers/providers.dart` | Riverpod provider’lar |
| `backend/functions/src/` | Cloud Functions kaynak kodu |

---

## ⚠️ YENİ PC’DE DİKKAT EDİLECEKLER

1. **Firebase options**: `firebase_options.dart` proje bazlıdır; clone sonrası `flutterfire configure` gerekebilir.
2. **Node.js**: Backend için Node.js 18+ kurulu olmalı.
3. **Flutter**: `flutter doctor` ile SDK ve platform kurulumunu kontrol et.
4. **Android Studio**: Android emülatör için gereklidir.

---

## 📌 HIZLI BAŞLANGIÇ (Yeni PC)

```bash
cd todo_app
flutter pub get
cd backend/functions && npm install && cd ../..
flutterfire configure   # firebase_options yoksa
flutter run
```

---

*Bu dosya projenin mevcut durumunu ve devam adımlarını özetler. Güncellemek için buraya ekleme yapılabilir.*
