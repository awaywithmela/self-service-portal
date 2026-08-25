enum UpdateIreachStatus { idle, loading, success, error }

enum UpdateIreachStep { login, confirmDevice, syncAndClose, result }

class UpdateIreachState {
  final String? token;
  final String? computerNumber;
  final String? name;
  final String? agentId;
  final bool deviceConfirmed;
  final bool syncedAndClosed;
  final UpdateIreachStatus status;
  final String? errorMessage;

  const UpdateIreachState({
    this.token,
    this.computerNumber,
    this.name,
    this.agentId,
    this.deviceConfirmed = false,
    this.syncedAndClosed = false,
    this.status = UpdateIreachStatus.idle,
    this.errorMessage,
  });

  const UpdateIreachState.initial()
      : token = null,
        computerNumber = null,
        name = null,
        agentId = null,
        deviceConfirmed = false,
        syncedAndClosed = false,
        status = UpdateIreachStatus.idle,
        errorMessage = null;

  bool get isLoading => status == UpdateIreachStatus.loading;
  bool get isSuccess => status == UpdateIreachStatus.success;
  bool get isError => status == UpdateIreachStatus.error;

  UpdateIreachStep get currentStep {
    if (token == null || token!.isEmpty) return UpdateIreachStep.login;
    if (!deviceConfirmed) return UpdateIreachStep.confirmDevice;
    if (status == UpdateIreachStatus.loading ||
        status == UpdateIreachStatus.success ||
        status == UpdateIreachStatus.error) {
      return UpdateIreachStep.result;
    }
    return UpdateIreachStep.syncAndClose;
  }

  UpdateIreachState copyWith({
    String? token,
    bool clearToken = false,
    String? computerNumber,
    bool clearComputerNumber = false,
    String? name,
    bool clearName = false,
    String? agentId,
    bool clearAgentId = false,
    bool? deviceConfirmed,
    bool? syncedAndClosed,
    UpdateIreachStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UpdateIreachState(
      token: clearToken ? null : (token ?? this.token),
      computerNumber:
          clearComputerNumber ? null : (computerNumber ?? this.computerNumber),
      name: clearName ? null : (name ?? this.name),
      agentId: clearAgentId ? null : (agentId ?? this.agentId),
      deviceConfirmed: deviceConfirmed ?? this.deviceConfirmed,
      syncedAndClosed: syncedAndClosed ?? this.syncedAndClosed,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
