import 'package:equatable/equatable.dart';
import '../../data/models/daily_menu.dart';

abstract class CafeteriaState extends Equatable {
  const CafeteriaState();

  @override
  List<Object?> get props => [];
}

/// İlk durum
class CafeteriaInitial extends CafeteriaState {
  const CafeteriaInitial();
}

/// Yükleniyor durumu
class CafeteriaLoading extends CafeteriaState {
  const CafeteriaLoading();
}

/// Menü başarıyla yüklendi
class CafeteriaLoaded extends CafeteriaState {
  final List<DailyMenu> menus;
  final MenuType currentMenuType;
  final DailyMenu? todayMenu;

  const CafeteriaLoaded({
    required this.menus,
    required this.currentMenuType,
    this.todayMenu,
  });

  CafeteriaLoaded copyWith({
    List<DailyMenu>? menus,
    MenuType? currentMenuType,
    DailyMenu? todayMenu,
  }) {
    return CafeteriaLoaded(
      menus: menus ?? this.menus,
      currentMenuType: currentMenuType ?? this.currentMenuType,
      todayMenu: todayMenu ?? this.todayMenu,
    );
  }

  @override
  List<Object?> get props => [menus, currentMenuType, todayMenu];
}

/// Hata durumu
class CafeteriaError extends CafeteriaState {
  final String message;
  final MenuType? currentMenuType;

  const CafeteriaError({
    required this.message,
    this.currentMenuType,
  });

  @override
  List<Object?> get props => [message, currentMenuType];
}