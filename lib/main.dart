import 'package:flutter/material.dart';

import 'src/casting/casting_service.dart';
import 'src/presentation/presentation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Access singleton to trigger Pigeon API registration
  // ignore: unnecessary_statements
  CastingService.instance;

  // Global error handling for Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  runApp(const CastNPlayApp());
}
