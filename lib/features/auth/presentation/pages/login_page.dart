import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validators/email_validator.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../view_models/login_view_model.dart';

/// Tela de login (tela 01 do design).
class LoginPage extends StatefulWidget {
  final LoginViewModel viewModel;

  /// Chamado após autenticação bem-sucedida.
  final VoidCallback onLoginSuccess;

  /// Abre o fluxo de cadastro de cliente ou oficina.
  final VoidCallback onCreateAccount;

  const LoginPage({
    super.key,
    required this.viewModel,
    required this.onLoginSuccess,
    required this.onCreateAccount,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  LoginViewModel get _viewModel => widget.viewModel;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await _viewModel.login(
      email: _emailController.text.trim(),
      pass: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ?? 'Não foi possível entrar.'),
        ),
      );
      return;
    }

    widget.onLoginSuccess();
  }

  void _showComingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login com $provider estará disponível em breve.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.xxl + AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xxl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _BrandHeader(),
                      const SizedBox(height: AppSpacing.xxl + AppSpacing.sm),
                      _buildForm(),
                      const SizedBox(height: AppSpacing.xxl + AppSpacing.sm),
                      const _OrDivider(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildSocialButtons(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildRegisterRow(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'E-mail',
            hint: 'seuemail@email.com',
            icon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: EmailValidator.validate,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Senha',
            hint: '••••••••',
            icon: Icons.lock_outline,
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            suffix: IconButton(
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe sua senha.';
              }

              if (value.length < 6) {
                return 'A senha deve ter pelo menos 6 caracteres.';
              }

              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _showComingSoon('recuperação de senha'),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: Text(
                  'Esqueceu a senha?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Entrar',
            isLoading: _viewModel.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            background: AppColors.bgWhite,
            foreground: AppColors.textPrimary,
            border: AppColors.border,
            onPressed: () => _showComingSoon('Google'),
            leading: const Text(
              'G',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.accentRed,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            background: Colors.black,
            foreground: AppColors.bgWhite,
            onPressed: () => _showComingSoon('Apple'),
            leading: const Icon(
              Icons.phone_iphone,
              size: 18,
              color: AppColors.bgWhite,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Não tem conta?', style: AppTypography.body),
        const SizedBox(width: AppSpacing.xs),
        InkWell(
          onTap: widget.onCreateAccount,
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.xs),
            child: Text(
              'Cadastre-se',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Logo, nome e slogan do aplicativo.
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.accentBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.build_outlined,
            size: 36,
            color: AppColors.bgWhite,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Oficina na Nuvem',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Gestão completa da sua oficina',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'ou',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget leading;
  final Color background;
  final Color foreground;
  final Color? border;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.leading,
    required this.background,
    required this.foreground,
    required this.onPressed,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          side: border == null ? null : BorderSide(color: border!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
