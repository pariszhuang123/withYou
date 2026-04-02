import 'dart:async';
import 'dart:math';

import '../contracts/audio_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../models/pending_follow_up.dart';

class CallFlowCoordinatorService implements CallFlowCoordinatorContract {
  CallFlowCoordinatorService({
    required FakeCallTimingContract timingContract,
    required ContentResolverContract contentResolverContract,
    required NotificationContract notificationContract,
    required PendingFollowUpRepositoryContract pendingFollowUpRepository,
    Random? random,
  }) : _timingContract = timingContract,
       _contentResolverContract = contentResolverContract,
       _notificationContract = notificationContract,
       _pendingFollowUpRepository = pendingFollowUpRepository,
       _random = random ?? Random() {
    _stateSubscription = _timingContract.stateStream.listen(_handleFlowState);
    _notificationSubscription = _notificationContract.eventStream.listen(
      _handleNotificationEvent,
    );
  }

  final FakeCallTimingContract _timingContract;
  final ContentResolverContract _contentResolverContract;
  final NotificationContract _notificationContract;
  final PendingFollowUpRepositoryContract _pendingFollowUpRepository;
  final Random _random;
  final StreamController<CallFlowSnapshot> _snapshotController =
      StreamController<CallFlowSnapshot>.broadcast();

  StreamSubscription<FakeCallState>? _stateSubscription;
  StreamSubscription<NotificationEvent>? _notificationSubscription;
  CallFlowSnapshot _currentSnapshot = CallFlowSnapshot.idle();
  String? _activeSessionId;

  @override
  Stream<CallFlowSnapshot> get snapshotStream => _snapshotController.stream;

  @override
  CallFlowSnapshot get currentSnapshot => _currentSnapshot;

  @override
  Future<void> initialize() async {
    await _reconcilePendingFollowUps();
  }

  @override
  Future<void> startFlow(Scenario scenario) async {
    final sessionId = DateTime.now().microsecondsSinceEpoch.toString();
    _activeSessionId = sessionId;
    _currentSnapshot = CallFlowSnapshot(
      flowState: FakeCallState.ringing,
      scenario: scenario,
      currentStage: 1,
      callerName: _contentResolverContract.resolveCallerName(scenario),
      sessionId: sessionId,
      followUpStage: null,
      followUpReadyAt: null,
    );
    _emitSnapshot();
    await _pendingFollowUpRepository.deleteBySession(sessionId);
    await _timingContract.startFlow(sessionId: sessionId, scenario: scenario);
  }

  @override
  Future<void> acceptCurrentStage() {
    return _timingContract.acceptCurrentStage();
  }

  @override
  Future<void> declineCurrentStage() {
    return _timingContract.declineCurrentStage();
  }

  @override
  Future<void> endCurrentStage() {
    return _timingContract.endCurrentStage();
  }

  @override
  Future<void> triggerFollowUpStage() async {
    final sessionId = _currentSnapshot.sessionId;
    final scenario = _timingContract.currentScenario;
    final followUpStage = _currentSnapshot.followUpStage;
    if (sessionId == null || scenario == null || followUpStage == null) {
      return;
    }

    await _timingContract.onNotificationTapped(
      sessionId: sessionId,
      scenario: scenario,
      stage: followUpStage,
    );
  }

  Future<void> _handleNotificationEvent(NotificationEvent event) async {
    final pending = await _findPending(event.sessionId, event.stage);
    switch (event.action) {
      case NotificationAction.tapped:
        if (pending != null) {
          await _pendingFollowUpRepository.savePendingFollowUp(
            pending.copyWith(status: PendingFollowUpStatus.tapped),
          );
          await _pendingFollowUpRepository.deletePendingFollowUp(
            sessionId: event.sessionId,
            stage: event.stage,
          );
        }
        _activeSessionId = event.sessionId;
        await _timingContract.onNotificationTapped(
          sessionId: event.sessionId,
          scenario: event.scenario,
          stage: event.stage,
        );
      case NotificationAction.missed:
        if (pending != null) {
          await _markMissedAndAdvance(pending);
          return;
        }
        await _advanceAfterMissedStage(
          sessionId: event.sessionId,
          scenario: event.scenario,
          stage: event.stage,
        );
    }
  }

  void _handleFlowState(FakeCallState flowState) {
    final scenario =
        _timingContract.currentScenario ?? _currentSnapshot.scenario;
    _activeSessionId ??= _currentSnapshot.sessionId;
    _currentSnapshot = CallFlowSnapshot(
      flowState: flowState,
      scenario: scenario,
      currentStage: _timingContract.currentStage,
      callerName: scenario == null
          ? null
          : _contentResolverContract.resolveCallerName(scenario),
      sessionId: _activeSessionId ?? _currentSnapshot.sessionId,
      followUpStage: _timingContract.pendingFollowUpStage,
      followUpReadyAt: _timingContract.nextStageReadyAt,
    );
    unawaited(_persistSnapshotSideEffects(_currentSnapshot));
    _emitSnapshot();
  }

  Future<void> _persistSnapshotSideEffects(CallFlowSnapshot snapshot) async {
    final sessionId = snapshot.sessionId;
    final scenario = snapshot.scenario;
    final followUpStage = snapshot.followUpStage;
    final followUpReadyAt = snapshot.followUpReadyAt;

    if (sessionId == null) {
      return;
    }

    switch (snapshot.flowState) {
      case FakeCallState.awaitingNextStage:
        if (scenario == null ||
            followUpStage == null ||
            followUpReadyAt == null) {
          return;
        }
        final pending = PendingFollowUp(
          sessionId: sessionId,
          scenario: scenario,
          stage: followUpStage,
          scheduledAtUtc: followUpReadyAt.toUtc(),
          expiresAtUtc: followUpReadyAt.toUtc().add(const Duration(minutes: 2)),
          callerName:
              snapshot.callerName ??
              _contentResolverContract.resolveCallerName(scenario),
          status: PendingFollowUpStatus.pending,
        );
        await _pendingFollowUpRepository.savePendingFollowUp(pending);
      case FakeCallState.completed:
        await _pendingFollowUpRepository.deleteBySession(sessionId);
        _activeSessionId = null;
      case FakeCallState.ringing:
      case FakeCallState.inCall:
      case FakeCallState.callEnded:
      case FakeCallState.idle:
        break;
    }
  }

  Future<void> _reconcilePendingFollowUps() async {
    final now = DateTime.now().toUtc();
    final pending = await _pendingFollowUpRepository.getAllPendingFollowUps();
    for (final followUp in pending) {
      if (followUp.status != PendingFollowUpStatus.pending) {
        continue;
      }
      if (followUp.expiresAtUtc.isBefore(now)) {
        await _markMissedAndAdvance(followUp);
      }
    }
  }

  Future<void> _markMissedAndAdvance(PendingFollowUp followUp) async {
    await _pendingFollowUpRepository.savePendingFollowUp(
      followUp.copyWith(status: PendingFollowUpStatus.missed),
    );
    await _pendingFollowUpRepository.deletePendingFollowUp(
      sessionId: followUp.sessionId,
      stage: followUp.stage,
    );
    await _notificationContract.cancelAll(followUp.sessionId);
    await _advanceAfterMissedStage(
      sessionId: followUp.sessionId,
      scenario: followUp.scenario,
      stage: followUp.stage,
    );
  }

  Future<void> _advanceAfterMissedStage({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  }) async {
    if (stage >= _maxStageFor(scenario)) {
      await _pendingFollowUpRepository.deleteBySession(sessionId);
      if (_currentSnapshot.sessionId == sessionId) {
        _currentSnapshot = CallFlowSnapshot(
          flowState: FakeCallState.completed,
          scenario: scenario,
          currentStage: stage,
          callerName: _contentResolverContract.resolveCallerName(scenario),
          sessionId: sessionId,
          followUpStage: null,
          followUpReadyAt: null,
        );
        _emitSnapshot();
      }
      return;
    }

    final nextStage = stage + 1;
    final delay = _calculateFollowUpDelayForScenario(
      scenario: scenario,
      stage: nextStage,
    );
    final scheduledAt = DateTime.now().toUtc().add(delay);
    final callerName = _contentResolverContract.resolveCallerName(scenario);

    await _notificationContract.scheduleFollowUp(
      sessionId: sessionId,
      scenario: scenario,
      stage: nextStage,
      delay: delay,
      callerName: callerName,
    );
    await _pendingFollowUpRepository.savePendingFollowUp(
      PendingFollowUp(
        sessionId: sessionId,
        scenario: scenario,
        stage: nextStage,
        scheduledAtUtc: scheduledAt,
        expiresAtUtc: scheduledAt.add(const Duration(minutes: 2)),
        callerName: callerName,
        status: PendingFollowUpStatus.pending,
      ),
    );
    if (_currentSnapshot.sessionId == sessionId) {
      _currentSnapshot = CallFlowSnapshot(
        flowState: FakeCallState.awaitingNextStage,
        scenario: scenario,
        currentStage: stage,
        callerName: callerName,
        sessionId: sessionId,
        followUpStage: nextStage,
        followUpReadyAt: scheduledAt.toLocal(),
      );
      _emitSnapshot();
    }
  }

  Future<PendingFollowUp?> _findPending(String sessionId, int stage) async {
    final all = await _pendingFollowUpRepository.getAllPendingFollowUps();
    for (final entry in all) {
      if (entry.sessionId == sessionId && entry.stage == stage) {
        return entry;
      }
    }
    return null;
  }

  int _maxStageFor(Scenario scenario) {
    switch (scenario) {
      case Scenario.presence:
        return 1;
      case Scenario.socialPull:
      case Scenario.exitPressure:
        return 3;
    }
  }

  Duration _calculateFollowUpDelayForScenario({
    required Scenario scenario,
    required int stage,
  }) {
    final (minSeconds, maxSeconds) = switch ((scenario, stage)) {
      (Scenario.socialPull, 2) => (120, 240),
      (Scenario.socialPull, 3) => (240, 480),
      (Scenario.exitPressure, 2) => (45, 90),
      (Scenario.exitPressure, 3) => (90, 180),
      _ => throw ArgumentError.value(
        stage,
        'stage',
        'No follow-up timing defined for ${scenario.name} stage $stage',
      ),
    };

    if (minSeconds == maxSeconds) {
      return Duration(seconds: minSeconds);
    }
    return Duration(
      seconds: minSeconds + _random.nextInt(maxSeconds - minSeconds + 1),
    );
  }

  void _emitSnapshot() {
    if (!_snapshotController.isClosed) {
      _snapshotController.add(_currentSnapshot);
    }
  }

  @override
  Future<void> dispose() async {
    await _stateSubscription?.cancel();
    await _notificationSubscription?.cancel();
    await _timingContract.dispose();
    await _snapshotController.close();
  }
}
