class GetUserDto {
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? email;
  final String? phoneNumber;

  const GetUserDto({
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.phoneNumber,
  });

  factory GetUserDto.fromJson(Map<String, dynamic> json) {
    return GetUserDto(
      firstName:   json['firstName'] as String?,
      lastName:    json['lastName'] as String?,
      username:    json['username'] as String?,
      email:       json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }
}

// ── Request models ────────────────────────────────────────────────────────────

class UpdateUserRequest {
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? email;
  final String? phoneNumber;

  const UpdateUserRequest({
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        if (firstName != null && firstName!.isNotEmpty) 'firstName': firstName,
        if (lastName != null && lastName!.isNotEmpty)   'lastName': lastName,
        if (username != null && username!.isNotEmpty)   'username': username,
        if (email != null && email!.isNotEmpty)         'email': email,
        if (phoneNumber != null && phoneNumber!.isNotEmpty)
          'phoneNumber': phoneNumber,
      };
}

class UpdatePasswordRequest {
  final String newPassword;
  final String confirmedPassword;

  const UpdatePasswordRequest({
    required this.newPassword,
    required this.confirmedPassword,
  });

  Map<String, dynamic> toJson() => {
        'newPassword': newPassword,
        'confirmedPassword': confirmedPassword,
      };
}

// ── Result ────────────────────────────────────────────────────────────────────

sealed class UserResult<T> {
  const UserResult();
}

class UserSuccess<T> extends UserResult<T> {
  final T data;
  const UserSuccess(this.data);
}

class UserFailure<T> extends UserResult<T> {
  final String message;
  const UserFailure(this.message);
}