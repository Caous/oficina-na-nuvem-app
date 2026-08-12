import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/brl_formatter.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../shared/products/presentation/product_visuals.dart';
import '../../models/cart_item.dart';
import '../view_models/marketplace_view_model.dart';

/// Carrinho do marketplace (tela 23): quantidades, remoção, total e envio do
/// pedido à oficina.
class CartPage extends StatelessWidget {
  final MarketplaceViewModel viewModel;

  const CartPage({super.key, required this.viewModel});

  Future<void> _clearCart(BuildContext context) async {
    final confirmed = await ConfirmDialog.askDeletion(
      context,
      title: 'Limpar carrinho',
      message: 'Todos os itens serão removidos.',
      confirmLabel: 'Limpar',
    );

    if (confirmed) {
      viewModel.clearCart();
    }
  }

  Future<void> _checkout(BuildContext context) async {
    final total = BrlFormatter.format(viewModel.cartSubtotal);
    final sellerName = viewModel.cartItems.first.product.sellerName;

    final placed = await viewModel.checkout();

    if (!context.mounted) {
      return;
    }

    if (!placed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível enviar o pedido. Tente novamente.',
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pedido enviado! 🎉', style: AppTypography.cardTitle),
          content: Text(
            'A $sellerName recebeu seu pedido de $total e vai te chamar '
            'para combinar a retirada ou entrega.',
            style: AppTypography.body.copyWith(height: 1.4),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
              ),
              child: const Text('Combinado'),
            ),
          ],
        );
      },
    );

    if (context.mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final items = viewModel.cartItems;

            return Column(
              children: [
                AppScreenHeader(
                  title: 'Carrinho',
                  subtitle: items.isEmpty
                      ? 'Nenhum item'
                      : '${viewModel.cartCount} '
                            '${viewModel.cartCount == 1 ? "item" : "itens"} da '
                            '${items.first.product.sellerName}',
                  actions: [
                    if (items.isNotEmpty)
                      TextButton(
                        onPressed: () => _clearCart(context),
                        child: const Text(
                          'Limpar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentRed,
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: items.isEmpty
                      ? AppEmptyState(
                          icon: Icons.shopping_cart_outlined,
                          title: 'Carrinho vazio',
                          message:
                              'Adicione produtos do marketplace para montar '
                              'seu pedido.',
                          actionLabel: 'Voltar à loja',
                          onAction: () => Navigator.of(context).maybePop(),
                        )
                      : _buildItems(items),
                ),
                if (items.isNotEmpty) _buildBottomBar(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildItems(List<CartItem> items) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.xs,
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
      ),
      children: [
        for (final (index, item) in items.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.md),
          _CartItemCard(
            item: item,
            onDecrease: () =>
                viewModel.changeQuantity(item.product.id, -1),
            onIncrease: () => viewModel.changeQuantity(item.product.id, 1),
            onRemove: () => viewModel.removeFromCart(item.product.id),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _SummaryCard(viewModel: viewModel),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md + 2,
        AppSpacing.screenHorizontal,
        AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: AppSpacing.buttonHeight,
            child: FilledButton(
              onPressed:
                  viewModel.isPlacingOrder ? null : () => _checkout(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 18, color: AppColors.bgWhite),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Finalizar pedido',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bgWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Você combina a retirada ou entrega direto com a oficina.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ProductVisuals.backgroundOf(product.category),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              ProductVisuals.iconOf(product.category),
              size: 22,
              color: ProductVisuals.foregroundOf(product.category),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${BrlFormatter.format(product.price)} cada',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      isEnabled: item.quantity > 1,
                      isPrimary: false,
                      onPressed: onDecrease,
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      isEnabled: item.quantity < product.stockQuantity,
                      isPrimary: true,
                      onPressed: onIncrease,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.accentRedLight,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 14,
                    color: AppColors.accentRed,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm + 2),
              Text(
                BrlFormatter.format(item.lineTotal),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _QuantityButton({
    required this.icon,
    required this.isEnabled,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onPressed : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: !isEnabled
              ? AppColors.gray100
              : isPrimary
              ? AppColors.accentBlueLight
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: isPrimary || !isEnabled
              ? null
              : Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 13,
          color: !isEnabled
              ? AppColors.textMuted
              : isPrimary
              ? AppColors.accentBlue
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final MarketplaceViewModel viewModel;

  const _SummaryCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final subtotal = BrlFormatter.format(viewModel.cartSubtotal);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Subtotal (${viewModel.cartCount} '
                '${viewModel.cartCount == 1 ? "produto" : "produtos"})',
            value: subtotal,
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          const _SummaryRow(
            label: 'Retirada na oficina',
            value: 'Grátis',
            valueColor: AppColors.accentGreen,
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: AppSpacing.sm + 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtotal,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentBlueDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
