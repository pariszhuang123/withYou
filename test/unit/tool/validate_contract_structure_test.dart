import 'package:flutter_test/flutter_test.dart';

import '../../../tool/validate_contract_structure.dart' as validator;

void main() {
  group('contract structure validator helpers', () {
    test('accepts contract file names that end with _contract.dart', () {
      expect(
        validator.isValidContractFileName('notification_contract.dart'),
        isTrue,
      );
      expect(
        validator.isValidContractFileName('notification_service.dart'),
        isFalse,
      );
    });

    test('maps contract file names to kebab-case doc names', () {
      expect(
        validator.expectedDocPathForContractFile(
          'call_flow/pending_follow_up_repository_contract.dart',
        ),
        'call_flow/pending-follow-up-repository.md',
      );
      expect(
        validator.expectedDocPathForContractFile(
          'app/app_locale_resolver_contract.dart',
        ),
        'app/app-locale-resolver.md',
      );
    });

    test('parses contract metadata rows from docs', () {
      final metadata = validator.parseMetadataTable('''
| Field | Value |
|---|---|
| Version | `v0.1` |
| Module | `audio` |
| Source | `lib/contracts/audio/audio_playback_contract.dart` |
''');

      expect(metadata['Version'], 'v0.1');
      expect(metadata['Module'], 'audio');
      expect(
        metadata['Source'],
        'lib/contracts/audio/audio_playback_contract.dart',
      );
    });
  });
}
