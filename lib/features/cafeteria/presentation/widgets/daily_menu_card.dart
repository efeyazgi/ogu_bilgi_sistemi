import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/daily_menu.dart';
import 'menu_item_tile.dart';

class DailyMenuCard extends StatelessWidget {
  final DailyMenu menu;

  const DailyMenuCard({
    super.key,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.zero,
      shadowColor: _getHeaderColor().withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: menu.isToday 
          ? BorderSide(color: AppColors.primary, width: 2)
          : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getHeaderColor().withValues(alpha: 0.05),
              AppColors.background,
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: _getHeaderTextColor().withValues(alpha: 0.1),
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              backgroundColor: Colors.transparent,
              collapsedBackgroundColor: Colors.transparent,
            iconColor: _getHeaderTextColor(),
            collapsedIconColor: _getHeaderTextColor(),
            initiallyExpanded: false,
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: _getHeaderColor(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                children: [
                  Icon(
                    _getHeaderIcon(),
                    color: _getHeaderIconColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDayName(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _getHeaderTextColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMMM yyyy', 'tr_TR').format(menu.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getHeaderTextColor().withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (menu.totalCalories > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getHeaderTextColor().withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${menu.totalCalories} kcal',
                        style: TextStyle(
                          color: _getHeaderTextColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
              children: [
                _buildMenuContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getHeaderColor() {
    if (menu.isToday) {
      return AppColors.primary;
    } else if (menu.isHoliday) {
      return AppColors.gradeYellow.withValues(alpha: 0.2);
    } else if (menu.isWeekend || !menu.isMenuReady) {
      return AppColors.textHint.withValues(alpha: 0.15);
    } else {
      return AppColors.appBarColor;
    }
  }

  Color _getHeaderTextColor() {
    // Tüm başlıklar için koyu veya açık renk kullan
    if (menu.isToday) {
      return AppColors.textLight; // Bugün beyaz
    } else if (_getHeaderColor().computeLuminance() > 0.5) {
      return AppColors.textDark; // Açık arka plan için koyu yazı
    } else {
      return AppColors.textLight; // Koyu arka plan için beyaz yazı
    }
  }

  Color _getHeaderIconColor() {
    if (menu.isToday) {
      return AppColors.textLight;
    } else if (menu.isHoliday) {
      return AppColors.gradeYellow;
    } else {
      return AppColors.textDark;
    }
  }

  IconData _getHeaderIcon() {
    if (menu.isToday) {
      return Icons.today;
    } else if (menu.isHoliday) {
      return Icons.celebration;
    } else if (menu.isWeekend) {
      return Icons.weekend;
    } else if (!menu.isMenuReady) {
      return Icons.access_time;
    } else {
      return Icons.restaurant_menu;
    }
  }

  String _formatDayName() {
    // Regex ile gün adını çıkar: "13 Eki. Pazartesi" -> "Pazartesi"
    final dayNameMatch = RegExp(r'(Pazartesi|Salı|Çarşamba|Perşembe|Cuma|Cumartesi|Pazar)').firstMatch(menu.dayName);
    
    if (dayNameMatch != null) {
      final dayName = dayNameMatch.group(1)!;
      // Tarih kısmını da al: "13 Eki."
      final dateMatch = RegExp(r'(\d+\s+[A-Za-zçğıöşüÇĞIÖŞÜ]+\.?)').firstMatch(menu.dayName);
      
      if (dateMatch != null) {
        return '${dateMatch.group(1)} $dayName';
      }
      return dayName;
    }
    
    // Eğer gün adı bulunamazsa orijinal metni döndür
    return menu.dayName;
  }

  Widget _buildMenuContent() {
    if (menu.isHoliday) {
      return _buildSpecialContent(
        icon: Icons.celebration,
        title: 'Tatil Günü',
        subtitle: menu.holidayName,
        iconColor: AppColors.gradeYellow,
      );
    } else if (menu.isWeekend) {
      return _buildSpecialContent(
        icon: Icons.weekend,
        title: 'Hafta Sonu',
        iconColor: AppColors.textHint,
      );
    } else if (!menu.isMenuReady) {
      return _buildSpecialContent(
        icon: Icons.access_time,
        title: 'Menü henüz hazır değil',
        iconColor: AppColors.gradeYellow,
      );
    } else if (menu.items.isEmpty) {
      return _buildSpecialContent(
        icon: Icons.no_meals,
        title: 'Menü bilgisi bulunamadı',
        iconColor: AppColors.textHint,
      );
    } else {
      return _buildMenuItems();
    }
  }

  Widget _buildSpecialContent({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
            ],
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
            isHighlighted: menu.isToday,
            isCompact: true,
          ),
          if (i < menu.items.length - 1)
            Divider(
              color: AppColors.textHint.withValues(alpha: 0.2),
              height: 1,
              indent: 8,
              endIndent: 8,
            ),
        ],
      ],
    );
  }
}