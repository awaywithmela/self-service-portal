import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';
import '../../../../core/errors/result.dart';

class ValidateDevice {
  final DeviceRepository _repository;
  const ValidateDevice(this._repository);

  Future<Result<DeviceEntity>> call(String deviceId) =>
      _repository.validateDevice(deviceId);
}
