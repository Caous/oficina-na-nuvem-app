import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_text_field.dart';
import 'address_form_controller.dart';

/// Bloco de endereço com busca por CEP e preenchimento manual como alternativa.
///
/// Usado nos cadastros de cliente, oficina e funcionário para que a regra de
/// preenchimento seja idêntica nos três.
class AddressFormSection extends StatefulWidget {
  final AddressFormController controller;

  /// Torna o endereço obrigatório na validação do formulário.
  final bool isRequired;

  const AddressFormSection({
    super.key,
    required this.controller,
    this.isRequired = true,
  });

  @override
  State<AddressFormSection> createState() => _AddressFormSectionState();
}

class _AddressFormSectionState extends State<AddressFormSection> {
  final _cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {'#': RegExp(r'[0-9]')},
  );

  late final _cepController = TextEditingController(
    text: widget.controller.address.cep,
  );
  late final _streetController = TextEditingController(
    text: widget.controller.address.street,
  );
  late final _numberController = TextEditingController(
    text: widget.controller.address.number,
  );
  late final _complementController = TextEditingController(
    text: widget.controller.address.complement,
  );
  late final _neighborhoodController = TextEditingController(
    text: widget.controller.address.neighborhood,
  );
  late final _cityController = TextEditingController(
    text: widget.controller.address.city,
  );
  late final _stateController = TextEditingController(
    text: widget.controller.address.state,
  );

  AddressFormController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_syncFieldsFromLookup);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncFieldsFromLookup);
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  /// Reflete nos campos o que a consulta trouxe, sem apagar o que a pessoa
  /// digitou (evita brigar com o cursor enquanto ela edita).
  void _syncFieldsFromLookup() {
    final address = _controller.address;

    _applyIfChanged(_streetController, address.street);
    _applyIfChanged(_neighborhoodController, address.neighborhood);
    _applyIfChanged(_cityController, address.city);
    _applyIfChanged(_stateController, address.state);
  }

  void _applyIfChanged(TextEditingController controller, String value) {
    if (controller.text != value) {
      controller.text = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCepField(),
            if (_controller.message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _LookupMessage(
                message: _controller.message!,
                onRetry: _controller.search,
                onManual: _controller.enableManualEntry,
              ),
            ],
            if (_controller.showsAddressFields) ...[
              const SizedBox(height: AppSpacing.md),
              _buildAddressFields(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCepField() {
    return AppTextField(
      label: 'CEP',
      hint: '00000-000',
      icon: Icons.location_on_outlined,
      controller: _cepController,
      keyboardType: TextInputType.number,
      inputFormatters: [_cepMask],
      onChanged: _controller.onCepChanged,
      suffix: _controller.isSearching
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accentBlue,
                ),
              ),
            )
          : _controller.status == AddressLookupStatus.found
          ? const Icon(
              Icons.check_circle_outline,
              size: 18,
              color: AppColors.accentGreen,
            )
          : null,
      validator: (value) {
        if (!widget.isRequired) {
          return null;
        }

        final digits = AddressFormController.sanitizeCep(value);

        if (digits.isEmpty) {
          return 'Informe o CEP.';
        }

        if (digits.length != 8) {
          return 'CEP incompleto. Confira o número.';
        }

        return null;
      },
    );
  }

  Widget _buildAddressFields() {
    final locked = _controller.lockLookupFields;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Rua',
          hint: 'Nome da rua',
          icon: Icons.signpost_outlined,
          controller: _streetController,
          enabled: !locked,
          onChanged: _controller.updateStreet,
          validator: _requiredIfNeeded('Informe a rua.'),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: 'Número',
                hint: '123',
                controller: _numberController,
                keyboardType: TextInputType.text,
                onChanged: _controller.updateNumber,
                validator: _requiredIfNeeded('Informe o número.'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                label: 'Complemento',
                hint: 'Apto, bloco',
                controller: _complementController,
                onChanged: _controller.updateComplement,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Bairro',
          hint: 'Nome do bairro',
          icon: Icons.map_outlined,
          controller: _neighborhoodController,
          enabled: !locked,
          onChanged: _controller.updateNeighborhood,
          validator: _requiredIfNeeded('Informe o bairro.'),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: AppTextField(
                label: 'Cidade',
                hint: 'Cidade',
                icon: Icons.location_city_outlined,
                controller: _cityController,
                enabled: !locked,
                onChanged: _controller.updateCity,
                validator: _requiredIfNeeded('Informe a cidade.'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                label: 'UF',
                hint: 'SP',
                controller: _stateController,
                enabled: !locked,
                onChanged: _controller.updateState,
                validator: (value) {
                  if (!widget.isRequired) {
                    return null;
                  }

                  final uf = (value ?? '').trim();

                  if (uf.isEmpty) {
                    return 'Informe a UF.';
                  }

                  if (uf.length != 2) {
                    return 'UF inválida.';
                  }

                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? Function(String?) _requiredIfNeeded(String message) {
    return (value) {
      if (!widget.isRequired) {
        return null;
      }

      return (value ?? '').trim().isEmpty ? message : null;
    };
  }
}

/// Aviso de falha na consulta, com as saídas possíveis.
class _LookupMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onManual;

  const _LookupMessage({
    required this.message,
    required this.onRetry,
    required this.onManual,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentRedLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.accentRed),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                size: 16,
                color: AppColors.accentRed,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.accentRedDark,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.md,
            children: [
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh,
                  size: 16,
                  color: AppColors.accentRed,
                ),
                label: const Text(
                  'Tentar novamente',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentRed,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              TextButton(
                onPressed: onManual,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Digitar endereço',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentRedDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
