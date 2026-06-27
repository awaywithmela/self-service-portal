import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/device_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../datasources/device_remote_datasource.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource _dataSource;
  const DeviceRepositoryImpl(this._dataSource);

  @override
  Future<Result<DeviceEntity>> validateDevice(String deviceId) async {
    if (deviceId.length < 5) {
      return const Err(DeviceFailure('Device ID must be at least 5 characters'));
    }
    try {
      final device = await _dataSource.validateDevice(deviceId);
      return Success(device);
    } catch (e) {
      return Err(DeviceFailure('Device validation failed: $e'));
    }
  }

  @override
  Future<Result<String>> executeIReachUpdate(String deviceId) async {
    try {
      final message = await _dataSource.executeIReachUpdate(deviceId);
      return Success(message);
    } catch (e) {
      return Err(DeviceFailure('Update failed: $e'));
    }
  }
}
