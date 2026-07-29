import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/service_order.dart';

/// Mapeia [ServiceOrderStatus] para as cores de destaque do design.
///
/// Centraliza a associação status → cor para que badges e chips em toda a
/// feature (e eventualmente outras, como o dashboard) usem sempre a mesma
/// paleta.
abstract final class ServiceOrderStatusVisuals {
  static Color foregroundOf(ServiceOrderStatus status) {
    return switch (status) {
      ServiceOrderStatus.inProgress => AppColors.accentBlue,
      ServiceOrderStatus.awaitingApproval => AppColors.accentAmber,
      ServiceOrderStatus.testing => AppColors.accentPurple,
      ServiceOrderStatus.approved => AppColors.accentGreen,
      ServiceOrderStatus.completed => AppColors.accentGreen,
      ServiceOrderStatus.cancelled => AppColors.accentRed,
    };
  }

  static Color backgroundOf(ServiceOrderStatus status) {
    return switch (status) {
      ServiceOrderStatus.inProgress => AppColors.accentBlueLight,
      ServiceOrderStatus.awaitingApproval => AppColors.accentAmberLight,
      ServiceOrderStatus.testing => AppColors.accentPurpleLight,
      ServiceOrderStatus.approved => AppColors.accentGreenLight,
      ServiceOrderStatus.completed => AppColors.accentGreenLight,
      ServiceOrderStatus.cancelled => AppColors.accentRedLight,
    };
  }
}
