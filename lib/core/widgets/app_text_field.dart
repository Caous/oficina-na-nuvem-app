import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Campo de formulário com o visual do design: rótulo acima, caixa cinza
/// arredondada com ícone à esquerda e ação opcional à direita.
class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;
  final void Function(String)? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  /// Quando revalidar. O padrão mostra o erro assim que o usuário edita o
  /// campo, em vez de esperar o envio do formulário.
  final AutovalidateMode autovalidateMode;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffix,
    this.maxLines = 1,
    this.inputFormatters = const [],
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.fieldLabel),
        const SizedBox(height: AppSpacing.xs + 2),
        TextFormField(
          controller: controller,
          validator: validator,
          // Revalida a cada digitação depois da primeira interação, para o
          // erro aparecer enquanto o campo é corrigido — não só ao enviar.
          autovalidateMode: autovalidateMode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          inputFormatters: inputFormatters,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          enabled: enabled,
          style: AppTypography.fieldValue,
          decoration: InputDecoration(
            hintText: hint,
            errorStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.accentRed,
            ),
            errorMaxLines: 2,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: icon == null
                ? null
                : Icon(icon, size: 18, color: AppColors.textMuted),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 46,
              minHeight: 24,
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.bgCard,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.accentBlue, width: 1.5),
            errorBorder: _border(AppColors.accentRed),
            focusedErrorBorder: _border(AppColors.accentRed, width: 1.5),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
