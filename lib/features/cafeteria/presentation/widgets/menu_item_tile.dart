import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/menu_item.dart';

class MenuItemTile extends StatelessWidget {
  final MenuItem item;
  final bool isHighlighted;
  final bool isCompact;

  const MenuItemTile({
    super.key,
    required this.item,
    this.isHighlighted = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.ingredients.isNotEmpty 
          ? () => _showIngredientsDialog(context)
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 8 : 12, 
          horizontal: isCompact ? 4 : 8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Yemek ikonu
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getItemColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _getItemIcon(),
                size: isCompact ? 16 : 20,
                color: _getItemColor(),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // İçerik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Yemek adı
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: isCompact ? 14 : 16,
                      fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                      color: isHighlighted ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Kalori ve karbonhidrat bilgisi
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (item.calories > 0) ...[
                        Icon(
                          Icons.local_fire_department,
                          size: 12,
                          color: AppColors.gradeRed,
                        ),
                        Text(
                          '${item.calories} kcal',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      
                      if (item.calories > 0 && item.carbohydrates != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 2,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.textHint,
                            shape: BoxShape.circle,
                          ),
                        ),
                      
                      if (item.carbohydrates != null) ...[
                        Icon(
                          Icons.grass,
                          size: 12,
                          color: AppColors.gradeGreen,
                        ),
                        Text(
                          item.carbohydrates!,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // İçerik gösterme ikonu
            if (item.ingredients.isNotEmpty)
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textHint,
              ),
          ],
        ),
      ),
    );
  }

  Color _getItemColor() {
    final lowerName = item.name.toLowerCase();
    
    if (lowerName.contains('çorba') || lowerName.contains('soup')) {
      return AppColors.gradeBlue;
    } else if (lowerName.contains('et') || 
               lowerName.contains('tavuk') || 
               lowerName.contains('köfte') ||
               lowerName.contains('kebap') ||
               lowerName.contains('döner')) {
      return AppColors.gradeRed;
    } else if (lowerName.contains('pilav') || 
               lowerName.contains('makarna') ||
               lowerName.contains('börek') ||
               lowerName.contains('şehriye')) {
      return AppColors.gradeYellow;
    } else if (lowerName.contains('salata') || 
               lowerName.contains('fasulye') ||
               lowerName.contains('sebze') ||
               lowerName.contains('zeytinyağlı')) {
      return AppColors.gradeGreen;
    } else if (lowerName.contains('tatlı') ||
               lowerName.contains('sütlaç') ||
               lowerName.contains('tulumba') ||
               lowerName.contains('brownie') ||
               lowerName.contains('kemalpaşa') ||
               lowerName.contains('supangle')) {
      return Colors.purple;
    } else if (lowerName.contains('meyve') ||
               lowerName.contains('ayran') ||
               lowerName.contains('cacık') ||
               lowerName.contains('meşrubat')) {
      return AppColors.primary;
    } else {
      return AppColors.textHint;
    }
  }

  IconData _getItemIcon() {
    final lowerName = item.name.toLowerCase();
    
    if (lowerName.contains('çorba') || lowerName.contains('soup')) {
      return Icons.soup_kitchen;
    } else if (lowerName.contains('et') || 
               lowerName.contains('tavuk') || 
               lowerName.contains('köfte') ||
               lowerName.contains('kebap') ||
               lowerName.contains('döner')) {
      return Icons.lunch_dining;
    } else if (lowerName.contains('pilav') || 
               lowerName.contains('makarna') ||
               lowerName.contains('börek') ||
               lowerName.contains('şehriye')) {
      return Icons.rice_bowl;
    } else if (lowerName.contains('salata') || 
               lowerName.contains('fasulye') ||
               lowerName.contains('sebze') ||
               lowerName.contains('zeytinyağlı')) {
      return Icons.eco;
    } else if (lowerName.contains('tatlı') ||
               lowerName.contains('sütlaç') ||
               lowerName.contains('tulumba') ||
               lowerName.contains('brownie') ||
               lowerName.contains('kemalpaşa') ||
               lowerName.contains('supangle')) {
      return Icons.cake;
    } else if (lowerName.contains('meyve')) {
      return Icons.apple;
    } else if (lowerName.contains('ayran') ||
               lowerName.contains('cacık') ||
               lowerName.contains('meşrubat')) {
      return Icons.local_drink;
    } else {
      return Icons.restaurant;
    }
  }

  void _showIngredientsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İçindekiler:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.ingredients,
              style: const TextStyle(fontSize: 14),
            ),
            if (item.calories > 0 || item.carbohydrates != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (item.calories > 0) ...[
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: AppColors.gradeRed,
                    ),
                    const SizedBox(width: 4),
                    Text('${item.calories} kcal'),
                  ],
                  if (item.calories > 0 && item.carbohydrates != null)
                    const Text(' • '),
                  if (item.carbohydrates != null) ...[
                    Icon(
                      Icons.grass,
                      size: 16,
                      color: AppColors.gradeGreen,
                    ),
                    const SizedBox(width: 4),
                    Text('Karbonhidrat: ${item.carbohydrates}'),
                  ],
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}