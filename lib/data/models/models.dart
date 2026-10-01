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
  final List<CommunityGeo> communities;
  const WardGeo({
    required this.id,
    required this.name,
    required this.code,
    required this.communities,
  });
  @override
  List<Object?> get props => [id];
}

class CommunityGeo extends Equatable {
  final String id;
  final String name;
  final String code;
  const CommunityGeo({required this.id, required this.name, required this.code});
  @override
  List<Object?> get props => [id];
}

class DemoUser extends Equatable {
  final String id;
  final String phone;
  final String fullName;
  final String role;
  final String? stateId;
  final String? lgaId;
  final String? wardId;
  const DemoUser({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.role,
    this.stateId,
    this.lgaId,
    this.wardId,
  });
  @override
  List<Object?> get props => [id];
}

class Member extends Equatable {
  final String id;
  final String? memberCode;
  final String fullName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? phone;
  final String? occupation;
  final String? education;
  final String category;
  final String status;
  final String? stateId;
  final String? lgaId;
  final String? wardId;
  final String? communityId;
  final String? photoUrl;
  final String? idDocumentUrl;
  final String? registeredBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime createdAt;
  final String? stateName;
  final String? lgaName;
  final String? wardName;
  final String? communityName;

  const Member({
    required this.id,
    this.memberCode,
    required this.fullName,
    this.gender,
    this.dateOfBirth,
    this.phone,
    this.occupation,
    this.education,
    required this.category,
    required this.status,
    this.stateId,
    this.lgaId,
    this.wardId,
    this.communityId,
    this.photoUrl,
    this.idDocumentUrl,
    this.registeredBy,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    required this.createdAt,
    this.stateName,
    this.lgaName,
    this.wardName,
    this.communityName,
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
    String? memberCode,
    String? status,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
  }) =>
      Member(
        id: id,
        memberCode: memberCode ?? this.memberCode,
        fullName: fullName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        phone: phone,
        occupation: occupation,
        education: education,
        category: category,
        status: status ?? this.status,
        stateId: stateId,
        lgaId: lgaId,
        wardId: wardId,
        communityId: communityId,
        photoUrl: photoUrl,
        idDocumentUrl: idDocumentUrl,
        registeredBy: registeredBy,
        approvedBy: approvedBy ?? this.approvedBy,
        approvedAt: approvedAt ?? this.approvedAt,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        createdAt: createdAt,
        stateName: stateName,
        lgaName: lgaName,
        wardName: wardName,
        communityName: communityName,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'memberCode': memberCode,
        'fullName': fullName,
        'gender': gender,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'phone': phone,
        'occupation': occupation,
        'education': education,
        'category': category,
        'status': status,
        'stateId': stateId,
        'lgaId': lgaId,
        'wardId': wardId,
        'communityId': communityId,
        'photoUrl': photoUrl,
        'idDocumentUrl': idDocumentUrl,
        'registeredBy': registeredBy,
        'approvedBy': approvedBy,
        'approvedAt': approvedAt?.toIso8601String(),
        'rejectionReason': rejectionReason,
        'createdAt': createdAt.toIso8601String(),
        'stateName': stateName,
        'lgaName': lgaName,
        'wardName': wardName,
        'communityName': communityName,
      };

  factory Member.fromMap(Map m) => Member(
        id: m['id'] as String,
        memberCode: m['memberCode'] as String? ?? m['member_code'] as String?,
        fullName: (m['fullName'] ?? m['full_name']) as String,
        gender: m['gender'] as String?,
        dateOfBirth: (m['dateOfBirth'] ?? m['date_of_birth']) != null
            ? DateTime.tryParse((m['dateOfBirth'] ?? m['date_of_birth']).toString())
            : null,
        phone: m['phone'] as String?,
        occupation: m['occupation'] as String?,
        education: m['education'] as String?,
        category: m['category'] as String,
        status: m['status'] as String,
        stateId: (m['stateId'] ?? m['state_id']) as String?,
        lgaId: (m['lgaId'] ?? m['lga_id']) as String?,
        wardId: (m['wardId'] ?? m['ward_id']) as String?,
        communityId: (m['communityId'] ?? m['community_id']) as String?,
        photoUrl: (m['photoUrl'] ?? m['photo_url']) as String?,
        idDocumentUrl: (m['idDocumentUrl'] ?? m['id_document_url']) as String?,
        registeredBy: (m['registeredBy'] ?? m['registered_by']) as String?,
        approvedBy: (m['approvedBy'] ?? m['approved_by']) as String?,
        approvedAt: (m['approvedAt'] ?? m['approved_at']) != null
            ? DateTime.tryParse((m['approvedAt'] ?? m['approved_at']).toString())
            : null,
        rejectionReason: (m['rejectionReason'] ?? m['rejection_reason']) as String?,
        createdAt: DateTime.tryParse((m['createdAt'] ?? m['created_at']).toString()) ??
            DateTime.now(),
        stateName: (m['stateName'] ?? m['state_name']) as String?,
        lgaName: (m['lgaName'] ?? m['lga_name']) as String?,
        wardName: (m['wardName'] ?? m['ward_name']) as String?,
        communityName: (m['communityName'] ?? m['community_name']) as String?,
      );

  @override
  List<Object?> get props => [id];
}

class ApprovalRecord extends Equatable {
  final String id;
  final String memberId;
  final String? actorId;
  final String action;
  final String? notes;
  final DateTime createdAt;
  const ApprovalRecord({
    required this.id,
    required this.memberId,
    this.actorId,
    required this.action,
    this.notes,
    required this.createdAt,
  });
  @override
  List<Object?> get props => [id];
}

class AppMessage extends Equatable {
  final String id;
  final String audienceScope;
  final String? audienceRef;
  final String body;
  final String? sentBy;
  final DateTime createdAt;
  const AppMessage({
    required this.id,
    required this.audienceScope,
    this.audienceRef,
    required this.body,
    this.sentBy,
    required this.createdAt,
  });
  @override
  List<Object?> get props => [id];
}

class AuditEntry extends Equatable {
  final String id;
  final String? actorId;
  final String action;
  final String? entity;
  final String? entityId;
  final DateTime createdAt;
  const AuditEntry({
    required this.id,
    this.actorId,
    required this.action,
    this.entity,
    this.entityId,
    required this.createdAt,
  });
  @override
  List<Object?> get props => [id];
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

class MembershipStats {
  final int registered;
  final int pending;
  final int approved;
  final int rejected;
  final int agents;
  final int states;
  final int lgas;
  final int wards;
  const MembershipStats({
    this.registered = 0,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
    this.agents = 0,
    this.states = 0,
    this.lgas = 0,
    this.wards = 0,
  });
}
