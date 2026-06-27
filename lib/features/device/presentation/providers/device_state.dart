import '../../domain/entities/device_entity.dart';

class DeviceState {
  final DeviceEntity? device;
  final bool isValidating;
  final bool isUpdating;
  final bool updateStarted;
  final String? updateMessage;
  final String? error;

  const DeviceState({
    this.device,
    this.isValidating = false,
    this.isUpdating = false,
    this.updateStarted = false,
    this.updateMessage,
    this.error,
  });

  const DeviceState.initial() : this();

  bool get isValidated => device != null;

  DeviceState copyWith({
    DeviceEntity? device,
    bool? isValidating,
    bool? isUpdating,
    bool? updateStarted,
    String? updateMessage,
    String? error,
    bool clearError = false,
    bool clearDevice = false,
  }) {
    return DeviceState(
      device: clearDevice ? null : (device ?? this.device),
      isValidating: isValidating ?? this.isValidating,
      isUpdating: isUpdating ?? this.isUpdating,
      updateStarted: updateStarted ?? this.updateStarted,
      updateMessage: updateMessage ?? this.updateMessage,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
