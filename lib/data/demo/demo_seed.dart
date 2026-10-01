import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../models/models.dart';

const _uuid = Uuid();

List<DemoUser> buildDemoUsers(List<StateGeo> states) {
  final kd = states.firstWhere((s) => s.code == 'KD', orElse: () => states.first);
  final kn = states.firstWhere((s) => s.code == 'KN', orElse: () => states.first);
  final kdLga = kd.lgas.isNotEmpty ? kd.lgas.first : null;
  final kdWard = kdLga != null && kdLga.wards.isNotEmpty ? kdLga.wards.first : null;
  final knLga = kn.lgas.isNotEmpty ? kn.lgas.first : null;

  return [
    DemoUser(
      id: '11111111-1111-1111-1111-111111111101',
      phone: '08030000001',
      fullName: 'Amina Yusuf',
      role: AppRoles.registrationAgent,
      stateId: kd.id,
      lgaId: kdLga?.id,
      wardId: kdWard?.id,
    ),
    DemoUser(
      id: '11111111-1111-1111-1111-111111111102',
      phone: '08030000002',
      fullName: 'Ibrahim Musa',
      role: AppRoles.wardCoordinator,
      stateId: kd.id,
      lgaId: kdLga?.id,
      wardId: kdWard?.id,
    ),
    DemoUser(
      id: '11111111-1111-1111-1111-111111111103',
      phone: '08030000003',
      fullName: 'Fatima Abdullahi',
      role: AppRoles.lgaCoordinator,
      stateId: kd.id,
      lgaId: kdLga?.id,
    ),
    DemoUser(
      id: '11111111-1111-1111-1111-111111111104',
      phone: '08030000004',
      fullName: 'Sani Bello',
      role: AppRoles.stateCoordinator,
      stateId: kn.id,
      lgaId: knLga?.id,
    ),
    DemoUser(
      id: '11111111-1111-1111-1111-111111111105',
      phone: '08030000005',
      fullName: 'Situation Room Admin',
      role: AppRoles.admin,
    ),
    DemoUser(
      id: '11111111-1111-1111-1111-111111111106',
      phone: '08030000006',
      fullName: 'Hassan Garba',
      role: AppRoles.registrationAgent,
      stateId: kn.id,
      lgaId: knLga?.id,
      wardId: knLga?.wards.isNotEmpty == true ? knLga!.wards.first.id : null,
    ),
  ];
}

List<Member> buildSeedMembers(List<StateGeo> states, List<DemoUser> agents) {
  final names = [
    ('Aisha Mohammed', 'female', MemberCategory.women),
    ('Usman Aliyu', 'male', MemberCategory.youth),
    ('Halima Sani', 'female', MemberCategory.student),
    ('Kabir Ahmed', 'male', MemberCategory.professional),
    ('Zainab Bello', 'female', MemberCategory.business),
    ('Murtala Danjuma', 'male', MemberCategory.volunteer),
    ('Hauwa Ibrahim', 'female', MemberCategory.communityLeader),
    ('Yusuf Lawal', 'male', MemberCategory.youth),
    ('Rabi Garba', 'female', MemberCategory.women),
    ('Tijjani Abubakar', 'male', MemberCategory.professional),
    ('Nafisa Musa', 'female', MemberCategory.student),
    ('Bashir Shehu', 'male', MemberCategory.business),
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
  final agent = agents.firstWhere((u) => u.role == AppRoles.registrationAgent);
  final out = <Member>[];
  var seq = 10001;
  for (var i = 0; i < names.length; i++) {
    final st = states[i % states.length];
    final lga = st.lgas[i % st.lgas.length];
    final ward = lga.wards[i % lga.wards.length];
    final community = ward.communities.isNotEmpty ? ward.communities[i % ward.communities.length] : null;
    final (fullName, gender, category) = names[i];
    final status = statuses[i];
    final code = 'CBM-NW-${st.code}-${seq.toString().padLeft(5, '0')}';
    seq++;
    out.add(Member(
      id: _uuid.v4(),
      memberCode: status == MemberStatus.approved ? code : null,
      fullName: fullName,
      gender: gender,
      dateOfBirth: DateTime(1985 + (i % 20), 1 + (i % 12), 5 + (i % 20)),
      phone: '0803${(1000000 + i * 111).toString().padLeft(7, '0')}',
      occupation: category == MemberCategory.student ? 'Student' : 'Trader',
      education: 'SSCE',
      category: category,
      status: status,
      stateId: st.id,
      lgaId: lga.id,
      wardId: ward.id,
      communityId: community?.id,
      registeredBy: agent.id,
      approvedBy: status == MemberStatus.approved ? agents[1].id : null,
      approvedAt: status == MemberStatus.approved ? DateTime.now().subtract(Duration(days: i + 1)) : null,
      rejectionReason: status == MemberStatus.rejected ? 'Incomplete documentation' : null,
      createdAt: DateTime.now().subtract(Duration(days: 14 - i)),
      stateName: st.name,
      lgaName: lga.name,
      wardName: ward.name,
      communityName: community?.name,
    ));
  }
  return out;
}
