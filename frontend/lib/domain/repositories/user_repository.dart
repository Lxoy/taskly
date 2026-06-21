import 'package:frontend/data/models/user_models.dart';

abstract interface class UserRepository {
  /// GET /api/user
  Future<UserResult<GetUserDto>> getUser();

  /// PUT /api/user
  Future<UserResult<String?>> updateUser(UpdateUserRequest request);

  /// PUT /api/user/password
  Future<UserResult<void>> updatePassword(UpdatePasswordRequest request);
}