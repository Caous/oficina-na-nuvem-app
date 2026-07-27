import 'package:flutter/material.dart';
import 'package:oficina_app/core/state/view_state.dart';
import 'package:oficina_app/core/theme/app_colors.dart';
import 'package:oficina_app/core/theme/app_spacing.dart';
import 'package:oficina_app/core/theme/app_typography.dart';
import 'package:oficina_app/core/utils/brl_formatter.dart';
import 'package:oficina_app/core/widgets/app_badge.dart';
import 'package:oficina_app/core/widgets/app_card.dart';
import 'package:oficina_app/core/widgets/app_empty_state.dart';
import 'package:oficina_app/core/widgets/app_filter_chip.dart';
import 'package:oficina_app/core/widgets/app_icon_button.dart';
import 'package:oficina_app/core/widgets/app_screen_header.dart';
import 'package:oficina_app/core/widgets/confirm_dialog.dart';
import 'package:oficina_app/features/service_catalog/models/workshop_service.dart';
import 'package:oficina_app/features/service_catalog/presentation/view_models/services_view_model.dart';

/// Tela 15 — Serviços: catálogo filtrável por categoria.
///
/// Não constrói o formulário de serviço: delega a navegação para
/// [onOpenServiceForm], recarregando a lista quando o retorno indica sucesso.
class ServicesPage extends StatefulWidget {
  final ServicesViewModel viewModel;
  final VoidCallback onOpenCategories;
  final Future<bool?> Function(WorkshopService? service) onOpenServiceForm;

  const ServicesPage({
    super.key,
    required this.viewModel,
    required this.onOpenCategories,
    required this.onOpenServiceForm,
  });

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  Future<void> _handleOpenForm(WorkshopService? service) async {
    final shouldReload = await widget.onOpenServiceForm(service);

    if (shouldReload == true) {
      widget.viewModel.load();
    }
  }

  Future<void> _handleDelete(WorkshopService service) async {
    final confirmed = await ConfirmDialog.askDeletion(
      context,
      title: 'Excluir serviço',
      message: 'Deseja realmente excluir o serviço "${service.name}"?',
    );

    if (!confirmed) {
      return;
    }

    final deleted = await widget.viewModel.delete(service.id);

    if (!deleted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir o serviço.')),
      );
    }
  }

  String _formatDiscount(double percent) {
    final isWhole = percent == percent.roundToDouble();
    final formatted = isWhole
        ? percent.toStringAsFixed(0)
        : percent.toString().replaceAll('.', ',');

    return 'até $formatted% off';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentBlue,
        onPressed: () => _handleOpenForm(null),
        child: const Icon(Icons.add, color: AppColors.bgWhite),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final state = widget.viewModel.state;

            return Column(
              children: [
                AppScreenHeader(
                  title: 'Serviços',
                  subtitle: '${widget.viewModel.totalCount} serviços cadastrados',
                  actions: [
                    AppHeaderAction(
                      icon: Icons.sell_outlined,
                      tooltip: 'Gerenciar categorias',
                      onPressed: widget.onOpenCategories,
                    ),
                  ],
                ),
                _buildFilterChips(),
                Expanded(
                  child: switch (state) {
                    ViewStateLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    ViewStateFailure(:final message) => AppEmptyState(
                      icon: Icons.error_outline,
                      title: 'Algo deu errado',
                      message: message,
                      actionLabel: 'Tentar novamente',
                      onAction: widget.viewModel.load,
                    ),
                    ViewStateSuccess() => _buildContent(),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final categories = widget.viewModel.categories;
    final selectedId = widget.viewModel.selectedCategoryId;

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
            isSelected: selectedId == null,
            onSelected: () => widget.viewModel.filterByCategory(null),
          ),
          for (final category in categories) ...[
            const SizedBox(width: AppSpacing.sm),
            AppFilterChip(
              label: category.name,
              isSelected: selectedId == category.id,
              onSelected: () => widget.viewModel.filterByCategory(category.id),
            ),
          ],
          const SizedBox(width: AppSpacing.sm),
          _ManageCategoriesChip(onPressed: widget.onOpenCategories),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final services = widget.viewModel.visibleServices;

    if (services.isEmpty) {
      return const AppEmptyState(
        icon: Icons.build_outlined,
        title: 'Nenhum serviço encontrado',
        message: 'Cadastre um serviço ou ajuste o filtro de categoria.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.xxl,
      ),
      children: [
        for (final service in services) ...[
          _buildServiceCard(service),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildServiceCard(WorkshopService service) {
    final categoryName = widget.viewModel.categoryNameOf(service.categoryId);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.name, style: AppTypography.cardTitle),
                    const SizedBox(height: AppSpacing.xs),
                    AppBadge(
                      label: categoryName,
                      foreground: AppColors.accentBlue,
                      background: AppColors.accentBlueLight,
                    ),
                  ],
                ),
              ),
              AppIconActionButton.edit(
                onPressed: () => _handleOpenForm(service),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppIconActionButton.delete(
                onPressed: () => _handleDelete(service),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(service.description, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(BrlFormatter.format(service.price), style: AppTypography.price),
              const Spacer(),
              AppBadge(
                label: _formatDiscount(service.maxDiscountPercent),
                icon: Icons.percent,
                foreground: AppColors.accentGreen,
                background: AppColors.accentGreenLight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Atalho ao final dos filtros que leva ao gerenciamento de categorias.
///
/// Duplica a ação do cabeçalho de propósito: o ícone sozinho não deixa claro
/// onde categorias são cadastradas.
class _ManageCategoriesChip extends StatelessWidget {
  final VoidCallback onPressed;

  const _ManageCategoriesChip({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + 1,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.accentBlueLight,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, size: 14, color: AppColors.accentBlue),
            SizedBox(width: AppSpacing.xs + 2),
            Text(
              'Categorias',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
