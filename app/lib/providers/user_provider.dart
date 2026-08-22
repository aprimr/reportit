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
    } catch (_) {
      rethrow;
    }
  }

  //  Update Fullname
  Future<void> updateFullname(String newFullname) async {
    try {
      await _userService.updateFullname(fullname: newFullname);

      if (state != null) {
        state = UserProfileData(
          user: UserProfile(
            uid: state!.user.uid,
            fullname: newFullname,
            email: state!.user.email,
            phone: state!.user.phone,
            role: state!.user.role,
            isVerified: state!.user.isVerified,
            createdAt: state!.user.createdAt,
            updatedAt: state!.user.updatedAt,
          ),
          complaintStats: ComplaintStats(
            open: state!.complaintStats.open,
            verified: state!.complaintStats.verified,
            resolved: state!.complaintStats.resolved,
            rejected: state!.complaintStats.rejected,
            total: state!.complaintStats.total,
          ),
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
