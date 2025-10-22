import '../../domain/entities/auth_user.dart';

abstract class UserProfileDataSource {
  Future<AuthUser> fetchProfile(String uid);
  Future<void> saveProfile(AuthUser user);
}
