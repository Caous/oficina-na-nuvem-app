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
import '../../../../core/widgets/app_toggle_switch.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../shared/products/models/product.dart';
import '../../../../shared/products/presentation/product_visuals.dart';
import '../view_models/product_form_view_model.dart';

/// Cadastro/edição de produto do estoque, com a chave de publicação no
/// marketplace do cliente.
class ProductFormPage extends StatefulWidget {
  final ProductFormViewModel viewModel;

  const ProductFormPage({super.key, required this.viewModel});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  ProductFormViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _prefillFromEditedProduct();
  }

  void _prefillFromEditedProduct() {
    final product = _viewModel.initial;

    if (product == null) {
      return;
    }

    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _skuController.text = product.sku;
    _priceController.text = BrlFormatter.formatWithoutSymbol(product.price);
    _stockController.text = product.stockQuantity.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final price = BrlFormatter.tryParse(_priceController.text);
    final stock = int.tryParse(_stockController.text.trim());

    if (price == null || stock == null) {
      return;
    }

    final saved = await _viewModel.save(
      name: _nameController.text,
      description: _descriptionController.text,
      sku: _skuController.text,
      price: price,
      stockQuantity: stock,
    );

    if (!mounted) {
      return;
    }

    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ?? 'Não foi possível salvar o produto.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Produto salvo.')));

    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmDialog.askDeletion(
      context,
      title: 'Excluir produto',
      message: 'O produto sai do estoque e do marketplace.',
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
            _viewModel.errorMessage ?? 'Não foi possível excluir o produto.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Produto excluído.')));

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
                      ? 'Editar Produto'
                      : 'Novo Produto',
                  subtitle: 'Item do estoque da oficina',
                ),
                Expanded(child: _buildForm()),
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
            AppSelectField<ProductCategory>(
              label: 'Categoria',
              placeholder: 'Selecione a categoria',
              searchHint: 'Digite o nome da categoria',
              icon: ProductVisuals.iconOf(_viewModel.selectedCategory),
              selectedLabel: _viewModel.selectedCategory.label,
              options: [
                for (final category in ProductCategory.values)
                  SelectOption(value: category, label: category.label),
              ],
              onSelected: _viewModel.selectCategory,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Nome do produto',
              hint: 'Ex: Óleo Motor 5W30 Sintético 1L',
              icon: Icons.inventory_2_outlined,
              controller: _nameController,
              validator: _requiredValidator('Informe o nome do produto.'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Descrição',
              hint: 'O que o cliente precisa saber sobre o produto',
              controller: _descriptionController,
              maxLines: 3,
              validator: _requiredValidator('Informe a descrição.'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'SKU',
              hint: '0012',
              icon: Icons.qr_code_2_outlined,
              controller: _skuController,
              validator: _requiredValidator('Informe o SKU.'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPriceField()),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildStockField()),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildPublishCard(),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: 'Salvar Produto',
              icon: Icons.check,
              isLoading: _viewModel.isSaving,
              onPressed: _submit,
            ),
            if (_viewModel.isEditing) ...[
              const SizedBox(height: AppSpacing.md),
              AppDestructiveButton(
                label: 'Excluir produto',
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

  Widget _buildPriceField() {
    return AppTextField(
      label: 'Preço (R\$)',
      hint: '0,00',
      controller: _priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      validator: (value) {
        final price = BrlFormatter.tryParse(value ?? '');

        if (price == null) {
          return 'Informe o preço.';
        }

        if (price <= 0) {
          return 'Preço deve ser maior que zero.';
        }

        return null;
      },
    );
  }

  Widget _buildStockField() {
    return AppTextField(
      label: 'Estoque',
      hint: '0',
      controller: _stockController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5),
      ],
      validator: (value) {
        final stock = int.tryParse((value ?? '').trim());

        if (stock == null) {
          return 'Informe a quantidade.';
        }

        if (stock < 0) {
          return 'Quantidade inválida.';
        }

        return null;
      },
    );
  }

  Widget _buildPublishCard() {
    final isPublished = _viewModel.isPublished;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: isPublished ? AppColors.accentBlueLight : AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isPublished ? AppColors.accentBlue : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 22,
            color: isPublished ? AppColors.accentBlue : AppColors.textMuted,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vender no marketplace',
                  style: AppTypography.fieldValue.copyWith(
                    color: isPublished
                        ? AppColors.accentBlueDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPublished
                      ? 'Visível para os clientes na loja do app.'
                      : 'Fica só no seu estoque interno.',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppToggleSwitch(
            value: isPublished,
            onChanged: _viewModel.setPublished,
          ),
        ],
      ),
    );
  }
}
