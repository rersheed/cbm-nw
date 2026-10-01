import '../models/models.dart';

abstract class MembershipRepository {
  Future<void> initialize();

  List<StateGeo> get states;
  List<DemoUser> get demoUsers;
  DemoUser? get currentUser;

  Future<void> loginAs(DemoUser user);
  Future<void> logout();

  List<Member> members({
    String? status,
    String? registeredBy,
    String? stateId,
    String? lgaId,
    String? wardId,
    String? category,
  });

  Member? findMember(String id);
  MembershipStats stats({String? stateId, String? lgaId, String? wardId, String? registeredBy});

  List<DemoUser> agents({String? stateId, String? lgaId, String? wardId});
  List<ApprovalRecord> approvalsFor(String memberId);
  List<AppMessage> messages();
  List<AuditEntry> auditLog();
  List<SyncQueueItem> syncQueue();
  List<Map<String, dynamic>> drafts();

  Future<Member> submitMember(Member member, {bool offline = false});
  Future<void> saveDraft(String key, Map<String, dynamic> data);
  Future<Member> approveMember(String memberId, {String? note});
  Future<Member> rejectMember(String memberId, {required String reason});
  Future<AppMessage> sendMessage({
    required String audienceScope,
    String? audienceRef,
    required String body,
  });

  Future<int> syncPending();

  StateGeo? findState(String id);
  LgaGeo? findLga(String id);
  WardGeo? findWard(String id);
  ({StateGeo state, LgaGeo lga, WardGeo ward, CommunityGeo? community})? resolveLocation({
    String? stateId,
    String? lgaId,
    String? wardId,
    String? communityId,
  });

  String nextMemberCode(String stateCode);

  void addListener(void Function() listener);
  void removeListener(void Function() listener);
}
