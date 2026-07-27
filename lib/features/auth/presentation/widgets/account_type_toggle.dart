import 'package:flutter/material.dart';
import 'package:oficina_app/core/theme/app_colors.dart';
import 'package:oficina_app/core/theme/app_spacing.dart';
import 'package:oficina_app/features/auth/models/account_registration.dart';

/// Seletor segmentado "Cliente | Oficina" usado no topo das telas de
/// cadastro para escolher o tipo de conta.
class AccountTypeToggle extends StatelessWidget {
  final AccountType selected;
  final ValueChanged<AccountType> onChanged;

  const AccountTypeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              icon: Icons.person_outline,
              label: 'Cliente',
              isActive: selected == AccountType.client,
              onTap: () => onChanged(AccountType.client),
            ),
          ),
          Expanded(
            child: _Segment(
              icon: Icons.storefront_outlined,
              label: 'Oficina',
              isActive: selected == AccountType.workshop,
              onTap: () => onChanged(AccountType.workshop),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Segment({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.bgWhite : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.bgWhite : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
