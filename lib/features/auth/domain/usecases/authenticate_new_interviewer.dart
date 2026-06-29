import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/usecases/use_case.dart';

final class AuthenticateNewInterviewerParams {
  final String email;
  final String lastFourDigits;
  const AuthenticateNewInterviewerParams({
    required this.email,
    required this.lastFourDigits,
  });
}

class AuthenticateNewInterviewer
    implements UseCase<UserEntity, AuthenticateNewInterviewerParams> {
  final AuthRepository _repository;
  const AuthenticateNewInterviewer(this._repository);

  @override
  Future<Result<UserEntity>> call(AuthenticateNewInterviewerParams params) =>
      _repository.authenticateNewInterviewer(params.email, params.lastFourDigits);
}
