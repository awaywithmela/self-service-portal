import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/usecases/use_case.dart';

final class ValidateDeviceParams {
  final String deviceId;
  const ValidateDeviceParams(this.deviceId);
}

class ValidateDevice implements UseCase<DeviceEntity, ValidateDeviceParams> {
  final DeviceRepository _repository;
  const ValidateDevice(this._repository);

  @override
  Future<Result<DeviceEntity>> call(ValidateDeviceParams params) =>
      _repository.validateDevice(params.deviceId);
}
