import 'package:flutter/material.dart';
import 'package:oficina_app/core/theme/app_colors.dart';
import 'package:oficina_app/core/widgets/app_text_field.dart';

/// Campo de senha com botão de olho para alternar a visibilidade do texto.
/// Compartilhado entre as telas de cadastro de cliente e de oficina.
class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  const PasswordFormField({
    super.key,
    required this.controller,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Senha',
      hint: '••••••••',
      icon: Icons.lock_outline,
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      suffix: IconButton(
        onPressed: () => setState(() => _obscureText = !_obscureText),
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 18,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
