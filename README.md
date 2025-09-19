# OGÜ Bilgi Sistemi

<div align="center">
  <img src="assets/images/app_logo.png" alt="OGÜ Bilgi Sistemi Logo" width="100" height="100">
  <h3>Eskişehir Osmangazi Üniversitesi Öğrenci Not Sistemi</h3>
  <p><strong>ESOGÜ</strong> öğrencileri için geliştirilmiş modern mobil uygulama</p>
</div>

## 📱 Uygulama Hakkında

**OGÜ Bilgi Sistemi**, Eskişehir Osmangazi Üniversitesi öğrencilerinin not durumlarını, ders programlarını ve akademik bilgilerini kolay ve hızlı bir şekilde görüntüleyebilmeleri için geliştirilmiş modern bir Flutter uygulamasıdır.

### ✨ Özellikler

- 🔐 **Güvenli Giriş**: ESOGÜ öğrenci bilgileri ile güvenli giriş
- 📊 **Not Görüntüleme**: Dönemlik ve genel not durumu görüntüleme
- 📅 **Ders Programı**: Haftalık ders programını görüntüleme
- 🧮 **GPA Hesaplama**: Otomatik GPA (Not Ortalaması) hesaplama
- 💾 **Offline Çalışma**: İnternet bağlantısı olmadan da önceki verilerinizi görüntüleyin
- 🌙 **Dark/Light Mode**: Sistem temasına uyumlu otomatik tema desteği
- 📱 **Responsive Tasarım**: Telefon ve tablet uyumlu responsive tasarım
- 🔄 **Otomatik Yenileme**: Verilerinizi güncel tutmak için otomatik yenileme

### 🎯 Ana Fonksiyonlar

1. **Kimlik Doğrulama**
   - ESOGÜ öğrenci numarası ve şifre ile giriş
   - CAPTCHA doğrulaması
   - Kullanıcı bilgilerini hatırlama özelliği

2. **Not Yönetimi**
   - Dönemlik notların görüntülenmesi
   - Harf notları ve sayısal karşılıkları
   - Not renkli görüntüleme (geçti/kaldı durumu)

3. **Ders Programı**
   - Haftalık ders programı görüntüleme
   - Ders saatleri ve sınıf bilgileri
   - Öğretim üyesi iletişim bilgileri

4. **GPA Hesaplama**
   - Otomatik GPA hesaplama
   - Dönemlik ve genel ortalama
   - Detaylı akademik durum

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK (3.8.1+)
- Dart SDK
- Android Studio / VS Code
- Android SDK (API 21+)

### Geliştirme Ortamı Kurulumu

1. **Proje dosyalarını klonlayın:**
   ```bash
   git clone <repo-url>
   cd ogu_not_sistemi_v2
   ```

2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Icon'ları oluşturun:**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. **Uygulamayı çalıştırın:**
   ```bash
   flutter run
   ```

### APK Build

**Release APK oluşturmak için:**
```bash
flutter build apk --release
```

APK dosyası `build/app/outputs/flutter-apk/app-release.apk` konumunda oluşturulacaktır.

## 🏗️ Proje Yapısı

```
lib/
├── core/                       # Çekirdek fonksiyonlar
│   ├── services/              # API ve depolama servisleri
│   │   ├── ogubs_service.dart # ESOGÜ web servisi
│   │   └── storage_service.dart # Yerel depolama
│   └── theme/                 # Tema dosyaları
│       ├── app_colors.dart    # Renk paleti
│       └── app_theme.dart     # Tema konfigürasyonu
├── features/                  # Özellik modülleri
│   ├── auth/                  # Kimlik doğrulama
│   │   ├── presentation/
│   │   │   ├── bloc/         # BLoC state management
│   │   │   ├── pages/        # Giriş sayfaları
│   │   │   └── widgets/      # UI bileşenleri
│   ├── grades/                # Not sistemi
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── schedule/              # Ders programı
│   └── gpa/                   # GPA hesaplama
└── main.dart                  # Ana uygulama giriş noktası

assets/
├── images/                    # Logo ve görseller
│   ├── app_logo.png          # Ana logo
│   └── app_logo_foreground.png # Adaptive ikon
├── data/
│   └── lecturer_emails.json  # Öğretim üyesi iletişim bilgileri
└── course_list.md            # Ders listesi
```

## 🛠️ Kullanılan Teknolojiler

### Framework & Dil
- **Flutter**: 3.8.1+
- **Dart**: SDK 3.8.1+

### State Management
- **flutter_bloc**: State management için
- **equatable**: Value equality için

### HTTP & Parsing
- **http**: HTTP istekleri
- **html**: HTML parsing
- **beautiful_soup_dart**: Web scraping

### UI & UX
- **google_fonts**: Modern tipografi (Poppins)
- **flutter_launcher_icons**: Uygulama ikonları

### Storage & Utilities
- **shared_preferences**: Yerel veri depolama
- **connectivity_plus**: Bağlantı durumu kontrolü
- **url_launcher**: External link açma

## 📋 Özellik Detayları

### 🔐 Kimlik Doğrulama
- ESOGÜ öğrenci bilgi sistemi ile entegrasyon
- Session yönetimi ve güvenlik
- CAPTCHA çözümleme
- Otomatik giriş (beni hatırla)

### 📊 Not Sistemi
- Dinamik not getirme ve görüntüleme
- Harf notu renklendirme sistemi
- GPA ile karşılaştırmalı renklendirme
- Offline not görüntüleme

### 📅 Ders Programı
- Haftalık program görüntüleme
- Ders detayları ve öğretim üyesi bilgileri
- Sınıf ve saat bilgileri

### 🧮 GPA Hesaplama
- Otomatik GPA hesaplama algoritması
- Dönemlik ve genel ortalama
- Detaylı akademik analiz

## 🎨 Tasarım

Uygulama, modern material design ilkelerine uygun olarak tasarlanmıştır:

- **Renk Paleti**: ESOGÜ kurumsal renkleri
- **Tipografi**: Poppins font ailesi
- **Layout**: Responsive ve kullanıcı dostu
- **Dark Mode**: Sistem teması desteği

## 🔧 Konfigürasyon

### Android Konfigürasyonu
- **minSdkVersion**: 21 (Android 5.0+)
- **targetSdkVersion**: En güncel Android sürümü
- **Package Name**: `com.ogu.bilgisistemi`

### Build Optimizasyonları
- ProGuard obfuscation
- Resource shrinking
- APK boyut optimizasyonu

## 📱 Desteklenen Platformlar

- ✅ **Android**: API 21+ (Android 5.0+)
- ⏳ **iOS**: Gelecek sürümlerde (hazır kod mevcut)
- ⏳ **Web**: Gelecek sürümlerde
- ⏳ **Windows**: Gelecek sürümlerde

## 🤝 Katkıda Bulunma

Bu proje açık kaynak değildir ve ESOGÜ öğrencileri için özel olarak geliştirilmiştir. Önerilerinizi ve hata raporlarınızı geliştiriciye iletebilirsiniz.

## 📞 İletişim

**Geliştirici**: Efe YAZGI
- **LinkedIn**: [efeyazgi](https://www.linkedin.com/in/efeyazgi)
- **GitHub**: [efeyazgi](https://github.com/efeyazgi)

## 📄 Lisans

Bu uygulama, Eskişehir Osmangazi Üniversitesi öğrencileri için özel olarak geliştirilmiştir. Ticari kullanımı yasaktır.

## ⚠️ Önemli Notlar

- Bu uygulama resmi ESOGÜ uygulaması değildir
- Öğrenci bilgileri güvenli şekilde işlenir ve saklanmaz
- Uygulama sadece eğitim amaçlı geliştirilmiştir
- ESOGÜ sistemindeki değişiklikler uygulamanın çalışmasını etkileyebilir

## 📈 Versiyon Geçmişi

### v1.0.0 (İlk Sürüm)
- ✅ ESOGÜ entegrasyonu
- ✅ Not görüntüleme sistemi
- ✅ Ders programı modülü
- ✅ GPA hesaplama
- ✅ Modern UI/UX
- ✅ Offline çalışma desteği

---

<div align="center">
  <p>❤️ ESOGÜ öğrencileri için sevgiyle geliştirilmiştir</p>
  <p><strong>Efe YAZGI</strong> - 2024</p>
</div>
