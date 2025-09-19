# Privacy Policy / Gizlilik Politikası

**Son Güncelleme: 20 Eylül 2025**

## 🇹🇷 Türkçe

### Genel Bakış
OGÜ Bilgi Sistemi, Eskişehir Osmangazi Üniversitesi öğrencilerinin akademik bilgilerine güvenli erişim sağlamak amacıyla geliştirilmiş açık kaynak bir mobil uygulamadır. Bu gizlilik politikası, uygulamanın veri toplama, saklama ve işleme uygulamalarını açıklar.

### Veri Toplama Politikası

#### 🚫 Toplamadığımız Veriler
- **Kişisel şifreler**: Asla saklanmaz, sadece ESOGÜ sunucusuna iletilir
- **Biyometrik veriler**: Parmak izi, yüz tanıma vb. kullanılmaz
- **Konum bilgileri**: GPS/konum verisi toplanmaz
- **Cihaz bilgileri**: IMEI, telefon numarası vb. erişilmez
- **Kamera/Mikrofon**: Bu izinler istenmez
- **Kişiler/SMS**: Bu verilere erişilmez
- **Dosya sistemi**: Harici depolama erişimi yoktur

#### ✅ Topladığımız Sınırlı Veriler
1. **Öğrenci Numarası** (isteğe bağlı, "Beni Hatırla" seçilirse)
   - **Amaç**: Tekrar giriş kolaylığı
   - **Saklama**: Yerel cihazda, şifrelenmiş
   - **Süre**: Kullanıcı silene kadar

2. **Akademik Veriler** (ESOGÜ'den gelen)
   - **İçerik**: Notlar, ders programı, GPA
   - **Amaç**: Offline görüntüleme
   - **Saklama**: Yerel cihazda, geçici
   - **Süre**: Cache temizleme veya uygulama silinene kadar

### Veri Saklama ve Güvenlik

#### 🔒 Yerel Saklama (Cihazınızda)
```
Saklanan Veriler:
├── Öğrenci numarası (opsiyonel, şifreli)
├── Son çekilen notlar (cache)
├── Ders programı (cache) 
└── GPA hesaplama geçmişi (geçici)

Saklanmayan Veriler:
├── ❌ Şifreler (asla saklanmaz)
├── ❌ CAPTCHA çözümleri
├── ❌ Session token'ları
└── ❌ Kişisel kimlik bilgileri
```

#### 🛡️ Güvenlik Önlemleri
- **Şifreleme**: Android SharedPreferences encryption
- **Network**: HTTPS protokolü zorunlu
- **Kod**: ProGuard obfuscation
- **İzinler**: Minimal android permission model

### Veri Paylaşımı

#### ❌ Asla Paylaşmadığımız Durumlar
- 3. parti reklam şirketleri ❌
- Veri satışı yapılmaz ❌
- Analytics servisleri ❌
- Cloud backup servisleri ❌
- Sosyal medya entegrasyonları ❌

#### ✅ Tek Veri Akışı: ESOGÜ
```
Kullanıcı → [OGÜ App] → ESOGÜ Sunucu
                ↑
         (Sadece bu yön)
```

### Kullanıcı Hakları (KVKK/GDPR Uyumlu)

#### 📋 Haklarınız
1. **Erişim Hakkı**: Hangi verilerinizin saklandığını öğrenme
2. **Düzeltme Hakkı**: Yanlış verilerin düzeltilmesini isteme
3. **Silme Hakkı**: Tüm verilerinizin silinmesini isteme
4. **Taşınabilirlik Hakkı**: Verilerinizi başka platforma aktarma
5. **İtiraz Hakkı**: Veri işlemeye itiraz etme

#### 🗑️ Veri Silme Yöntemleri
```
Yöntem 1: Uygulama ayarlarından
- Ayarlar → Verileri Temizle → Onayla

Yöntem 2: Android sistem ayarları
- Ayarlar → Uygulamalar → OGÜ Bilgi Sistemi → Depolama → Verileri Sil

Yöntem 3: Uygulamayı kaldırma
- Uygulama silindiğinde tüm veriler otomatik silinir
```

### Çocuk Gizliliği
- Bu uygulama 18+ yaş grubu için tasarlanmıştır
- 18 yaş altı kullanımda veli onayı önerilir
- Özel çocuk veri koruması uygulanmaktadır

### Değişiklik Bildirimi
- Bu politikada yapılan değişiklikler GitHub repository'de duyurulur
- Major değişikliklerde uygulama içi bildirim yapılır
- Kullanıcılar değişiklikleri reddetme hakkına sahiptir

### İletişim
Gizlilik konularında:
- **E-posta**: efeyazgi@yahoo.com
- **GitHub**: https://github.com/efeyazgi/ogu_bilgi_sistemi/issues
- **Konu Başlığı**: "[PRIVACY] Gizlilik Politikası"

---

## 🇺🇸 English

### Overview
OGÜ Information System is an open-source mobile application designed to provide secure access to academic information for Eskişehir Osmangazi University students. This privacy policy explains the app's data collection, storage, and processing practices.

### Data Collection Policy

#### 🚫 Data We DO NOT Collect
- **Personal passwords**: Never stored, only transmitted to ESOGÜ servers
- **Biometric data**: No fingerprint, face recognition, etc.
- **Location information**: No GPS/location data collection
- **Device information**: No access to IMEI, phone numbers, etc.
- **Camera/Microphone**: These permissions are not requested
- **Contacts/SMS**: No access to this data
- **File system**: No external storage access

#### ✅ Limited Data We DO Collect
1. **Student Number** (optional, only if "Remember Me" is selected)
   - **Purpose**: Login convenience
   - **Storage**: Local device, encrypted
   - **Duration**: Until user deletes

2. **Academic Data** (from ESOGÜ servers)
   - **Content**: Grades, schedule, GPA
   - **Purpose**: Offline viewing
   - **Storage**: Local device, temporary
   - **Duration**: Until cache clearing or app deletion

### Data Storage and Security

#### 🔒 Local Storage (On Your Device)
```
Stored Data:
├── Student number (optional, encrypted)
├── Last fetched grades (cache)
├── Course schedule (cache)
└── GPA calculation history (temporary)

NOT Stored:
├── ❌ Passwords (never stored)
├── ❌ CAPTCHA solutions
├── ❌ Session tokens
└── ❌ Personal identity information
```

#### 🛡️ Security Measures
- **Encryption**: Android SharedPreferences encryption
- **Network**: HTTPS protocol mandatory
- **Code**: ProGuard obfuscation
- **Permissions**: Minimal android permission model

### Data Sharing

#### ❌ We NEVER Share With
- 3rd party advertising companies ❌
- No data sales ❌
- Analytics services ❌
- Cloud backup services ❌
- Social media integrations ❌

#### ✅ Single Data Flow: ESOGÜ Only
```
User → [OGÜ App] → ESOGÜ Server
              ↑
      (Only this direction)
```

### User Rights (KVKK/GDPR Compliant)

#### 📋 Your Rights
1. **Access Right**: Learn what data is stored
2. **Rectification Right**: Request correction of incorrect data
3. **Erasure Right**: Request deletion of all data
4. **Portability Right**: Transfer data to another platform
5. **Objection Right**: Object to data processing

#### 🗑️ Data Deletion Methods
```
Method 1: From app settings
- Settings → Clear Data → Confirm

Method 2: Android system settings
- Settings → Apps → OGÜ Information System → Storage → Clear Data

Method 3: Uninstalling the app
- All data automatically deleted when app is uninstalled
```

### Children's Privacy
- This application is designed for 18+ age group
- Parental consent recommended for under 18 usage
- Special child data protection measures applied

### Change Notification
- Changes to this policy announced on GitHub repository
- In-app notification for major changes
- Users have the right to reject changes

### Contact
For privacy matters:
- **Email**: efeyazgi@yahoo.com
- **GitHub**: https://github.com/efeyazgi/ogu_bilgi_sistemi/issues
- **Subject**: "[PRIVACY] Privacy Policy"

---

*Bu gizlilik politikası, KVKK (Türkiye) ve GDPR (AB) düzenlemelerine uyumlu olarak hazırlanmıştır.*

*This privacy policy is prepared in compliance with KVKK (Turkey) and GDPR (EU) regulations.*