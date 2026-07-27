import 'package:flutter/material.dart';
import 'package:oficina_app/core/state/view_state.dart';
import 'package:oficina_app/core/theme/app_colors.dart';
import 'package:oficina_app/core/theme/app_spacing.dart';
import 'package:oficina_app/core/theme/app_typography.dart';
import 'package:oficina_app/core/widgets/app_card.dart';
import 'package:oficina_app/core/widgets/app_empty_state.dart';
import 'package:oficina_app/core/widgets/app_icon_button.dart';
import 'package:oficina_app/core/widgets/app_screen_header.dart';
import 'package:oficina_app/core/widgets/confirm_dialog.dart';
import 'package:oficina_app/features/service_catalog/models/service_category.dart';
import 'package:oficina_app/features/service_catalog/presentation/view_models/service_categories_view_model.dart';
import 'package:oficina_app/features/service_catalog/presentation/widgets/category_visuals.dart';

/// Tela 14 — Categorias de Serviço: criação inline, renomeação e exclusão.
class ServiceCategoriesPage extends StatefulWidget {
  final ServiceCategoriesViewModel viewModel;

  const ServiceCategoriesPage({super.key, required this.viewModel});

  @override
  State<ServiceCategoriesPage> createState() => _ServiceCategoriesPageState();
}

class _ServiceCategoriesPageState extends State<ServiceCategoriesPage> {
  final _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final name = _newCategoryController.text;
    final created = await widget.viewModel.create(name);

    if (created) {
      _newCategoryController.clear();
    } else if (mounted && widget.viewModel.errorMessage != null) {
      _showError(widget.viewModel.errorMessage!);
      widget.viewModel.clearError();
    }
  }

  Future<void> _handleRename(ServiceCategory category) async {
    final controller = TextEditingController(text: category.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Renomear categoria', style: AppTypography.cardTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nome da categoria'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              style: FilledButton.styleFrom(backgroundColor: AppColors.accentBlue),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null || newName.trim().isEmpty) {
      return;
    }

    final renamed = await widget.viewModel.rename(category, newName);

    if (!renamed && mounted && widget.viewModel.errorMessage != null) {
      _showError(widget.viewModel.errorMessage!);
      widget.viewModel.clearError();
    }
  }

  Future<void> _handleDelete(ServiceCategory category) async {
    final confirmed = await ConfirmDialog.askDeletion(
      context,
      title: 'Excluir categoria',
      message: 'Deseja realmente excluir a categoria "${category.name}"?',
    );

    if (!confirmed) {
      return;
    }

    final deleted = await widget.viewModel.delete(category.id);

    if (!deleted && mounted && widget.viewModel.errorMessage != null) {
      _showError(widget.viewModel.errorMessage!);
      widget.viewModel.clearError();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final state = widget.viewModel.state;

            return Column(
              children: [
                AppScreenHeader(
                  title: 'Categorias de Serviço',
                  subtitle: '${widget.viewModel.totalCount} categorias criadas',
                ),
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
                    ViewStateSuccess(:final data) => _buildContent(data),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(List<ServiceCategory> categories) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.xxl,
      ),
      children: [
        _buildCreateCard(),
        const SizedBox(height: AppSpacing.xl),
        if (categories.isEmpty)
          const AppEmptyState(
            icon: Icons.sell_outlined,
            title: 'Nenhuma categoria criada',
            message: 'Crie a primeira categoria para organizar seus serviços.',
          )
        else
          for (final category in categories) ...[
            _buildCategoryCard(category),
            const SizedBox(height: 14),
          ],
      ],
    );
  }

  Widget _buildCreateCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nova categoria',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sell_outlined,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _newCategoryController,
                          onSubmitted: (_) => _handleCreate(),
                          decoration: const InputDecoration(
                            hintText: 'Nome da categoria',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: AppTypography.fieldValue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              InkWell(
                onTap: widget.viewModel.isSaving ? null : _handleCreate,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.add, color: AppColors.bgWhite),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ServiceCategory category) {
    final visual = CategoryVisual.of(category.style);
    final count = widget.viewModel.serviceCountFor(category.id);

    return AppCard(
      child: Row(
        children: [
          AppIconBadge(
            icon: visual.icon,
            foreground: visual.foreground,
            background: visual.background,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count serviços',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          AppIconActionButton.edit(onPressed: () => _handleRename(category)),
          const SizedBox(width: AppSpacing.sm),
          AppIconActionButton.delete(onPressed: () => _handleDelete(category)),
        ],
      ),
    );
  }
}
