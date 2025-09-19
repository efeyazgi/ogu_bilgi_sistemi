# Security Policy

## Güvenlik Politikası

OGÜ Bilgi Sistemi projesi, kullanıcı güvenliğini ciddiye almaktadır. Bu uygulama ESOGÜ öğrencilerinin hassas verilerini işlediğinden, güvenlik açıklarını ciddi bir şekilde ele almaktayız.

## Desteklenen Sürümler

| Sürüm | Güvenlik Desteği |
| ------- | ------------------ |
| 1.0.x   | ✅ Destekleniyor    |

## Güvenlik Açığı Bildirimi

Güvenlik açığı keşfettiğinizde, lütfen sorumlu şekilde bildirin:

### ✅ Doğru Yol:
- **E-posta**: [efeyazgi@yahoo.com](mailto:efeyazgi@yahoo.com)
- **Konu**: `[SECURITY] OGÜ Bilgi Sistemi - Güvenlik Açığı`
- **İçerik**: Detaylı açıklama ve tekrar edebilme adımları

### ❌ Yanlış Yol:
- Public issue açmayın
- Social media'da paylaşmayın
- Açığı kötüye kullanmayın

## Bildirinin İçermesi Gerekenler

1. **Açık Tanımı**: Ne tür bir güvenlik açığı?
2. **Etki Analizi**: Hangi veriler etkilenebilir?
3. **Tekrar Etme Adımları**: Nasıl reproduce edilir?
4. **Önerilen Çözüm**: Varsa çözüm öneriniz
5. **İletişim**: Size nasıl geri dönülür?

## Yanıt Süreci

1. **24 saat** içinde alındı onayı
2. **7 gün** içinde ilk değerlendirme
3. **30 gün** içinde çözüm veya güncelleme planı
4. Çözüm sonrası **kabul bildirimi**

## Desteklenen Güvenlik Alanları

✅ **Kimlik Doğrulama**: ESOGÜ giriş güvenliği  
✅ **Veri İletimi**: HTTPS/Network güvenliği  
✅ **Yerel Depolama**: SharedPreferences güvenliği  
✅ **Uygulama İzinleri**: Android permissions  
✅ **Kod Güvenliği**: ProGuard obfuscation  

## Güvenlik En İyi Uygulamaları

### Kullanıcılar İçin:
- Uygulamayı sadece güvenilir kaynaklardan indirin
- Cihazınızı güncel tutun
- Şifrenizi kimseyle paylaşmayın
- Public Wi-Fi'da kullanmaktan kaçının

### Geliştiriciler İçin:
- Sensitive data'yı log'a yazmayın
- API key'leri kod'a gömmeyin
- Input validation yapın
- Secure storage kullanın

## Teşekkür

Güvenlik açığı bildiren kişilere:
- **Hall of Fame** listesinde yer verilir
- Katkılarınız **README**'de belirtilir  
- Çözüm sonrası **teşekkür mesajı** gönderilir

## İletişim

**Proje Sahibi**: Efe YAZGI  
**E-posta**: efeyazgi@yahoo.com  
**LinkedIn**: https://www.linkedin.com/in/efeyazgi  
**GitHub**: https://github.com/efeyazgi  

---

*Bu güvenlik politikası, projenin güvenli gelişimini sağlamak için oluşturulmuştur.*