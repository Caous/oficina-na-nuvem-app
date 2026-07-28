import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/product.dart';

/// Ícone e cores de cada categoria de produto.
///
/// Compartilhado pelo estoque da oficina e pelo marketplace, para que o mesmo
/// produto tenha sempre a mesma identidade visual nas duas pontas.
abstract final class ProductVisuals {
  static IconData iconOf(ProductCategory category) {
    return switch (category) {
      ProductCategory.oils => Icons.water_drop_outlined,
      ProductCategory.filters => Icons.filter_alt_outlined,
      ProductCategory.tires => Icons.trip_origin,
      ProductCategory.parts => Icons.settings_outlined,
      ProductCategory.accessories => Icons.chair_outlined,
      ProductCategory.sound => Icons.speaker_outlined,
    };
  }

  static Color foregroundOf(ProductCategory category) {
    return switch (category) {
      ProductCategory.oils => AppColors.accentBlue,
      ProductCategory.filters => AppColors.accentGreen,
      ProductCategory.tires => AppColors.gray700,
      ProductCategory.parts => AppColors.accentPurple,
      ProductCategory.accessories => AppColors.accentAmber,
      ProductCategory.sound => AppColors.accentBlueDark,
    };
  }

  static Color backgroundOf(ProductCategory category) {
    return switch (category) {
      ProductCategory.oils => AppColors.accentBlueLight,
      ProductCategory.filters => AppColors.accentGreenLight,
      ProductCategory.tires => AppColors.gray100,
      ProductCategory.parts => AppColors.accentPurpleLight,
      ProductCategory.accessories => AppColors.accentAmberLight,
      ProductCategory.sound => AppColors.accentBlueLight,
    };
  }
}
