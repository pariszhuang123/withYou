import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/commerce_contracts.dart';

void main() {
  test('premium access remains a binary entitlement surface', () {
    expect(PremiumAccessState.values, <PremiumAccessState>[
      PremiumAccessState.inactive,
      PremiumAccessState.active,
    ]);
  });
}
