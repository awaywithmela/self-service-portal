import '../../../../core/network/network_client.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  // ignore: unused_field
  final NetworkClient _client;
  const AuthRemoteDataSource(this._client);

  // Test credentials — replace with real API calls when backend is ready
  static const _newInterviewers = {
    'test@ipsos.com': '1234',
    'jane.smith@ipsos.com': '5678',
    'new.interviewer@ipsos.com': '9999',
  };

  static const _existingInterviewers = {
    'interviewer1': 'password123',
    'john.doe': 'Test1234',
    'admin': 'admin123',
  };

  Future<UserModel> authenticateNewInterviewer(String email, String lastFourDigits) async {
    // TODO: replace with real API call
    // final response = await _client.post('/api/auth/new-interviewer', data: {
    //   'email': email, 'lastFourDigits': lastFourDigits,
    // });
    // return UserModel.fromJson(response.data as Map<String, dynamic>);
    await Future.delayed(const Duration(milliseconds: 500));

    final expected = _newInterviewers[email.toLowerCase().trim()];
    if (expected == null || expected != lastFourDigits.trim()) {
      throw Exception('Email or phone number not recognised. Please check your details and try again.');
    }

    return UserModel(id: email, username: email, type: UserType.newInterviewer);
  }

  Future<UserModel> authenticateExistingInterviewer(String username, String password) async {
    // TODO: replace with real API call
    // final response = await _client.post('/api/auth/login', data: {
    //   'username': username, 'password': password,
    // });
    // return UserModel.fromJson(response.data as Map<String, dynamic>);
    await Future.delayed(const Duration(milliseconds: 500));

    final expected = _existingInterviewers[username.trim()];
    if (expected == null || expected != password) {
      throw Exception('Incorrect username or password. Please try again.');
    }

    return UserModel(id: username, username: username, type: UserType.existingInterviewer);
  }
}
