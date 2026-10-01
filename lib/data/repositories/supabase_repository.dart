import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_config.dart';
import '../local/hive_drafts.dart';
import '../models/models.dart';
import 'demo_repository.dart';
import 'membership_repository.dart';

/// Hybrid: always boots DemoRepository; probes Supabase and syncs when connected.
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
      await _bestEffortUpsertProfiles();
    } catch (e) {
      debugPrint('Supabase probe failed: $e');
      _connected = false;
      _connectionLabel = 'Demo local';
    }
  }

  Future<void> _bestEffortUpsertProfiles() async {
    final client = _client;
    if (client == null || !_connected) return;
    try {
      // Local demo geo uses string ids; remote uses UUIDs — keep profiles local-only for demo.
      // Probe already confirmed connectivity.
    } catch (e) {
      debugPrint('profile upsert skipped: $e');
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
  Future<void> logout() => _demo.logout();

  @override
  List<Member> members({
    String? status,
    String? registeredBy,
    String? stateId,
    String? lgaId,
    String? wardId,
    String? category,
  }) =>
      _demo.members(
        status: status,
        registeredBy: registeredBy,
        stateId: stateId,
        lgaId: lgaId,
        wardId: wardId,
        category: category,
      );

  @override
  Member? findMember(String id) => _demo.findMember(id);

  @override
  MembershipStats stats({String? stateId, String? lgaId, String? wardId, String? registeredBy}) =>
      _demo.stats(stateId: stateId, lgaId: lgaId, wardId: wardId, registeredBy: registeredBy);

  @override
  List<DemoUser> agents({String? stateId, String? lgaId, String? wardId}) =>
      _demo.agents(stateId: stateId, lgaId: lgaId, wardId: wardId);

  @override
  List<ApprovalRecord> approvalsFor(String memberId) => _demo.approvalsFor(memberId);
  @override
  List<AppMessage> messages() => _demo.messages();
  @override
  List<AuditEntry> auditLog() => _demo.auditLog();
  @override
  List<SyncQueueItem> syncQueue() => _demo.syncQueue();
  @override
  List<Map<String, dynamic>> drafts() => _demo.drafts();

  @override
  Future<Member> submitMember(Member member, {bool offline = false}) async {
    final m = await _demo.submitMember(member, offline: offline || !_connected);
    if (_connected && !offline) {
      try {
        // Best-effort remote write; geo IDs differ (local vs UUID) so skip FK columns.
        await _client!.from('messages').insert({
          'audience_scope': 'audit',
          'body': 'Local member submitted: ${m.fullName} (${m.id})',
          'sent_by': null,
        });
      } catch (e) {
        debugPrint('remote member note failed: $e');
      }
    }
    return m;
  }

  @override
  Future<void> saveDraft(String key, Map<String, dynamic> data) => _demo.saveDraft(key, data);

  @override
  Future<Member> approveMember(String memberId, {String? note}) =>
      _demo.approveMember(memberId, note: note);

  @override
  Future<Member> rejectMember(String memberId, {required String reason}) =>
      _demo.rejectMember(memberId, reason: reason);

  @override
  Future<AppMessage> sendMessage({
    required String audienceScope,
    String? audienceRef,
    required String body,
  }) async {
    final msg = await _demo.sendMessage(
      audienceScope: audienceScope,
      audienceRef: audienceRef,
      body: body,
    );
    if (_connected) {
      try {
        await _client!.from('messages').insert({
          'audience_scope': audienceScope,
          'audience_ref': audienceRef,
          'body': body,
        });
      } catch (e) {
        debugPrint('remote message failed: $e');
      }
    }
    return msg;
  }

  @override
  Future<int> syncPending() => _demo.syncPending();

  @override
  StateGeo? findState(String id) => _demo.findState(id);
  @override
  LgaGeo? findLga(String id) => _demo.findLga(id);
  @override
  WardGeo? findWard(String id) => _demo.findWard(id);

  @override
  ({StateGeo state, LgaGeo lga, WardGeo ward, CommunityGeo? community})? resolveLocation({
    String? stateId,
    String? lgaId,
    String? wardId,
    String? communityId,
  }) =>
      _demo.resolveLocation(
        stateId: stateId,
        lgaId: lgaId,
        wardId: wardId,
        communityId: communityId,
      );

  @override
  String nextMemberCode(String stateCode) => _demo.nextMemberCode(stateCode);

  @override
  void addListener(void Function() listener) {
    super.addListener(listener);
  }

  @override
  void removeListener(void Function() listener) {
    super.removeListener(listener);
  }
}
