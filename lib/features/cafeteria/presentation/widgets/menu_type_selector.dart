import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/daily_menu.dart';

class MenuTypeSelector extends StatelessWidget {
  final MenuType currentType;
  final Function(MenuType) onTypeChanged;

  const MenuTypeSelector({
    super.key,
    required this.currentType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: MenuType.values.map((type) {
            final isSelected = type == currentType;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  _getShortTitle(type),
                  style: TextStyle(
                    color: isSelected ? AppColors.textLight : AppColors.textDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onTypeChanged(type),
                backgroundColor: AppColors.background,
                selectedColor: AppColors.primary,
                checkmarkColor: AppColors.textLight,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getShortTitle(MenuType type) {
    switch (type) {
      case MenuType.standard:
        return 'Standart Menü';
      case MenuType.vegetarian:
        return 'Vejetaryen';
      case MenuType.glutenFree:
        return 'Glutensiz';
    }
  }
}