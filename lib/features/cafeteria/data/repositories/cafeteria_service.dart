import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../models/daily_menu.dart';
import '../models/menu_item.dart';

class CafeteriaService {
  static const String _baseUrl = 'https://yemekhane.ogu.edu.tr';
  
  final http.Client _httpClient;
  
  CafeteriaService({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();

  /// Standart menüyü getirir (varsayılan)
  Future<List<DailyMenu>> getStandardMenu() async {
    return _getMenuByType(1); // 1 = Standart Menü
  }

  /// Vejetaryen menüyü getirir
  Future<List<DailyMenu>> getVegetarianMenu() async {
    return _getMenuByType(2); // 2 = Vejetaryen Menü
  }

  /// Glutensiz menüyü getirir
  Future<List<DailyMenu>> getGlutenFreeMenu() async {
    return _getMenuByType(3); // 3 = Glutensiz Menü
  }

  /// Menü tipine göre veri çeker ve parse eder
  Future<List<DailyMenu>> _getMenuByType(int menuType) async {
    try {
      final url = '$_baseUrl/Menu/$menuType';
      
      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'tr-TR,tr;q=0.8,en-US;q=0.5,en;q=0.3',
          'Accept-Encoding': 'gzip, deflate',
          'Connection': 'keep-alive',
        },
      );

      if (response.statusCode == 200) {
        // Türkçe karakter sorunları için UTF-8 decode
        final decodedBody = utf8.decode(response.bodyBytes);
        return _parseMenuHtml(decodedBody);
      } else {
        throw Exception('Menü yüklenemedi. HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Menü yüklenirken hata oluştu: $e');
    }
  }

  /// HTML içeriğini parse ederek DailyMenu listesi döndürür
  List<DailyMenu> _parseMenuHtml(String html) {
    final document = parser.parse(html);
    final List<DailyMenu> menus = [];

    // Her hafta için ayrı ayrı işlem yap
    final weekContainers = document.querySelectorAll('.menu-hafta .row');

    for (final weekContainer in weekContainers) {
      final dayColumns = weekContainer.querySelectorAll('.yemek-menu-col');

      for (final dayColumn in dayColumns) {
        final menu = _parseDayMenu(dayColumn);
        if (menu != null) {
          menus.add(menu);
        }
      }
    }

    return menus;
  }

  /// Tek günlük menüyü parse eder
  DailyMenu? _parseDayMenu(Element dayElement) {
    try {
      // Gün başlığını al
      final dayHeader = dayElement.querySelector('.panel-title');
      if (dayHeader == null) return null;

      final dayText = dayHeader.text.trim();
      
      // Önce tarihi parse et
      final date = _parseDateFromDayText(dayText);
      
      // Hafta sonu kontrolü - tarihe göre yap
      final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      
      // Eğer hafta sonu ise ve "Hafta Sonu" yazısı varsa
      final weekendElement = dayElement.querySelector('.yemek-menu-haftasonu');
      if (isWeekend && weekendElement != null) {
        return _createWeekendMenu(dayText, date);
      }

      // Tatil kontrolü
      final holidayElement = dayElement.querySelector('.yemek-menu-tatil');
      if (holidayElement != null) {
        return _createHolidayMenu(dayText, holidayElement.text, date);
      }

      // Menü hazır değil kontrolü
      final notReadyElement = dayElement.querySelector('p');
      if (notReadyElement != null && notReadyElement.text.contains('Menü hazır değil')) {
        return _createNotReadyMenu(dayText, date);
      }

      // Normal menü parse et
      final menuItems = _parseMenuItems(dayElement);

      return DailyMenu(
        date: date,
        dayName: dayText,
        items: menuItems,
        isWeekend: isWeekend,
        isHoliday: false,
        isMenuReady: true,
      );
    } catch (e) {
      debugPrint('Gün menüsü parse edilemedi: $e');
      return null;
    }
  }

  /// Hafta sonu menüsü oluşturur
  DailyMenu _createWeekendMenu(String dayText, DateTime date) {
    return DailyMenu(
      date: date,
      dayName: dayText,
      items: [],
      isWeekend: true,
      isHoliday: false,
      isMenuReady: false,
    );
  }

  /// Tatil günü menüsü oluşturur
  DailyMenu _createHolidayMenu(String dayText, String holidayText, DateTime date) {
    final holidayName = holidayText.replaceAll('Tatil:', '').trim();
    
    return DailyMenu(
      date: date,
      dayName: dayText,
      items: [],
      isWeekend: false,
      isHoliday: true,
      holidayName: holidayName,
      isMenuReady: false,
    );
  }

  /// Hazır olmayan menü oluşturur
  DailyMenu _createNotReadyMenu(String dayText, DateTime date) {
    return DailyMenu(
      date: date,
      dayName: dayText,
      items: [],
      isWeekend: false,
      isHoliday: false,
      isMenuReady: false,
    );
  }

  /// Menü öğelerini parse eder
  List<MenuItem> _parseMenuItems(Element dayElement) {
    final items = <MenuItem>[];
    final menuList = dayElement.querySelector('.yemek-menu-liste');
    
    if (menuList == null) return items;

    final menuItems = menuList.querySelectorAll('li');
    
    for (final item in menuItems) {
      // Boş li elementlerini atla
      if (item.classes.contains('clearfix') || item.text.trim().isEmpty) {
        continue;
      }

      final menuItem = _parseMenuItem(item);
      if (menuItem != null) {
        items.add(menuItem);
      }
    }

    return items;
  }

  /// Tek menü öğesini parse eder
  MenuItem? _parseMenuItem(Element itemElement) {
    try {
      final nameElement = itemElement.querySelector('.yemek-menu-yemek a');
      final calorieElement = itemElement.querySelector('.yemek-menu-kalori');
      
      if (nameElement == null) return null;

      String name = nameElement.text.trim();
      final ingredients = nameElement.attributes['data-icerik'] ?? '';
      
      // Kalori bilgisini parse et
      int calories = 0;
      if (calorieElement != null) {
        final calorieText = calorieElement.text;
        final calorieMatch = RegExp(r'\((\d+) kcal\)').firstMatch(calorieText);
        if (calorieMatch != null) {
          calories = int.tryParse(calorieMatch.group(1)!) ?? 0;
        }
      }

      // Karbonhidrat bilgisini name'den çıkar
      String? carbohydrates;
      final carbMatch = RegExp(r'Karbonhidrat[:\s]+(\d+(?:\.\d+)?)\s*gr?').firstMatch(name);
      if (carbMatch != null) {
        carbohydrates = '${carbMatch.group(1)} gr';
        // Name'den karbonhidrat bilgisini çıkar
        name = name.replaceAll(RegExp(r'\s*Karbonhidrat[:\s]+\d+(?:\.\d+)?\s*gr?'), '');
      }

      return MenuItem(
        name: name.trim(),
        ingredients: ingredients.trim(),
        calories: calories,
        carbohydrates: carbohydrates,
      );
    } catch (e) {
      debugPrint('Menü öğesi parse edilemedi: $e');
      return null;
    }
  }

  /// Gün metninden tarihi parse eder
  DateTime _parseDateFromDayText(String dayText) {
    try {
      // "13 Eki. Pazartesi" veya sadece "Cumartesi"/"Pazar" formatlarını parse et
      
      // Önce tam tarih formatını dene: "13 Eki. Pazartesi"
      final dateMatch = RegExp(r'(\d+)\s+([A-Za-zçğıöşüÇĞIÖŞÜ]+)\.?').firstMatch(dayText);
      
      if (dateMatch != null) {
        final day = int.parse(dateMatch.group(1)!);
        final monthAbbr = dateMatch.group(2)!;
        
        // Ay kısaltmalarını rakamla eşle
        final monthMap = {
          'Oca': 1, 'Şub': 2, 'Mar': 3, 'Nis': 4, 'May': 5, 'Haz': 6,
          'Tem': 7, 'Ağu': 8, 'Eyl': 9, 'Eki': 10, 'Kas': 11, 'Ara': 12,
        };
        
        final month = monthMap[monthAbbr] ?? DateTime.now().month;
        final now = DateTime.now();
        int year = now.year;
        
        // Yıl belirleme mantığı:
        // Menü tarihleri genelde bugünden önce veya sonra 1-2 hafta içindedir
        // Önce bugünün yılıyla bir tarih oluştur
        DateTime candidateDate = DateTime(year, month, day);
        
        // Eğer bu tarih bugünden çok önceyse (30 günden fazla), gelecek yıla geç
        final daysDifference = candidateDate.difference(now).inDays;
        
        if (daysDifference < -30) {
          // Geçmişte kaldı, gelecek yıl olmalı
          year += 1;
        }
        
        return DateTime(year, month, day);
      }
      
      // Eğer sadece gün adı varsa (Cumartesi/Pazar için), bugünden en yakın o günü bul
      if (dayText.contains('Cumartesi')) {
        return _findNextWeekday(DateTime.saturday);
      } else if (dayText.contains('Pazar')) {
        return _findNextWeekday(DateTime.sunday);
      }
    } catch (e) {
      debugPrint('Tarih parse edilemedi: $e');
    }
    
    // Parse edilemezse bugünün tarihini döndür
    return DateTime.now();
  }
  
  /// Belirtilen gün için en yakın tarihi bul
  DateTime _findNextWeekday(int targetWeekday) {
    final now = DateTime.now();
    int daysToAdd = targetWeekday - now.weekday;
    
    if (daysToAdd <= 0) {
      daysToAdd += 7; // Gelecek haftaya git
    }
    
    return DateTime(now.year, now.month, now.day).add(Duration(days: daysToAdd));
  }

  void dispose() {
    _httpClient.close();
  }
}