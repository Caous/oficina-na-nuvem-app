import 'package:flutter/material.dart';
import 'package:oficina_app/core/theme/app_colors.dart';
import 'package:oficina_app/core/theme/app_spacing.dart';
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
import 'package:oficina_app/core/formatters/input_masks.dart';
import 'package:oficina_app/core/validators/cpf_validator.dart';
import 'package:oficina_app/core/validators/email_validator.dart';
import 'package:oficina_app/core/validators/phone_validator.dart';

/// Tela 09 do design: cadastro de conta de cliente.
class ClientRegisterPage extends StatefulWidget {
  final AccountRegistrationViewModel viewModel;
  final AddressFormController addressController;
  final VoidCallback onSwitchToWorkshop;
  final VoidCallback onBackToLogin;

  const ClientRegisterPage({
    super.key,
    required this.viewModel,
    required this.addressController,
    required this.onSwitchToWorkshop,
    required this.onBackToLogin,
  });

  @override
  State<ClientRegisterPage> createState() => _ClientRegisterPageState();
}

class _ClientRegisterPageState extends State<ClientRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _cpfMask = InputMasks.cpf();
  final _phoneMask = InputMasks.phone();
  final _nameController = TextEditingController();
  final _documentController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _acceptedTerms = false;

  AccountRegistrationViewModel get _viewModel => widget.viewModel;

  @override
  void dispose() {
    _nameController.dispose();
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

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aceite os Termos de Uso e Privacidade para continuar.',
          ),
        ),
      );
      return;
    }

    final success = await _viewModel.submitClient(
      name: _nameController.text,
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
      const SnackBar(
        content: Text('Bem-vindo! Sua conta foi criada com sucesso.'),
      ),
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
                            selected: AccountType.client,
                            onChanged: (type) {
                              if (type == AccountType.workshop) {
                                widget.onSwitchToWorkshop();
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppTextField(
                            label: 'Nome completo',
                            hint: 'Seu nome',
                            icon: Icons.person_outline,
                            controller: _nameController,
                            validator: (value) =>
                                _requiredValidator(value, 'seu nome completo'),
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
                            label: 'E-mail',
                            hint: 'seu@email.com',
                            icon: Icons.mail_outline,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: EmailValidator.validate,
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
                          AddressFormSection(
                            controller: widget.addressController,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          PasswordFormField(
                            controller: _passwordController,
                            validator: _passwordValidator,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _TermsCheckbox(
                            value: _acceptedTerms,
                            onChanged: (value) =>
                                setState(() => _acceptedTerms = value),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppPrimaryButton(
                            label: 'Criar Conta',
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

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: (checked) => onChanged(checked ?? false),
            activeColor: AppColors.accentBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              children: [
                TextSpan(text: 'Aceito os '),
                TextSpan(
                  text: 'Termos de Uso',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentBlue,
                  ),
                ),
                TextSpan(text: ' e '),
                TextSpan(
                  text: 'Privacidade',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
