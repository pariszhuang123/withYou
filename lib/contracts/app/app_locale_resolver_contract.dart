import 'package:flutter/widgets.dart';

abstract class AppLocaleResolverContract {
  Locale resolve({
    required List<Locale>? preferredLocales,
    required List<Locale> supportedLocales,
  });
}
