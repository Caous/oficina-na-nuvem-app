import 'package:flutter/material.dart';
import 'package:oficina_app/core/theme/app_colors.dart';
import 'package:oficina_app/features/service_catalog/models/service_category.dart';

/// Ícone e cores associados a cada [ServiceCategoryStyle].
///
/// Centraliza o mapeamento visual para que as páginas de categorias e de
/// serviços fiquem consistentes sem duplicar o `switch`.
class CategoryVisual {
  final IconData icon;
  final Color foreground;
  final Color background;

  const CategoryVisual({
    required this.icon,
    required this.foreground,
    required this.background,
  });

  factory CategoryVisual.of(ServiceCategoryStyle style) {
    return switch (style) {
      ServiceCategoryStyle.engine => const CategoryVisual(
        icon: Icons.settings,
        foreground: AppColors.accentBlue,
        background: AppColors.accentBlueLight,
      ),
      ServiceCategoryStyle.brakes => const CategoryVisual(
        icon: Icons.album_outlined,
        foreground: AppColors.accentRed,
        background: AppColors.accentRedLight,
      ),
      ServiceCategoryStyle.suspension => const CategoryVisual(
        icon: Icons.height,
        foreground: AppColors.accentPurple,
        background: AppColors.accentPurpleLight,
      ),
      ServiceCategoryStyle.electrical => const CategoryVisual(
        icon: Icons.bolt,
        foreground: AppColors.accentAmber,
        background: AppColors.accentAmberLight,
      ),
      ServiceCategoryStyle.fluids => const CategoryVisual(
        icon: Icons.water_drop_outlined,
        foreground: AppColors.accentGreen,
        background: AppColors.accentGreenLight,
      ),
      ServiceCategoryStyle.generic => const CategoryVisual(
        icon: Icons.category_outlined,
        foreground: AppColors.textSecondary,
        background: AppColors.gray100,
      ),
    };
  }
}
