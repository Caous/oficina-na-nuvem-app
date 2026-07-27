import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_screen_header.dart';

/// Tela de perfil do cliente: dados básicos e ações de conta.
class ClientProfilePage extends StatelessWidget {
  final String userName;
  final String email;
  final VoidCallback onLogout;

  const ClientProfilePage({
    super.key,
    required this.userName,
    required this.email,
    required this.onLogout,
  });

  String get _initials {
    final words = userName.trim().split(RegExp(r'\s+'));
    final first = words.isNotEmpty && words.first.isNotEmpty
        ? words.first[0]
        : '';
    final last = words.length > 1 && words.last.isNotEmpty
        ? words.last[0]
        : '';

    final initials = '$first$last'.toUpperCase();
    return initials.isEmpty ? '?' : initials;
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Em breve.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppScreenHeader(title: 'Perfil', showBackButton: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.xl,
                  AppSpacing.screenHorizontal,
                  100,
                ),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.accentBlueLight,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          userName,
                          textAlign: TextAlign.center,
                          style: AppTypography.sectionTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: AppTypography.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _ProfileRow(
                          icon: Icons.person_outline,
                          label: 'Meus dados',
                          onTap: () => _showComingSoon(context),
                        ),
                        const Divider(height: 1, color: AppColors.borderLight),
                        _ProfileRow(
                          icon: Icons.notifications_none,
                          label: 'Notificações',
                          onTap: () => _showComingSoon(context),
                        ),
                        const Divider(height: 1, color: AppColors.borderLight),
                        _ProfileRow(
                          icon: Icons.help_outline,
                          label: 'Ajuda',
                          onTap: () => _showComingSoon(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppDestructiveButton(
                    label: 'Sair da conta',
                    icon: Icons.logout,
                    onPressed: onLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.fieldValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
