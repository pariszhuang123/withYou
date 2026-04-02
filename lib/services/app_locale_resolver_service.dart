import 'package:flutter/widgets.dart';

import '../contracts/app_contracts.dart';

class AppLocaleResolverService implements AppLocaleResolverContract {
  const AppLocaleResolverService();

  @override
  Locale resolve({
    required List<Locale>? preferredLocales,
    required List<Locale> supportedLocales,
  }) {
    if (preferredLocales == null || preferredLocales.isEmpty) {
      return _fallbackLocale(supportedLocales);
    }

    for (final preferred in preferredLocales) {
      final exact = _findExactMatch(preferred, supportedLocales);
      if (exact != null) {
        return exact;
      }
    }

    for (final preferred in preferredLocales) {
      final languageMatch = _findLanguageFallback(preferred, supportedLocales);
      if (languageMatch != null) {
        return languageMatch;
      }
    }

    return _fallbackLocale(supportedLocales);
  }

  Locale? _findExactMatch(Locale preferred, List<Locale> supportedLocales) {
    for (final supported in supportedLocales) {
      if (_sameLocale(preferred, supported)) {
        return supported;
      }
    }
    return null;
  }

  Locale? _findLanguageFallback(Locale preferred, List<Locale> supportedLocales) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == preferred.languageCode &&
          supported.countryCode == null &&
          supported.scriptCode == null) {
        return supported;
      }
    }
    return null;
  }

  Locale _fallbackLocale(List<Locale> supportedLocales) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == 'en') {
        return supported;
      }
    }
    return supportedLocales.first;
  }

  bool _sameLocale(Locale left, Locale right) {
    return left.languageCode == right.languageCode &&
        (left.countryCode?.toUpperCase() ?? '') ==
            (right.countryCode?.toUpperCase() ?? '') &&
        (left.scriptCode?.toLowerCase() ?? '') ==
            (right.scriptCode?.toLowerCase() ?? '');
  }
}
