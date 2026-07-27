import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Etiqueta arredondada usada para status, categorias e contadores.
class AppBadge extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final bool showDot;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.showDot = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs + 1),
          ],
          if (icon != null) ...[
            Icon(icon, size: 11, color: foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTypography.badge.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
