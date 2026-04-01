import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/services/app_locale_resolver_service.dart';

void main() {
  const service = AppLocaleResolverService();
  const supported = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  test('prefers exact locale matches first', () {
    final resolved = service.resolve(
      preferredLocales: const <Locale>[Locale('zh', 'TW')],
      supportedLocales: supported,
    );

    expect(resolved, const Locale('zh', 'TW'));
  });

  test('falls back from regional zh locale to base zh', () {
    final resolved = service.resolve(
      preferredLocales: const <Locale>[Locale('zh', 'SG')],
      supportedLocales: supported,
    );

    expect(resolved, const Locale('zh'));
  });

  test('falls back to english when chinese is unavailable', () {
    final resolved = service.resolve(
      preferredLocales: const <Locale>[Locale('fr')],
      supportedLocales: supported,
    );

    expect(resolved, const Locale('en'));
  });
}
