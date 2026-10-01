class AppConstants {
  static const appTitle = 'CBM-NW';
  static const appSubtitle = 'City Boy Movement NW Membership';
  static const zoneLabel = 'North-West Zone';
  static const geographyAsset = 'assets/data/nw_geography.json';
  static const apcLogo = 'assets/images/apc-logo.png';
  static const cityBoyLogo = 'assets/images/city-boy-logo.png';
  static const hiveDraftsBox = 'cbm_nw_drafts';
  static const hiveSyncBox = 'cbm_nw_sync_queue';
}

class AppRoles {
  static const registrationAgent = 'registration_agent';
  static const wardCoordinator = 'ward_coordinator';
  static const lgaCoordinator = 'lga_coordinator';
  static const stateCoordinator = 'state_coordinator';
  static const admin = 'admin';

  static String label(String role) => switch (role) {
        registrationAgent => 'Registration Agent',
        wardCoordinator => 'Ward Coordinator',
        lgaCoordinator => 'LGA Coordinator',
        stateCoordinator => 'State Coordinator',
        admin => 'Admin (Situation Room)',
        _ => role,
      };

  static String shortLabel(String role) => switch (role) {
        registrationAgent => 'Agent',
        wardCoordinator => 'Ward',
        lgaCoordinator => 'LGA',
        stateCoordinator => 'State',
        admin => 'Admin',
        _ => role,
      };
}

class MemberStatus {
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const draft = 'draft';

  static String label(String s) => switch (s) {
        pending => 'Pending',
        approved => 'Approved',
        rejected => 'Rejected',
        draft => 'Draft',
        _ => s,
      };
}

class MemberCategory {
  static const youth = 'youth';
  static const women = 'women';
  static const student = 'student';
  static const professional = 'professional';
  static const business = 'business';
  static const volunteer = 'volunteer';
  static const communityLeader = 'community_leader';

  static const all = [
    youth,
    women,
    student,
    professional,
    business,
    volunteer,
    communityLeader,
  ];

  static String label(String c) => switch (c) {
        youth => 'Youth',
        women => 'Women',
        student => 'Student',
        professional => 'Professional',
        business => 'Business',
        volunteer => 'Volunteer',
        communityLeader => 'Community Leader',
        _ => c,
      };
}
