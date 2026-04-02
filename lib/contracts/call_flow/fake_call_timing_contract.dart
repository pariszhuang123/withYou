import 'dart:async';

enum Scenario { presence, socialPull, exitPressure }

enum FakeCallTrack { active, background }

enum FakeCallState {
  idle,
  ringing,
  inCall,
  callEnded,
  awaitingNextStage,
  completed,
}

abstract class FakeCallTimingContract {
  Stream<FakeCallState> get stateStream;

  FakeCallState get currentState;

  Scenario? get currentScenario;

  int get currentStage;

  int? get pendingFollowUpStage;

  DateTime? get nextStageReadyAt;

  Future<void> startFlow({
    required String sessionId,
    required Scenario scenario,
    FakeCallTrack track = FakeCallTrack.active,
  });

  Future<void> acceptCurrentStage();

  Future<void> declineCurrentStage();

  Future<void> endCurrentStage();

  Future<void> onNotificationTapped({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  });

  Future<void> handleMissedStage({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  });

  Future<void> dispose();
}
