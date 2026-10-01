import 'package:flutter_test/flutter_test.dart';
import 'package:cbm_nw/core/constants/app_constants.dart';

void main() {
  test('app roles are member and admin only', () {
    expect(AppRoles.member, 'member');
    expect(AppRoles.admin, 'admin');
    expect(AppRoles.label(AppRoles.member), 'Member');
  });
}
