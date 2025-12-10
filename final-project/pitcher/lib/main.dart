import 'package:flutter/material.dart';
import 'package:pitcher/src/core/constants/strings.dart';
import 'package:pitcher/src/core/theme/theme.dart';
import 'package:pitcher/src/presentation/ui/media_player_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  runApp(
    MaterialApp(
      title: Strings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppThemeConfig.darkTheme,
      home: const MediaPlayerPage(),
    ),
  );
}
