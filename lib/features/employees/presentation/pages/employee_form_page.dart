import 'package:flutter/material.dart';
import 'package:oficina_app/features/employees/models/employee.dart';
import 'package:oficina_app/features/employees/presentation/view_models/employee_form_view_model.dart';
import 'package:oficina_app/shared/address_lookup/presentation/address_form_controller.dart';
import 'package:oficina_app/shared/address_lookup/presentation/address_form_section.dart';

import '../../../../core/formatters/input_masks.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validators/cpf_validator.dart';
import '../../../../core/validators/email_validator.dart';
import '../../../../core/validators/phone_validator.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_select_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';

/// Formulário de criação/edição de funcionário.
class EmployeeFormPage extends StatefulWidget {
  final EmployeeFormViewModel viewModel;
  final AddressFormController addressController;

  const EmployeeFormPage({
    super.key,
    required this.viewModel,
    required this.addressController,
  });

  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _cpfMask = InputMasks.cpf();
  final _phoneMask = InputMasks.phone();

  late final _nameController = TextEditingController(text: widget.viewModel.initial?.name);
  late final _documentController = TextEditingController(text: widget.viewModel.initial?.document);
  late final _phoneController = TextEditingController(text: widget.viewModel.initial?.phone);
  late final _emailController = TextEditingController(text: widget.viewModel.initial?.email);

  @override
  void dispose() {
    _nameController.dispose();
    _documentController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await widget.viewModel.save(
      name: _nameController.text.trim(),
      document: _documentController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: widget.addressController.address,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funcionário salvo com sucesso.')),
      );
      return;
    }

    final message = widget.viewModel.errorMessage ?? 'Não foi possível salvar o funcionário.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmDialog.askDeletion(
      context,
      title: 'Excluir funcionário',
      message: 'Deseja realmente excluir este funcionário?',
    );

    if (!confirmed) {
      return;
    }

    final success = await widget.viewModel.delete();

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funcionário excluído com sucesso.')),
      );
      return;
    }

    final message = widget.viewModel.errorMessage ?? 'Não foi possível excluir o funcionário.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                  title: widget.viewModel.isEditing ? 'Editar Funcionário' : 'Novo Funcionário',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      AppSpacing.lg,
                      AppSpacing.screenHorizontal,
                      AppSpacing.xxl,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildAvatar(),
                          const SizedBox(height: AppSpacing.xxl),
                          AppTextField(
                            label: 'Nome completo',
                            hint: 'Nome do funcionário',
                            icon: Icons.person_outline,
                            controller: _nameController,
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? 'Informe o nome do funcionário.'
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'CPF',
                            hint: '000.000.000-00',
                            icon: Icons.badge_outlined,
                            controller: _documentController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_cpfMask],
                            validator: CpfValidator.validate,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Telefone',
                            hint: '(11) 99999-9999',
                            icon: Icons.phone_outlined,
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [_phoneMask],
                            validator: PhoneValidator.validate,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'E-mail',
                            hint: 'funcionario@email.com',
                            icon: Icons.mail_outline,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: EmailValidator.validate,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AddressFormSection(
                            controller: widget.addressController,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppSelectField<EmployeeRole>(
                            label: 'Cargo',
                            placeholder: 'Selecione o cargo',
                            icon: Icons.work_outline,
                            selectedLabel: widget.viewModel.selectedRole?.label,
                            options: [
                              for (final role in EmployeeRole.values)
                                SelectOption(value: role, label: role.label),
                            ],
                            onSelected: widget.viewModel.selectRole,
                            errorText: widget.viewModel.selectedRole == null
                                ? widget.viewModel.errorMessage
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          AppPrimaryButton(
                            label: 'Salvar Funcionário',
                            icon: Icons.check,
                            isLoading: widget.viewModel.isSaving,
                            onPressed: _save,
                          ),
                          if (widget.viewModel.isEditing) ...[
                            const SizedBox(height: AppSpacing.md),
                            AppDestructiveButton(
                              label: 'Excluir funcionário',
                              onPressed: _delete,
                            ),
                          ],
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

  Widget _buildAvatar() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: AppColors.accentBlueLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 34, color: AppColors.accentBlue),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgWhite, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 14, color: AppColors.bgWhite),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text('Adicionar foto', style: AppTypography.caption),
        ],
      ),
    );
  }
}
