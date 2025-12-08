// =============================================================================
// CASTING CONTROLLER SCOPE - InheritedNotifier for Controller Access
// =============================================================================
// This scope provides CastingController to the widget subtree without prop
// drilling. Widgets can access the controller and its state via:
//
//   final controller = CastingControllerScope.of(context);
//   final state = CastingControllerScope.stateOf(context);
//
// The scope automatically rebuilds dependent widgets when state changes.
// =============================================================================

import 'package:flutter/material.dart';

import '../state/casting_ui_state.dart';
import 'casting_controller.dart';

/// Provides [CastingController] to the widget subtree.
///
/// This uses [InheritedNotifier] which automatically rebuilds dependents
/// when the controller calls [notifyListeners].
///
/// ## Usage
///
/// Wrap your widget tree:
/// ```dart
/// CastingControllerScope(
///   controller: myController,
///   child: MyApp(),
/// )
/// ```
///
/// Access in descendants:
/// ```dart
/// // Get controller (for calling methods)
/// final controller = CastingControllerScope.of(context);
/// controller.togglePlayPause();
///
/// // Get state (rebuilds when state changes)
/// final state = CastingControllerScope.stateOf(context);
/// if (state.isPlaying) { ... }
/// ```
class CastingControllerScope extends InheritedNotifier<CastingController> {
  const CastingControllerScope({
    super.key,
    required CastingController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Gets the [CastingController] without establishing a dependency.
  ///
  /// Use this when you only need to call methods on the controller
  /// and don't need to rebuild when state changes.
  ///
  /// Example:
  /// ```dart
  /// final controller = CastingControllerScope.of(context);
  /// controller.togglePlayPause();
  /// ```
  static CastingController of(BuildContext context) {
    final scope =
        context.getInheritedWidgetOfExactType<CastingControllerScope>();
    assert(scope != null, 'No CastingControllerScope found in context');
    return scope!.notifier!;
  }

  /// Gets the current [CastingUiState] and establishes a dependency.
  ///
  /// The calling widget will rebuild when the state changes.
  ///
  /// Example:
  /// ```dart
  /// final state = CastingControllerScope.stateOf(context);
  /// if (state.isPlaying) {
  ///   showPauseButton();
  /// }
  /// ```
  static CastingUiState stateOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<CastingControllerScope>();
    assert(scope != null, 'No CastingControllerScope found in context');
    return scope!.notifier!.state;
  }

  /// Gets the [CastingController] and establishes a dependency.
  ///
  /// The calling widget will rebuild when state changes.
  /// Use this when you need both access to methods AND reactive updates.
  static CastingController watch(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<CastingControllerScope>();
    assert(scope != null, 'No CastingControllerScope found in context');
    return scope!.notifier!;
  }
}

