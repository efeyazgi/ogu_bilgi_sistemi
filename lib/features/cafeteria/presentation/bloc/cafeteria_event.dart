import 'package:equatable/equatable.dart';
import '../../data/models/daily_menu.dart';

abstract class CafeteriaEvent extends Equatable {
  const CafeteriaEvent();

  @override
  List<Object> get props => [];
}

/// Standart menüyü yükle
class LoadStandardMenu extends CafeteriaEvent {
  const LoadStandardMenu();
}

/// Vejetaryen menüyü yükle
class LoadVegetarianMenu extends CafeteriaEvent {
  const LoadVegetarianMenu();
}

/// Glutensiz menüyü yükle
class LoadGlutenFreeMenu extends CafeteriaEvent {
  const LoadGlutenFreeMenu();
}

/// Menü tipini değiştir
class ChangeMenuType extends CafeteriaEvent {
  final MenuType menuType;
  
  const ChangeMenuType(this.menuType);
  
  @override
  List<Object> get props => [menuType];
}

/// Menüyü yenile
class RefreshMenu extends CafeteriaEvent {
  const RefreshMenu();
}