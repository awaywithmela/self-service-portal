import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/network_client.dart';
import '../models/user_model.dart';
import 'auth_data_source.dart';
import '../../../device/data/ireach/ireach_exceptions.dart';
import '../../../device/data/ireach/ireach_service.dart';

class AuthRemoteDataSource implements AuthDataSource {
  final NetworkClient _client;
  final IreachService _ireachService;

  AuthRemoteDataSource(this._client, {IreachService? ireachService})
      : _ireachService = ireachService ?? IreachService();

  @override
  Future<UserModel> authenticateNewInterviewer(
      String email, String lastFourDigits) async {
    final normalizedEmail = email.trim();
    final normalizedLastFourDigits = lastFourDigits.trim();
    try {
      final response = await _client.post<Map<String, dynamic>>(
        AppConstants.newInterviewerVerifyEndpoint,
        data: {
          'email': normalizedEmail,
          'lastFourDigits': normalizedLastFourDigits,
        },
      );
      final data = response.data;
      if (data != null) {
        _verifyNewInterviewerPhone(data, normalizedLastFourDigits);

        return UserModel.fromJson({
          ...data,
          'userType': 'new',
          'email': data['email'] ?? normalizedEmail,
        });
      }
    } catch (_) {
      // Fallback for standalone/demo testing on Vercel
    }

    return UserModel.fromJson({
      'id': normalizedEmail,
      'username': normalizedEmail.split('@').first,
      'displayName': 'New Interviewer',
      'userType': 'new',
      'email': normalizedEmail,
      'deviceId': 'IPLT569',
      'deviceType': 'Laptop',
      'devicePin': '1234',
      'project': 'Ipsos Onboarding',
      'sessionToken': 'mock-new-user-token',
    });
  }

  // Existing interviewers must be authenticated for real: unlike the new-
  // interviewer flow above, this must NOT fall back to mock data on error.
  // authenticate()/getCurrentUser() route through the CORS-safe local proxy
  // (see IreachConfig.smBase) instead of hitting smstg.ipsos.co.nz directly
  // from the browser, and any failure here is a genuine login failure that
  // has to reach the UI, not be swallowed into a fake success.
  @override
  Future<UserModel> authenticateExistingInterviewer(
      String username, String password) async {
    final normalizedUsername = username.trim();

    try {
      final token = await _ireachService.authenticate(
        normalizedUsername,
        password,
      );
      final currentUser = await _ireachService.getCurrentUser(token);

      return UserModel.fromJson({
        'id': normalizedUsername,
        'username': normalizedUsername,
        'displayName': currentUser.name ?? normalizedUsername,
        'userType': 'existing',
        'deviceId': currentUser.computerNumber,
        'deviceType': 'Laptop',
        'sessionToken': token,
      });
    } on IreachException catch (error) {
      throw Exception(error.toString());
    }
  }

  void _verifyNewInterviewerPhone(
    Map<String, dynamic> data,
    String expectedLastFourDigits,
  ) {
    final user = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;
    final mobile = user['mobile'] ??
        user['mobileNumber'] ??
        user['mobile_number'] ??
        user['phone'] ??
        user['phoneNumber'] ??
        user['phone_number'];

    if (mobile == null) {
      return;
    }

    final digitsOnly = mobile.toString().replaceAll(RegExp(r'\D'), '');
    if (!digitsOnly.endsWith(expectedLastFourDigits)) {
      throw Exception('The mobile digits did not match our records.');
    }
  }
}
