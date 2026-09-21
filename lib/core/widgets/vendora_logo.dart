import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class VendoraLogo extends StatelessWidget {
  const VendoraLogo({super.key, this.large = false});
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Vendora',
      image: true,
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            children: const [
              TextSpan(text: 'vendora'),
              TextSpan(
                text: '.',
                style: TextStyle(color: AppColors.secondary),
              ),
            ],
          ),
          style: TextStyle(
            color: AppColors.primary,
            fontSize: large ? 36 : 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
        ),
      ),
    );
  }
}
