import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/readiness_contracts.dart';

void main() {
  test(
    'notification readiness distinguishes armed and permission-needed states',
    () {
      expect(NotificationReadinessState.values, <NotificationReadinessState>[
        NotificationReadinessState.ready,
        NotificationReadinessState.needsPermission,
        NotificationReadinessState.unavailable,
      ]);
    },
  );
}
