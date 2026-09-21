import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/providers/auth_controller.dart';
import '../features/auth/presentation/screens/auth_gate.dart';

// Nom conservé pour rester compatible avec votre main.dart actuel.
class ExamShopApp extends StatelessWidget {
  const ExamShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(AuthRepository(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      )),
      child: MaterialApp(
        title: 'Vendora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}
