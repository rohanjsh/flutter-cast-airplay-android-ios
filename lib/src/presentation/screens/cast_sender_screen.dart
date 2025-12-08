// =============================================================================
// CAST SENDER SCREEN - Purely Presentational UI
// =============================================================================
// This screen is purely presentational. All business logic lives in
// CastingController. The screen:
// 1. Creates and disposes the controller
// 2. Provides controller to subtree via CastingControllerScope
// 3. Widgets access controller directly - no prop drilling
// =============================================================================

import 'package:flutter/material.dart';

import '../controllers/casting_controller.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// Main screen for Cast n Play application.
///
/// This is a purely presentational widget. All business logic is delegated
/// to [CastingController], making this screen easy to understand and test.
class CastSenderScreen extends StatefulWidget {
  const CastSenderScreen({super.key});

  @override
  State<CastSenderScreen> createState() => _CastSenderScreenState();
}

class _CastSenderScreenState extends State<CastSenderScreen> {
  // ---------------------------------------------------------------------------
  // CONTROLLER
  // ---------------------------------------------------------------------------

  late final CastingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CastingController(onError: _showError);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // ERROR DISPLAY
  // ---------------------------------------------------------------------------

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return CastingControllerScope(
      controller: _controller,
      child: Scaffold(
        body: Stack(
          children: [
            const _BackgroundGradient(),
            const SafeArea(child: _MainContent()),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PRIVATE WIDGETS
// =============================================================================

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    // Watch for state changes to rebuild
    final state = CastingControllerScope.stateOf(context);

    return Column(
      children: [
        HeaderWidget(isDeviceSelected: state.isConnected),
        const Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                NowPlayingCardWidget(),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// PRIVATE WIDGETS
// =============================================================================

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgDark, AppColors.bgDarkSecondary.fade(0.8)],
        ),
      ),
    );
  }
}
