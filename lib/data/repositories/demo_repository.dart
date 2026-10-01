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

  List<StateGeo> _states = [];
  List<DemoUser> _users = [];
  List<Member> _members = [];
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
              // Map legacy communities → polling units for NW demo geo
              final communities = (wm['communities'] as List?) ?? [];
              final pus = (wm['polling_units'] as List?) ?? communities;
              return WardGeo(
                id: wm['id'] as String,
                name: wm['name'] as String,
                code: wm['code'] as String? ?? wm['id'] as String,
                pollingUnits: pus.map((c) {
                  final cm = c as Map<String, dynamic>;
                  return PollingUnitGeo(
                    id: cm['id'] as String,
                    name: cm['name'] as String,
                    code: cm['code'] as String? ?? 'PU01',
                  );
                }).toList(),
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();

    _members = buildSeedMembers(_states);
    // Link userIds after building users
    _users = buildDemoUsers(_states, _members);
    for (var i = 0; i < _users.length; i++) {
      final u = _users[i];
      if (u.memberId != null) {
        final mi = _members.indexWhere((m) => m.id == u.memberId);
        if (mi >= 0) {
          _members[mi] = Member(
            id: _members[mi].id,
            membershipNumber: _members[mi].membershipNumber,
            fullName: _members[mi].fullName,
            gender: _members[mi].gender,
            dateOfBirth: _members[mi].dateOfBirth,
            phone: u.phone,
            email: u.email ?? _members[mi].email,
            occupation: _members[mi].occupation,
            status: _members[mi].status,
            stateId: _members[mi].stateId,
            lgaId: _members[mi].lgaId,
            wardId: _members[mi].wardId,
            pollingUnitId: _members[mi].pollingUnitId,
            isRegisteredVoter: _members[mi].isRegisteredVoter,
            vin: _members[mi].vin,
            voterCardUrl: _members[mi].voterCardUrl,
            photoUrl: _members[mi].photoUrl,
            approvedBy: _members[mi].approvedBy,
            approvedAt: _members[mi].approvedAt,
            rejectionReason: _members[mi].rejectionReason,
            rejectedAt: _members[mi].rejectedAt,
            createdAt: _members[mi].createdAt,
            stateName: _members[mi].stateName,
            lgaName: _members[mi].lgaName,
            wardName: _members[mi].wardName,
            pollingUnitName: _members[mi].pollingUnitName,
            userId: u.id,
          );
        }
      }
    }
    for (final m in _members) {
      if (m.membershipNumber != null) {
        final parts = m.membershipNumber!.split('-');
        if (parts.length >= 4) {
          final code = parts[2];
          final n = int.tryParse(parts[3]) ?? 100000;
          if ((_seqByState[code] ?? 0) < n) _seqByState[code] = n;
        }
      }
    }
    notifyListeners();
  }

  @override
  Future<void> loginAs(DemoUser user) async {
    _current = user;
    notifyListeners();
  }

  @override
  Future<DemoUser> registerMemberAccount({
    required String fullName,
    required String phone,
    String? email,
  }) async {
    final existing = _users.where((u) => u.phone == phone).firstOrNull;
    if (existing != null) {
      _current = existing;
      notifyListeners();
      return existing;
    }
    final user = DemoUser(
      id: _uuid.v4(),
      phone: phone,
      fullName: fullName,
      role: AppRoles.member,
      email: email,
    );
    _users.add(user);
    _current = user;
    notifyListeners();
    return user;
  }

  @override
  Future<void> logout() async {
    _current = null;
    notifyListeners();
  }

  @override
  List<Member> members({MemberFilters filters = const MemberFilters()}) {
    final q = filters.query?.trim().toLowerCase();
    return _members.where((m) {
      if (filters.status != null && m.status != filters.status) return false;
      if (filters.stateId != null && m.stateId != filters.stateId) return false;
      if (filters.lgaId != null && m.lgaId != filters.lgaId) return false;
      if (filters.wardId != null && m.wardId != filters.wardId) return false;
      if (filters.pollingUnitId != null && m.pollingUnitId != filters.pollingUnitId) return false;
      if (filters.gender != null && m.gender != filters.gender) return false;
      if (filters.occupation != null &&
          filters.occupation!.isNotEmpty &&
          !(m.occupation ?? '').toLowerCase().contains(filters.occupation!.toLowerCase())) {
        return false;
      }
      if (filters.ageMin != null && (m.age == null || m.age! < filters.ageMin!)) return false;
      if (filters.ageMax != null && (m.age == null || m.age! > filters.ageMax!)) return false;
      if (filters.registeredFrom != null && m.createdAt.isBefore(filters.registeredFrom!)) return false;
      if (filters.registeredTo != null && m.createdAt.isAfter(filters.registeredTo!.add(const Duration(days: 1)))) {
        return false;
      }
      if (q != null && q.isNotEmpty) {
        final hay = [
          m.fullName,
          m.phone ?? '',
          m.membershipNumber ?? '',
          m.vin ?? '',
          m.email ?? '',
        ].join(' ').toLowerCase();
        if (!hay.contains(q)) return false;
      }
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
  Member? memberForCurrentUser() {
    final u = _current;
    if (u == null || u.role != AppRoles.member) return null;
    if (u.memberId != null) {
      final byId = findMember(u.memberId!);
      if (byId != null) return byId;
    }
    try {
      return _members.firstWhere((m) => m.userId == u.id || m.phone == u.phone);
    } catch (_) {
      return null;
    }
  }

  @override
  MembershipStats stats() {
    final list = _members;
    var lgas = 0, wards = 0, pus = 0;
    for (final s in _states) {
      lgas += s.lgas.length;
      for (final l in s.lgas) {
        wards += l.wards.length;
        for (final w in l.wards) {
          pus += w.pollingUnits.length;
        }
      }
    }
    return MembershipStats(
      total: list.length,
      pending: list.where((m) => m.status == MemberStatus.pending).length,
      approved: list.where((m) => m.status == MemberStatus.approved).length,
      rejected: list.where((m) => m.status == MemberStatus.rejected).length,
      states: _states.length,
      lgas: lgas,
      wards: wards,
      pollingUnits: pus,
    );
  }

  @override
  Future<Member> submitMember(Member member, {bool offline = false}) async {
    final m = Member(
      id: member.id.isEmpty ? _uuid.v4() : member.id,
      membershipNumber: null,
      fullName: member.fullName,
      gender: member.gender,
      dateOfBirth: member.dateOfBirth,
      phone: member.phone ?? _current?.phone,
      email: member.email ?? _current?.email,
      occupation: member.occupation,
      status: MemberStatus.pending,
      stateId: member.stateId,
      lgaId: member.lgaId,
      wardId: member.wardId,
      pollingUnitId: member.pollingUnitId,
      isRegisteredVoter: member.isRegisteredVoter,
      vin: member.vin,
      voterCardUrl: member.voterCardUrl,
      photoUrl: member.photoUrl,
      createdAt: DateTime.now(),
      stateName: member.stateName,
      lgaName: member.lgaName,
      wardName: member.wardName,
      pollingUnitName: member.pollingUnitName,
      userId: _current?.id ?? member.userId,
    );
    final existingIdx = _members.indexWhere((x) => x.userId == m.userId || (m.phone != null && x.phone == m.phone));
    if (existingIdx >= 0) {
      _members[existingIdx] = m;
    } else {
      _members.insert(0, m);
    }
    if (_current != null && _current!.role == AppRoles.member) {
      final ui = _users.indexWhere((u) => u.id == _current!.id);
      if (ui >= 0) {
        _users[ui] = _users[ui].copyWith(memberId: m.id, fullName: m.fullName, email: m.email);
        _current = _users[ui];
      }
    }
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
  Future<Member> updateMemberProfile(
    String memberId, {
    String? fullName,
    String? phone,
    String? email,
    String? occupation,
    String? photoUrl,
  }) async {
    final idx = _members.indexWhere((m) => m.id == memberId);
    if (idx < 0) throw StateError('Member not found');
    final cur = _members[idx];
    final updated = cur.copyWith(
      fullName: fullName,
      phone: phone,
      email: email,
      occupation: occupation,
      photoUrl: photoUrl,
    );
    _members[idx] = updated;
    notifyListeners();
    return updated;
  }

  @override
  Future<void> saveDraft(String key, Map<String, dynamic> data) => hive.saveDraft(key, data);

  @override
  Future<Member> approveMember(String memberId, {String? note}) async {
    final idx = _members.indexWhere((m) => m.id == memberId);
    if (idx < 0) throw StateError('Member not found');
    final cur = _members[idx];
    final st = findState(cur.stateId ?? '');
    final code = nextMembershipNumber(st?.code ?? 'NW');
    final updated = cur.copyWith(
      status: MemberStatus.approved,
      membershipNumber: code,
      approvedBy: _current?.id,
      approvedAt: DateTime.now(),
      clearRejection: true,
    );
    _members[idx] = updated;
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
      rejectedAt: DateTime.now(),
      approvedBy: _current?.id,
    );
    _members[idx] = updated;
    notifyListeners();
    return updated;
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
  List<SyncQueueItem> syncQueue() => hive.syncQueue();

  @override
  List<Map<String, dynamic>> drafts() => hive.allDrafts();

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
  PollingUnitGeo? findPollingUnit(String id) {
    for (final s in _states) {
      for (final l in s.lgas) {
        for (final w in l.wards) {
          for (final p in w.pollingUnits) {
            if (p.id == id) return p;
          }
        }
      }
    }
    return null;
  }

  @override
  String nextMembershipNumber(String stateCode) {
    final n = (_seqByState[stateCode] ?? 100000) + 1;
    _seqByState[stateCode] = n;
    return 'CBM-NW-$stateCode-${n.toString().padLeft(6, '0')}';
  }
}
