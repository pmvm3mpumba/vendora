import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'auth_page.dart';

/// Présentation testable sans connexion Firebase.
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.onSubmit,
    required this.onRegister,
    required this.onVisit,
    this.isLoading = false,
    this.error,
  });
  final Future<void> Function(String email, String password) onSubmit;
  final VoidCallback onRegister;
  final VoidCallback onVisit;
  final bool isLoading;
  final String? error;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  bool get _busy => widget.isLoading || _submitting;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(_email.text.trim(), _password.text);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Content de vous retrouver.',
      subtitle: 'Connectez-vous pour retrouver votre espace client ou votre boutique.',
      badge: 'Bienvenue chez vous',
      showBackButton: true,
      onBack: widget.onVisit,
      busy: _busy,
      children: [
        AutofillGroup(
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  key: const Key('login_email'),
                  label: 'Adresse email',
                  hint: 'vous@exemple.com',
                  controller: _email,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.username],
                  textInputAction: TextInputAction.next,
                  validator: AuthValidators.email,
                  enabled: !_busy,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  key: const Key('login_password'),
                  label: 'Mot de passe',
                  controller: _password,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: AuthValidators.loginPassword,
                  enabled: !_busy,
                ),
                const SizedBox(height: AppSpacing.xl),
                AuthErrorText(message: widget.error),
                AppButton(
                  key: const Key('login_submit'),
                  label: 'Se connecter',
                  isLoading: _busy,
                  onPressed: _submit,
                  icon: Icons.arrow_forward_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Créer un compte',
                  variant: AppButtonVariant.secondary,
                  onPressed: _busy ? null : widget.onRegister,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: _busy ? null : widget.onVisit,
                  child: const Text('Continuer sans compte'),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Votre connexion est gérée par Firebase Authentication.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
