import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Diálogo de confirmação para ações destrutivas.
///
/// Retorna `true` somente quando o usuário confirma explicitamente.
abstract final class ConfirmDialog {
  static Future<bool> askDeletion(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Excluir',
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title, style: AppTypography.cardTitle),
          content: Text(message, style: AppTypography.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentRed,
              ),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }
}
