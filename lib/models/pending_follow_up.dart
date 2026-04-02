import '../contracts/call_flow_contracts.dart';

enum PendingFollowUpStatus { pending, tapped, missed, cancelled }

class PendingFollowUp {
  const PendingFollowUp({
    required this.sessionId,
    required this.scenario,
    required this.stage,
    required this.scheduledAtUtc,
    required this.expiresAtUtc,
    required this.callerName,
    required this.status,
  });

  final String sessionId;
  final Scenario scenario;
  final int stage;
  final DateTime scheduledAtUtc;
  final DateTime expiresAtUtc;
  final String callerName;
  final PendingFollowUpStatus status;

  PendingFollowUp copyWith({
    DateTime? scheduledAtUtc,
    DateTime? expiresAtUtc,
    String? callerName,
    PendingFollowUpStatus? status,
  }) {
    return PendingFollowUp(
      sessionId: sessionId,
      scenario: scenario,
      stage: stage,
      scheduledAtUtc: scheduledAtUtc ?? this.scheduledAtUtc,
      expiresAtUtc: expiresAtUtc ?? this.expiresAtUtc,
      callerName: callerName ?? this.callerName,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'sessionId': sessionId,
      'scenario': scenario.name,
      'stage': stage,
      'scheduledAtUtc': scheduledAtUtc.toUtc().toIso8601String(),
      'expiresAtUtc': expiresAtUtc.toUtc().toIso8601String(),
      'callerName': callerName,
      'status': status.name,
    };
  }

  factory PendingFollowUp.fromJson(Map<String, Object?> json) {
    return PendingFollowUp(
      sessionId: json['sessionId']! as String,
      scenario: Scenario.values.byName(json['scenario']! as String),
      stage: json['stage']! as int,
      scheduledAtUtc: DateTime.parse(json['scheduledAtUtc']! as String).toUtc(),
      expiresAtUtc: DateTime.parse(json['expiresAtUtc']! as String).toUtc(),
      callerName: json['callerName']! as String,
      status: PendingFollowUpStatus.values.byName(json['status']! as String),
    );
  }
}
