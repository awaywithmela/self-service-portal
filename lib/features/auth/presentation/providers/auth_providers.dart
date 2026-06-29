import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_data_source.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/authenticate_new_interviewer.dart';
import '../../domain/usecases/authenticate_existing_interviewer.dart';
import '../../../../core/network/network_providers.dart';

final _authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthRemoteDataSource(ref.read(networkClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(_authDataSourceProvider));
});

final authenticateNewInterviewerProvider = Provider<AuthenticateNewInterviewer>((ref) {
  return AuthenticateNewInterviewer(ref.read(authRepositoryProvider));
});

final authenticateExistingInterviewerProvider =
    Provider<AuthenticateExistingInterviewer>((ref) {
  return AuthenticateExistingInterviewer(ref.read(authRepositoryProvider));
});
