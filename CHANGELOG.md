# Changelog

Bu dosya, projedeki tüm önemli değişiklikleri belgeler.

Format [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) standardına dayanmaktadır,
ve bu proje [Semantic Versioning](https://semver.org/spec/v2.0.0.html) kullanmaktadır.

## [Unreleased]

### Planning
- iOS platform desteği
- Web platform desteği  
- Push notifications
- Dark theme toggle
- Biometric authentication
- Semester GPA comparison
- Course performance analytics

## [1.0.0] - 2025-09-20

### Added - İlk Sürüm 🎉

#### 🔐 Kimlik Doğrulama
- ESOGÜ öğrenci bilgi sistemi entegrasyonu
- CAPTCHA doğrulama desteği
- "Beni hatırla" özelliği ile otomatik giriş
- Güvenli session yönetimi
- Şifre görünürlük toggle butonu

#### 📊 Not Sistemi
- Dönemlik not görüntüleme
- Harf notları ve sayısal karşılıkları
- GPA ile karşılaştırmalı renk kodlaması
- Not detayları ve ders bilgileri
- Offline not görüntüleme desteği

#### 📅 Ders Programı
- Haftalık program görünümü
- Günlük ders listesi
- Interaktif ders tablosu
- Ders detay sayfaları
- Sade/Tam görünüm seçenekleri
- Ders renk kişiselleştirmesi

#### 🧮 GPA Hesaplaması
- Otomatik GPA hesaplama
- Dönemlik ortalama gösterimi
- Detaylı akademik durum analizi
- Credit/ECTS bilgileri

#### 👨‍🏫 Öğretim Üyesi İletişimi
- Öğretim üyesi e-posta bilgileri
- Clipboard'a e-posta kopyalama
- 30+ öğretim üyesi veri tabanı

#### 🔗 External Linkler
- GitHub profil linki
- LinkedIn profil linki
- External browser'da açılma
- Hata durumu yönetimi

#### 🎨 UI/UX
- Modern Material Design
- ESOGÜ kurumsal renkleri
- Poppins font ailesi
- Responsive tasarım
- Tablet desteği
- Loading states
- Error handling
- SnackBar bildirimleri

#### 🔧 Teknik Özellikler
- Flutter 3.8.1+ desteği
- BLoC state management
- SharedPreferences ile yerel depolama
- HTTP requests & HTML parsing
- Network security configuration
- ProGuard obfuscation
- APK boyut optimizasyonu
- Android 5.0+ desteği

#### 📱 Platform Desteği
- Android 5.0+ (API 21+)
- ARM64 & x86_64 architecture
- Adaptive icons
- Network permissions

### Technical Details

#### Dependencies
- `flutter_bloc ^9.1.1` - State management
- `http ^1.2.2` - Network requests  
- `html ^0.15.4` - HTML parsing
- `beautiful_soup_dart ^0.3.0` - Web scraping
- `shared_preferences ^2.2.3` - Local storage
- `url_launcher ^6.3.0` - External links
- `google_fonts ^6.2.1` - Typography
- `connectivity_plus ^7.0.0` - Network status
- `equatable ^2.0.5` - Value equality

#### Build Configuration
- Min SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Compile SDK: 35
- ProGuard enabled for release builds
- Resource shrinking enabled
- Network security config for HTTP traffic

#### Performance Metrics
- APK size: 24.0 MB (release)
- Cold start: < 2s
- Network requests: Optimized caching
- Memory usage: Efficient BLoC management

### Security
- Network traffic secured with domain-specific cleartext permissions
- Sensitive data not logged
- ProGuard code obfuscation
- No hardcoded API keys
- Secure SharedPreferences usage

### Known Issues
- None currently reported

### Migration Guide
- İlk sürüm, migration gerekmez

---

## Versiyon Notasyonu

Bu proje [Semantic Versioning](https://semver.org/) kullanır:
- `MAJOR.MINOR.PATCH` formatında
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## Kategoriler

- `Added` - Yeni özellikler
- `Changed` - Var olan fonksiyonlarda değişiklikler
- `Deprecated` - Yakında kaldırılacak özellikler
- `Removed` - Kaldırılan özellikler
- `Fixed` - Bug fix'ler
- `Security` - Güvenlik güncellemeleri