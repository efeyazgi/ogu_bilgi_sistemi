import 'package:equatable/equatable.dart';
import 'menu_item.dart';

enum MenuType {
  standard('Öğle/Akşam Yemeği - Standart Menü'),
  vegetarian('Öğle Yemeği - Vejetaryen Menü'),
  glutenFree('Öğle Yemeği - Glutensiz Menü');

  const MenuType(this.title);
  final String title;
}

class DailyMenu extends Equatable {
  final DateTime date;
  final String dayName;
  final List<MenuItem> items;
  final bool isWeekend;
  final bool isHoliday;
  final String? holidayName;
  final bool isMenuReady;

  const DailyMenu({
    required this.date,
    required this.dayName,
    required this.items,
    this.isWeekend = false,
    this.isHoliday = false,
    this.holidayName,
    this.isMenuReady = true,
  });

  factory DailyMenu.fromMap(Map<String, dynamic> map) {
    return DailyMenu(
      date: DateTime.parse(map['date']),
      dayName: map['dayName'] ?? '',
      items: List<MenuItem>.from(
        (map['items'] ?? []).map((x) => MenuItem.fromMap(x)),
      ),
      isWeekend: map['isWeekend'] ?? false,
      isHoliday: map['isHoliday'] ?? false,
      holidayName: map['holidayName'],
      isMenuReady: map['isMenuReady'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'dayName': dayName,
      'items': items.map((x) => x.toMap()).toList(),
      'isWeekend': isWeekend,
      'isHoliday': isHoliday,
      'holidayName': holidayName,
      'isMenuReady': isMenuReady,
    };
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  int get totalCalories {
    return items.fold(0, (sum, item) => sum + item.calories);
  }

  @override
  List<Object?> get props => [
        date,
        dayName,
        items,
        isWeekend,
        isHoliday,
        holidayName,
        isMenuReady,
      ];
}