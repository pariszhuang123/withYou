import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/blocs/call_flow_cubit.dart';
import 'package:with_you/contracts/app_contracts.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/readiness_contracts.dart';

class _TestAppStateContract implements AppStateContract {
  String? _selectedAudioLocaleTag;
  Scenario? _selectedScenario;
  bool _hasPremiumAccess = false;

  @override
  Future<String?> getSelectedAudioLocaleTag() async => _selectedAudioLocaleTag;

  @override
  Future<Scenario?> getSelectedScenario() async => _selectedScenario;

  @override
  Future<bool> hasPremiumAccess() async => _hasPremiumAccess;

  @override
  Future<void> setPremiumAccess(bool hasPremiumAccess) async {
    _hasPremiumAccess = hasPremiumAccess;
  }

  @override
  Future<void> setSelectedAudioLocaleTag(String localeTag) async {
    _selectedAudioLocaleTag = localeTag;
  }

  @override
  Future<void> setSelectedScenario(Scenario scenario) async {
    _selectedScenario = scenario;
  }
}

class _TestSceneReadinessContract implements SceneReadinessContract {
  @override
  Future<List<SceneReadinessSnapshot>> getAllReadiness() async {
    return const <SceneReadinessSnapshot>[
      SceneReadinessSnapshot(
        scenario: Scenario.presence,
        state: SceneReadinessState.ready,
      ),
      SceneReadinessSnapshot(
        scenario: Scenario.socialPull,
        state: SceneReadinessState.lockedPremium,
      ),
      SceneReadinessSnapshot(
        scenario: Scenario.exitPressure,
        state: SceneReadinessState.needsNotification,
      ),
    ];
  }

  @override
  Future<SceneReadinessSnapshot> getReadiness(Scenario scenario) async {
    return (await getAllReadiness()).singleWhere(
      (snapshot) => snapshot.scenario == scenario,
    );
  }
}

class _TestCoordinatorContract implements CallFlowCoordinatorContract {
  final _controller = StreamController<CallFlowSnapshot>.broadcast();
  int triggerFollowUpCount = 0;

  @override
  CallFlowSnapshot currentSnapshot = CallFlowSnapshot.idle();

  @override
  Stream<CallFlowSnapshot> get snapshotStream => _controller.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> acceptCurrentStage() async {
    currentSnapshot = CallFlowSnapshot(
      flowState: FakeCallState.inCall,
      scenario: currentSnapshot.scenario,
      currentStage: currentSnapshot.currentStage,
      callerName: currentSnapshot.callerName,
      sessionId: currentSnapshot.sessionId,
      followUpStage: null,
      followUpReadyAt: null,
    );
    _controller.add(currentSnapshot);
  }

  @override
  Future<void> declineCurrentStage() async {
    currentSnapshot = CallFlowSnapshot(
      flowState: FakeCallState.awaitingNextStage,
      scenario: currentSnapshot.scenario,
      currentStage: currentSnapshot.currentStage,
      callerName: currentSnapshot.callerName,
      sessionId: currentSnapshot.sessionId,
      followUpStage: currentSnapshot.currentStage + 1,
      followUpReadyAt: DateTime.now(),
    );
    _controller.add(currentSnapshot);
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<void> endCurrentStage() async {
    currentSnapshot = CallFlowSnapshot(
      flowState: FakeCallState.completed,
      scenario: currentSnapshot.scenario,
      currentStage: currentSnapshot.currentStage,
      callerName: currentSnapshot.callerName,
      sessionId: currentSnapshot.sessionId,
      followUpStage: null,
      followUpReadyAt: null,
    );
    _controller.add(currentSnapshot);
  }

  @override
  Future<void> resumeFromNotification({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  }) async {
    currentSnapshot = CallFlowSnapshot(
      flowState: FakeCallState.ringing,
      scenario: scenario,
      currentStage: stage,
      callerName: switch (scenario) {
        Scenario.presence => 'Xiao Chen',
        Scenario.socialPull => 'Xiao Li',
        Scenario.exitPressure => 'Xiao Zhang',
      },
      sessionId: sessionId,
      followUpStage: null,
      followUpReadyAt: null,
    );
    _controller.add(currentSnapshot);
  }

  @override
  Future<void> startFlow(Scenario scenario) async {
    currentSnapshot = CallFlowSnapshot(
      flowState: FakeCallState.ringing,
      scenario: scenario,
      currentStage: 1,
      callerName: switch (scenario) {
        Scenario.presence => 'Xiao Chen',
        Scenario.socialPull => 'Xiao Li',
        Scenario.exitPressure => 'Xiao Zhang',
      },
      sessionId: 'session-1',
      followUpStage: null,
      followUpReadyAt: null,
    );
    _controller.add(currentSnapshot);
  }

  @override
  Future<void> triggerFollowUpStage() async {
    triggerFollowUpCount++;
    currentSnapshot = CallFlowSnapshot(
      flowState: FakeCallState.ringing,
      scenario: currentSnapshot.scenario,
      currentStage:
          currentSnapshot.followUpStage ?? currentSnapshot.currentStage,
      callerName: currentSnapshot.callerName,
      sessionId: currentSnapshot.sessionId,
      followUpStage: null,
      followUpReadyAt: null,
    );
    _controller.add(currentSnapshot);
  }
}

void main() {
  test(
    'startFlow seeds state from selected scenario and enters ringing',
    () async {
      final coordinator = _TestCoordinatorContract();
      final cubit = CallFlowCubit(
        coordinator: coordinator,
        appStateContract: _TestAppStateContract(),
        sceneReadinessContract: _TestSceneReadinessContract(),
      );

      await Future<void>.delayed(Duration.zero);
      await cubit.selectScenario(Scenario.presence);
      await cubit.startFlow();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.flowState, FakeCallState.ringing);
      expect(cubit.state.currentStage, 1);
      expect(cubit.state.callerName, 'Xiao Chen');
      expect(cubit.state.sessionId, isNotNull);

      await cubit.close();
    },
  );

  test('hydrates immediately from the coordinator current snapshot', () async {
    final coordinator = _TestCoordinatorContract()
      ..currentSnapshot = const CallFlowSnapshot(
        flowState: FakeCallState.ringing,
        scenario: Scenario.presence,
        currentStage: 1,
        callerName: 'Taylor',
        sessionId: 'session-1',
        followUpStage: null,
        followUpReadyAt: null,
      );
    final cubit = CallFlowCubit(
      coordinator: coordinator,
      appStateContract: _TestAppStateContract(),
      sceneReadinessContract: _TestSceneReadinessContract(),
    );

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.flowState, FakeCallState.ringing);
    expect(cubit.state.currentStage, 1);
    expect(cubit.state.callerName, 'Taylor');
    expect(cubit.state.sessionId, 'session-1');

    await cubit.close();
  });

  test(
    'triggerFollowUp re-enters the flow when the placeholder follow-up is ready',
    () async {
      final coordinator = _TestCoordinatorContract();
      final cubit = CallFlowCubit(
        coordinator: coordinator,
        appStateContract: _TestAppStateContract(),
        sceneReadinessContract: _TestSceneReadinessContract(),
      );

      await cubit.startFlow();
      await Future<void>.delayed(Duration.zero);
      await cubit.decline();
      await Future<void>.delayed(Duration.zero);
      await cubit.triggerFollowUp();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.flowState, FakeCallState.ringing);
      expect(cubit.state.currentStage, 2);

      await cubit.close();
    },
  );

  test('foreground expiry auto-triggers a ready follow-up stage', () async {
    final coordinator = _TestCoordinatorContract();
    final cubit = CallFlowCubit(
      coordinator: coordinator,
      appStateContract: _TestAppStateContract(),
      sceneReadinessContract: _TestSceneReadinessContract(),
    );

    cubit.setAppInForeground(true);
    coordinator.currentSnapshot = CallFlowSnapshot(
      flowState: FakeCallState.awaitingNextStage,
      scenario: Scenario.socialPull,
      currentStage: 1,
      callerName: 'Xiao Li',
      sessionId: 'session-1',
      followUpStage: 2,
      followUpReadyAt: DateTime.now(),
    );
    coordinator.snapshotStream.listen((_) {});
    coordinator._controller.add(coordinator.currentSnapshot);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(coordinator.triggerFollowUpCount, 1);
    expect(cubit.state.flowState, FakeCallState.ringing);
    expect(cubit.state.currentStage, 2);

    await cubit.close();
  });

  test(
    'background expiry does not auto-trigger a ready follow-up stage',
    () async {
      final coordinator = _TestCoordinatorContract();
      final cubit = CallFlowCubit(
        coordinator: coordinator,
        appStateContract: _TestAppStateContract(),
        sceneReadinessContract: _TestSceneReadinessContract(),
      );

      cubit.setAppInForeground(false);
      coordinator.currentSnapshot = CallFlowSnapshot(
        flowState: FakeCallState.awaitingNextStage,
        scenario: Scenario.socialPull,
        currentStage: 1,
        callerName: 'Xiao Li',
        sessionId: 'session-1',
        followUpStage: 2,
        followUpReadyAt: DateTime.now(),
      );
      coordinator._controller.add(coordinator.currentSnapshot);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(coordinator.triggerFollowUpCount, 0);
      expect(cubit.state.flowState, FakeCallState.awaitingNextStage);

      await cubit.close();
    },
  );

  test('locked or unarmed scenarios stay blocked on launch', () async {
    final coordinator = _TestCoordinatorContract();
    final cubit = CallFlowCubit(
      coordinator: coordinator,
      appStateContract: _TestAppStateContract(),
      sceneReadinessContract: _TestSceneReadinessContract(),
    );

    await Future<void>.delayed(Duration.zero);
    await cubit.selectScenario(Scenario.socialPull);
    await cubit.startFlow();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.selectedScenario, Scenario.socialPull);
    expect(cubit.state.activeScenario, isNull);
    expect(cubit.state.callerName, isNull);
    expect(cubit.state.flowState, FakeCallState.idle);

    await cubit.close();
  });

  test(
    'completed flow clears caller identity and active session state',
    () async {
      final coordinator = _TestCoordinatorContract()
        ..currentSnapshot = const CallFlowSnapshot(
          flowState: FakeCallState.ringing,
          scenario: Scenario.presence,
          currentStage: 1,
          callerName: 'Taylor',
          sessionId: 'session-1',
          followUpStage: null,
          followUpReadyAt: null,
        );
      final cubit = CallFlowCubit(
        coordinator: coordinator,
        appStateContract: _TestAppStateContract(),
        sceneReadinessContract: _TestSceneReadinessContract(),
      );

      await Future<void>.delayed(Duration.zero);
      await cubit.end();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.flowState, FakeCallState.completed);
      expect(cubit.state.activeScenario, isNull);
      expect(cubit.state.currentStage, 0);
      expect(cubit.state.callerName, isNull);
      expect(cubit.state.sessionId, isNull);

      await cubit.close();
    },
  );
}
