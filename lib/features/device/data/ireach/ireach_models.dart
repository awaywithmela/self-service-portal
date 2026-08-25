import 'ireach_exceptions.dart';

class CurrentUser {
  final String computerNumber;
  final String? name;

  const CurrentUser({
    required this.computerNumber,
    this.name,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    final computerNumberValue = json['computerNumber'] ??
        json['computer_number'] ??
        json['computerName'] ??
        json['deviceId'] ??
        json['device_id'];
    final nameValue = json['name'] ??
        json['displayName'] ??
        json['fullName'] ??
        json['userName'] ??
        json['username'];

    final computerNumber = computerNumberValue?.toString().trim();
    if (computerNumber == null || computerNumber.isEmpty) {
      throw const UserDataException(
        'No device on file — please contact help desk.',
      );
    }
    return CurrentUser(
      computerNumber: computerNumber,
      name: nameValue?.toString().trim(),
    );
  }
}

class Agent {
  final String hostname;
  final String agentId;

  const Agent({
    required this.hostname,
    required this.agentId,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    final hostname = (json['hostname'] ??
            json['host_name'] ??
            json['computer_name'] ??
            json['computerName'])
        ?.toString()
        .trim();
    final agentId = (json['agent_id'] ?? json['agentId'] ?? json['id'])
        ?.toString()
        .trim();

    if (hostname == null ||
        hostname.isEmpty ||
        agentId == null ||
        agentId.isEmpty) {
      throw const FormatException(
        'Agent response did not include hostname and agent_id.',
      );
    }
    return Agent(hostname: hostname, agentId: agentId);
  }
}
