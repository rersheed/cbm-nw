import '../models/models.dart';

abstract class MembershipRepository {
  Future<void> initialize();

  List<StateGeo> get states;
  List<DemoUser> get demoUsers;
  DemoUser? get currentUser;

  Future<void> loginAs(DemoUser user);
  Future<DemoUser> registerMemberAccount({
    required String fullName,
    required String phone,
    String? email,
  });
  Future<void> logout();

  List<Member> members({MemberFilters filters = const MemberFilters()});
  Member? findMember(String id);
  Member? memberForCurrentUser();
  MembershipStats stats();

  Future<Member> submitMember(Member member, {bool offline = false});
  Future<Member> updateMemberProfile(String memberId, {
    String? fullName,
    String? phone,
    String? email,
    String? occupation,
    String? photoUrl,
  });
  Future<void> saveDraft(String key, Map<String, dynamic> data);
  Future<Member> approveMember(String memberId, {String? note});
  Future<Member> rejectMember(String memberId, {required String reason});

  Future<int> syncPending();
  List<SyncQueueItem> syncQueue();
  List<Map<String, dynamic>> drafts();

  StateGeo? findState(String id);
  LgaGeo? findLga(String id);
  WardGeo? findWard(String id);
  PollingUnitGeo? findPollingUnit(String id);

  String nextMembershipNumber(String stateCode);

  void addListener(void Function() listener);
  void removeListener(void Function() listener);
}
