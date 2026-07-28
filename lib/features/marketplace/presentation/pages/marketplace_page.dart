import 'package:flutter/material.dart';

import '../../../../core/state/view_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/brl_formatter.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_filter_chip.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../shared/products/models/product.dart';
import '../../../../shared/products/presentation/product_visuals.dart';
import '../view_models/marketplace_view_model.dart';

/// Tela 20 — Marketplace: loja de peças e acessórios vista pelo cliente.
class MarketplacePage extends StatefulWidget {
  final MarketplaceViewModel viewModel;

  /// Abre o detalhe do produto tocado (tela 22).
  final ValueChanged<Product> onOpenProduct;

  /// Abre o carrinho (tela 23).
  final VoidCallback onOpenCart;

  const MarketplacePage({
    super.key,
    required this.viewModel,
    required this.onOpenProduct,
    required this.onOpenCart,
  });

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<ProductSort>(
      context: context,
      backgroundColor: AppColors.bgWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              const Text('Ordenar por', style: AppTypography.groupTitle),
              const SizedBox(height: AppSpacing.sm),
              for (final option in ProductSort.values)
                ListTile(
                  title: Text(option.label, style: AppTypography.fieldValue),
                  trailing: widget.viewModel.sort == option
                      ? const Icon(Icons.check, color: AppColors.accentBlue)
                      : null,
                  onTap: () => Navigator.of(context).pop(option),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      widget.viewModel.changeSort(selected);
    }
  }

  void _handleAddToCart(Product product) {
    widget.viewModel.addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} adicionado ao carrinho.'),
        action: SnackBarAction(
          label: 'Ver carrinho',
          onPressed: widget.onOpenCart,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return Column(
              children: [
                AppScreenHeader(
                  title: 'Marketplace',
                  subtitle: 'Peças e acessórios para seu veículo',
                  showBackButton: false,
                  actions: [
                    _CartButton(
                      count: widget.viewModel.cartCount,
                      onPressed: widget.onOpenCart,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildSearchRow(),
                const SizedBox(height: AppSpacing.sm),
                _buildCategoryChips(),
                _buildContextRow(),
                Expanded(child: _buildBody()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppSearchField(
              hint: 'Buscar produto...',
              controller: _searchController,
              onChanged: widget.viewModel.search,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          InkWell(
            onTap: _openSortSheet,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.swap_vert,
                size: 17,
                color: AppColors.accentBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final selected = widget.viewModel.selectedCategory;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.sm,
        ),
        children: [
          AppFilterChip(
            label: 'Todos',
            isSelected: selected == null,
            onSelected: () => widget.viewModel.filterByCategory(null),
          ),
          for (final category in ProductCategory.values) ...[
            const SizedBox(width: AppSpacing.sm),
            AppFilterChip(
              label: category.label,
              isSelected: selected == category,
              onSelected: () => widget.viewModel.filterByCategory(category),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContextRow() {
    final count = widget.viewModel.visibleProducts.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text('$count produtos', style: AppTypography.caption),
          const Spacer(),
          // Flexible + ellipsis: rótulos de ordenação longos não podem
          // empurrar a linha para fora da tela.
          Flexible(
            child: InkWell(
              onTap: _openSortSheet,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ordenar: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      widget.viewModel.sort.label,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    const Icon(
                      Icons.expand_more,
                      size: 13,
                      color: AppColors.accentBlue,
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

  Widget _buildBody() {
    final state = widget.viewModel.state;

    return switch (state) {
      ViewStateLoading() => const Center(child: CircularProgressIndicator()),
      ViewStateFailure(:final message) => AppEmptyState(
        icon: Icons.error_outline,
        title: 'Algo deu errado',
        message: message,
        actionLabel: 'Tentar novamente',
        onAction: widget.viewModel.load,
      ),
      ViewStateSuccess() => _buildGrid(),
    };
  }

  Widget _buildGrid() {
    final products = widget.viewModel.visibleProducts;

    if (products.isEmpty) {
      return const AppEmptyState(
        icon: Icons.search_off,
        title: 'Nenhum produto encontrado',
        message: 'Tente outra busca ou categoria.',
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.62,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.xxl,
      ),
      children: [
        for (final product in products)
          _ProductCard(
            product: product,
            onAddToCart: _handleAddToCart,
            onOpen: () => widget.onOpenProduct(product),
          ),
      ],
    );
  }
}

/// Botão de carrinho do cabeçalho, com badge de contagem.
class _CartButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _CartButton({required this.count, required this.onPressed});

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

/// Card de produto da grade do marketplace.
///
/// O card inteiro abre o detalhe; o botão "+" adiciona direto ao carrinho.
class _ProductCard extends StatelessWidget {
  final Product product;
  final ValueChanged<Product> onAddToCart;
  final VoidCallback onOpen;

  const _ProductCard({
    required this.product,
    required this.onAddToCart,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 88,
            decoration: BoxDecoration(
              color: ProductVisuals.backgroundOf(product.category),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Icon(
                ProductVisuals.iconOf(product.category),
                size: 34,
                color: ProductVisuals.foregroundOf(product.category),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            product.sellerName,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Flexible(
                child: Text(
                  BrlFormatter.format(product.price),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              InkWell(
                onTap: () => onAddToCart(product),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 15,
                    color: AppColors.bgWhite,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
