import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../providers/auth_controller.dart';
import '../widgets/auth_page.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onVisit});
  final VoidCallback onVisit;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await context.read<AuthController>().signIn(_email.text, _password.text);
    // AuthGate réagit à Firebase : pas de navigation manuelle vers un rôle.
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return AuthPage(
      title: 'Heureux de vous retrouver',
      children: [
        const Text('Connectez-vous avec votre compte client ou vendeur.'),
        const SizedBox(height: AppSpacing.xl),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Adresse email', controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: AuthValidators.email, enabled: !auth.busy,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Mot de passe', controller: _password,
                obscureText: true, validator: AuthValidators.loginPassword,
                enabled: !auth.busy,
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthErrorText(message: auth.operationError),
              AppButton(label: 'Se connecter', isLoading: auth.busy,
                  onPressed: _submit),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Créer un compte', variant: AppButtonVariant.secondary,
                onPressed: auth.busy ? null : () {
                  auth.clearOperationError();
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => const RegisterScreen(),
                  ));
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(onPressed: auth.busy ? null : widget.onVisit,
                  child: const Text('Continuer sans compte')),
            ],
          ),
        ),
      ],
    );
  }
}
