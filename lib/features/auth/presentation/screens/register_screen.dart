import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_controller.dart';
import '../widgets/registration_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key, this.completeProfileOnly = false});
  final bool completeProfileOnly;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return RegistrationForm(
      completeProfileOnly: completeProfileOnly,
      isLoading: auth.busy,
      error: auth.operationError,
      onBack: () => Navigator.of(context).maybePop(),
      onSignOut: () => auth.signOut(),
      onSubmit: (data) async {
        if (completeProfileOnly) {
          await auth.completeProfile(
            name: data.name,
            phone: data.phone,
            role: data.role,
            whatsappNumber: data.whatsappNumber,
          );
        } else {
          await auth.register(
            email: data.email,
            password: data.password,
            name: data.name,
            phone: data.phone,
            role: data.role,
            whatsappNumber: data.whatsappNumber,
          );
          // Firebase Auth et Firestore sont deux opérations distinctes.
          // AuthGate gère aussi le compte créé dont le profil manque encore.
          if (context.mounted && auth.isAuthenticated) {
            Navigator.of(context).pop();
          }
        }
      },
    );
  }
}
