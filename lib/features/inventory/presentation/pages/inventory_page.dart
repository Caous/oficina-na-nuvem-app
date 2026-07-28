import 'package:flutter/material.dart';

import '../../../../core/state/view_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/brl_formatter.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_toggle_switch.dart';
import '../../../../shared/products/models/product.dart';
import '../../../../shared/products/presentation/product_visuals.dart';
import '../view_models/inventory_view_model.dart';

/// Estoque da oficina (tela 21): ajusta quantidade, edita preço e publica o
/// produto no marketplace do cliente.
class InventoryPage extends StatefulWidget {
  final InventoryViewModel viewModel;

  /// Abre o formulário de produto; `null` cria, preenchido edita.
  /// Retorna `true` quando algo mudou.
  final Future<bool?> Function(Product? product) onOpenProductForm;

  const InventoryPage({
    super.key,
    required this.viewModel,
    required this.onOpenProductForm,
  });

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _searchController = TextEditingController();

  InventoryViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm(Product? product) async {
    final changed = await widget.onOpenProductForm(product);

    if (changed == true) {
      await _viewModel.load();
    }
  }

  Future<void> _adjustStock(Product product, int delta) async {
    if (delta < 0 && product.isOutOfStock) {
      return;
    }

    final applied = await _viewModel.adjustStock(product.id, delta);

    if (!applied && mounted) {
      _showError();
    }
  }

  Future<void> _togglePublished(Product product, bool value) async {
    final applied = await _viewModel.setPublished(product.id, value);

    if (!mounted) {
      return;
    }

    if (!applied) {
      _showError();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? '${product.name} publicado no marketplace.'
              : '${product.name} saiu do marketplace.',
        ),
      ),
    );
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _viewModel.errorMessage ?? 'Não foi possível atualizar o produto.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentBlue,
        onPressed: () => _openForm(null),
        child: const Icon(Icons.add, color: AppColors.bgWhite),
      ),
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              children: [
                AppScreenHeader(
                  title: 'Estoque e Produtos',
                  subtitle:
                      '${_viewModel.totalCount} produtos • '
                      '${_viewModel.publishedCount} no marketplace',
                  showBackButton: false,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.md,
                    AppSpacing.screenHorizontal,
                    AppSpacing.sm,
                  ),
                  child: AppSearchField(
                    hint: 'Buscar no estoque...',
                    controller: _searchController,
                    onChanged: _viewModel.search,
                  ),
                ),
                Expanded(child: _buildBody()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    return switch (_viewModel.state) {
      ViewStateLoading<List<Product>>() => const Center(
        child: CircularProgressIndicator(),
      ),
      ViewStateFailure<List<Product>>(:final message) => AppEmptyState(
        icon: Icons.error_outline,
        title: 'Algo deu errado',
        message: message,
        actionLabel: 'Tentar novamente',
        onAction: _viewModel.load,
      ),
      ViewStateSuccess<List<Product>>() => _buildList(),
    };
  }

  Widget _buildList() {
    final products = _viewModel.visibleProducts;

    if (products.isEmpty) {
      return AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Nenhum produto',
        message: _viewModel.searchQuery.isEmpty
            ? 'Cadastre o primeiro produto do seu estoque.'
            : 'Nenhum produto encontrado para a busca.',
        actionLabel: _viewModel.searchQuery.isEmpty ? 'Cadastrar produto' : null,
        onAction: _viewModel.searchQuery.isEmpty ? () => _openForm(null) : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        100,
      ),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final product = products[index];

        return _StockCard(
          product: product,
          onEdit: () => _openForm(product),
          onDecrease: () => _adjustStock(product, -1),
          onIncrease: () => _adjustStock(product, 1),
          onTogglePublished: (value) => _togglePublished(product, value),
        );
      },
    );
  }
}

/// Linha do estoque com preço, ajuste de quantidade e chave do marketplace.
class _StockCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final ValueChanged<bool> onTogglePublished;

  const _StockCard({
    required this.product,
    required this.onEdit,
    required this.onDecrease,
    required this.onIncrease,
    required this.onTogglePublished,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: ProductVisuals.backgroundOf(product.category),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  ProductVisuals.iconOf(product.category),
                  size: 20,
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
                      style: AppTypography.fieldValue,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.category.label} • SKU ${product.sku}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  BrlFormatter.format(product.price),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              _SquareButton(
                icon: Icons.edit_outlined,
                foreground: AppColors.accentBlue,
                background: AppColors.accentBlueLight,
                size: 26,
                iconSize: 13,
                tooltip: 'Editar produto',
                onPressed: onEdit,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: AppSpacing.sm + 2),
          Row(
            children: [
              Text(
                'Estoque',
                style: AppTypography.caption.copyWith(fontSize: 11),
              ),
              const SizedBox(width: AppSpacing.sm),
              _SquareButton(
                icon: Icons.remove,
                foreground: AppColors.accentRed,
                background: AppColors.accentRedLight,
                tooltip: 'Dar baixa',
                onPressed: product.isOutOfStock ? null : onDecrease,
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '${product.stockQuantity}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: product.isOutOfStock
                        ? AppColors.accentRed
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              _SquareButton(
                icon: Icons.add,
                foreground: AppColors.accentBlue,
                background: AppColors.accentBlueLight,
                tooltip: 'Dar entrada',
                onPressed: onIncrease,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppToggleSwitch(
                    value: product.isPublished,
                    onChanged: onTogglePublished,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.isPublished ? 'NO MARKETPLACE' : 'FORA DO AR',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: product.isPublished
                          ? AppColors.accentBlue
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (product.isPublished && product.isOutOfStock) ...[
            const SizedBox(height: AppSpacing.sm),
            const _OutOfStockWarning(),
          ],
        ],
      ),
    );
  }
}

/// Publicado sem estoque não chega ao cliente — o aviso explica o porquê.
class _OutOfStockWarning extends StatelessWidget {
  const _OutOfStockWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentAmberLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.accentAmber),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Sem estoque: não aparece na loja até repor.',
              style: TextStyle(fontSize: 11, color: AppColors.gray700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final double iconSize;

  const _SquareButton({
    required this.icon,
    required this.foreground,
    required this.background,
    required this.tooltip,
    this.onPressed,
    this.size = 28,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isEnabled ? background : AppColors.gray100,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: isEnabled ? foreground : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
