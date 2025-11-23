import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser; // HTML ayrıştırma için
import 'package:html/dom.dart' as dom; // DOM elementlerine erişim için
import 'package:ogu_not_sistemi_v2/features/auth/data/models/login_page_data.dart';
import 'package:ogu_not_sistemi_v2/features/grades/data/models/academic_summary_model.dart';
import 'package:ogu_not_sistemi_v2/features/grades/data/models/course_grade_model.dart';
import 'package:ogu_not_sistemi_v2/features/grades/data/models/grades_page_data.dart';
import 'package:ogu_not_sistemi_v2/features/schedule/data/models/course_model.dart';
import 'package:ogu_not_sistemi_v2/features/schedule/data/models/registered_course.dart';
import 'package:ogu_not_sistemi_v2/features/grades/data/models/grade_details_model.dart';

class OgubsService {
  final http.Client _client;
  final String _loginUrl = "https://ogubs1.ogu.edu.tr/giris.aspx";
  final String _sinavSonucUrl = "https://ogubs1.ogu.edu.tr/SinavSonuc.aspx";
  final String _notDokumUrl = "https://ogubs1.ogu.edu.tr/NotDokum.aspx";
  final String _dersProgramUrl = "https://ogubs1.ogu.edu.tr/DersProgram.aspx";
  final String _kayitliDerslerUrl = "https://ogubs1.ogu.edu.tr/KayitliDers.aspx";

  // Session yönetimi için cookieleri saklayacak bir yapı (Basit bir map)
  final Map<String, String> _cookies = {};

  OgubsService({http.Client? client}) : _client = client ?? http.Client();

  // Cookieleri header'a eklemek için yardımcı metot
  Map<String, String> _getHeaders() {
    final headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
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
          .timeout(const Duration(seconds: 30));

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
          Uri loginUri = Uri.parse(_loginUrl);
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
          Uri loginUri = Uri.parse(_loginUrl);
          fullCaptchaUrl =
              "${loginUri.scheme}://${loginUri.host}$captchaRelativeUrl";
        } else {
          fullCaptchaUrl = Uri.parse(
            _loginUrl,
          ).resolve(captchaRelativeUrl).toString();
        }

        try {
          final captchaResponse = await _client
              .get(
                Uri.parse(fullCaptchaUrl),
                headers: _getHeaders(),
              )
              .timeout(const Duration(seconds: 10));
          _updateCookies(captchaResponse);

          if (captchaResponse.statusCode == 200) {
            captchaBytes = captchaResponse.bodyBytes;
          } else {
            print(
              'CAPTCHA resmi indirilemedi. Durum Kodu: ${captchaResponse.statusCode}',
            );
          }
        } catch (e) {
          print('CAPTCHA resmi indirilirken hata: $e');
        }

        return LoginPageData(
          viewState: viewState,
          viewStateGenerator: viewStateGenerator,
          eventValidation: eventValidation,
          captchaRelativeUrl: captchaRelativeUrl,
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

  String? _currentStudentNumber;
  String? get currentStudentNumber => _currentStudentNumber;

  Future<Map<String, String>?> login({
    required String studentNumber,
    required String password,
    required String captcha,
    required LoginPageData loginPageData,
  }) async {
    _currentStudentNumber = studentNumber; // Store student number
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
        ..followRedirects = false
        ..bodyFields = loginPayload;

      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      _updateCookies(response);

      if (response.statusCode == 302) {
        final location = response.headers['location'];
        if (location != null &&
            location.toLowerCase().contains('/anasayfa.aspx')) {
          final homePageResponse = await _client.get(
            Uri.parse("https://ogubs1.ogu.edu.tr$location"),
            headers: _getHeaders(),
          );
          _updateCookies(homePageResponse);

          if (homePageResponse.statusCode == 200) {
            final document = html_parser.parse(homePageResponse.body);
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
          }
          return null;
        }
      } else if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final errorLabel = document.getElementById('lblHata');
        if (errorLabel != null && errorLabel.text.isNotEmpty) {
          return null;
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
        return null;
      }
      return null;
    } catch (e) {
      print('Login Hata: $e');
      return null;
    }
  }

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
            
            String component = "";
            if (isim.isNotEmpty && cleanNotVal.isNotEmpty) {
              component = "$isim $cleanNotVal";
            } else if (isim.isNotEmpty) {
              component = isim;
            }
            
            // Extract URL
            final href = notTag.attributes['href'];
            if (href != null && href.isNotEmpty) {
              component += "|$href";
            }
            
            if (component.isNotEmpty) {
              bilesenler.add(component);
            }
          }
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
          
          // Debug: Print column content to find instructor
          print('Row $i Columns: ${cols.length}');
          for (int k = 0; k < cols.length; k++) {
             print('Col $k Text: "${cols[k].text.trim()}"');
             // print('Col $k HTML: "${cols[k].innerHtml}"'); // Commented out to reduce noise
             print('Col $k Attributes: ${cols[k].attributes}');
          }
          
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
        final aktsSpan = document.querySelector('span#LbAnadalAkts');
        
        String? gpa;
        String? credits;
        String? akts;

        if (summarySpan != null) {
          final fullText = summarySpan.text.trim();
          final gpaMatch = RegExp(r'GNO:\s*([\d,]+)').firstMatch(fullText);
          final creditsMatch = RegExp(r'Kredi:\s*(\d+)').firstMatch(fullText);
          gpa = gpaMatch?.group(1)?.replaceAll(',', '.');
          credits = creditsMatch?.group(1);
        }

        if (aktsSpan != null) {
          akts = aktsSpan.text.trim();
        }

        return {
          'gpa': gpa,
          'credits': credits,
          'akts': akts,
        };
      }
    } catch (e) {
      print('fetchSummaryData Hata: $e');
    }
    return {'gpa': null, 'credits': null, 'akts': null};
  }

  Future<List<Course>> fetchSchedule() async {
    try {
      final response = await _client
          .get(Uri.parse(_dersProgramUrl), headers: _getHeaders())
          .timeout(const Duration(seconds: 15));
      _updateCookies(response);

      if (response.statusCode != 200) {
        throw Exception(
          'Ders programı sayfası yüklenemedi. Durum Kodu: ${response.statusCode}',
        );
      }

      final document = html_parser.parse(response.body);
      final scheduleTable = document.querySelector('table#gvDersProgram');
      final List<Course> courses = [];

      if (scheduleTable != null) {
        print('fetchSchedule: Table found.');
        final tbody = scheduleTable.querySelector('tbody');
        if (tbody != null) {
          final rows = tbody.querySelectorAll('tr');
          print('fetchSchedule: Found ${rows.length} rows.');
          
          for (final row in rows) {
            final cells = row.querySelectorAll('td');
            if (cells.isNotEmpty) {
              final time = cells[0].text.trim();
              // print('fetchSchedule: Row time: $time');
              
              for (int dayIndex = 1; dayIndex < cells.length && dayIndex <= 7; dayIndex++) {
                String cellContent = cells[dayIndex].text.replaceAll('\u00A0', ' ').trim();
                
                if (cellContent.isNotEmpty && cellContent != '&nbsp;') {
                  print('fetchSchedule: Found content at day $dayIndex, time $time: "$cellContent"');
                  final dayName = _getDayFromIndex(dayIndex);
                  final courseData = _parseCourseCell(cellContent);
                  print('fetchSchedule: Parsed course data: $courseData');
                  
                  if (courseData['name']!.isNotEmpty) {
                    courses.add(
                      Course(
                        name: courseData['name']!,
                        shortName: courseData['shortName']!,
                        classroom: courseData['classroom']!,
                        day: dayName,
                        time: time,
                      ),
                    );
                  }
                }
              }
            }
          }
        }
      } else {
        print('fetchSchedule: Table #gvDersProgram NOT found.');
      }
      
      return courses;
    } catch (e) {
      print('fetchSchedule Hata: $e');
      throw Exception(
        'Ders programı alınırken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  Map<String, String> _parseCourseCell(String content) {
    // Format: "Course Name (Classroom)" or just "Course Name"
    // Handle potential newlines or extra spaces
    content = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    final RegExp pattern = RegExp(r'^(.+?)\s*\(([^)]+)\)$');
    final match = pattern.firstMatch(content);
    
    if (match != null) {
      final shortName = match.group(1)?.trim() ?? '';
      final classroom = match.group(2)?.trim() ?? '';
      final fullName = _expandCourseName(shortName);
      
      return {
        'name': fullName,
        'shortName': shortName,
        'classroom': classroom,
      };
    }
    
    // Fallback: assume whole content is name if no parens
    return {
      'name': _expandCourseName(content),
      'shortName': content,
      'classroom': '',
    };
  }

  String _expandCourseName(String shortName) {
    final Map<String, String> courseExpansions = {
      'KİM.MH.TS.I': 'KİMYA MÜHENDİSLİĞİNDE TASARIM I',
      'KİM.MÜH.BL.U': 'KİMYA MÜHENDİSLİĞİNDE BİLGİSAYAR UYGULAMALARI',
      'KİM.LB.II': 'KİMYA MÜHENDİSLİĞİ LABORATUVARI II',
      'KİMTEPMÜHII': 'KİMYASAL TEPKİME MÜHENDİSLİĞİ II',
      'SÜR.KONT.': 'SÜREÇ KONTROLÜ',
      'KİM.MÜH.D.T.': 'KİMYA MÜHENDİSLİĞİNDE DENEY TASARIMI',
      'MÜH.AR.HZ.': 'MÜHENDİSLİK ARAŞTIRMALARINA HAZIRLIK',
    };

    if (courseExpansions.containsKey(shortName)) {
      return courseExpansions[shortName]!;
    }

    for (final entry in courseExpansions.entries) {
      if (shortName.startsWith(entry.key.split('.')[0])) {
        return entry.value;
      }
    }

    return shortName.replaceAll('.', ' ').trim();
  }

  String _getDayFromIndex(int index) {
    switch (index) {
      case 1: return 'Pazartesi';
      case 2: return 'Salı';
      case 3: return 'Çarşamba';
      case 4: return 'Perşembe';
      case 5: return 'Cuma';
      case 6: return 'Cumartesi';
      case 7: return 'Pazar';
      default: return 'Bilinmeyen';
    }
  }

  Future<List<RegisteredCourse>> fetchRegisteredCourses() async {
    try {
      final response = await _client
          .get(Uri.parse(_kayitliDerslerUrl), headers: _getHeaders())
          .timeout(const Duration(seconds: 15));
      _updateCookies(response);

      if (response.statusCode != 200) {
        throw Exception(
          'Kayıtlı dersler sayfası yüklenemedi. Durum Kodu: ${response.statusCode}',
        );
      }

      final document = html_parser.parse(response.body);
      final table = document.querySelector('table#GvBilgi');
      final List<RegisteredCourse> list = [];

      if (table != null) {
        final rows = table.querySelectorAll('tbody > tr');
        for (final row in rows) {
          final tds = row.querySelectorAll('td');
          if (tds.length >= 13) {
            final code = tds[2].text.trim();
            final name = tds[3].text.trim();
            final classroom = tds[5].text.trim();
            final subGroup = tds[6].text.trim();
            final lecturer = tds[7].text.trim();
            final theory = int.tryParse(tds[9].text.trim()) ?? 0;
            final practice = int.tryParse(tds[10].text.trim()) ?? 0;
            final credit = int.tryParse(tds[11].text.trim()) ?? 0;
            final ects = int.tryParse(tds[12].text.trim()) ?? 0;

            list.add(
              RegisteredCourse(
                code: code,
                name: name,
                classroom: classroom,
                subGroup: subGroup,
                lecturer: lecturer,
                theory: theory,
                practice: practice,
                credit: credit,
                ects: ects,
              ),
            );
          }
        }
      }

      return list;
    } catch (e) {
      print('fetchRegisteredCourses Hata: $e');
      throw Exception('Kayıtlı dersler alınırken hata: ${e.toString()}');
    }
  }

  void clearSessionCookies() {
    _cookies.clear();
    print("Session cookies cleared.");
  }


  Future<GradeDetailsModel> fetchGradeDetails(String relativeUrl) async {
    try {
      final uri = Uri.parse("https://ogubs1.ogu.edu.tr/$relativeUrl");
      print('Fetching grade details from: $uri');
      
      final response = await _client.get(uri, headers: _getHeaders());
      _updateCookies(response);

      if (response.statusCode == 200) {
        return _parseGradeDetails(response.body);
      } else {
        throw Exception('Failed to fetch grade details. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching grade details: $e');
      rethrow;
    }
  }

  GradeDetailsModel _parseGradeDetails(String html) {
    final document = html_parser.parse(html);
    
    // Try getElementById
    var table = document.getElementById('GvHisto');
    
    // If not found by ID, search by content
    if (table == null) {
      final tables = document.querySelectorAll('table');
      for (var t in tables) {
        // Check for unique strings in the table
        if (t.text.contains('Ortalama') || t.text.contains('Sınıf Ortalaması')) {
             table = t;
             break;
        }
      }
    }

    double average = 0.0;
    int studentCount = 0;
    final Map<String, int> distribution = {};

    if (table != null) {
      final rows = table.querySelectorAll('tr');
      
      for (final row in rows) {
        final rowText = row.text.replaceAll('\xa0', ' ').trim();
        final cells = row.querySelectorAll('td');
        
        // Parse Average
        // HTML: <td>Ortalama:</td><td>72,50</td>
        // OR: <td>Sınıf Ortalaması:</td><td>49,17</td>
        if ((rowText.contains('Sınıf Ortalaması') || rowText.contains('Ortalama:')) && cells.length >= 2) {
          final valText = cells[1].text.replaceAll('\xa0', '').trim();
          average = double.tryParse(valText.replaceAll(',', '.')) ?? 0.0;
        }

        // Parse Student Count
        // HTML: <td colspan='2'>Sınava giren toplam 18 öğrenci vardır.</td>
        if (rowText.contains('Sınava giren toplam')) {
          final match = RegExp(r'toplam\s*(\d+)').firstMatch(rowText);
          if (match != null) {
            studentCount = int.tryParse(match.group(1)!) ?? 0;
          }
        }

        // Parse Distribution
        // HTML: <td>90-100:</td><td>1</td>
        if (cells.length == 2) {
          final rangeText = cells[0].text.replaceAll('\xa0', '').trim().replaceAll(':', '');
          final countText = cells[1].text.replaceAll('\xa0', '').trim();
          
          if (RegExp(r'^\d+-\d+$').hasMatch(rangeText)) {
            distribution[rangeText] = int.tryParse(countText) ?? 0;
          }
        }
      }
    } else {
      // Regex Fallback
      // Matches: Ortalama:</td><td...>72,50</td> OR Sınıf Ortalaması:</td>...
      final avgMatch = RegExp(r'(?:Sınıf\s+)?Ortalama:.*?</td>.*?<td.*?>(.*?)</td>', dotAll: true).firstMatch(html);
      if (avgMatch != null) {
          // Remove everything except digits and comma
          String val = avgMatch.group(1)!.replaceAll(RegExp(r'[^\d,]'), '');
          average = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
      }
      
      final countMatch = RegExp(r'Sınava giren toplam\s*(\d+)').firstMatch(html);
      if (countMatch != null) {
          studentCount = int.tryParse(countMatch.group(1)!) ?? 0;
      }
      
      // Distribution Regex
      // Matches: >90-100:</td><td width='75' class='grisatir'>1</td>
      final distMatches = RegExp(r'>(\d+-\d+):</td>\s*<td.*?>(.*?)</td>', dotAll: true).allMatches(html);
      for (final m in distMatches) {
          final range = m.group(1)!;
          final count = m.group(2)!.trim();
          distribution[range] = int.tryParse(count) ?? 0;
      }
    }

    return GradeDetailsModel(
      average: average,
      studentCount: studentCount,
      distribution: distribution,
    );
  }
}

