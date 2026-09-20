import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'foundation_screen.dart';

class ExamShopApp extends StatelessWidget {
  const ExamShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const FoundationScreen(),
    );
  }
}
