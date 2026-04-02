import '../../models/pending_follow_up.dart';

abstract class PendingFollowUpRepositoryContract {
  Future<List<PendingFollowUp>> getAllPendingFollowUps();

  Future<void> savePendingFollowUp(PendingFollowUp pendingFollowUp);

  Future<void> deletePendingFollowUp({
    required String sessionId,
    required int stage,
  });

  Future<void> deleteBySession(String sessionId);
}
