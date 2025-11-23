import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/daily_menu.dart';
import 'menu_item_tile.dart';

class TodayMenuCard extends StatelessWidget {
  final DailyMenu menu;

  const TodayMenuCard({
    super.key,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.background,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.today,
                    color: AppColors.textLight,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bugünün Menüsü',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTodayDate(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (menu.totalCalories > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.textLight.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${menu.totalCalories} kcal',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // İçerik
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMenuContent(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTodayDate() {
    // Gün adını menu.dayName'den al
    final dayNameMatch = RegExp(r'(Pazartesi|Salı|Çarşamba|Perşembe|Cuma|Cumartesi|Pazar)').firstMatch(menu.dayName);
    
    if (dayNameMatch != null) {
      final dayName = dayNameMatch.group(1)!;
      return '${DateFormat('dd MMMM yyyy', 'tr_TR').format(menu.date)}, $dayName';
    }
    
    // Eğer gün adı bulunamazsa sadece tarihi göster
    return DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(menu.date);
  }
  
  Widget _buildMenuContent() {
    if (menu.isHoliday) {
      return _buildHolidayContent();
    } else if (menu.isWeekend) {
      return _buildWeekendContent();
    } else if (!menu.isMenuReady) {
      return _buildNotReadyContent();
    } else if (menu.items.isEmpty) {
      return _buildEmptyContent();
    } else {
      return _buildMenuItems();
    }
  }

  Widget _buildHolidayContent() {
    return Row(
      children: [
        Icon(
          Icons.celebration,
          color: AppColors.gradeYellow,
          size: 32,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tatil Günü',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (menu.holidayName != null)
                Text(
                  menu.holidayName!,
                  style: TextStyle(
                    color: AppColors.textHint,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekendContent() {
    return Row(
      children: [
        Icon(
          Icons.weekend,
          color: AppColors.textHint,
          size: 32,
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Hafta Sonu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotReadyContent() {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          color: AppColors.gradeYellow,
          size: 32,
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Menü henüz hazır değil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyContent() {
    return Row(
      children: [
        Icon(
          Icons.no_meals,
          color: AppColors.textHint,
          size: 32,
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Menü bilgisi bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < menu.items.length; i++) ...[
          MenuItemTile(
            item: menu.items[i],
            isHighlighted: true,
          ),
          if (i < menu.items.length - 1)
            Divider(
              color: AppColors.textHint.withValues(alpha: 0.2),
              height: 1,
            ),
        ],
      ],
    );
  }
}