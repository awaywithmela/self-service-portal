import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/result.dart';

class AuthenticateExistingInterviewer {
  final AuthRepository _repository;
  const AuthenticateExistingInterviewer(this._repository);

  Future<Result<UserEntity>> call(String username, String password) =>
      _repository.authenticateExistingInterviewer(username, password);
}
