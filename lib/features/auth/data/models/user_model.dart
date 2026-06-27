import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.type,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId'] as String,
      username: (json['username'] ?? json['userId']) as String,
      type: json['userType'] == 'new' ? UserType.newInterviewer : UserType.existingInterviewer,
    );
  }
}
