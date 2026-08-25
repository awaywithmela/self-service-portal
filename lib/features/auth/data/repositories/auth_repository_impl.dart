import 'package:dio/dio.dart';

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
      final model =
          await _dataSource.authenticateNewInterviewer(email, lastFourDigits);
      return Success(model.toEntity());
    } on DioException catch (e) {
      return Err(AuthFailure(_extractDioMessage(e)));
    } on Exception catch (e) {
      return Err(AuthFailure(_extractMessage(e)));
    }
  }

  @override
  Future<Result<UserEntity>> authenticateExistingInterviewer(
      String username, String password) async {
    try {
      final model =
          await _dataSource.authenticateExistingInterviewer(username, password);
      return Success(model.toEntity());
    } on DioException catch (e) {
      return Err(AuthFailure(_extractDioMessage(e)));
    } on Exception catch (e) {
      return Err(AuthFailure(_extractMessage(e)));
    }
  }

  String _extractDioMessage(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return 'The API request could not be completed. For local testing, start the API proxy with: dart run tool/dev_api_proxy.dart';
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return 'Authentication was rejected by the staging API. Please check the username and password.';
    }

    return 'We could not complete authentication. Please check your details or contact Helpdesk.';
  }

  // Surface the real failure reason (bad credentials, proxy unreachable,
  // session expired, etc.) instead of masking every non-whitelisted message
  // behind a generic string — that made every real error indistinguishable
  // and impossible to diagnose from the UI.
  String _extractMessage(Exception e) {
    final message = e.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty
        ? 'We could not complete authentication. Please check your details or contact Helpdesk.'
        : message;
  }
}
