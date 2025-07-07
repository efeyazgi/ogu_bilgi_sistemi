import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser; // HTML ayrıştırma için
import 'package:html/dom.dart' as dom; // DOM elementlerine erişim için
import 'package:ogu_not_sistemi/features/auth/data/models/login_page_data.dart';
import 'package:ogu_not_sistemi/features/grades/data/models/academic_summary_model.dart';
import 'package:ogu_not_sistemi/features/grades/data/models/course_grade_model.dart';
import 'package:ogu_not_sistemi/features/grades/data/models/grades_page_data.dart';

class OgubsService {
  final http.Client _client;
  final String _loginUrl = "https://ogubs1.ogu.edu.tr/giris.aspx";
  final String _sinavSonucUrl = "https://ogubs1.ogu.edu.tr/SinavSonuc.aspx";
  final String _notDokumUrl = "https://ogubs1.ogu.edu.tr/NotDokum.aspx";

  // Session yönetimi için cookieleri saklayacak bir yapı (Basit bir map)
  // Gerçek bir uygulamada daha gelişmiş bir cookie jar (örn: cookie_jar paketi) kullanılabilir.
  final Map<String, String> _cookies = {};

  OgubsService({http.Client? client}) : _client = client ?? http.Client();

  // Cookieleri header'a eklemek için yardımcı metot
  Map<String, String> _getHeaders() {
    final headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      // Diğer gerekli headerlar buraya eklenebilir
    };
    if (_cookies.isNotEmpty) {
      headers['Cookie'] = _cookies.entries
          .map((e) => '${e.key}=${e.value}')
          .join('; ');
    }
    return headers;
  }

  // Cookieleri güncellemek için yardımcı metot
  void _updateCookies(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      // Basit cookie ayrıştırma, birden fazla cookie ve path/domain gibi detayları işlemez.
      // Örnek: ASP.NET_SessionId=xyz; path=/; HttpOnly
      var cookies = rawCookie.split(',');
      for (var cookieString in cookies) {
        var parts = cookieString.split(';');
        if (parts.isNotEmpty) {
          var cookieParts = parts[0].split('=');
          if (cookieParts.length == 2) {
            _cookies[cookieParts[0].trim()] = cookieParts[1].trim();
          }
        }
      }
    }
  }

  Future<LoginPageData> fetchLoginPageData() async {
    try {
      final response = await _client
          .get(Uri.parse(_loginUrl), headers: _getHeaders())
          .timeout(const Duration(seconds: 15));

      _updateCookies(response); // Session cookie'sini al

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        final String? viewState = document
            .querySelector('input[name="__VIEWSTATE"]')
            ?.attributes['value'];
        final String? viewStateGenerator = document
            .querySelector('input[name="__VIEWSTATEGENERATOR"]')
            ?.attributes['value'];
        final String? eventValidation = document
            .querySelector('input[name="__EVENTVALIDATION"]')
            ?.attributes['value'];
        final String? captchaRelativeUrl = document
            .querySelector('img#kappi2')
            ?.attributes['src'];

        if (viewState == null ||
            viewStateGenerator == null ||
            eventValidation == null ||
            captchaRelativeUrl == null) {
          throw Exception(
            'Giriş sayfası verileri (VIEWSTATE, CAPTCHA URL vb.) ayrıştırılamadı.',
          );
        }

        // CAPTCHA resmini indir
        Uint8List? captchaBytes;
        String fullCaptchaUrl;

        if (captchaRelativeUrl.startsWith("../")) {
          // Örn: ../../images/kappi.aspx -> https://ogubs1.ogu.edu.tr/images/kappi.aspx
          // Bu kısım Kivy kodundaki mantığa göre daha dikkatli ele alınmalı.
          // LOGIN_URL'in base'ini alıp birleştirelim.
          Uri loginUri = Uri.parse(_loginUrl);
          // ../ sayısına göre path segmentlerini çıkar
          int parentCount = captchaRelativeUrl.split("../").length - 1;
          List<String> pathSegments = List.from(loginUri.pathSegments);
          if (pathSegments.isNotEmpty && pathSegments.last.endsWith('.aspx')) {
            pathSegments.removeLast(); // giris.aspx'i kaldır
          }
          for (int i = 0; i < parentCount && pathSegments.isNotEmpty; i++) {
            pathSegments.removeLast();
          }
          String basePath = pathSegments.join('/');
          fullCaptchaUrl =
              "${loginUri.scheme}://${loginUri.host}/$basePath/${captchaRelativeUrl.replaceAll("../", "")}";
        } else if (captchaRelativeUrl.startsWith("/")) {
          // Örn: /Kullanici/kappi.aspx -> https://ogubs1.ogu.edu.tr/Kullanici/kappi.aspx
          Uri loginUri = Uri.parse(_loginUrl);
          fullCaptchaUrl =
              "${loginUri.scheme}://${loginUri.host}$captchaRelativeUrl";
        } else {
          // Örn: kappi.aspx -> https://ogubs1.ogu.edu.tr/kappi.aspx (Eğer giris.aspx ile aynı dizindeyse)
          // Bu durum için Kivy'deki gibi LOGIN_URL'in son segmentini değiştirerek URL oluşturulabilir.
          fullCaptchaUrl = Uri.parse(
            _loginUrl,
          ).resolve(captchaRelativeUrl).toString();
        }

        try {
          final captchaResponse = await _client
              .get(
                Uri.parse(fullCaptchaUrl),
                headers:
                    _getHeaders(), // Session cookie'sini CAPTCHA isteğinde de gönder
              )
              .timeout(const Duration(seconds: 10));
          _updateCookies(
            captchaResponse,
          ); // CAPTCHA sonrası yeni cookie gelebilir

          if (captchaResponse.statusCode == 200) {
            captchaBytes = captchaResponse.bodyBytes;
          } else {
            print(
              'CAPTCHA resmi indirilemedi. Durum Kodu: ${captchaResponse.statusCode}',
            );
            // Hata durumu için null bırakılabilir veya özel bir exception atılabilir.
          }
        } catch (e) {
          print('CAPTCHA resmi indirilirken hata: $e');
          // Hata durumu için null bırakılabilir veya özel bir exception atılabilir.
        }

        return LoginPageData(
          viewState: viewState,
          viewStateGenerator: viewStateGenerator,
          eventValidation: eventValidation,
          captchaRelativeUrl:
              captchaRelativeUrl, // Orijinal relative URL'i saklayalım
          captchaImageBytes: captchaBytes,
        );
      } else {
        throw Exception(
          'Giriş sayfası yüklenemedi. Durum Kodu: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('Giriş sayfası yüklenirken zaman aşımı oldu.');
    } catch (e) {
      print('fetchLoginPageData Hata: $e');
      throw Exception(
        'Giriş sayfası verileri alınırken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<Map<String, String>?> login({
    required String studentNumber,
    required String password,
    required String captcha,
    required LoginPageData loginPageData, // __VIEWSTATE vb. içerir
  }) async {
    final loginPayload = {
      '__VIEWSTATE': loginPageData.viewState,
      '__VIEWSTATEGENERATOR': loginPageData.viewStateGenerator,
      '__EVENTVALIDATION': loginPageData.eventValidation,
      'txtKulAd': studentNumber,
      'txtpwd': password,
      'txtKappa': captcha,
      'btnLogin': 'Giriş',
    };

    try {
      final request = http.Request('POST', Uri.parse(_loginUrl))
        ..headers.addAll(_getHeaders())
        ..followRedirects =
            false // Yönlendirmeleri manuel takip et
        ..bodyFields = loginPayload;

      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      _updateCookies(response); // Giriş sonrası yeni cookieler gelebilir

      if (response.statusCode == 302) {
        final location = response.headers['location'];
        if (location != null &&
            location.toLowerCase().contains('/anasayfa.aspx')) {
          // Yönlendirme başarılı. Ana sayfaya gidip kullanıcı bilgilerini al.
          final homePageResponse = await _client.get(
            Uri.parse("https://ogubs1.ogu.edu.tr$location"),
            headers: _getHeaders(),
          );
          _updateCookies(homePageResponse);

          if (homePageResponse.statusCode == 200) {
            final document = html_parser.parse(homePageResponse.body);
            final welcomeLabel = document.querySelector('span#lbKullanici');
            if (welcomeLabel != null) {
              // Örnek: "Hoş Geldiniz: 151620221049 EFE YAZGI"
              final studentInfoText = welcomeLabel.text.split(':').last.trim();

              // Numarayı ve ismi ayırmak için daha güvenilir bir yöntem
              final studentNumberMatch = RegExp(
                r'^(\d+)',
              ).firstMatch(studentInfoText);

              if (studentNumberMatch != null) {
                final extractedStudentNumber = studentNumberMatch.group(1)!;
                final studentName = studentInfoText
                    .substring(extractedStudentNumber.length)
                    .trim();
                return {
                  'studentName': studentName,
                  'studentNumber': extractedStudentNumber,
                };
              }
            }
          }
          // Bilgiler ayrıştırılamazsa veya ana sayfa yüklenemezse bile
          // giriş başarılı kabul edilebilir ama bilgiler eksik olur.
          // Bu durumu ele almak için null yerine varsayılan bir değer döndürülebilir
          // veya hata fırlatılabilir. Şimdilik null dönüyoruz.
          return null;
        }
      }
      // Bazı durumlarda yönlendirme olmadan da başarılı olabilir (AJAX sonrası gibi)
      else if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        // Hata mesajı var mı kontrol et
        final errorLabel = document.getElementById('lblHata');
        if (errorLabel != null && errorLabel.text.isNotEmpty) {
          return null; // Hata mesajı varsa giriş başarısızdır.
        }

        final welcomeLabel = document.querySelector('span#lbKullanici');
        if (welcomeLabel != null) {
          final studentInfoText = welcomeLabel.text.split(':').last.trim();
          final studentNumberMatch = RegExp(
            r'^(\d+)',
          ).firstMatch(studentInfoText);

          if (studentNumberMatch != null) {
            final extractedStudentNumber = studentNumberMatch.group(1)!;
            final studentName = studentInfoText
                .substring(extractedStudentNumber.length)
                .trim();
            return {
              'studentName': studentName,
              'studentNumber': extractedStudentNumber,
            };
          }
        }

        // Eğer hiçbir bilgi bulunamazsa ve hata da yoksa, muhtemelen giriş ekranındayızdır.
        return null;
      }

      // Diğer tüm durumlar başarısız kabul edilir.
      return null;
    } catch (e) {
      print('Login Hata: $e');
      return null; // Hata durumunda null döndür
    }
  }

  // Sınav sonuçlarını çekmek için
  // final String _sinavSonucUrl = "https://ogubs1.ogu.edu.tr/SinavSonuc.aspx";

  // Kivy'deki parse_sinav_hucre metodunun Dart karşılığı
  String _parseSinavHucre(dom.Element? hucreSoup) {
    if (hucreSoup == null) return "Veri Yok";

    final bilesenler = <String>[];
    final innerTable = hucreSoup.querySelector('table');

    if (innerTable != null) {
      for (final trTag in innerTable.querySelectorAll('tr')) {
        final tdTags = trTag.querySelectorAll('td');
        if (tdTags.length == 2) {
          final isimTag = tdTags[0].querySelector('a');
          final notTag = tdTags[1].querySelector('a');
          if (isimTag != null && notTag != null) {
            final isim = isimTag.text.trim();
            final notValBTag = notTag.querySelector('b');
            final notVal = (notValBTag?.text ?? notTag.text).trim();
            final cleanNotVal = notVal.replaceAll("\xa0", "").trim();

            if (isim.isNotEmpty && cleanNotVal.isNotEmpty) {
              bilesenler.add("$isim $cleanNotVal");
            } else if (isim.isNotEmpty) {
              bilesenler.add(isim);
            }
          }
        }
      }
    }

    if (bilesenler.isEmpty) {
      final links = hucreSoup.querySelectorAll('a.normaltext');
      for (final linkTag in links) {
        final text = linkTag.text.trim().replaceAll("\xa0", "").trim();
        if (text.isNotEmpty) {
          bilesenler.add(text);
        }
      }
    }

    if (bilesenler.isEmpty) {
      final rawText = hucreSoup.text
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll("\xa0", "")
          .trim();
      return rawText.isNotEmpty ? rawText : "Veri Yok";
    }
    return bilesenler.join(", ");
  }

  Future<GradesPageData> fetchGrades({
    String? selectedYear,
    String? selectedTerm,
  }) async {
    try {
      http.Response response;
      final uri = Uri.parse(_sinavSonucUrl);
      final headers = _getHeaders();

      if (selectedYear != null && selectedTerm != null) {
        print(
          'Yıl ($selectedYear) ve Dönem ($selectedTerm) için notlar çekiliyor...',
        );
        final initialResponse = await _client.get(uri, headers: headers);
        _updateCookies(initialResponse);

        if (initialResponse.statusCode != 200) {
          throw Exception(
            'Sınav sonuçları için gerekli viewstate bilgileri alınamadı. Durum Kodu: ${initialResponse.statusCode}',
          );
        }

        final doc = html_parser.parse(initialResponse.body);
        final payload = {
          '__VIEWSTATE':
              doc
                  .querySelector('input[name="__VIEWSTATE"]')
                  ?.attributes['value'] ??
              '',
          '__VIEWSTATEGENERATOR':
              doc
                  .querySelector('input[name="__VIEWSTATEGENERATOR"]')
                  ?.attributes['value'] ??
              '',
          '__EVENTVALIDATION':
              doc
                  .querySelector('input[name="__EVENTVALIDATION"]')
                  ?.attributes['value'] ??
              '',
          'dpYariyil': selectedYear,
          'dpDonem': selectedTerm,
          'btnTakvim': 'Sınav Sonuçları',
        };

        final request = http.Request('POST', uri)
          ..headers.addAll(headers)
          ..followRedirects = false
          ..bodyFields = payload;

        final streamedResponse = await _client
            .send(request)
            .timeout(const Duration(seconds: 20));
        response = await http.Response.fromStream(streamedResponse);
      } else {
        print('Varsayılan (en son) dönem için notlar çekiliyor...');
        response = await _client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15));
      }

      _updateCookies(response);

      if (response.statusCode != 200) {
        throw Exception(
          'Sınav sonuçları sayfası yüklenemedi. Durum Kodu: ${response.statusCode}',
        );
      }

      final document = html_parser.parse(response.body);
      final resultsTable = document.querySelector('table#gvSinavSonuc');
      final List<CourseGradeModel> dersDataList = [];

      if (resultsTable != null) {
        final rows = resultsTable.querySelectorAll('tr');
        for (int i = 1; i < rows.length; i++) {
          final cols = rows[i].children
              .where((node) => node.localName == 'td')
              .cast<dom.Element>()
              .toList();
          if (cols.length != 9) continue;

          dersDataList.add(
            CourseGradeModel.fromMap({
              "ad": cols[1].text.trim(),
              "as1": _parseSinavHucre(cols[2]),
              "as2": _parseSinavHucre(cols[3]),
              "final": _parseSinavHucre(cols[4]),
              "but": _parseSinavHucre(cols[5]),
              "eks": _parseSinavHucre(cols[6]),
              "snot": cols[7].text.trim().replaceAll("\xa0", ""),
              "hnot": cols[8].text.trim().replaceAll("\xa0", ""),
            }),
          );
        }
      }

      final summaryData = await fetchSummaryData();

      // Yıl seçeneklerini değere (value) göre sırala (eskiden yeniye)
      final yearOptions = _parseSelectOptions(document, 'select#dpYariyil');
      yearOptions.sort((a, b) => a.value.compareTo(b.value));

      return GradesPageData(
        courses: dersDataList,
        summary: AcademicSummaryModel.fromMap(summaryData),
        yearOptions: yearOptions,
        termOptions: _parseSelectOptions(document, 'select#dpDonem'),
        selectedYear: _getSelectedOptionValue(document, 'select#dpYariyil'),
        selectedTerm: _getSelectedOptionValue(document, 'select#dpDonem'),
      );
    } catch (e) {
      print('fetchGrades Hata: $e');
      throw Exception(
        'Sınav sonuçları alınırken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  List<SelectionOption> _parseSelectOptions(
    dom.Document document,
    String selector,
  ) {
    final selectElement = document.querySelector(selector);
    if (selectElement == null) return [];
    return selectElement
        .querySelectorAll('option')
        .map(
          (opt) =>
              SelectionOption(value: opt.attributes['value']!, text: opt.text),
        )
        .toList();
  }

  String? _getSelectedOptionValue(dom.Document document, String selector) {
    final selectElement = document.querySelector(selector);
    if (selectElement == null) return null;
    final selectedOption = selectElement.querySelector('option[selected]');
    return selectedOption?.attributes['value'];
  }

  Future<Map<String, String?>> fetchSummaryData() async {
    try {
      final response = await _client
          .get(Uri.parse(_notDokumUrl), headers: _getHeaders())
          .timeout(const Duration(seconds: 10));
      _updateCookies(response);

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final summarySpan = document.querySelector('span#lbAnadalGpa');
        if (summarySpan != null) {
          final fullText = summarySpan.text.trim();
          final gpaMatch = RegExp(r'GNO:\s*([\d,]+)').firstMatch(fullText);
          final creditsMatch = RegExp(r'Kredi:\s*(\d+)').firstMatch(fullText);
          return {
            'gpa': gpaMatch?.group(1)?.replaceAll(',', '.'),
            'credits': creditsMatch?.group(1),
          };
        }
      }
    } catch (e) {
      print('fetchSummaryData Hata: $e');
    }
    return {'gpa': null, 'credits': null};
  }

  void clearSessionCookies() {
    _cookies.clear();
    print("Session cookies cleared.");
  }
}
