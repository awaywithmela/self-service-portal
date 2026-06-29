import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String username;
  final String userType;

  const UserModel({
    required this.id,
    required this.username,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId'] as String,
      username: (json['username'] ?? json['userId']) as String,
      userType: json['userType'] as String? ?? 'existing',
    );
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        username: username,
        type: userType == 'new' ? UserType.newInterviewer : UserType.existingInterviewer,
      );
}
