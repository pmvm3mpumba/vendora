import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../models/app_user.dart';
import 'auth_page.dart';

/// Lecture des vraies données Firestore ; édition de profil dans un lot ultérieur.
class AccountContent extends StatelessWidget {
  const AccountContent({
    super.key,
    required this.profile,
    required this.onSignOut,
    this.isLoading = false,
    this.error,
  });
  final AppUser profile;
  final VoidCallback onSignOut;
  final bool isLoading;
  final String? error;

  String get _initials {
    final words = profile.name.trim().split(RegExp(r'\s+'));
    return words
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word.characters.first)
        .join()
        .toUpperCase();
  }

  Widget _detail(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                SelectableText(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.hero,
            borderRadius: BorderRadius.circular(AppSpacing.heroRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFD2E4CC),
                foregroundColor: AppColors.secondary,
                child: Text(
                  _initials,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                profile.name,
                style: text.headlineSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                profile.isSeller
                    ? 'Votre espace vendeur'
                    : 'Votre espace client',
                style: text.bodyMedium?.copyWith(
                  color: const Color(0xFFD2E3D8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Mes informations', style: text.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Column(
            children: [
              _detail(
                context,
                Icons.mail_outline_rounded,
                'Adresse email',
                profile.email,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _detail(
                context,
                Icons.phone_outlined,
                'Téléphone',
                profile.phone,
              ),
              if (profile.isSeller) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                _detail(
                  context,
                  Icons.chat_bubble_outline_rounded,
                  'WhatsApp',
                  profile.whatsappNumber,
                ),
              ],
              const Divider(height: 1, indent: 16, endIndent: 16),
              _detail(
                context,
                profile.isSeller
                    ? Icons.storefront_outlined
                    : Icons.person_outline,
                'Type de compte',
                profile.role.label,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Ces informations proviennent de votre profil Firebase. Le rôle du compte ne se modifie pas ici.',
          style: text.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xl),
        AuthErrorText(message: error),
        AppButton(
          label: 'Se déconnecter',
          variant: AppButtonVariant.secondary,
          icon: Icons.logout_rounded,
          isLoading: isLoading,
          onPressed: onSignOut,
        ),
      ],
    );
  }
}
