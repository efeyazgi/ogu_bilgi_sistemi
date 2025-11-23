import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/cafeteria_service.dart';
import '../../data/models/daily_menu.dart';
import 'cafeteria_event.dart';
import 'cafeteria_state.dart';

class CafeteriaBloc extends Bloc<CafeteriaEvent, CafeteriaState> {
  final CafeteriaService _cafeteriaService;
  MenuType _currentMenuType = MenuType.standard;

  CafeteriaBloc({
    required CafeteriaService cafeteriaService,
  }) : _cafeteriaService = cafeteriaService, super(const CafeteriaInitial()) {
    
    // Event handler'ları kaydet
    on<LoadStandardMenu>(_onLoadStandardMenu);
    on<LoadVegetarianMenu>(_onLoadVegetarianMenu);
    on<LoadGlutenFreeMenu>(_onLoadGlutenFreeMenu);
    on<ChangeMenuType>(_onChangeMenuType);
    on<RefreshMenu>(_onRefreshMenu);
  }

  /// Standart menüyü yükle
  Future<void> _onLoadStandardMenu(
    LoadStandardMenu event,
    Emitter<CafeteriaState> emit,
  ) async {
    await _loadMenu(emit, MenuType.standard);
  }

  /// Vejetaryen menüyü yükle
  Future<void> _onLoadVegetarianMenu(
    LoadVegetarianMenu event,
    Emitter<CafeteriaState> emit,
  ) async {
    await _loadMenu(emit, MenuType.vegetarian);
  }

  /// Glutensiz menüyü yükle
  Future<void> _onLoadGlutenFreeMenu(
    LoadGlutenFreeMenu event,
    Emitter<CafeteriaState> emit,
  ) async {
    await _loadMenu(emit, MenuType.glutenFree);
  }

  /// Menü tipini değiştir
  Future<void> _onChangeMenuType(
    ChangeMenuType event,
    Emitter<CafeteriaState> emit,
  ) async {
    _currentMenuType = event.menuType;
    await _loadMenu(emit, event.menuType);
  }

  /// Menüyü yenile
  Future<void> _onRefreshMenu(
    RefreshMenu event,
    Emitter<CafeteriaState> emit,
  ) async {
    await _loadMenu(emit, _currentMenuType);
  }

  /// Menü yükleme ana fonksiyonu
  Future<void> _loadMenu(
    Emitter<CafeteriaState> emit,
    MenuType menuType,
  ) async {
    try {
      emit(const CafeteriaLoading());

      List<DailyMenu> menus;
      
      // Menü tipine göre ilgili servisi çağır
      switch (menuType) {
        case MenuType.standard:
          menus = await _cafeteriaService.getStandardMenu();
          break;
        case MenuType.vegetarian:
          menus = await _cafeteriaService.getVegetarianMenu();
          break;
        case MenuType.glutenFree:
          menus = await _cafeteriaService.getGlutenFreeMenu();
          break;
      }

      // Bugünün menüsünü bul
      final todayMenu = _findTodayMenu(menus);

      emit(CafeteriaLoaded(
        menus: menus,
        currentMenuType: menuType,
        todayMenu: todayMenu,
      ));
      
    } catch (e) {
      emit(CafeteriaError(
        message: e.toString(),
        currentMenuType: menuType,
      ));
    }
  }

  /// Bugünün menüsünü bul
  DailyMenu? _findTodayMenu(List<DailyMenu> menus) {
    try {
      return menus.firstWhere((menu) => menu.isToday);
    } catch (e) {
      // Bugünün menüsü bulunamadı
      return null;
    }
  }

  @override
  Future<void> close() {
    _cafeteriaService.dispose();
    return super.close();
  }
}