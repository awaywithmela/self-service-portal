import '../entities/user_entity.dart';
import '../../../../core/errors/result.dart';

abstract interface class AuthRepository {
  Future<Result<UserEntity>> authenticateNewInterviewer(String email, String lastFourDigits);
  Future<Result<UserEntity>> authenticateExistingInterviewer(String username, String password);
}
