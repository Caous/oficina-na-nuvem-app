import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/brl_formatter.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_select_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../models/service_category.dart';
import '../view_models/service_form_view_model.dart';

/// Cadastro/edição de um serviço do catálogo (tela 16).
class ServiceFormPage extends StatefulWidget {
  final ServiceFormViewModel viewModel;

  const ServiceFormPage({super.key, required this.viewModel});

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();

  ServiceFormViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _prefillFromEditedService();
    _viewModel.load();
  }

  void _prefillFromEditedService() {
    final service = _viewModel.initial;

    if (service == null) {
      return;
    }

    _nameController.text = service.name;
    _descriptionController.text = service.description;
    _priceController.text = BrlFormatter.formatWithoutSymbol(service.price);
    _discountController.text = _formatPercent(service.maxDiscountPercent);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  static String _formatPercent(double percent) {
    return percent == percent.roundToDouble()
        ? percent.toInt().toString()
        : percent.toString();
  }

  Future<void> _createCategory() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _NewCategoryDialog(),
    );

    if (name == null || name.trim().isEmpty) {
      return;
    }

    final created = await _viewModel.createCategory(name);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          created
              ? 'Categoria "${name.trim()}" criada e selecionada.'
              : _viewModel.errorMessage ?? 'Não foi possível criar a categoria.',
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_viewModel.selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a categoria do serviço.')),
      );
      return;
    }

    final price = BrlFormatter.tryParse(_priceController.text);
    final discount = double.tryParse(
      _discountController.text.replaceAll(',', '.'),
    );

    if (price == null || discount == null) {
      return;
    }

    final saved = await _viewModel.save(
      name: _nameController.text,
      description: _descriptionController.text,
      price: price,
      maxDiscountPercent: discount,
    );

    if (!mounted) {
      return;
    }

    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ?? 'Não foi possível salvar o serviço.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Serviço salvo.')));

    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmDialog.askDeletion(
      context,
      title: 'Excluir serviço',
      message: 'Esta ação não pode ser desfeita.',
    );

    if (!confirmed) {
      return;
    }

    final deleted = await _viewModel.delete();

    if (!mounted) {
      return;
    }

    if (!deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ?? 'Não foi possível excluir o serviço.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Serviço excluído.')));

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              children: [
                AppScreenHeader(
                  title: _viewModel.isEditing
                      ? 'Editar Serviço'
                      : 'Novo Serviço',
                  subtitle: 'Item do catálogo da oficina',
                ),
                Expanded(
                  child: _viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildForm(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.xxl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCategoryField(),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Nome do serviço',
              hint: 'Ex: Troca de óleo e filtro',
              icon: Icons.build_outlined,
              controller: _nameController,
              validator: _requiredValidator('Informe o nome do serviço.'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Descrição',
              hint: 'O que está incluso neste serviço',
              controller: _descriptionController,
              maxLines: 3,
              validator: _requiredValidator('Informe a descrição.'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPriceField()),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildDiscountField()),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildMinimumPriceHint(),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: 'Salvar Serviço',
              icon: Icons.check,
              isLoading: _viewModel.isSaving,
              onPressed: _submit,
            ),
            if (_viewModel.isEditing) ...[
              const SizedBox(height: AppSpacing.md),
              AppDestructiveButton(
                label: 'Excluir serviço',
                onPressed: _viewModel.isSaving ? null : _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? Function(String?) _requiredValidator(String message) {
    return (value) => (value?.trim().isEmpty ?? true) ? message : null;
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSelectField<ServiceCategory>(
          label: 'Categoria do serviço',
          placeholder: _viewModel.hasNoCategories
              ? 'Nenhuma categoria cadastrada'
              : 'Selecione a categoria',
          searchHint: 'Digite o nome da categoria',
          icon: Icons.sell_outlined,
          selectedLabel: _viewModel.selectedCategory?.name,
          emptyMessage: 'Crie a primeira categoria abaixo',
          options: [
            for (final category in _viewModel.categories)
              SelectOption(value: category, label: category.name),
          ],
          onSelected: _viewModel.selectCategory,
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _viewModel.isSaving ? null : _createCategory,
            icon: const Icon(Icons.add, size: 16, color: AppColors.accentBlue),
            label: const Text(
              'Nova categoria',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return AppTextField(
      label: 'Valor (R\$)',
      hint: '0,00',
      controller: _priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      validator: (value) {
        final price = BrlFormatter.tryParse(value ?? '');

        if (price == null) {
          return 'Informe o valor.';
        }

        if (price <= 0) {
          return 'Valor deve ser maior que zero.';
        }

        return null;
      },
    );
  }

  Widget _buildDiscountField() {
    return AppTextField(
      label: 'Desconto máx.',
      hint: '0',
      controller: _discountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        LengthLimitingTextInputFormatter(5),
      ],
      suffix: const Padding(
        padding: EdgeInsets.only(right: AppSpacing.md),
        child: Icon(Icons.percent, size: 16, color: AppColors.textMuted),
      ),
      validator: (value) {
        final discount = double.tryParse((value ?? '').replaceAll(',', '.'));

        if (discount == null) {
          return 'Informe o desconto.';
        }

        if (discount < 0 || discount > 100) {
          return 'Use um valor entre 0 e 100.';
        }

        return null;
      },
    );
  }

  /// Mostra quanto o serviço pode chegar a custar aplicando o desconto máximo.
  Widget _buildMinimumPriceHint() {
    final price = BrlFormatter.tryParse(_priceController.text);
    final discount = double.tryParse(
      _discountController.text.replaceAll(',', '.'),
    );

    if (price == null || discount == null || discount <= 0 || discount > 100) {
      return const SizedBox.shrink();
    }

    final minimum = price * (1 - discount / 100);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentBlueLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.accentBlue),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Text(
              'Com ${_formatPercent(discount)}% de desconto, o valor mínimo '
              'cobrado será ${BrlFormatter.format(minimum)}.',
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.accentBlueDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Diálogo de criação rápida de categoria.
///
/// Mantém o próprio `TextEditingController` para que ele seja descartado
/// somente quando o diálogo sair da árvore — descartá-lo logo após o
/// `showDialog` dispara asserção enquanto a rota ainda anima a saída.
class _NewCategoryDialog extends StatefulWidget {
  const _NewCategoryDialog();

  @override
  State<_NewCategoryDialog> createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<_NewCategoryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova categoria', style: AppTypography.cardTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Ex: Motor, Freios, Elétrica',
        ),
        onSubmitted: (_) => _confirm(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        FilledButton(onPressed: _confirm, child: const Text('Criar')),
      ],
    );
  }
}
