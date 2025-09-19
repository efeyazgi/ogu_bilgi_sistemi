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

## 🔒 Güvenlik ve Gizlilik - Sık Sorulan Sorular

### "Şifremi çalar mı? Güvenli mi?"
**✅ EVET, GÜVENLİ!** İşte kanıtları:

- **Şifreler SAKLANMIYOR**: Sadece ESOGÜ serverına direkt gönderiliyor, uygulamada tutulmuyor
- **Yerel kayıt sadece "Beni Hatırla" seçeneği**: Şifrelenmiş SharedPreferences'da sadece öğrenci numarası
- **Açık kaynak kod**: Tüm kodları GitHub'da inceleyebilirsiniz
- **Sunucu yok**: Hiçbir veri dış sunucuya gönderilmiyor

### "Verilerim nereye gidiyor?"
**📍 Sadece ESOGÜ'ye:**
- Giriş bilgileri → **ESOGÜ serverı** (ogubs.ogu.edu.tr)
- Not/program verileri ← **ESOGÜ'den geliyor**
- **BAŞKA HİÇBİR YERE GİTMİYOR!**

### "Nasıl emin olabilirim?"
**🔍 Kendiniz kontrol edin:**
```bash
# Kodu indirin ve inceleyin
git clone https://github.com/efeyazgi/ogu_bilgi_sistemi.git
# Network trafiğini kontrol edin (Android Studio/Wireshark)
# Sadece ogubs.ogu.edu.tr'ye istek gidiyor
```

### "Virüs var mı?"
**🛡️ Kesinlikle yok:**
- **VirusTotal taraması**: APK'yı test ettirin
- **GitHub Actions**: Otomatik güvenlik taraması
- **Açık kaynak**: Zararlı kod gizlenemez
- **Flutter framework**: Google'ın güvenli platformu

### "Şifrem nasıl korunuyor?"
**🔐 Katmanlı koruma:**
1. **Network seviyesi**: HTTPS şifreleme
2. **Kod seviyesi**: ProGuard obfuscation
3. **Storage seviyesi**: Android Keystore (beni hatırla için)
4. **Session yönetimi**: Güvenli token kullanımı

### "Hangi izinleri istiyor?"
**📋 Minimal izinler:**
- **INTERNET**: ESOGÜ'ye bağlanmak için (zorunlu)
- **BAŞKA HİÇBİR İZİN YOK**: Kamera, konum, dosya, vb. YOK

### "Offline çalışıyor, bu güvenli mi?"
**💾 Yerel saklama detayları:**
- **Sadece not/program verileri**: Hassas bilgi değil
- **Şifrelenmiş storage**: Android SharedPreferences
- **Manuel temizleme**: Ayarlardan silebilirsiniz
- **Uygulama silindiğinde**: Tüm veriler kalıcı olarak siliniyor

### "Kişisel verilerimi kim görebilir?"
**👥 Erişim seviyeleri:**
- **Siz**: Sadece kendi verilerinizi görürsünüz
- **ESOGÜ**: Zaten sahip oldukları veriler
- **Geliştirici (ben)**: HİÇBİR VERİNİZE ERİŞİMİM YOK
- **3. partiler**: HİÇBİR VERİ PAYLAŞILMIYOR

### "APK nereden indirmeliyim?"
**📥 Güvenli indirme yerleri:**
- **GitHub Releases**: https://github.com/efeyazgi/ogu_bilgi_sistemi/releases
- **Direkt APK linki**: Repository'deki artifacts
- **❌ DİKKAT**: Play Store, APKPure gibi yerlerden değil!

### "Bu uygulamayı neden güvenmeliyim?"
**🎯 Güven faktörleri:**
1. **Açık kaynak**: Her satır kod görünür
2. **GitHub profili**: Geliştirici geçmişi şeffaf
3. **LinkedIn profili**: Profesyonel kimlik
4. **Eğitim amaçlı**: Ticari kazanç yok
5. **ESOGÜ öğrencisi**: Aynı topluluktan

### "Sorun yaşarsam ne yapmalıyım?"
**🆘 Destek kanalları:**
- **GitHub Issues**: Bug raporu için
- **E-posta**: efeyazgi@yahoo.com
- **LinkedIn**: Direkt mesaj
- **Güvenlik sorunu**: SECURITY.md dosyasındaki talimatlar

## ⚠️ Önemli Notlar

- Bu uygulama resmi ESOGÜ uygulaması değildir
- Öğrenci bilgileri güvenli şekilde işlenir ve saklanmaz
- Uygulama sadece eğitim amaçlı geliştirilmiştir
- ESOGÜ sistemindeki değişiklikler uygulamanın çalışmasını etkileyebilir

### 🛡️ Güvenlik Sözü
**Bu uygulamayı kullanan her öğrenci arkadaşıma söz veriyorum:**
- Verileriniz asla 3. partilerle paylaşılmayacak
- Güvenlik açığı bulunursa derhal düzeltilecek
- Şeffaflık ilkesinden asla taviz verilmeyecek
- Topluluk yararı ticari kazançtan önce gelecek

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
  <p><strong>Efe YAZGI</strong> - 2025</p>
</div>
