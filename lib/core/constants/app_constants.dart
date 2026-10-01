class AppConstants {
  static const appTitle = 'CBM-NW';
  static const appSubtitle = 'City Boy Movement NW Membership';
  static const zoneLabel = 'North-West Zone';
  static const brandName = 'City Boy';
  static const geographyAsset = 'assets/data/nw_geography.json';
  static const apcLogo = 'assets/images/apc-logo.png';
  static const cityBoyLogo = 'assets/images/city-boy-logo.png';
  static const hiveDraftsBox = 'cbm_nw_drafts';
  static const hiveSyncBox = 'cbm_nw_sync_queue';
  static const consentNotice =
      'I confirm the information provided is accurate. I consent to City Boy Movement '
      'North-West processing my membership data for registration and verification. '
      'My VIN and voter card (if provided) are visible to admins only and are never shown on the public membership card or QR.';
}

class AppRoles {
  static const member = 'member';
  static const admin = 'admin';

  static String label(String role) => switch (role) {
        member => 'Member',
        admin => 'Admin',
        _ => role,
      };

  static String shortLabel(String role) => label(role);
}

class MemberStatus {
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const draft = 'draft';
  static const none = 'none';

  static String label(String s) => switch (s) {
        pending => 'Pending',
        approved => 'Approved',
        rejected => 'Rejected',
        draft => 'Draft',
        none => 'Not registered',
        _ => s,
      };
}
