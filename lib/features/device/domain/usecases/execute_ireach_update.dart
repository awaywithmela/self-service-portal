import '../repositories/device_repository.dart';
import '../../../../core/errors/result.dart';

class ExecuteIReachUpdate {
  final DeviceRepository _repository;
  const ExecuteIReachUpdate(this._repository);

  Future<Result<String>> call(String deviceId) =>
      _repository.executeIReachUpdate(deviceId);
}
