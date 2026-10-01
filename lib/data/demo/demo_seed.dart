import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../models/models.dart';

const _uuid = Uuid();

List<DemoUser> buildDemoUsers(List<StateGeo> states, List<Member> members) {
  final approved = members.where((m) => m.status == MemberStatus.approved).firstOrNull;
  final pending = members.where((m) => m.status == MemberStatus.pending).firstOrNull;
  return [
    DemoUser(
      id: '11111111-1111-1111-1111-111111111101',
      phone: '08030000001',
      fullName: approved?.fullName ?? 'Aisha Mohammed',
      role: AppRoles.member,
      email: 'aisha@cbm-nw.demo',
      memberId: approved?.id,
    ),
    DemoUser(
      id: '11111111-1111-1111-1111-111111111102',
      phone: '08030000002',
      fullName: pending?.fullName ?? 'Usman Aliyu',
      role: AppRoles.member,
      email: 'usman@cbm-nw.demo',
      memberId: pending?.id,
    ),
    DemoUser(
      id: '11111111-1111-1111-1111-111111111105',
      phone: '08030000005',
      fullName: 'Situation Room Admin',
      role: AppRoles.admin,
      email: 'admin@cbm-nw.demo',
    ),
  ];
}

List<Member> buildSeedMembers(List<StateGeo> states) {
  final names = [
    ('Aisha Mohammed', 'female', 'Trader', true, '90F5A1B2C3D4E5F6'),
    ('Usman Aliyu', 'male', 'Student', true, '90F5A1B2C3D4E5F7'),
    ('Halima Sani', 'female', 'Teacher', false, null),
    ('Kabir Ahmed', 'male', 'Engineer', true, '90F5A1B2C3D4E5F8'),
    ('Zainab Bello', 'female', 'Business', true, '90F5A1B2C3D4E5F9'),
    ('Murtala Danjuma', 'male', 'Farmer', false, null),
    ('Hauwa Ibrahim', 'female', 'Nurse', true, '90F5A1B2C3D4E5FA'),
    ('Yusuf Lawal', 'male', 'Youth leader', true, '90F5A1B2C3D4E5FB'),
    ('Rabi Garba', 'female', 'Trader', false, null),
    ('Tijjani Abubakar', 'male', 'Civil servant', true, '90F5A1B2C3D4E5FC'),
    ('Nafisa Musa', 'female', 'Student', true, '90F5A1B2C3D4E5FD'),
    ('Bashir Shehu', 'male', 'Driver', false, null),
  ];
  final statuses = [
    MemberStatus.approved,
    MemberStatus.pending,
    MemberStatus.approved,
    MemberStatus.rejected,
    MemberStatus.pending,
    MemberStatus.approved,
    MemberStatus.approved,
    MemberStatus.pending,
    MemberStatus.approved,
    MemberStatus.approved,
    MemberStatus.pending,
    MemberStatus.approved,
  ];
  final out = <Member>[];
  var seq = 100001;
  for (var i = 0; i < names.length; i++) {
    final st = states[i % states.length];
    final lga = st.lgas[i % st.lgas.length];
    final ward = lga.wards[i % lga.wards.length];
    final pu = ward.pollingUnits.isNotEmpty
        ? ward.pollingUnits[i % ward.pollingUnits.length]
        : null;
    final (fullName, gender, occupation, isVoter, vin) = names[i];
    final status = statuses[i];
    final code = 'CBM-NW-${st.code}-${seq.toString().padLeft(6, '0')}';
    seq++;
    out.add(Member(
      id: _uuid.v4(),
      membershipNumber: status == MemberStatus.approved ? code : null,
      fullName: fullName,
      gender: gender,
      dateOfBirth: DateTime(1985 + (i % 20), 1 + (i % 12), 5 + (i % 20)),
      phone: '0803${(1000000 + i * 111).toString().padLeft(7, '0')}',
      email: i.isEven ? '${fullName.split(' ').first.toLowerCase()}@demo.nw' : null,
      occupation: occupation,
      status: status,
      stateId: st.id,
      lgaId: lga.id,
      wardId: ward.id,
      pollingUnitId: pu?.id,
      isRegisteredVoter: isVoter,
      vin: vin,
      voterCardUrl: isVoter ? 'stub://voter-card-$i' : null,
      photoUrl: 'stub://photo-$i',
      approvedBy: status == MemberStatus.approved ? '11111111-1111-1111-1111-111111111105' : null,
      approvedAt: status == MemberStatus.approved ? DateTime.now().subtract(Duration(days: i + 1)) : null,
      rejectionReason: status == MemberStatus.rejected ? 'Incomplete documentation' : null,
      rejectedAt: status == MemberStatus.rejected ? DateTime.now().subtract(Duration(days: i)) : null,
      createdAt: DateTime.now().subtract(Duration(days: 14 - i)),
      stateName: st.name,
      lgaName: lga.name,
      wardName: ward.name,
      pollingUnitName: pu?.name,
    ));
  }
  // Link first approved / first pending phones to demo logins
  if (out.isNotEmpty) {
    out[0] = out[0].copyWith(phone: '08030000001');
  }
  if (out.length > 1) {
    out[1] = out[1].copyWith(phone: '08030000002');
  }
  return out;
}
