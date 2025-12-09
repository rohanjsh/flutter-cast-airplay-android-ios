import 'package:flutter/material.dart';
import 'casting_controller_state.dart';
import 'casting_controller.dart';

class CastingControllerScope extends InheritedNotifier<CastingController> {
  const CastingControllerScope({
    super.key,
    required CastingController controller,
    required super.child,
  }) : super(notifier: controller);

  static CastingController of(BuildContext context) {
    final scope = context
        .getInheritedWidgetOfExactType<CastingControllerScope>();
    assert(scope != null, 'No CastingControllerScope found in context');
    return scope!.notifier!;
  }

  static CastingUiState stateOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<CastingControllerScope>();
    assert(scope != null, 'No CastingControllerScope found in context');
    return scope!.notifier!.state;
  }

  static CastingController watch(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<CastingControllerScope>();
    assert(scope != null, 'No CastingControllerScope found in context');
    return scope!.notifier!;
  }
}
