import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../models/app_user.dart';
import 'auth_page.dart';

class RegistrationData {
  const RegistrationData({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    required this.whatsappNumber,
  });
  final String name;
  final String email;
  final String phone;
  final String password;
  final UserRole role;
  final String whatsappNumber;
}

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({
    super.key,
    required this.onSubmit,
    this.onBack,
    this.onSignOut,
    this.isLoading = false,
    this.error,
    this.completeProfileOnly = false,
  });
  final Future<void> Function(RegistrationData data) onSubmit;
  final VoidCallback? onBack;
  final VoidCallback? onSignOut;
  final bool isLoading;
  final String? error;
  final bool completeProfileOnly;

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  UserRole _role = UserRole.client;
  bool _submitting = false;
  bool get _busy => widget.isLoading || _submitting;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _phone,
      _whatsapp,
      _password,
      _confirmation,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        RegistrationData(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text,
          password: _password.text,
          role: _role,
          whatsappNumber: _role == UserRole.seller ? _whatsapp.text : '',
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _roleCard(UserRole role) {
    final selected = _role == role;
    return Semantics(
      button: true,
      selected: selected,
      label: role == UserRole.client
          ? 'Choisir le rôle client'
          : 'Choisir le rôle vendeur',
      child: Material(
        color: selected ? AppColors.primarySoft : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.inputBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('role_${role.name}'),
          onTap: _busy ? null : () => setState(() => _role = role),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  role == UserRole.client
                      ? Icons.shopping_bag_outlined
                      : Icons.storefront_outlined,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  role == UserRole.client
                      ? 'Je suis client'
                      : 'Je suis vendeur',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  role == UserRole.client
                      ? 'Acheter et découvrir'
                      : 'Créer ma boutique',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recovery = widget.completeProfileOnly;
    return PopScope(
      canPop: !_busy,
      child: AuthPage(
        title: recovery
            ? 'Terminons votre profil.'
            : 'Vos prochaines trouvailles commencent ici.',
        subtitle: recovery
            ? 'Votre compte existe déjà. Enregistrez votre profil pour accéder à votre espace.'
            : 'Un compte pour acheter en toute simplicité ou lancer votre boutique.',
        badge: recovery ? 'Une dernière étape' : 'Bienvenue sur Vendora',
        showBackButton: !recovery,
        onBack: widget.onBack,
        busy: _busy,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stack =
                  constraints.maxWidth < 300 ||
                  MediaQuery.textScalerOf(context).scale(16) > 23;
              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _roleCard(UserRole.client),
                    const SizedBox(height: AppSpacing.md),
                    _roleCard(UserRole.seller),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _roleCard(UserRole.client)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _roleCard(UserRole.seller)),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Choisissez votre rôle avec soin : il ne sera pas modifiable depuis le profil.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          AutofillGroup(
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    key: const Key('register_name'),
                    label: 'Nom complet',
                    controller: _name,
                    prefixIcon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    textInputAction: TextInputAction.next,
                    validator: AuthValidators.name,
                    enabled: !_busy,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (!recovery) ...[
                    AppTextField(
                      key: const Key('register_email'),
                      label: 'Adresse email',
                      hint: 'vous@exemple.com',
                      controller: _email,
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: AuthValidators.email,
                      enabled: !_busy,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  AppTextField(
                    key: const Key('register_phone'),
                    label: 'Téléphone',
                    hint: '+257 suivi de votre numéro',
                    controller: _phone,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    textInputAction: TextInputAction.next,
                    validator: AuthValidators.phone,
                    enabled: !_busy,
                  ),
                  if (_role == UserRole.seller) ...[
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      key: const Key('register_whatsapp'),
                      label: 'Numéro WhatsApp',
                      hint: 'Avec l’indicatif du pays',
                      controller: _whatsapp,
                      prefixIcon: Icons.chat_bubble_outline_rounded,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: AuthValidators.phone,
                      enabled: !_busy,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Ce numéro servira à recevoir les messages de commande.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (!recovery) ...[
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      key: const Key('register_password'),
                      label: 'Mot de passe',
                      hint: '8 caractères minimum',
                      controller: _password,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.next,
                      validator: AuthValidators.password,
                      enabled: !_busy,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      key: const Key('register_confirm'),
                      label: 'Confirmer le mot de passe',
                      controller: _confirmation,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      enabled: !_busy,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirme le mot de passe.';
                        }
                        return value != _password.text
                            ? 'Les mots de passe ne correspondent pas.'
                            : null;
                      },
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AuthErrorText(message: widget.error),
                  AppButton(
                    key: const Key('register_submit'),
                    label: recovery
                        ? 'Enregistrer mon profil'
                        : 'Créer mon compte',
                    isLoading: _busy,
                    onPressed: _submit,
                    icon: Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (!recovery)
                    TextButton(
                      onPressed: _busy ? null : widget.onBack,
                      child: const Text('J’ai déjà un compte'),
                    )
                  else
                    TextButton(
                      onPressed: _busy ? null : widget.onSignOut,
                      child: const Text('Se déconnecter'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
