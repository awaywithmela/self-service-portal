class IreachException implements Exception {
  final int? statusCode;
  final String message;

  const IreachException(this.message, {this.statusCode});

  @override
  String toString() =>
      statusCode == null ? message : '$message (HTTP $statusCode)';
}

class AuthException extends IreachException {
  const AuthException(super.message, {super.statusCode});
}

class UserDataException extends IreachException {
  const UserDataException(
    super.message, {
    super.statusCode,
  });
}

class AgentNotFoundException extends IreachException {
  final String? computerNumber;

  const AgentNotFoundException([
    super.message = 'Device not registered — please contact help desk.',
    this.computerNumber,
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

class RunScriptException extends IreachException {
  const RunScriptException(super.message, {super.statusCode});
}
