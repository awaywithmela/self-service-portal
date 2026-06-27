import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<Result<UserEntity>> authenticateNewInterviewer(
      String email, String lastFourDigits) async {
    try {
      final user = await _dataSource.authenticateNewInterviewer(email, lastFourDigits);
      return Success(user);
    } catch (e) {
      return Err(AuthFailure('Authentication failed: $e'));
    }
  }

  @override
  Future<Result<UserEntity>> authenticateExistingInterviewer(
      String username, String password) async {
    try {
      final user = await _dataSource.authenticateExistingInterviewer(username, password);
      return Success(user);
    } catch (e) {
      return Err(AuthFailure('Authentication failed: $e'));
    }
  }
}
