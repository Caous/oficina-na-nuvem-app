import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Abas da área do cliente, na ordem em que aparecem na navegação.
enum ClientTab {
  home(Icons.home_outlined, 'HOME'),
  vehicles(Icons.directions_car_outlined, 'VEÍCULOS'),
  sos(Icons.phone_in_talk_outlined, 'SOCORRO'),
  profile(Icons.person_outline, 'PERFIL');

  final IconData icon;
  final String label;

  const ClientTab(this.icon, this.label);
}

/// Barra inferior em formato de pílula da área do cliente, mesmo visual da
/// navegação da oficina (`ShopBottomNav`).
class ClientBottomNav extends StatelessWidget {
  final ClientTab current;
  final ValueChanged<ClientTab> onTabSelected;

  const ClientBottomNav({
    super.key,
    required this.current,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgWhite,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl + 1,
        AppSpacing.md,
        AppSpacing.xl + 1,
        AppSpacing.md,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 62,
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              for (final tab in ClientTab.values)
                Expanded(
                  child: _NavItem(
                    tab: tab,
                    isActive: tab == current,
                    onTap: () => onTabSelected(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final ClientTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isActive ? AppColors.bgWhite : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tab.icon, size: 18, color: foreground),
            const SizedBox(height: AppSpacing.xs),
            Text(
              tab.label,
              style: AppTypography.navLabel.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
