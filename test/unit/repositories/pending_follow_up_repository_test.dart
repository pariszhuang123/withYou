import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/models/pending_follow_up.dart';
import 'package:with_you/repositories/pending_follow_up_repository.dart';

void main() {
  late Directory tempDirectory;
  late PendingFollowUpRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'pending_follow_up_repository_test',
    );
    repository = PendingFollowUpRepository(
      directoryProvider: () async => tempDirectory,
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('savePendingFollowUp persists and updates follow-up records', () async {
    final record = PendingFollowUp(
      sessionId: 'session-a',
      scenario: Scenario.socialPull,
      stage: 2,
      scheduledAtUtc: DateTime.utc(2026, 4, 2, 8, 0),
      expiresAtUtc: DateTime.utc(2026, 4, 2, 8, 2),
      callerName: 'Xiao Li',
      status: PendingFollowUpStatus.pending,
    );

    await repository.savePendingFollowUp(record);
    await repository.savePendingFollowUp(
      record.copyWith(status: PendingFollowUpStatus.tapped),
    );

    final all = await repository.getAllPendingFollowUps();
    expect(all.single.status, PendingFollowUpStatus.tapped);
  });

  test('deleteBySession removes all follow-ups for the session', () async {
    await repository.savePendingFollowUp(
      PendingFollowUp(
        sessionId: 'session-a',
        scenario: Scenario.socialPull,
        stage: 2,
        scheduledAtUtc: DateTime.utc(2026, 4, 2, 8, 0),
        expiresAtUtc: DateTime.utc(2026, 4, 2, 8, 2),
        callerName: 'Xiao Li',
        status: PendingFollowUpStatus.pending,
      ),
    );
    await repository.savePendingFollowUp(
      PendingFollowUp(
        sessionId: 'session-b',
        scenario: Scenario.exitPressure,
        stage: 2,
        scheduledAtUtc: DateTime.utc(2026, 4, 2, 9, 0),
        expiresAtUtc: DateTime.utc(2026, 4, 2, 9, 2),
        callerName: 'Xiao Zhang',
        status: PendingFollowUpStatus.pending,
      ),
    );

    await repository.deleteBySession('session-a');

    final all = await repository.getAllPendingFollowUps();
    expect(all.single.sessionId, 'session-b');
  });
}
