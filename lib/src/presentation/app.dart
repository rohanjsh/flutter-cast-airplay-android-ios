import 'package:flutter/material.dart';

import 'constants/strings.dart';
import 'screens/cast_sender_screen.dart';
import 'theme/theme.dart';

/// Main app widget for Cast n Play.
class CastNPlayApp extends StatelessWidget {
  const CastNPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appTitle,
      debugShowCheckedModeBanner: AppConfig.debugShowBanner,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryIndigo,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.bgDark,
      ),
      home: const CastSenderScreen(),
    );
  }
}

