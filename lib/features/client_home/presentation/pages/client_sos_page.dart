import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_screen_header.dart';

/// Tela de socorro/assistência 24 horas (versão simplificada da tela 04 do
/// design).
class ClientSosPage extends StatelessWidget {
  const ClientSosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppScreenHeader(
              title: 'Socorro',
              subtitle: 'Assistência 24 horas',
              showBackButton: false,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppColors.accentRedLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone_in_talk,
                        size: 48,
                        color: AppColors.accentRed,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Text(
                      'Precisa de ajuda agora?',
                      style: AppTypography.cardTitle,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Nossa equipe está pronta para te atender.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppPrimaryButton(
                      label: 'Ligar para o socorro',
                      icon: Icons.call,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Em breve.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
