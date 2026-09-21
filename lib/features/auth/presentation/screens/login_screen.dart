import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_controller.dart';
import '../widgets/login_form.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.onVisit});
  final VoidCallback onVisit;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return LoginForm(
      isLoading: auth.busy,
      error: auth.operationError,
      onVisit: onVisit,
      onSubmit: (email, password) async {
        await auth.signIn(email, password);
        // AuthGate gère la destination à partir du profil réel.
      },
      onRegister: () {
        auth.clearOperationError();
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const RegisterScreen()));
      },
    );
  }
}
