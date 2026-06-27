sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}

final class AuthFailure extends AppFailure {
  const AuthFailure(String message) : super(message);
}

final class DeviceFailure extends AppFailure {
  const DeviceFailure(String message) : super(message);
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(String message) : super(message);
}

final class ServerFailure extends AppFailure {
  final int? statusCode;
  const ServerFailure(String message, {this.statusCode}) : super(message);
}
