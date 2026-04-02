import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/audio_contracts.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/models/pending_follow_up.dart';
import 'package:with_you/services/call_flow_coordinator_service.dart';

class _TestTimingContract implements FakeCallTimingContract {
  final _controller = StreamController<FakeCallState>.broadcast();

  @override
  Scenario? currentScenario;

  @override
  int currentStage = 0;

  @override
  FakeCallState currentState = FakeCallState.idle;

  @override
  DateTime? nextStageReadyAt;

  @override
  int? pendingFollowUpStage;

  String? lastSessionId;

  @override
  Stream<FakeCallState> get stateStream => _controller.stream;

  @override
  Future<void> acceptCurrentStage() async {
    currentState = FakeCallState.inCall;
    _controller.add(currentState);
  }

  @override
  Future<void> declineCurrentStage() async {
    currentState = FakeCallState.awaitingNextStage;
    pendingFollowUpStage = currentStage + 1;
    nextStageReadyAt = DateTime.now();
    _controller.add(currentState);
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<void> endCurrentStage() async {
    currentState = FakeCallState.completed;
    _controller.add(currentState);
  }

  @override
  Future<void> handleMissedStage({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  }) async {
    lastSessionId = sessionId;
    currentScenario = scenario;
    currentStage = stage;
    currentState = FakeCallState.awaitingNextStage;
    _controller.add(currentState);
  }

  @override
  Future<void> onNotificationTapped({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  }) async {
    lastSessionId = sessionId;
    currentScenario = scenario;
    currentStage = stage;
    pendingFollowUpStage = null;
    nextStageReadyAt = null;
    currentState = FakeCallState.ringing;
    _controller.add(currentState);
  }

  @override
  Future<void> startFlow({
    required String sessionId,
    required Scenario scenario,
    FakeCallTrack track = FakeCallTrack.active,
  }) async {
    lastSessionId = sessionId;
    currentScenario = scenario;
    currentStage = 1;
    currentState = FakeCallState.ringing;
    pendingFollowUpStage = null;
    nextStageReadyAt = null;
    _controller.add(currentState);
  }
}

class _TestContentResolver implements ContentResolverContract {
  @override
  List<AudioContentDescriptor> listRequiredAudio() =>
      const <AudioContentDescriptor>[];

  @override
  String resolveBundledAudioAssetPath({
    required String localeTag,
    required Scenario scenario,
    required int stage,
  }) {
    return '$localeTag/${scenario.name}/stage_$stage.m4a';
  }

  @override
  AudioContentDescriptor resolveAudioContent({
    required Scenario scenario,
    required int stage,
  }) {
    return AudioContentDescriptor(
      scenario: scenario,
      stage: stage,
      scenarioDirectory: scenario.name,
    );
  }

  @override
  String resolveCallerName(Scenario scenario) {
    switch (scenario) {
      case Scenario.presence:
        return 'Xiao Chen';
      case Scenario.socialPull:
        return 'Xiao Li';
      case Scenario.exitPressure:
        return 'Xiao Zhang';
    }
  }
}

class _TestNotificationContract implements NotificationContract {
  final _controller = StreamController<NotificationEvent>.broadcast();
  final List<({String sessionId, Scenario scenario, int stage, Duration delay})>
  scheduled = [];
  final List<String> cancelledSessions = [];

  @override
  Stream<NotificationEvent> get eventStream => _controller.stream;

  @override
  Future<void> cancelAll(String sessionId) async {
    cancelledSessions.add(sessionId);
  }

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> scheduleFollowUp({
    required String sessionId,
    required Scenario scenario,
    required int stage,
    required Duration delay,
    required String callerName,
  }) async {
    scheduled.add((
      sessionId: sessionId,
      scenario: scenario,
      stage: stage,
      delay: delay,
    ));
  }

  void emit(NotificationEvent event) {
    _controller.add(event);
  }
}

class _TestPendingFollowUpRepository
    implements PendingFollowUpRepositoryContract {
  final List<PendingFollowUp> records = [];

  @override
  Future<void> deleteBySession(String sessionId) async {
    records.removeWhere((entry) => entry.sessionId == sessionId);
  }

  @override
  Future<void> deletePendingFollowUp({
    required String sessionId,
    required int stage,
  }) async {
    records.removeWhere(
      (entry) => entry.sessionId == sessionId && entry.stage == stage,
    );
  }

  @override
  Future<List<PendingFollowUp>> getAllPendingFollowUps() async {
    return List<PendingFollowUp>.from(records);
  }

  @override
  Future<void> savePendingFollowUp(PendingFollowUp pendingFollowUp) async {
    final index = records.indexWhere(
      (entry) =>
          entry.sessionId == pendingFollowUp.sessionId &&
          entry.stage == pendingFollowUp.stage,
    );
    if (index == -1) {
      records.add(pendingFollowUp);
    } else {
      records[index] = pendingFollowUp;
    }
  }
}

void main() {
  test(
    'startFlow maps scenario to caller and emits ringing snapshot',
    () async {
      final timing = _TestTimingContract();
      final notifications = _TestNotificationContract();
      final pendingRepository = _TestPendingFollowUpRepository();
      final service = CallFlowCoordinatorService(
        timingContract: timing,
        contentResolverContract: _TestContentResolver(),
        notificationContract: notifications,
        pendingFollowUpRepository: pendingRepository,
      );

      await service.startFlow(Scenario.socialPull);
      await Future<void>.delayed(Duration.zero);

      expect(service.currentSnapshot.flowState, FakeCallState.ringing);
      expect(service.currentSnapshot.callerName, 'Xiao Li');
      expect(service.currentSnapshot.currentStage, 1);
      expect(service.currentSnapshot.sessionId, isNotNull);

      await service.dispose();
    },
  );

  test('awaiting next stage persists pending follow-up metadata', () async {
    final timing = _TestTimingContract();
    final notifications = _TestNotificationContract();
    final pendingRepository = _TestPendingFollowUpRepository();
    final service = CallFlowCoordinatorService(
      timingContract: timing,
      contentResolverContract: _TestContentResolver(),
      notificationContract: notifications,
      pendingFollowUpRepository: pendingRepository,
    );

    await service.startFlow(Scenario.socialPull);
    await Future<void>.delayed(Duration.zero);
    await timing.declineCurrentStage();
    await Future<void>.delayed(Duration.zero);

    expect(pendingRepository.records.single.stage, 2);
    expect(
      pendingRepository.records.single.status,
      PendingFollowUpStatus.pending,
    );

    await service.dispose();
  });

  test(
    'notification tap events are forwarded into the timing service and clear pending records',
    () async {
      final timing = _TestTimingContract();
      final notifications = _TestNotificationContract();
      final pendingRepository = _TestPendingFollowUpRepository()
        ..records.add(
          PendingFollowUp(
            sessionId: 'session-from-notification',
            scenario: Scenario.socialPull,
            stage: 2,
            scheduledAtUtc: DateTime.now().toUtc(),
            expiresAtUtc: DateTime.now().toUtc().add(
              const Duration(minutes: 2),
            ),
            callerName: 'Xiao Li',
            status: PendingFollowUpStatus.pending,
          ),
        );
      final service = CallFlowCoordinatorService(
        timingContract: timing,
        contentResolverContract: _TestContentResolver(),
        notificationContract: notifications,
        pendingFollowUpRepository: pendingRepository,
      );

      notifications.emit(
        const NotificationEvent(
          sessionId: 'session-from-notification',
          scenario: Scenario.socialPull,
          stage: 2,
          action: NotificationAction.tapped,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(timing.lastSessionId, 'session-from-notification');
      expect(timing.currentStage, 2);
      expect(pendingRepository.records, isEmpty);

      await service.dispose();
    },
  );

  test(
    'initialize reconciles expired pending follow-ups and schedules the next stage',
    () async {
      final timing = _TestTimingContract();
      final notifications = _TestNotificationContract();
      final pendingRepository = _TestPendingFollowUpRepository()
        ..records.add(
          PendingFollowUp(
            sessionId: 'expired-session',
            scenario: Scenario.exitPressure,
            stage: 2,
            scheduledAtUtc: DateTime.now().toUtc().subtract(
              const Duration(minutes: 4),
            ),
            expiresAtUtc: DateTime.now().toUtc().subtract(
              const Duration(minutes: 2, seconds: 1),
            ),
            callerName: 'Xiao Zhang',
            status: PendingFollowUpStatus.pending,
          ),
        );
      final service = CallFlowCoordinatorService(
        timingContract: timing,
        contentResolverContract: _TestContentResolver(),
        notificationContract: notifications,
        pendingFollowUpRepository: pendingRepository,
      );

      await service.initialize();

      expect(notifications.cancelledSessions.single, 'expired-session');
      expect(notifications.scheduled.single.stage, 3);
      expect(pendingRepository.records.single.stage, 3);
      expect(
        pendingRepository.records.single.status,
        PendingFollowUpStatus.pending,
      );

      await service.dispose();
    },
  );
}
