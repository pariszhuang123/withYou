import 'dart:convert';
import 'dart:io';

import '../contracts/app_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../models/pending_follow_up.dart';

class PendingFollowUpRepository implements PendingFollowUpRepositoryContract {
  PendingFollowUpRepository({required DirectoryProvider directoryProvider})
    : _directoryProvider = directoryProvider;

  final DirectoryProvider _directoryProvider;

  static const String _fileName = 'pending_follow_ups.json';

  @override
  Future<List<PendingFollowUp>> getAllPendingFollowUps() async {
    final file = await _file();
    if (!await file.exists()) {
      return const <PendingFollowUp>[];
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return const <PendingFollowUp>[];
    }

    final decoded = jsonDecode(raw) as List<Object?>;
    return decoded
        .map(
          (entry) => PendingFollowUp.fromJson(
            Map<String, Object?>.from(entry! as Map),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> savePendingFollowUp(PendingFollowUp pendingFollowUp) async {
    final all = (await getAllPendingFollowUps()).toList(growable: true);
    final index = all.indexWhere(
      (entry) =>
          entry.sessionId == pendingFollowUp.sessionId &&
          entry.stage == pendingFollowUp.stage,
    );
    if (index == -1) {
      all.add(pendingFollowUp);
    } else {
      all[index] = pendingFollowUp;
    }
    await _writeAll(all);
  }

  @override
  Future<void> deletePendingFollowUp({
    required String sessionId,
    required int stage,
  }) async {
    final all = (await getAllPendingFollowUps())
        .where(
          (entry) => !(entry.sessionId == sessionId && entry.stage == stage),
        )
        .toList(growable: false);
    await _writeAll(all);
  }

  @override
  Future<void> deleteBySession(String sessionId) async {
    final all = (await getAllPendingFollowUps())
        .where((entry) => entry.sessionId != sessionId)
        .toList(growable: false);
    await _writeAll(all);
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    await directory.create(recursive: true);
    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }

  Future<void> _writeAll(List<PendingFollowUp> records) async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode(
        records.map((entry) => entry.toJson()).toList(growable: false),
      ),
    );
  }
}
