import '../models/user_model.dart';

abstract interface class AuthDataSource {
  Future<UserModel> authenticateNewInterviewer(String email, String lastFourDigits);
  Future<UserModel> authenticateExistingInterviewer(String username, String password);
}
