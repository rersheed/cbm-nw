import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../demo/demo_seed.dart';
import '../local/hive_drafts.dart';
import '../models/models.dart';
import 'membership_repository.dart';

class DemoRepository extends ChangeNotifier implements MembershipRepository {
  DemoRepository({required this.hive});

  final HiveDraftStore hive;
  final _uuid = const Uuid();
  final _listeners = <void Function()>[];

  List<StateGeo> _states = [];
  List<DemoUser> _users = [];
  List<Member> _members = [];
  final List<ApprovalRecord> _approvals = [];
  final List<AppMessage> _messages = [];
  final List<AuditEntry> _audit = [];
  DemoUser? _current;
  final Map<String, int> _seqByState = {};

  @override
  List<StateGeo> get states => _states;
  @override
  List<DemoUser> get demoUsers => _users;
  @override
  DemoUser? get currentUser => _current;

  @override
  Future<void> initialize() async {
    await hive.init();
    final raw = await rootBundle.loadString(AppConstants.geographyAsset);
    final list = jsonDecode(raw) as List;
    _states = list.map((s) {
      final sm = s as Map<String, dynamic>;
      return StateGeo(
        id: sm['id'] as String,
        name: sm['name'] as String,
        code: sm['code'] as String,
        lgas: ((sm['lgas'] as List?) ?? []).map((l) {
          final lm = l as Map<String, dynamic>;
          return LgaGeo(
            id: lm['id'] as String,
            name: lm['name'] as String,
            code: lm['code'] as String? ?? lm['id'] as String,
            wards: ((lm['wards'] as List?) ?? []).map((w) {
              final wm = w as Map<String, dynamic>;
              return WardGeo(
                id: wm['id'] as String,
                name: wm['name'] as String,
                code: wm['code'] as String? ?? wm['id'] as String,
                communities: ((wm['communities'] as List?) ?? []).map((c) {
                  final cm = c as Map<String, dynamic>;
                  return CommunityGeo(
                    id: cm['id'] as String,
                    name: cm['name'] as String,
                    code: cm['code'] as String? ?? 'C01',
                  );
                }).toList(),
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();

    _users = buildDemoUsers(_states);
    _members = buildSeedMembers(_states, _users);
    for (final m in _members) {
      if (m.memberCode != null) {
        final parts = m.memberCode!.split('-');
        if (parts.length >= 4) {
          final code = parts[2];
          final n = int.tryParse(parts[3]) ?? 10000;
          _seqByState[code] = (_seqByState[code] ?? 10000).clamp(0, n) < n ? n : (_seqByState[code] ?? n);
          if ((_seqByState[code] ?? 0) < n) _seqByState[code] = n;
        }
      }
    }
    notifyListeners();
  }

  @override
  Future<void> loginAs(DemoUser user) async {
    _current = user;
    _audit.add(AuditEntry(
      id: _uuid.v4(),
      actorId: user.id,
      action: 'login',
      entity: 'profile',
      entityId: user.id,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  @override
  Future<void> logout() async {
    _current = null;
    notifyListeners();
  }

  @override
  List<Member> members({
    String? status,
    String? registeredBy,
    String? stateId,
    String? lgaId,
    String? wardId,
    String? category,
  }) {
    return _members.where((m) {
      if (status != null && m.status != status) return false;
      if (registeredBy != null && m.registeredBy != registeredBy) return false;
      if (stateId != null && m.stateId != stateId) return false;
      if (lgaId != null && m.lgaId != lgaId) return false;
      if (wardId != null && m.wardId != wardId) return false;
      if (category != null && m.category != category) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Member? findMember(String id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  MembershipStats stats({String? stateId, String? lgaId, String? wardId, String? registeredBy}) {
    final list = members(stateId: stateId, lgaId: lgaId, wardId: wardId, registeredBy: registeredBy);
    return MembershipStats(
      registered: list.length,
      pending: list.where((m) => m.status == MemberStatus.pending).length,
      approved: list.where((m) => m.status == MemberStatus.approved).length,
      rejected: list.where((m) => m.status == MemberStatus.rejected).length,
      agents: agents(stateId: stateId, lgaId: lgaId, wardId: wardId).length,
      states: _states.length,
      lgas: stateId == null
          ? _states.fold<int>(0, (a, s) => a + s.lgas.length)
          : (findState(stateId)?.lgas.length ?? 0),
      wards: lgaId != null
          ? (findLga(lgaId)?.wards.length ?? 0)
          : stateId != null
              ? (findState(stateId)?.lgas.fold<int>(0, (a, l) => a + l.wards.length) ?? 0)
              : _states.fold<int>(0, (a, s) => a + s.lgas.fold<int>(0, (b, l) => b + l.wards.length)),
    );
  }

  @override
  List<DemoUser> agents({String? stateId, String? lgaId, String? wardId}) {
    return _users.where((u) {
      if (u.role != AppRoles.registrationAgent) return false;
      if (stateId != null && u.stateId != stateId) return false;
      if (lgaId != null && u.lgaId != lgaId) return false;
      if (wardId != null && u.wardId != wardId) return false;
      return true;
    }).toList();
  }

  @override
  List<ApprovalRecord> approvalsFor(String memberId) =>
      _approvals.where((a) => a.memberId == memberId).toList();

  @override
  List<AppMessage> messages() => List.unmodifiable(_messages.reversed);

  @override
  List<AuditEntry> auditLog() => List.unmodifiable(_audit.reversed);

  @override
  List<SyncQueueItem> syncQueue() => hive.syncQueue();

  @override
  List<Map<String, dynamic>> drafts() => hive.allDrafts();

  @override
  Future<Member> submitMember(Member member, {bool offline = false}) async {
    final m = Member(
      id: member.id.isEmpty ? _uuid.v4() : member.id,
      memberCode: member.memberCode,
      fullName: member.fullName,
      gender: member.gender,
      dateOfBirth: member.dateOfBirth,
      phone: member.phone,
      occupation: member.occupation,
      education: member.education,
      category: member.category,
      status: MemberStatus.pending,
      stateId: member.stateId,
      lgaId: member.lgaId,
      wardId: member.wardId,
      communityId: member.communityId,
      photoUrl: member.photoUrl,
      idDocumentUrl: member.idDocumentUrl,
      registeredBy: _current?.id ?? member.registeredBy,
      createdAt: DateTime.now(),
      stateName: member.stateName,
      lgaName: member.lgaName,
      wardName: member.wardName,
      communityName: member.communityName,
    );
    _members.insert(0, m);
    _approvals.add(ApprovalRecord(
      id: _uuid.v4(),
      memberId: m.id,
      actorId: _current?.id,
      action: 'submitted',
      notes: 'Registration submitted',
      createdAt: DateTime.now(),
    ));
    _audit.add(AuditEntry(
      id: _uuid.v4(),
      actorId: _current?.id,
      action: 'member_submit',
      entity: 'member',
      entityId: m.id,
      createdAt: DateTime.now(),
    ));
    if (offline) {
      await hive.enqueue(SyncQueueItem(
        id: _uuid.v4(),
        type: 'member',
        payload: m.toMap(),
        enqueuedAt: DateTime.now(),
      ));
    }
    notifyListeners();
    return m;
  }

  @override
  Future<void> saveDraft(String key, Map<String, dynamic> data) => hive.saveDraft(key, data);

  @override
  Future<Member> approveMember(String memberId, {String? note}) async {
    final idx = _members.indexWhere((m) => m.id == memberId);
    if (idx < 0) throw StateError('Member not found');
    final cur = _members[idx];
    final st = findState(cur.stateId ?? '');
    final code = nextMemberCode(st?.code ?? 'NW');
    final updated = cur.copyWith(
      status: MemberStatus.approved,
      memberCode: code,
      approvedBy: _current?.id,
      approvedAt: DateTime.now(),
    );
    _members[idx] = updated;
    _approvals.add(ApprovalRecord(
      id: _uuid.v4(),
      memberId: memberId,
      actorId: _current?.id,
      action: 'approved',
      notes: note,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
    return updated;
  }

  @override
  Future<Member> rejectMember(String memberId, {required String reason}) async {
    final idx = _members.indexWhere((m) => m.id == memberId);
    if (idx < 0) throw StateError('Member not found');
    final updated = _members[idx].copyWith(
      status: MemberStatus.rejected,
      rejectionReason: reason,
      approvedBy: _current?.id,
      approvedAt: DateTime.now(),
    );
    _members[idx] = updated;
    _approvals.add(ApprovalRecord(
      id: _uuid.v4(),
      memberId: memberId,
      actorId: _current?.id,
      action: 'rejected',
      notes: reason,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
    return updated;
  }

  @override
  Future<AppMessage> sendMessage({
    required String audienceScope,
    String? audienceRef,
    required String body,
  }) async {
    final msg = AppMessage(
      id: _uuid.v4(),
      audienceScope: audienceScope,
      audienceRef: audienceRef,
      body: body,
      sentBy: _current?.id,
      createdAt: DateTime.now(),
    );
    _messages.add(msg);
    notifyListeners();
    return msg;
  }

  @override
  Future<int> syncPending() async {
    final q = hive.syncQueue();
    for (final item in q) {
      await hive.removeFromQueue(item.id);
    }
    notifyListeners();
    return q.length;
  }

  @override
  StateGeo? findState(String id) {
    try {
      return _states.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  LgaGeo? findLga(String id) {
    for (final s in _states) {
      for (final l in s.lgas) {
        if (l.id == id) return l;
      }
    }
    return null;
  }

  @override
  WardGeo? findWard(String id) {
    for (final s in _states) {
      for (final l in s.lgas) {
        for (final w in l.wards) {
          if (w.id == id) return w;
        }
      }
    }
    return null;
  }

  @override
  ({StateGeo state, LgaGeo lga, WardGeo ward, CommunityGeo? community})? resolveLocation({
    String? stateId,
    String? lgaId,
    String? wardId,
    String? communityId,
  }) {
    if (stateId == null || lgaId == null || wardId == null) return null;
    final state = findState(stateId);
    final lga = findLga(lgaId);
    final ward = findWard(wardId);
    if (state == null || lga == null || ward == null) return null;
    CommunityGeo? community;
    if (communityId != null) {
      try {
        community = ward.communities.firstWhere((c) => c.id == communityId);
      } catch (_) {}
    }
    return (state: state, lga: lga, ward: ward, community: community);
  }

  @override
  String nextMemberCode(String stateCode) {
    final n = (_seqByState[stateCode] ?? 10000) + 1;
    _seqByState[stateCode] = n;
    return 'CBM-NW-$stateCode-${n.toString().padLeft(5, '0')}';
  }

  @override
  void addListener(void Function() listener) {
    _listeners.add(listener);
    super.addListener(listener);
  }

  @override
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
    super.removeListener(listener);
  }
}
