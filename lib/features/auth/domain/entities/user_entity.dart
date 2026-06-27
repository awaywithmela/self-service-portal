class UserEntity {
  final String id;
  final String username;
  final UserType type;

  const UserEntity({
    required this.id,
    required this.username,
    required this.type,
  });
}

enum UserType { newInterviewer, existingInterviewer }
