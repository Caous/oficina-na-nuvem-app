import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Chip de filtro com contador opcional, conforme telas de Serviços e Ordens.
class AppFilterChip extends StatelessWidget {
  final String label;
  final String? count;
  final bool isSelected;
  final VoidCallback onSelected;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? AppColors.bgWhite : AppColors.textSecondary;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + 1,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentBlue : AppColors.bgWhite,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.accentBlue : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: foreground,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: AppSpacing.xs + 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs + 2,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.bgWhite.withValues(alpha: 0.2)
                      : AppColors.gray100,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  count!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
