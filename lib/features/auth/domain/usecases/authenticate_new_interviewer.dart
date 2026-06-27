import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/result.dart';

class AuthenticateNewInterviewer {
  final AuthRepository _repository;
  const AuthenticateNewInterviewer(this._repository);

  Future<Result<UserEntity>> call(String email, String lastFourDigits) =>
      _repository.authenticateNewInterviewer(email, lastFourDigits);
}
