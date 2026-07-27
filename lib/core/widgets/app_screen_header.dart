import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Cabeçalho das telas: título, subtítulo opcional, botão de voltar e ações.
///
/// Reproduz o header do design em vez do `AppBar` padrão, que não comporta
/// o par título + contador na mesma coluna.
class AppScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget> actions;

  const AppScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.bgWhite,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: Icon(
                  Icons.chevron_left,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.screenTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          for (final action in actions) ...[
            const SizedBox(width: AppSpacing.sm),
            action,
          ],
        ],
      ),
    );
  }
}

/// Botão quadrado de ação no cabeçalho.
class AppHeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color foreground;
  final Color background;

  const AppHeaderAction({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.foreground = AppColors.accentBlue,
    this.background = AppColors.accentBlueLight,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 18, color: foreground),
        ),
      ),
    );
  }
}
