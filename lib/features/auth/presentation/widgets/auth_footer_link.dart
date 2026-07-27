import 'package:flutter/material.dart';
import 'package:oficina_app/core/theme/app_colors.dart';

/// Rodapé centralizado "Já tem conta? Entrar" usado nas telas de cadastro
/// para retornar ao login.
class AuthFooterLink extends StatelessWidget {
  final VoidCallback onPressed;

  const AuthFooterLink({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Já tem conta?',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: onPressed,
            child: const Text(
              'Entrar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
