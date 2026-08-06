import 'package:app/core/model/user_model.dart';
import 'package:app/core/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

final userProvider = StateNotifierProvider<UserNotifier, UserProfileData?>((
  ref,
) {
  return UserNotifier(ref.watch(userServiceProvider));
});

class UserNotifier extends StateNotifier<UserProfileData?> {
  final UserService _userService;

  UserNotifier(this._userService) : super(null);

  //  Fetch and store user profile
  Future<void> fetchProfile() async {
    try {
      final response = await _userService.fetchProfile();
      state = response.data;
    } catch (e) {
      rethrow;
    }
  }

  //  Update Fullname
  Future<void> updateFullname(String newFullname) async {
    try {
      await _userService.updateFullname(fullname: newFullname);

      if (state != null) {
        state = UserProfileData(
          uid: state!.uid,
          fullname: newFullname,
          email: state!.email,
          phone: state!.phone,
          role: state!.role,
          isVerified: state!.isVerified,
          createdAt: state!.createdAt,
          updatedAt: DateTime.now().toIso8601String(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _userService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // logout
  void clearUser() {
    state = null;
  }
}
