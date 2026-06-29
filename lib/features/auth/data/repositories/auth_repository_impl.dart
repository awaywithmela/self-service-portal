import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../datasources/auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<Result<UserEntity>> authenticateNewInterviewer(
      String email, String lastFourDigits) async {
    try {
      final model = await _dataSource.authenticateNewInterviewer(email, lastFourDigits);
      return Success(model.toEntity());
    } on Exception catch (e) {
      return Err(AuthFailure(_extractMessage(e)));
    }
  }

  @override
  Future<Result<UserEntity>> authenticateExistingInterviewer(
      String username, String password) async {
    try {
      final model = await _dataSource.authenticateExistingInterviewer(username, password);
      return Success(model.toEntity());
    } on Exception catch (e) {
      return Err(AuthFailure(_extractMessage(e)));
    }
  }

  String _extractMessage(Exception e) =>
      e.toString().replaceFirst('Exception: ', '');
}
