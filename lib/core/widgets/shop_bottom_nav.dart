import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Abas da área da oficina, na ordem em que aparecem na navegação.
enum ShopTab {
  dashboard(Icons.dashboard_outlined, 'INÍCIO'),
  orders(Icons.assignment_outlined, 'ORDENS'),
  services(Icons.build_outlined, 'SERVIÇOS'),
  team(Icons.people_outline, 'EQUIPE');

  final IconData icon;
  final String label;

  const ShopTab(this.icon, this.label);
}

/// Barra inferior em formato de pílula, conforme o design.
class ShopBottomNav extends StatelessWidget {
  final ShopTab current;
  final ValueChanged<ShopTab> onTabSelected;

  const ShopBottomNav({
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
              for (final tab in ShopTab.values)
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
  final ShopTab tab;
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
