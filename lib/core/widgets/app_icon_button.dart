import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Botão quadrado de ação em linha de lista (editar / excluir).
class AppIconActionButton extends StatelessWidget {
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback onPressed;
  final String tooltip;

  const AppIconActionButton({
    super.key,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onPressed,
    required this.tooltip,
  });

  /// Variante azul de edição.
  factory AppIconActionButton.edit({required VoidCallback onPressed}) {
    return AppIconActionButton(
      icon: Icons.edit_outlined,
      foreground: AppColors.accentBlue,
      background: AppColors.accentBlueLight,
      onPressed: onPressed,
      tooltip: 'Editar',
    );
  }

  /// Variante vermelha de exclusão.
  factory AppIconActionButton.delete({required VoidCallback onPressed}) {
    return AppIconActionButton(
      icon: Icons.delete_outline,
      foreground: AppColors.accentRed,
      background: AppColors.accentRedLight,
      onPressed: onPressed,
      tooltip: 'Excluir',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 16, color: foreground),
        ),
      ),
    );
  }
}

/// Círculo colorido com ícone, usado em cartões de métrica e categorias.
class AppIconBadge extends StatelessWidget {
  final IconData icon;
  final Color foreground;
  final Color background;
  final double size;
  final double radius;

  const AppIconBadge({
    super.key,
    required this.icon,
    required this.foreground,
    required this.background,
    this.size = 40,
    this.radius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, size: size * 0.48, color: foreground),
    );
  }
}
