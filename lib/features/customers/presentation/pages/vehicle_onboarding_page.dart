import 'package:flutter/material.dart';

import '../../../../core/formatters/input_masks.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_select_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../models/fipe_reference.dart';
import '../../models/vehicle.dart';
import '../view_models/vehicle_onboarding_view_model.dart';

/// Ícone de cada tipo de veículo, compartilhado com a área do cliente.
IconData _iconOfType(VehicleType type) {
  return switch (type) {
    VehicleType.car => Icons.directions_car_outlined,
    VehicleType.motorcycle => Icons.two_wheeler_outlined,
    VehicleType.truck => Icons.local_shipping_outlined,
    VehicleType.utility => Icons.airport_shuttle_outlined,
    VehicleType.jetSki => Icons.pool_outlined,
    VehicleType.aircraft => Icons.flight_outlined,
  };
}

/// Cadastro dos veículos do cliente logo após criar a conta (tela 19).
///
/// Fecha com `true` tanto ao concluir quanto ao pular — o chamador segue para
/// a home do cliente nos dois casos.
class VehicleOnboardingPage extends StatefulWidget {
  final VehicleOnboardingViewModel viewModel;

  const VehicleOnboardingPage({super.key, required this.viewModel});

  @override
  State<VehicleOnboardingPage> createState() => _VehicleOnboardingPageState();
}

class _VehicleOnboardingPageState extends State<VehicleOnboardingPage> {
  final _plateController = TextEditingController();
  final _manualBrandController = TextEditingController();
  final _manualModelController = TextEditingController();
  final _manualYearController = TextEditingController();
  final _plateMask = InputMasks.plate();

  VehicleOnboardingViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.loadBrands();
  }

  @override
  void dispose() {
    _plateController.dispose();
    _manualBrandController.dispose();
    _manualModelController.dispose();
    _manualYearController.dispose();
    super.dispose();
  }

  Future<void> _addVehicle() async {
    FocusScope.of(context).unfocus();

    final plate = _plateController.text.replaceAll(
      RegExp(r'[^0-9A-Za-z]'),
      '',
    );

    if (plate.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a placa completa do veículo.')),
      );
      return;
    }

    final added = await _viewModel.addVehicle(
      plate: _plateController.text,
      manualBrand: _manualBrandController.text,
      manualModel: _manualModelController.text,
      manualYear: _manualYearController.text,
    );

    if (!mounted) {
      return;
    }

    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ?? 'Não foi possível adicionar o veículo.',
          ),
        ),
      );
      return;
    }

    _plateController.clear();
    _manualBrandController.clear();
    _manualModelController.clear();
    _manualYearController.clear();
  }

  void _finish() => Navigator.of(context).pop(true);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bgWhite,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return Column(
                children: [
                  const AppScreenHeader(
                    title: 'Meus Veículos',
                    subtitle: 'Cadastre os veículos que você possui',
                    showBackButton: false,
                    actions: [_StepBadge()],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        AppSpacing.sm,
                        AppSpacing.screenHorizontal,
                        AppSpacing.xxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTypeGrid(),
                          const SizedBox(height: AppSpacing.md),
                          if (_viewModel.selectedType.supportsFipe)
                            _buildFipeFields()
                          else
                            _buildManualFields(),
                          const SizedBox(height: AppSpacing.md),
                          _buildPlateField(),
                          const SizedBox(height: AppSpacing.md),
                          _buildAddButton(),
                          if (_viewModel.addedVehicles.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _buildAddedList(),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          AppPrimaryButton(
                            label: 'Concluir cadastro',
                            icon: Icons.check,
                            onPressed: _viewModel.canFinish ? _finish : null,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: _finish,
                            child: const Text(
                              'Pular por enquanto',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTypeGrid() {
    const types = VehicleType.values;

    Widget cell(VehicleType type) {
      final isSelected = type == _viewModel.selectedType;

      return Expanded(
        child: InkWell(
          onTap: () => _viewModel.selectType(type),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentBlueLight : AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? AppColors.accentBlue : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _iconOfType(type),
                  size: 22,
                  color: isSelected
                      ? AppColors.accentBlue
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.xs + 2),
                Text(
                  type.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.accentBlueDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            cell(types[0]),
            const SizedBox(width: AppSpacing.sm + 2),
            cell(types[1]),
            const SizedBox(width: AppSpacing.sm + 2),
            cell(types[2]),
          ],
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        Row(
          children: [
            cell(types[3]),
            const SizedBox(width: AppSpacing.sm + 2),
            cell(types[4]),
            const SizedBox(width: AppSpacing.sm + 2),
            cell(types[5]),
          ],
        ),
      ],
    );
  }

  Widget _buildFipeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSelectField<FipeBrand>(
          label: 'Marca',
          placeholder: _viewModel.isLoadingBrands
              ? 'Carregando marcas...'
              : 'Selecione ou digite a marca',
          searchHint: 'Digite para filtrar as marcas',
          icon: Icons.search,
          selectedLabel: _viewModel.selectedBrand?.name,
          enabled: !_viewModel.isLoadingBrands,
          options: [
            for (final brand in _viewModel.brands)
              SelectOption(value: brand, label: brand.name),
          ],
          onSelected: _viewModel.selectBrand,
        ),
        const SizedBox(height: AppSpacing.md),
        AppSelectField<FipeModel>(
          label: 'Modelo',
          placeholder: _viewModel.isLoadingModels
              ? 'Carregando modelos...'
              : 'Selecione ou digite o modelo',
          searchHint: 'Digite para filtrar os modelos',
          icon: Icons.search,
          selectedLabel: _viewModel.selectedModel?.name,
          enabled:
              _viewModel.selectedBrand != null && !_viewModel.isLoadingModels,
          emptyMessage: 'Escolha a marca primeiro',
          options: [
            for (final model in _viewModel.models)
              SelectOption(value: model, label: model.name),
          ],
          onSelected: _viewModel.selectModel,
        ),
        const SizedBox(height: AppSpacing.md),
        AppSelectField<FipeYear>(
          label: 'Ano',
          placeholder: _viewModel.isLoadingYears ? 'Carregando...' : 'Selecione',
          searchHint: 'Digite para filtrar os anos',
          icon: Icons.event_outlined,
          selectedLabel: _viewModel.selectedYear?.label,
          enabled:
              _viewModel.selectedModel != null && !_viewModel.isLoadingYears,
          emptyMessage: 'Escolha o modelo',
          options: [
            for (final year in _viewModel.years)
              SelectOption(value: year, label: year.label),
          ],
          onSelected: _viewModel.selectYear,
        ),
      ],
    );
  }

  /// Jet ski e aeronave ficam fora da FIPE: marca, modelo e ano são digitados.
  Widget _buildManualFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Marca',
          hint: 'Ex: Sea-Doo, Cessna',
          icon: Icons.factory_outlined,
          controller: _manualBrandController,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Modelo',
          hint: 'Modelo do veículo',
          controller: _manualModelController,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Ano',
          hint: '2022',
          controller: _manualYearController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildPlateField() {
    return AppTextField(
      label: _viewModel.selectedType == VehicleType.aircraft
          ? 'Matrícula'
          : 'Placa / Registro',
      hint: 'ABC-1D23',
      controller: _plateController,
      inputFormatters: [InputMasks.upperCase(), _plateMask],
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: _viewModel.isSaving ? null : _addVehicle,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.accentBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: _viewModel.isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accentBlue,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 18, color: AppColors.accentBlue),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Adicionar veículo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAddedList() {
    final vehicles = _viewModel.addedVehicles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Veículos adicionados', style: AppTypography.groupTitle),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentBlueLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '${vehicles.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        for (final (index, vehicle) in vehicles.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.sm + 2),
          _AddedVehicleCard(
            vehicle: vehicle,
            onRemove: () => _viewModel.removeVehicle(vehicle.id),
          ),
        ],
      ],
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 1,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentBlueLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Text(
        'Passo 2 de 2',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.accentBlue,
        ),
      ),
    );
  }
}

class _AddedVehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onRemove;

  const _AddedVehicleCard({required this.vehicle, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          AppIconBadge(
            icon: _iconOfType(vehicle.type),
            foreground: AppColors.accentBlue,
            background: AppColors.accentBlueLight,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.fieldValue,
                ),
                const SizedBox(height: 2),
                Text(
                  '${vehicle.plate} • ${vehicle.type.label} • ${vehicle.year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppIconActionButton.delete(onPressed: onRemove),
        ],
      ),
    );
  }
}
