import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../models/app_user.dart';
import '../../providers/auth_controller.dart';
import '../widgets/auth_page.dart';

/// Le mode completeProfileOnly répare un compte Auth sans profil Firestore.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.completeProfileOnly = false});
  final bool completeProfileOnly;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  UserRole _role = UserRole.client;

  @override
  void dispose() {
    for (final controller in [
      _name, _email, _phone, _whatsapp, _password, _confirmation,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthController>();
    if (widget.completeProfileOnly) {
      await auth.completeProfile(
        name: _name.text, phone: _phone.text, role: _role,
        whatsappNumber: _whatsapp.text,
      );
    } else {
      await auth.register(
        email: _email.text, password: _password.text,
        name: _name.text, phone: _phone.text, role: _role,
        whatsappNumber: _whatsapp.text,
      );
      // Si Auth a réussi mais Firestore a échoué, AuthGate propose de
      // compléter le profil existant, sans créer une deuxième identité.
      if (mounted && auth.isAuthenticated) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return PopScope(
      canPop: !auth.busy,
      child: AuthPage(
        title: widget.completeProfileOnly ? 'Compléter mon profil' : 'Créer mon compte',
        children: [
          Text(widget.completeProfileOnly
              ? 'Votre compte est connecté, mais son profil n’est pas encore '
                  'enregistré. Complétez les informations pour continuer.'
              : 'Choisissez votre rôle. Il ne pourra pas être changé depuis le profil.'),
          const SizedBox(height: AppSpacing.xl),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<UserRole>(
                  initialValue: _role,
                  decoration: const InputDecoration(labelText: 'Type de compte'),
                  items: UserRole.values.map((role) => DropdownMenuItem(
                    value: role, child: Text(role.label),
                  )).toList(),
                  onChanged: auth.busy ? null : (value) {
                    if (value != null) setState(() => _role = value);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(label: 'Nom complet', controller: _name,
                    validator: AuthValidators.name, enabled: !auth.busy),
                const SizedBox(height: AppSpacing.lg),
                if (!widget.completeProfileOnly) ...[
                  AppTextField(label: 'Adresse email', controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: AuthValidators.email, enabled: !auth.busy),
                  const SizedBox(height: AppSpacing.lg),
                ],
                AppTextField(label: 'Téléphone international', controller: _phone,
                    hint: '+257XXXXXXXX', keyboardType: TextInputType.phone,
                    validator: AuthValidators.phone, enabled: !auth.busy),
                const SizedBox(height: AppSpacing.lg),
                if (_role == UserRole.seller) ...[
                  AppTextField(label: 'Numéro WhatsApp du vendeur',
                      controller: _whatsapp, hint: '+257XXXXXXXX',
                      keyboardType: TextInputType.phone,
                      validator: AuthValidators.phone, enabled: !auth.busy),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (!widget.completeProfileOnly) ...[
                  AppTextField(label: 'Mot de passe', controller: _password,
                      obscureText: true, validator: AuthValidators.password,
                      enabled: !auth.busy),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(label: 'Confirmer le mot de passe',
                      controller: _confirmation, obscureText: true,
                      enabled: !auth.busy,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Confirme le mot de passe.'
                          : value != _password.text
                              ? 'Les mots de passe ne correspondent pas.' : null),
                  const SizedBox(height: AppSpacing.lg),
                ],
                AuthErrorText(message: auth.operationError),
                AppButton(
                  label: widget.completeProfileOnly ? 'Enregistrer le profil' : 'Créer mon compte',
                  isLoading: auth.busy, onPressed: _submit,
                ),
                if (widget.completeProfileOnly) ...[
                  const SizedBox(height: AppSpacing.md),
                  TextButton(onPressed: auth.busy ? null : () => auth.signOut(),
                      child: const Text('Se déconnecter')),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
