import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final content = isLoading
        ? Semantics(
            label: 'Chargement en cours',
            liveRegion: true,
            child: const SizedBox(
              width: AppSpacing.xl,
              height: AppSpacing.xl,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        : Text(label, textAlign: TextAlign.center);

    final callback = isLoading ? null : onPressed;
    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: callback,
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: callback,
        child: content,
      ),
    };

    return SizedBox(width: expand ? double.infinity : null, child: button);
  }
}
