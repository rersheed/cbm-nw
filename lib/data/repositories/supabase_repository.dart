import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_config.dart';
import '../local/hive_drafts.dart';
import '../models/models.dart';
import 'demo_repository.dart';
import 'membership_repository.dart';

/// Hybrid: always boots DemoRepository; probes Supabase and labels connection.
class SupabaseRepository extends ChangeNotifier implements MembershipRepository {
  SupabaseRepository({required HiveDraftStore hive}) : _demo = DemoRepository(hive: hive);

  final DemoRepository _demo;
  bool _connected = false;
  String _connectionLabel = 'Demo local';

  bool get isConnected => _connected;
  String get connectionLabel => _connectionLabel;

  SupabaseClient? get _client {
    try {
      if (!SupabaseConfig.isConfigured) return null;
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> initialize() async {
    await _demo.initialize();
    _demo.addListener(notifyListeners);
    await _probe();
    notifyListeners();
  }

  Future<void> _probe() async {
    final client = _client;
    if (client == null) {
      _connected = false;
      _connectionLabel = 'Demo local';
      return;
    }
    try {
      await client.from('states').select('id').limit(1);
      _connected = true;
      _connectionLabel = 'Connected to Supabase';
    } catch (e) {
      debugPrint('Supabase probe failed: $e');
      _connected = false;
      _connectionLabel = 'Demo local';
    }
  }

  @override
  List<StateGeo> get states => _demo.states;
  @override
  List<DemoUser> get demoUsers => _demo.demoUsers;
  @override
  DemoUser? get currentUser => _demo.currentUser;

  @override
  Future<void> loginAs(DemoUser user) => _demo.loginAs(user);
  @override
  Future<DemoUser> registerMemberAccount({
    required String fullName,
    required String phone,
    String? email,
  }) =>
      _demo.registerMemberAccount(fullName: fullName, phone: phone, email: email);
  @override
  Future<void> logout() => _demo.logout();

  @override
  List<Member> members({MemberFilters filters = const MemberFilters()}) =>
      _demo.members(filters: filters);
  @override
  Member? findMember(String id) => _demo.findMember(id);
  @override
  Member? memberForCurrentUser() => _demo.memberForCurrentUser();
  @override
  MembershipStats stats() => _demo.stats();

  @override
  Future<Member> submitMember(Member member, {bool offline = false}) =>
      _demo.submitMember(member, offline: offline || !_connected);
  @override
  Future<Member> updateMemberProfile(
    String memberId, {
    String? fullName,
    String? phone,
    String? email,
    String? occupation,
    String? photoUrl,
  }) =>
      _demo.updateMemberProfile(
        memberId,
        fullName: fullName,
        phone: phone,
        email: email,
        occupation: occupation,
        photoUrl: photoUrl,
      );
  @override
  Future<void> saveDraft(String key, Map<String, dynamic> data) => _demo.saveDraft(key, data);
  @override
  Future<Member> approveMember(String memberId, {String? note}) =>
      _demo.approveMember(memberId, note: note);
  @override
  Future<Member> rejectMember(String memberId, {required String reason}) =>
      _demo.rejectMember(memberId, reason: reason);
  @override
  Future<int> syncPending() => _demo.syncPending();
  @override
  List<SyncQueueItem> syncQueue() => _demo.syncQueue();
  @override
  List<Map<String, dynamic>> drafts() => _demo.drafts();
  @override
  StateGeo? findState(String id) => _demo.findState(id);
  @override
  LgaGeo? findLga(String id) => _demo.findLga(id);
  @override
  WardGeo? findWard(String id) => _demo.findWard(id);
  @override
  PollingUnitGeo? findPollingUnit(String id) => _demo.findPollingUnit(id);
  @override
  String nextMembershipNumber(String stateCode) => _demo.nextMembershipNumber(stateCode);
}
