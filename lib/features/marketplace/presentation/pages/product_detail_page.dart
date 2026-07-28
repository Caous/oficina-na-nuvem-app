import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/brl_formatter.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../shared/products/models/product.dart';
import '../../../../shared/products/presentation/product_visuals.dart';
import '../view_models/marketplace_view_model.dart';

/// Detalhe de um produto do marketplace (tela 22), com seleção de quantidade
/// e adição ao carrinho.
class ProductDetailPage extends StatefulWidget {
  final Product product;
  final MarketplaceViewModel viewModel;

  /// Abre o carrinho a partir do atalho no cabeçalho.
  final VoidCallback onOpenCart;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.viewModel,
    required this.onOpenCart,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  Product get _product => widget.product;

  void _changeQuantity(int delta) {
    final updated = (_quantity + delta).clamp(1, _product.stockQuantity);

    if (updated != _quantity) {
      setState(() => _quantity = updated);
    }
  }

  void _addToCart() {
    widget.viewModel.addToCart(_product, quantity: _quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _quantity == 1
              ? '${_product.name} adicionado ao carrinho.'
              : '$_quantity× ${_product.name} adicionados ao carrinho.',
        ),
        action: SnackBarAction(label: 'Ver carrinho', onPressed: widget.onOpenCart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return Column(
              children: [
                AppScreenHeader(
                  title: 'Detalhe do Produto',
                  actions: [
                    _CartShortcut(
                      count: widget.viewModel.cartCount,
                      onPressed: widget.onOpenCart,
                    ),
                  ],
                ),
                Expanded(child: _buildContent()),
                _buildBottomBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.xs,
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 210,
            decoration: BoxDecoration(
              color: ProductVisuals.backgroundOf(_product.category),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(
              ProductVisuals.iconOf(_product.category),
              size: 84,
              color: ProductVisuals.foregroundOf(_product.category),
            ),
          ),
          const SizedBox(height: AppSpacing.md + 2),
          Row(
            children: [
              AppBadge(
                label: _product.category.label,
                foreground: AppColors.accentBlue,
                background: AppColors.accentBlueLight,
              ),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(
                label: '${_product.stockQuantity} em estoque',
                icon: Icons.check,
                foreground: AppColors.accentGreen,
                background: AppColors.accentGreenLight,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _product.name,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Flexible(
                child: Text(
                  'Vendido por ${_product.sellerName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            BrlFormatter.format(_product.price),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.accentBlueDark,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: AppSpacing.lg),
          const Text('Descrição', style: AppTypography.groupTitle),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _product.description,
            style: AppTypography.body.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _StepperButton(
                  icon: Icons.remove,
                  isEnabled: _quantity > 1,
                  onPressed: () => _changeQuantity(-1),
                ),
                SizedBox(
                  width: 34,
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _StepperButton(
                  icon: Icons.add,
                  isEnabled: _quantity < _product.stockQuantity,
                  onPressed: () => _changeQuantity(1),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: SizedBox(
              height: AppSpacing.buttonHeight,
              child: FilledButton(
                onPressed: _addToCart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 18,
                      color: AppColors.bgWhite,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        'Adicionar ao carrinho',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bgWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _StepperButton({
    required this.icon,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onPressed : null,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Icon(
        icon,
        size: 18,
        color: isEnabled ? AppColors.accentBlue : AppColors.textMuted,
      ),
    );
  }
}

/// Atalho do carrinho no cabeçalho, com o contador de itens.
class _CartShortcut extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _CartShortcut({required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentBlueLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 18,
              color: AppColors.accentBlue,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.accentRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.bgWhite,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
