import 'package:flutter/material.dart';

import 'cast_controller.dart';

class CastControllerScope extends InheritedNotifier<CastController> {
  const CastControllerScope({
    super.key,
    required CastController controller,
    required super.child,
  }) : super(notifier: controller);

  static CastController of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<CastControllerScope>();
    assert(scope != null, 'No CastControllerScope found in context');
    return scope!.notifier!;
  }

  static CastState stateOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<CastControllerScope>();
    assert(scope != null, 'No CastControllerScope found in context');
    return scope!.notifier!.state;
  }

  static CastController watch(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<CastControllerScope>();
    assert(scope != null, 'No CastControllerScope found in context');
    return scope!.notifier!;
  }
}
