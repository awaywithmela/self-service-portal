import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/usecases/use_case.dart';

final class AuthenticateExistingInterviewerParams {
  final String username;
  final String password;
  const AuthenticateExistingInterviewerParams({
    required this.username,
    required this.password,
  });
}

class AuthenticateExistingInterviewer
    implements UseCase<UserEntity, AuthenticateExistingInterviewerParams> {
  final AuthRepository _repository;
  const AuthenticateExistingInterviewer(this._repository);

  @override
  Future<Result<UserEntity>> call(AuthenticateExistingInterviewerParams params) =>
      _repository.authenticateExistingInterviewer(params.username, params.password);
}
