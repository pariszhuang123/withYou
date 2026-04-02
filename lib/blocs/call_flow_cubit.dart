import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../contracts/app_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../contracts/readiness_contracts.dart';

class CallFlowState {
  const CallFlowState({
    required this.selectedScenario,
    required this.activeScenario,
    required this.flowState,
    required this.currentStage,
    required this.callerName,
    required this.sessionId,
    required this.callDuration,
    required this.followUpStage,
    required this.followUpReadyAt,
    required this.followUpRemaining,
    required this.sceneReadiness,
  });

  factory CallFlowState.initial() {
    return const CallFlowState(
      selectedScenario: Scenario.presence,
      activeScenario: null,
      flowState: FakeCallState.idle,
      currentStage: 0,
      callerName: null,
      sessionId: null,
      callDuration: Duration.zero,
      followUpStage: null,
      followUpReadyAt: null,
      followUpRemaining: Duration.zero,
      sceneReadiness: <Scenario, SceneReadinessSnapshot>{},
    );
  }

  final Scenario selectedScenario;
  final Scenario? activeScenario;
  final FakeCallState flowState;
  final int currentStage;
  final String? callerName;
  final String? sessionId;
  final Duration callDuration;
  final int? followUpStage;
  final DateTime? followUpReadyAt;
  final Duration followUpRemaining;
  final Map<Scenario, SceneReadinessSnapshot> sceneReadiness;

  bool get showsCallScreen =>
      flowState == FakeCallState.ringing || flowState == FakeCallState.inCall;

  bool get followUpReady =>
      flowState == FakeCallState.awaitingNextStage &&
      followUpStage != null &&
      followUpRemaining <= Duration.zero;

  CallFlowState copyWith({
    Scenario? selectedScenario,
    Scenario? activeScenario,
    FakeCallState? flowState,
    int? currentStage,
    String? callerName,
    String? sessionId,
    Duration? callDuration,
    int? followUpStage,
    DateTime? followUpReadyAt,
    Duration? followUpRemaining,
    Map<Scenario, SceneReadinessSnapshot>? sceneReadiness,
    bool clearCallerName = false,
    bool clearSessionId = false,
    bool clearFollowUp = false,
    bool clearActiveScenario = false,
  }) {
    return CallFlowState(
      selectedScenario: selectedScenario ?? this.selectedScenario,
      activeScenario: clearActiveScenario
          ? null
          : activeScenario ?? this.activeScenario,
      flowState: flowState ?? this.flowState,
      currentStage: currentStage ?? this.currentStage,
      callerName: clearCallerName ? null : callerName ?? this.callerName,
      sessionId: clearSessionId ? null : sessionId ?? this.sessionId,
      callDuration: callDuration ?? this.callDuration,
      followUpStage: clearFollowUp ? null : followUpStage ?? this.followUpStage,
      followUpReadyAt: clearFollowUp
          ? null
          : followUpReadyAt ?? this.followUpReadyAt,
      followUpRemaining: clearFollowUp
          ? Duration.zero
          : followUpRemaining ?? this.followUpRemaining,
      sceneReadiness: sceneReadiness ?? this.sceneReadiness,
    );
  }
}

class CallFlowCubit extends Cubit<CallFlowState> {
  CallFlowCubit({
    required CallFlowCoordinatorContract coordinator,
    required AppStateContract appStateContract,
    required SceneReadinessContract sceneReadinessContract,
  }) : _coordinator = coordinator,
       _appStateContract = appStateContract,
       _sceneReadinessContract = sceneReadinessContract,
      super(CallFlowState.initial()) {
    _stateSubscription = _coordinator.snapshotStream.listen(_handleSnapshot);
    unawaited(_loadInitialState());
  }

  final CallFlowCoordinatorContract _coordinator;
  final AppStateContract _appStateContract;
  final SceneReadinessContract _sceneReadinessContract;

  StreamSubscription<CallFlowSnapshot>? _stateSubscription;
  Timer? _ticker;
  DateTime? _inCallStartedAt;

  Future<void> selectScenario(Scenario scenario) async {
    await _appStateContract.setSelectedScenario(scenario);
    emit(state.copyWith(selectedScenario: scenario));
  }

  Future<void> startFlow() async {
    final selectedScenario = state.selectedScenario;
    final readiness =
        state.sceneReadiness[selectedScenario] ??
        await _sceneReadinessContract.getReadiness(selectedScenario);
    final scenarioToLaunch = readiness.state == SceneReadinessState.ready
        ? selectedScenario
        : Scenario.presence;

    await _coordinator.startFlow(scenarioToLaunch);
  }

  Future<void> accept() async {
    await _coordinator.acceptCurrentStage();
  }

  Future<void> decline() async {
    await _coordinator.declineCurrentStage();
  }

  Future<void> end() async {
    await _coordinator.endCurrentStage();
  }

  Future<void> triggerFollowUp() async {
    await _coordinator.triggerFollowUpStage();
  }

  Future<void> _loadInitialState() async {
    final selectedScenario =
        await _appStateContract.getSelectedScenario() ?? Scenario.presence;
    final sceneReadinessList = await _sceneReadinessContract.getAllReadiness();
    final sceneReadiness = <Scenario, SceneReadinessSnapshot>{
      for (final snapshot in sceneReadinessList) snapshot.scenario: snapshot,
    };

    emit(
      state.copyWith(
        selectedScenario: selectedScenario,
        sceneReadiness: sceneReadiness,
      ),
    );
  }

  void _handleSnapshot(CallFlowSnapshot snapshot) {
    _syncTicker(snapshot.flowState);

    emit(
      state.copyWith(
        activeScenario: snapshot.scenario,
        flowState: snapshot.flowState,
        currentStage: snapshot.currentStage,
        callerName: snapshot.callerName,
        sessionId: snapshot.sessionId,
        callDuration: _currentCallDuration(snapshot.flowState),
        followUpStage: snapshot.followUpStage,
        followUpReadyAt: snapshot.followUpReadyAt,
        followUpRemaining: _remainingUntil(snapshot.followUpReadyAt),
      ),
    );
  }

  void _syncTicker(FakeCallState flowState) {
    if (flowState == FakeCallState.inCall) {
      _inCallStartedAt ??= DateTime.now();
      _startTicker();
      return;
    }

    if (flowState == FakeCallState.awaitingNextStage) {
      _inCallStartedAt = null;
      _startTicker();
      return;
    }

    _inCallStartedAt = null;
    _stopTicker();
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      emit(
        state.copyWith(
          callDuration: _currentCallDuration(state.flowState),
          followUpRemaining: _remainingUntil(state.followUpReadyAt),
        ),
      );
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Duration _currentCallDuration(FakeCallState flowState) {
    if (flowState != FakeCallState.inCall || _inCallStartedAt == null) {
      return Duration.zero;
    }
    return DateTime.now().difference(_inCallStartedAt!);
  }

  Duration _remainingUntil(DateTime? followUpReadyAt) {
    if (followUpReadyAt == null) {
      return Duration.zero;
    }

    final remaining = followUpReadyAt.difference(DateTime.now());
    if (remaining.isNegative) {
      return Duration.zero;
    }
    return Duration(seconds: remaining.inSeconds);
  }

  @override
  Future<void> close() async {
    _stopTicker();
    await _stateSubscription?.cancel();
    await _coordinator.dispose();
    return super.close();
  }
}
