import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Campo de busca das telas de listagem.
class AppSearchField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const AppSearchField({
    super.key,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        prefixIcon: const Icon(
          Icons.search,
          size: 18,
          color: AppColors.textMuted,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 46,
          minHeight: 24,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
        filled: true,
        fillColor: AppColors.bgWhite,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.accentBlue, width: 1.5),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
