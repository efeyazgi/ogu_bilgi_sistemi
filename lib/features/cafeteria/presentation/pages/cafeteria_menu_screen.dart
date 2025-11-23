import 'package:flutter/material.dart';
import 'package:ogu_not_sistemi_v2/core/models/cafeteria_menu.dart';
import 'package:ogu_not_sistemi_v2/core/services/cafeteria_service.dart';
import 'package:ogu_not_sistemi_v2/core/theme/app_colors.dart';

class CafeteriaMenuScreen extends StatefulWidget {
  const CafeteriaMenuScreen({super.key});

  @override
  State<CafeteriaMenuScreen> createState() => _CafeteriaMenuScreenState();
}

class _CafeteriaMenuScreenState extends State<CafeteriaMenuScreen> {
  final CafeteriaService _service = CafeteriaService();
  late Future<List<CafeteriaMenu>> _menusFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _menusFuture = _service.fetchMenus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Yemekhane Menüsü',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<CafeteriaMenu>>(
        future: _menusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorView(snapshot.error);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Menü bulunamadı.'));
          }

          final menus = snapshot.data!;
          // Ensure selected index is valid
          if (_selectedIndex >= menus.length) _selectedIndex = 0;

          return Column(
            children: [
              _buildDateSelector(menus),
              Expanded(
                child: _buildMenuContent(menus[_selectedIndex]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorView(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.gradeRed),
          const SizedBox(height: 16),
          Text('Hata oluştu: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _menusFuture = _service.fetchMenus();
                _selectedIndex = 0;
              });
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(List<CafeteriaMenu> menus) {
    return Container(
      height: 110, // Increased height to fix overflow
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardWhiteBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: menus.length,
        itemBuilder: (context, index) {
          final menu = menus[index];
          final isSelected = index == _selectedIndex;
          final dateParts = _parseDateString(menu.date);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.appBarColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.appBarColor : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateParts['day'] ?? '',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateParts['month'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.textHint,
                    ),
                  ),
                  Text(
                    dateParts['dayName'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuContent(CafeteriaMenu menu) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ));
      },
      child: Container(
        key: ValueKey<String>(menu.date),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Günün Menüsü',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              menu.date,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: menu.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildMenuItem(menu.items[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String itemText) {
    // Extract calories if present (e.g., "(166 kcal)")
    final calorieMatch = RegExp(r'\(([\d\s]+kcal)\)').firstMatch(itemText);
    String name = itemText;
    String? calories;

    if (calorieMatch != null) {
      calories = calorieMatch.group(1);
      name = itemText.replaceAll(calorieMatch.group(0)!, '').trim();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhiteBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.appBarColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant,
              color: AppColors.appBarColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (calories != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        calories,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _parseDateString(String dateString) {
    // Example: "17 Kas. Pazartesi"
    try {
      final parts = dateString.split(' ');
      if (parts.length >= 3) {
        return {
          'day': parts[0],
          'month': parts[1].replaceAll('.', ''),
          'dayName': parts.sublist(2).join(' '),
        };
      }
    } catch (e) {
      // Fallback
    }
    return {
      'day': '',
      'month': '',
      'dayName': dateString,
    };
  }
}
