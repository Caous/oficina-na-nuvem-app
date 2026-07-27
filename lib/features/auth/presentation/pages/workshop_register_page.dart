import 'package:flutter/material.dart';
import 'package:oficina_app/core/formatters/input_masks.dart';
import 'package:oficina_app/core/theme/app_colors.dart';
import 'package:oficina_app/core/theme/app_spacing.dart';
import 'package:oficina_app/core/validators/cnpj_validator.dart';
import 'package:oficina_app/core/validators/email_validator.dart';
import 'package:oficina_app/core/validators/phone_validator.dart';
import 'package:oficina_app/core/widgets/app_buttons.dart';
import 'package:oficina_app/core/widgets/app_screen_header.dart';
import 'package:oficina_app/core/widgets/app_text_field.dart';
import 'package:oficina_app/features/auth/models/account_registration.dart';
import 'package:oficina_app/features/auth/presentation/view_models/account_registration_view_model.dart';
import 'package:oficina_app/features/auth/presentation/widgets/account_type_toggle.dart';
import 'package:oficina_app/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:oficina_app/features/auth/presentation/widgets/password_form_field.dart';
import 'package:oficina_app/shared/address_lookup/presentation/address_form_controller.dart';
import 'package:oficina_app/shared/address_lookup/presentation/address_form_section.dart';

/// Tela 10 do design: cadastro de conta de oficina.
class WorkshopRegisterPage extends StatefulWidget {
  final AccountRegistrationViewModel viewModel;
  final AddressFormController addressController;
  final VoidCallback onSwitchToClient;
  final VoidCallback onBackToLogin;

  const WorkshopRegisterPage({
    super.key,
    required this.viewModel,
    required this.addressController,
    required this.onSwitchToClient,
    required this.onBackToLogin,
  });

  @override
  State<WorkshopRegisterPage> createState() => _WorkshopRegisterPageState();
}

class _WorkshopRegisterPageState extends State<WorkshopRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _cnpjMask = InputMasks.cnpj();
  final _phoneMask = InputMasks.phone();

  final _tradeNameController = TextEditingController();
  final _documentController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  AccountRegistrationViewModel get _viewModel => widget.viewModel;

  @override
  void dispose() {
    _tradeNameController.dispose();
    _documentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe $fieldName.';
    }
    return null;
  }


  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe uma senha.';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final success = await _viewModel.submitWorkshop(
      tradeName: _tradeNameController.text,
      document: _documentController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: widget.addressController.address,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ?? 'Não foi possível concluir o cadastro.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bem-vindo! Sua oficina foi cadastrada com sucesso.')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppScreenHeader(title: 'Criar Conta'),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AccountTypeToggle(
                            selected: AccountType.workshop,
                            onChanged: (type) {
                              if (type == AccountType.client) {
                                widget.onSwitchToClient();
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppTextField(
                            label: 'Nome da oficina',
                            hint: 'Ex: Oficina do Zé',
                            icon: Icons.storefront_outlined,
                            controller: _tradeNameController,
                            validator: (value) =>
                                _requiredValidator(value, 'o nome da oficina'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'CNPJ',
                            hint: '00.000.000/0001-00',
                            icon: Icons.account_balance_outlined,
                            controller: _documentController,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              InputMasks.upperCase(),
                              _cnpjMask,
                            ],
                            validator: CnpjValidator.validate,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'E-mail',
                            hint: 'contato@oficina.com',
                            icon: Icons.mail_outline,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: EmailValidator.validate,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Telefone',
                            hint: '(11) 3333-4444',
                            icon: Icons.phone_outlined,
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [_phoneMask],
                            validator: PhoneValidator.validate,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AddressFormSection(
                            controller: widget.addressController,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          PasswordFormField(
                            controller: _passwordController,
                            validator: _passwordValidator,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppPrimaryButton(
                            label: 'Cadastrar Oficina',
                            isLoading: _viewModel.isSubmitting,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AuthFooterLink(onPressed: widget.onBackToLogin),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
