import 'dart:async';
import 'dart:math';

import '../contracts/audio_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../models/playable_audio_source.dart';

class FakeCallTimingService implements FakeCallTimingContract {
  final NotificationContract notificationContract;
  final AudioPlaybackContract audioPlaybackContract;
  final AudioLanguagePackManagerContract audioLanguagePackManagerContract;
  final ContentResolverContract contentResolverContract;
  final String Function() localeTagProvider;

  final _stateController = StreamController<FakeCallState>.broadcast();
  final Random _random;

  String? _sessionId;
  Scenario? _scenario;
  FakeCallState _currentState = FakeCallState.idle;
  int _currentStage = 0;
  int? _pendingFollowUpStage;
  DateTime? _nextStageReadyAt;
  int _playbackSequence = 0;

  Timer? _missedTimer;

  FakeCallTimingService({
    required this.notificationContract,
    required this.audioPlaybackContract,
    required this.audioLanguagePackManagerContract,
    required this.contentResolverContract,
    required this.localeTagProvider,
    Random? random,
  }) : _random = random ?? Random();

  @override
  Stream<FakeCallState> get stateStream => _stateController.stream;

  @override
  FakeCallState get currentState => _currentState;

  @override
  Scenario? get currentScenario => _scenario;

  @override
  int get currentStage => _currentStage;

  @override
  int? get pendingFollowUpStage => _pendingFollowUpStage;

  @override
  DateTime? get nextStageReadyAt => _nextStageReadyAt;

  void _setState(FakeCallState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  void _clearPendingFollowUp() {
    _pendingFollowUpStage = null;
    _nextStageReadyAt = null;
  }

  void _cancelMissedTimer() {
    _missedTimer?.cancel();
    _missedTimer = null;
  }

  void _scheduleMissedTimer(String sessionId, int stage) {
    _cancelMissedTimer();
    _missedTimer = Timer(const Duration(minutes: 2), () {
      if (_sessionId != sessionId || _currentStage != stage) return;
      final scenario = _scenario;
      if (scenario == null) return;
      handleMissedStage(sessionId: sessionId, scenario: scenario, stage: stage);
    });
  }

  @override
  Future<void> startFlow({
    required String sessionId,
    required Scenario scenario,
    FakeCallTrack track = FakeCallTrack.active,
  }) async {
    await notificationContract.cancelAll(sessionId);
    await audioPlaybackContract.stop();

    _sessionId = sessionId;
    _scenario = scenario;
    _currentStage = 1;
    _clearPendingFollowUp();
    _setState(FakeCallState.ringing);
    await _startRingtoneLoop();

    switch (track) {
      case FakeCallTrack.active:
      case FakeCallTrack.background:
        break;
    }

    // Stage 1 is immediate; start missed timer for tap/answer window.
    _scheduleMissedTimer(sessionId, 1);
  }

  @override
  Future<void> onNotificationTapped({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  }) async {
    if (stage < 1 || stage > _maxStageFor(scenario)) {
      throw ArgumentError.value(
        stage,
        'stage',
        'must be 1..${_maxStageFor(scenario)} for ${scenario.name}',
      );
    }

    _sessionId = sessionId;
    _scenario = scenario;
    _currentStage = stage;
    _clearPendingFollowUp();
    _setState(FakeCallState.ringing);
    await _startRingtoneLoop();
    _scheduleMissedTimer(sessionId, stage);
  }

  @override
  Future<void> acceptCurrentStage() async {
    if (_currentState != FakeCallState.ringing) {
      throw StateError(
        'Cannot accept unless ringing. Current state: $_currentState',
      );
    }

    _cancelMissedTimer();
    await audioPlaybackContract.stop();
    _setState(FakeCallState.inCall);
    final playbackSequence = ++_playbackSequence;

    final scenario = _scenario;
    if (scenario == null) {
      throw StateError('Scenario is not set');
    }

    final resolvedAudio = await audioLanguagePackManagerContract
        .resolvePlayableAudio(scenario: scenario, stage: _currentStage);

    await audioPlaybackContract.playScenarioClip(
      scenario: scenario,
      stage: _currentStage,
      source: resolvedAudio.source,
    );

    if (_playbackSequence != playbackSequence ||
        _currentState != FakeCallState.inCall) {
      return;
    }

    _setState(FakeCallState.callEnded);
    await _onStageResolved();
  }

  @override
  Future<void> declineCurrentStage() async {
    if (_currentState != FakeCallState.ringing) {
      throw StateError(
        'Cannot decline unless ringing. Current state: $_currentState',
      );
    }

    _cancelMissedTimer();
    await audioPlaybackContract.stop();
    await _completeFlowAfterDecline();
  }

  @override
  Future<void> endCurrentStage() async {
    if (_currentState != FakeCallState.inCall) {
      throw StateError(
        'Cannot end unless inCall. Current state: $_currentState',
      );
    }

    _playbackSequence++;
    await audioPlaybackContract.stop();
    _setState(FakeCallState.callEnded);
    await _onStageResolved();
  }

  @override
  Future<void> handleMissedStage({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  }) async {
    if (_sessionId != sessionId ||
        _scenario != scenario ||
        _currentStage != stage) {
      return;
    }

    if (_currentState != FakeCallState.ringing) {
      return;
    }

    _cancelMissedTimer();
    await audioPlaybackContract.stop();
    await _onStageResolved();
  }

  Future<void> _startRingtoneLoop() {
    return audioPlaybackContract.playRingtoneLoop(
      source: BundledAudioSource(
        assetPath: contentResolverContract.resolveBundledRingtoneAssetPath(),
      ),
    );
  }

  Future<void> _onStageResolved() async {
    final sessionId = _sessionId;
    final scenario = _scenario;
    if (sessionId == null || scenario == null) {
      throw StateError('Flow state is incomplete');
    }

    if (_currentStage >= _maxStageFor(scenario)) {
      _clearPendingFollowUp();
      _setState(FakeCallState.completed);
      await notificationContract.cancelAll(sessionId);
      return;
    }

    final nextStage = _currentStage + 1;
    final delay = _calculateFollowUpDelayForScenario(
      scenario: scenario,
      stage: nextStage,
    );
    _pendingFollowUpStage = nextStage;
    _nextStageReadyAt = DateTime.now().add(delay);
    _setState(FakeCallState.awaitingNextStage);
  }

  Future<void> _completeFlowAfterDecline() async {
    final sessionId = _sessionId;
    if (sessionId == null) {
      throw StateError('Flow state is incomplete');
    }

    _clearPendingFollowUp();
    _setState(FakeCallState.completed);
    await notificationContract.cancelAll(sessionId);
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
    final range = _followUpDelayRange(scenario: scenario, stage: stage);
    final minSeconds = range.$1;
    final maxSeconds = range.$2;
    if (minSeconds == maxSeconds) {
      return Duration(seconds: minSeconds);
    }
    return Duration(
      seconds: minSeconds + _random.nextInt(maxSeconds - minSeconds + 1),
    );
  }

  (int, int) _followUpDelayRange({
    required Scenario scenario,
    required int stage,
  }) {
    switch (scenario) {
      case Scenario.presence:
        throw StateError('Presence does not schedule follow-up stages');
      case Scenario.socialPull:
        if (stage == 2) return (120, 240);
        if (stage == 3) return (240, 480);
        break;
      case Scenario.exitPressure:
        if (stage == 2) return (45, 90);
        if (stage == 3) return (90, 180);
        break;
    }

    throw ArgumentError.value(
      stage,
      'stage',
      'No follow-up timing defined for ${scenario.name} stage $stage',
    );
  }

  @override
  Future<void> dispose() async {
    _cancelMissedTimer();
    _clearPendingFollowUp();
    await _stateController.close();
  }
}
