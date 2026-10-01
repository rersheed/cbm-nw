import 'package:equatable/equatable.dart';

class StateGeo extends Equatable {
  final String id;
  final String name;
  final String code;
  final List<LgaGeo> lgas;
  const StateGeo({required this.id, required this.name, required this.code, required this.lgas});
  @override
  List<Object?> get props => [id];
}

class LgaGeo extends Equatable {
  final String id;
  final String name;
  final String code;
  final List<WardGeo> wards;
  const LgaGeo({required this.id, required this.name, required this.code, required this.wards});
  @override
  List<Object?> get props => [id];
}

class WardGeo extends Equatable {
  final String id;
  final String name;
  final String code;
  final List<PollingUnitGeo> pollingUnits;
  const WardGeo({
    required this.id,
    required this.name,
    required this.code,
    required this.pollingUnits,
  });
  @override
  List<Object?> get props => [id];
}

class PollingUnitGeo extends Equatable {
  final String id;
  final String name;
  final String code;
  const PollingUnitGeo({required this.id, required this.name, required this.code});
  @override
  List<Object?> get props => [id];
}

class DemoUser extends Equatable {
  final String id;
  final String phone;
  final String fullName;
  final String role;
  final String? email;
  final String? memberId;
  const DemoUser({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.role,
    this.email,
    this.memberId,
  });
  DemoUser copyWith({String? fullName, String? email, String? memberId}) => DemoUser(
        id: id,
        phone: phone,
        fullName: fullName ?? this.fullName,
        role: role,
        email: email ?? this.email,
        memberId: memberId ?? this.memberId,
      );
  @override
  List<Object?> get props => [id];
}

class Member extends Equatable {
  final String id;
  final String? membershipNumber;
  final String fullName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? phone;
  final String? email;
  final String? occupation;
  final String status;
  final String? stateId;
  final String? lgaId;
  final String? wardId;
  final String? pollingUnitId;
  final bool isRegisteredVoter;
  final String? vin;
  final String? voterCardUrl;
  final String? photoUrl;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime? rejectedAt;
  final DateTime createdAt;
  final String? stateName;
  final String? lgaName;
  final String? wardName;
  final String? pollingUnitName;
  final String? userId;

  const Member({
    required this.id,
    this.membershipNumber,
    required this.fullName,
    this.gender,
    this.dateOfBirth,
    this.phone,
    this.email,
    this.occupation,
    required this.status,
    this.stateId,
    this.lgaId,
    this.wardId,
    this.pollingUnitId,
    this.isRegisteredVoter = false,
    this.vin,
    this.voterCardUrl,
    this.photoUrl,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.rejectedAt,
    required this.createdAt,
    this.stateName,
    this.lgaName,
    this.wardName,
    this.pollingUnitName,
    this.userId,
  });

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    var a = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      a--;
    }
    return a;
  }

  Member copyWith({
    String? membershipNumber,
    String? fullName,
    String? gender,
    DateTime? dateOfBirth,
    String? phone,
    String? email,
    String? occupation,
    String? status,
    String? photoUrl,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    DateTime? rejectedAt,
    bool clearRejection = false,
  }) =>
      Member(
        id: id,
        membershipNumber: membershipNumber ?? this.membershipNumber,
        fullName: fullName ?? this.fullName,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        occupation: occupation ?? this.occupation,
        status: status ?? this.status,
        stateId: stateId,
        lgaId: lgaId,
        wardId: wardId,
        pollingUnitId: pollingUnitId,
        isRegisteredVoter: isRegisteredVoter,
        vin: vin,
        voterCardUrl: voterCardUrl,
        photoUrl: photoUrl ?? this.photoUrl,
        approvedBy: approvedBy ?? this.approvedBy,
        approvedAt: approvedAt ?? this.approvedAt,
        rejectionReason: clearRejection ? null : (rejectionReason ?? this.rejectionReason),
        rejectedAt: clearRejection ? null : (rejectedAt ?? this.rejectedAt),
        createdAt: createdAt,
        stateName: stateName,
        lgaName: lgaName,
        wardName: wardName,
        pollingUnitName: pollingUnitName,
        userId: userId,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'membershipNumber': membershipNumber,
        'fullName': fullName,
        'gender': gender,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'phone': phone,
        'email': email,
        'occupation': occupation,
        'status': status,
        'stateId': stateId,
        'lgaId': lgaId,
        'wardId': wardId,
        'pollingUnitId': pollingUnitId,
        'isRegisteredVoter': isRegisteredVoter,
        'vin': vin,
        'voterCardUrl': voterCardUrl,
        'photoUrl': photoUrl,
        'approvedBy': approvedBy,
        'approvedAt': approvedAt?.toIso8601String(),
        'rejectionReason': rejectionReason,
        'rejectedAt': rejectedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'stateName': stateName,
        'lgaName': lgaName,
        'wardName': wardName,
        'pollingUnitName': pollingUnitName,
        'userId': userId,
      };

  factory Member.fromMap(Map m) => Member(
        id: m['id'] as String,
        membershipNumber: (m['membershipNumber'] ?? m['membership_number'] ?? m['memberCode'] ?? m['member_code']) as String?,
        fullName: (m['fullName'] ?? m['full_name']) as String,
        gender: m['gender'] as String?,
        dateOfBirth: (m['dateOfBirth'] ?? m['date_of_birth']) != null
            ? DateTime.tryParse((m['dateOfBirth'] ?? m['date_of_birth']).toString())
            : null,
        phone: m['phone'] as String?,
        email: m['email'] as String?,
        occupation: m['occupation'] as String?,
        status: m['status'] as String,
        stateId: (m['stateId'] ?? m['state_id']) as String?,
        lgaId: (m['lgaId'] ?? m['lga_id']) as String?,
        wardId: (m['wardId'] ?? m['ward_id']) as String?,
        pollingUnitId: (m['pollingUnitId'] ?? m['polling_unit_id']) as String?,
        isRegisteredVoter: (m['isRegisteredVoter'] ?? m['is_registered_voter'] ?? false) as bool,
        vin: m['vin'] as String?,
        voterCardUrl: (m['voterCardUrl'] ?? m['voter_card_url']) as String?,
        photoUrl: (m['photoUrl'] ?? m['photo_url']) as String?,
        approvedBy: (m['approvedBy'] ?? m['approved_by']) as String?,
        approvedAt: (m['approvedAt'] ?? m['approved_at']) != null
            ? DateTime.tryParse((m['approvedAt'] ?? m['approved_at']).toString())
            : null,
        rejectionReason: (m['rejectionReason'] ?? m['rejection_reason']) as String?,
        rejectedAt: (m['rejectedAt'] ?? m['rejected_at']) != null
            ? DateTime.tryParse((m['rejectedAt'] ?? m['rejected_at']).toString())
            : null,
        createdAt: DateTime.tryParse((m['createdAt'] ?? m['created_at']).toString()) ?? DateTime.now(),
        stateName: (m['stateName'] ?? m['state_name']) as String?,
        lgaName: (m['lgaName'] ?? m['lga_name']) as String?,
        wardName: (m['wardName'] ?? m['ward_name']) as String?,
        pollingUnitName: (m['pollingUnitName'] ?? m['polling_unit_name']) as String?,
        userId: (m['userId'] ?? m['user_id']) as String?,
      );

  @override
  List<Object?> get props => [id];
}

class MembershipStats {
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final int states;
  final int lgas;
  final int wards;
  final int pollingUnits;
  const MembershipStats({
    this.total = 0,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
    this.states = 0,
    this.lgas = 0,
    this.wards = 0,
    this.pollingUnits = 0,
  });
}

class SyncQueueItem extends Equatable {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime enqueuedAt;
  const SyncQueueItem({
    required this.id,
    required this.type,
    required this.payload,
    required this.enqueuedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'payload': payload,
        'enqueuedAt': enqueuedAt.toIso8601String(),
      };

  factory SyncQueueItem.fromMap(Map m) => SyncQueueItem(
        id: m['id'] as String,
        type: m['type'] as String,
        payload: Map<String, dynamic>.from(m['payload'] as Map),
        enqueuedAt: DateTime.tryParse(m['enqueuedAt'].toString()) ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [id];
}

class MemberFilters {
  final String? query;
  final String? stateId;
  final String? lgaId;
  final String? wardId;
  final String? pollingUnitId;
  final String? gender;
  final int? ageMin;
  final int? ageMax;
  final String? occupation;
  final DateTime? registeredFrom;
  final DateTime? registeredTo;
  final String? status;

  const MemberFilters({
    this.query,
    this.stateId,
    this.lgaId,
    this.wardId,
    this.pollingUnitId,
    this.gender,
    this.ageMin,
    this.ageMax,
    this.occupation,
    this.registeredFrom,
    this.registeredTo,
    this.status,
  });

  MemberFilters copyWith({
    String? query,
    String? stateId,
    String? lgaId,
    String? wardId,
    String? pollingUnitId,
    String? gender,
    int? ageMin,
    int? ageMax,
    String? occupation,
    DateTime? registeredFrom,
    DateTime? registeredTo,
    String? status,
    bool clearQuery = false,
    bool clearState = false,
    bool clearLga = false,
    bool clearWard = false,
    bool clearPu = false,
    bool clearGender = false,
    bool clearOccupation = false,
    bool clearStatus = false,
    bool clearDates = false,
    bool clearAge = false,
  }) =>
      MemberFilters(
        query: clearQuery ? null : (query ?? this.query),
        stateId: clearState ? null : (stateId ?? this.stateId),
        lgaId: clearLga ? null : (lgaId ?? this.lgaId),
        wardId: clearWard ? null : (wardId ?? this.wardId),
        pollingUnitId: clearPu ? null : (pollingUnitId ?? this.pollingUnitId),
        gender: clearGender ? null : (gender ?? this.gender),
        ageMin: clearAge ? null : (ageMin ?? this.ageMin),
        ageMax: clearAge ? null : (ageMax ?? this.ageMax),
        occupation: clearOccupation ? null : (occupation ?? this.occupation),
        registeredFrom: clearDates ? null : (registeredFrom ?? this.registeredFrom),
        registeredTo: clearDates ? null : (registeredTo ?? this.registeredTo),
        status: clearStatus ? null : (status ?? this.status),
      );
}
