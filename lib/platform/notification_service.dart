import 'dart:async';

import 'package:flutter/services.dart';

import '../contracts/call_flow_contracts.dart';

class NotificationService implements NotificationContract {
  NotificationService({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methodChannel =
           methodChannel ??
           const MethodChannel('with_you/notifications/methods'),
       _eventChannel =
           eventChannel ?? const EventChannel('with_you/notifications/events') {
    _eventController = StreamController<NotificationEvent>.broadcast(
      onListen: _flushPendingEvents,
    );
  }

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  late final StreamController<NotificationEvent> _eventController;
  final List<NotificationEvent> _pendingEvents = <NotificationEvent>[];

  StreamSubscription<dynamic>? _nativeEventSubscription;
  bool _initialized = false;

  @override
  Stream<NotificationEvent> get eventStream => _eventController.stream;

  @override
  Future<bool> initialize() async {
    await _ensureEventStreamBound();
    return await _methodChannel.invokeMethod<bool>('initialize') ?? false;
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureEventStreamBound();
    return await _methodChannel.invokeMethod<bool>('requestPermission') ??
        false;
  }

  @override
  Future<void> openSystemSettings() async {
    await _methodChannel.invokeMethod<void>('openSystemSettings');
  }

  @override
  Future<void> scheduleFollowUp({
    required String sessionId,
    required Scenario scenario,
    required int stage,
    required Duration delay,
    required String title,
    required String body,
  }) async {
    await _methodChannel
        .invokeMethod<void>('scheduleFollowUp', <String, Object?>{
          'sessionId': sessionId,
          'scenario': scenario.name,
          'stage': stage,
          'delaySeconds': delay.inSeconds,
          'title': title,
          'body': body,
        });
  }

  @override
  Future<void> cancelAll(String sessionId) async {
    await _methodChannel.invokeMethod<void>('cancelAll', <String, Object?>{
      'sessionId': sessionId,
    });
  }

  void _handleNativeEvent(dynamic rawEvent) {
    if (rawEvent is! Map<Object?, Object?>) {
      return;
    }

    final event = NotificationEvent(
      sessionId: rawEvent['sessionId']! as String,
      scenario: Scenario.values.byName(rawEvent['scenario']! as String),
      stage: rawEvent['stage']! as int,
      action: NotificationAction.values.byName(rawEvent['action']! as String),
    );
    if (_eventController.hasListener && !_eventController.isClosed) {
      _eventController.add(event);
      return;
    }
    _pendingEvents.add(event);
  }

  void _flushPendingEvents() {
    if (!_eventController.hasListener || _eventController.isClosed) {
      return;
    }
    for (final event in _pendingEvents) {
      _eventController.add(event);
    }
    _pendingEvents.clear();
  }

  Future<void> _ensureEventStreamBound() async {
    if (_initialized) {
      return;
    }

    _nativeEventSubscription = _eventChannel.receiveBroadcastStream().listen(
      _handleNativeEvent,
    );
    _initialized = true;
  }

  Future<void> dispose() async {
    await _nativeEventSubscription?.cancel();
    await _eventController.close();
  }
}
