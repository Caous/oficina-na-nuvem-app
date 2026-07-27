import 'package:flutter/material.dart';

import '../../../../core/formatters/input_masks.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/brl_formatter.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_select_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../models/fipe_reference.dart';
import '../view_models/vehicle_form_view_model.dart';

/// Cadastro de veículo do cliente com dados da Tabela FIPE (tela 18).
class VehicleFormPage extends StatefulWidget {
  final VehicleFormViewModel viewModel;

  const VehicleFormPage({super.key, required this.viewModel});

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _plateMask = InputMasks.plate();

  VehicleFormViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.loadBrands();
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final created = await _viewModel.save(plate: _plateController.text);

    if (!mounted) {
      return;
    }

    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ?? 'Não foi possível salvar o veículo.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${created.fullName} cadastrado.')),
    );

    Navigator.of(context).pop(created);
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
                  title: 'Cadastrar Veículo',
                  subtitle: 'Cliente: ${_viewModel.customerName}',
                  actions: const [_FipeBadge()],
                ),
                Expanded(
                  child: SingleChildScrollView(
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
                          _buildBrandField(),
                          const SizedBox(height: AppSpacing.md),
                          _buildModelField(),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildYearField()),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: _buildPlateField()),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildQuoteSection(),
                          const SizedBox(height: AppSpacing.lg),
                          AppPrimaryButton(
                            label: 'Salvar Veículo',
                            icon: Icons.check,
                            isLoading: _viewModel.isSaving,
                            onPressed: _viewModel.canSubmit ? _submit : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandField() {
    return AppSelectField<FipeBrand>(
      label: 'Marca',
      placeholder: _viewModel.isLoadingBrands
          ? 'Carregando marcas...'
          : 'Selecione ou digite a marca',
      searchHint: 'Digite para filtrar as marcas',
      icon: Icons.directions_car_outlined,
      selectedLabel: _viewModel.selectedBrand?.name,
      enabled: !_viewModel.isLoadingBrands,
      options: [
        for (final brand in _viewModel.brands)
          SelectOption(value: brand, label: brand.name),
      ],
      onSelected: _viewModel.selectBrand,
    );
  }

  Widget _buildModelField() {
    final hasBrand = _viewModel.selectedBrand != null;

    return AppSelectField<FipeModel>(
      label: 'Modelo',
      placeholder: _viewModel.isLoadingModels
          ? 'Carregando modelos...'
          : 'Selecione ou digite o modelo',
      searchHint: 'Digite para filtrar os modelos',
      icon: Icons.commute_outlined,
      selectedLabel: _viewModel.selectedModel?.name,
      enabled: hasBrand && !_viewModel.isLoadingModels,
      emptyMessage: 'Escolha a marca primeiro',
      options: [
        for (final model in _viewModel.models)
          SelectOption(value: model, label: model.name),
      ],
      onSelected: _viewModel.selectModel,
    );
  }

  Widget _buildYearField() {
    final hasModel = _viewModel.selectedModel != null;

    return AppSelectField<FipeYear>(
      label: 'Ano',
      placeholder: _viewModel.isLoadingYears ? 'Carregando...' : 'Selecione',
      searchHint: 'Digite para filtrar os anos',
      icon: Icons.event_outlined,
      selectedLabel: _viewModel.selectedYear?.label,
      enabled: hasModel && !_viewModel.isLoadingYears,
      emptyMessage: 'Escolha o modelo',
      options: [
        for (final year in _viewModel.years)
          SelectOption(value: year, label: year.label),
      ],
      onSelected: _viewModel.selectYear,
    );
  }

  Widget _buildPlateField() {
    return AppTextField(
      label: 'Placa',
      hint: 'ABC-1D23',
      controller: _plateController,
      textInputAction: TextInputAction.done,
      inputFormatters: [InputMasks.upperCase(), _plateMask],
      validator: (value) {
        // A máscara insere o hífen; contamos só os caracteres da placa.
        final plate = (value ?? '').replaceAll(RegExp(r'[^0-9A-Za-z]'), '');

        if (plate.isEmpty) {
          return 'Informe a placa.';
        }

        if (plate.length < 7) {
          return 'Placa incompleta. Confira os dados.';
        }

        return null;
      },
    );
  }

  Widget _buildQuoteSection() {
    if (_viewModel.isLoadingQuote) {
      return const _QuotePlaceholder(
        message: 'Consultando valor na Tabela FIPE...',
        showProgress: true,
      );
    }

    final quote = _viewModel.quote;

    if (quote == null) {
      return const _QuotePlaceholder(
        message: 'Selecione marca, modelo e ano para consultar a FIPE.',
        showProgress: false,
      );
    }

    return _QuoteCard(quote: quote);
  }
}

/// Selo verde "FIPE" exibido no cabeçalho.
class _FipeBadge extends StatelessWidget {
  const _FipeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 1,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentGreenLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 13, color: AppColors.accentGreen),
          SizedBox(width: AppSpacing.xs),
          Text(
            'FIPE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.accentGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotePlaceholder extends StatelessWidget {
  final String message;
  final bool showProgress;

  const _QuotePlaceholder({required this.message, required this.showProgress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (showProgress)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentBlue,
              ),
            )
          else
            const Icon(
              Icons.info_outline,
              size: 18,
              color: AppColors.textMuted,
            ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final FipeQuote quote;

  const _QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIconBadge(
                icon: Icons.directions_car_outlined,
                foreground: AppColors.accentBlue,
                background: AppColors.accentBlueLight,
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote.fullName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Código FIPE: ${quote.fipeCode}',
                      style: AppTypography.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.sm + 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Valor de referência FIPE',
                  style: AppTypography.bodySmall,
                ),
              ),
              Text(
                BrlFormatter.format(quote.value),
                style: const TextStyle(
                  fontSize: 17,
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

