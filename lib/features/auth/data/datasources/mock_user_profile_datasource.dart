import '../../domain/entities/auth_user.dart';
import 'user_profile_datasource.dart';

class MockUserProfileDataSource implements UserProfileDataSource {
  final Map<String, AuthUser> _profiles = {};

  @override
  Future<AuthUser> fetchProfile(String uid) async {
    return _profiles[uid] ?? AuthUser(uid: uid, email: '');
  }

  @override
  Future<void> saveProfile(AuthUser user) async {
    _profiles[user.uid] = user;
  }
}
