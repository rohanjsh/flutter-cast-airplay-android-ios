import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pitcher/src/cast/domain/sample_media.dart';
import 'package:pitcher/src/core/constants/strings.dart';
import 'package:pitcher/src/core/theme/theme.dart';
import 'package:pitcher/src/presentation/logic/cast_controller.dart';
import 'package:pitcher/src/presentation/logic/cast_controller_scope.dart';

part 'widgets.dart';

class MediaPlayerPage extends StatefulWidget {
  const MediaPlayerPage({super.key});

  @override
  State<MediaPlayerPage> createState() => _MediaPlayerPageState();
}

class _MediaPlayerPageState extends State<MediaPlayerPage> {
  late final CastController _controller;

  @override
  Widget build(BuildContext context) {
    return CastControllerScope(
      controller: _controller,
      child: Scaffold(
        body: Stack(
          children: [
            const _CastScreenBackground(),
            const SafeArea(child: _CastScreenBody()),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = CastController(onError: _showError);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: colorScheme.error),
    );
  }
}
