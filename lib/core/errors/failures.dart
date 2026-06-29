sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}

final class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

final class DeviceFailure extends AppFailure {
  const DeviceFailure(super.message);
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

final class ServerFailure extends AppFailure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}
