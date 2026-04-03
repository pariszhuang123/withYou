import 'dart:async';

import 'fake_call_timing_contract.dart';

class CallFlowSnapshot {
  const CallFlowSnapshot({
    required this.flowState,
    required this.scenario,
    required this.currentStage,
    required this.callerName,
    required this.sessionId,
    required this.followUpStage,
    required this.followUpReadyAt,
  });

  factory CallFlowSnapshot.idle() {
    return const CallFlowSnapshot(
      flowState: FakeCallState.idle,
      scenario: null,
      currentStage: 0,
      callerName: null,
      sessionId: null,
      followUpStage: null,
      followUpReadyAt: null,
    );
  }

  final FakeCallState flowState;
  final Scenario? scenario;
  final int currentStage;
  final String? callerName;
  final String? sessionId;
  final int? followUpStage;
  final DateTime? followUpReadyAt;
}

abstract class CallFlowCoordinatorContract {
  Stream<CallFlowSnapshot> get snapshotStream;

  CallFlowSnapshot get currentSnapshot;

  Future<void> initialize();

  Future<void> startFlow(Scenario scenario);

  Future<void> resumeFromNotification({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  });

  Future<void> acceptCurrentStage();

  Future<void> declineCurrentStage();

  Future<void> endCurrentStage();

  Future<void> triggerFollowUpStage();

  Future<void> dispose();
}
