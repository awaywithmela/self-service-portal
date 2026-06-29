import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/device_data_source.dart';
import '../../data/datasources/device_remote_datasource.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/usecases/validate_device.dart';
import '../../domain/usecases/execute_ireach_update.dart';
import '../../../../core/network/network_providers.dart';

final _deviceDataSourceProvider = Provider<DeviceDataSource>((ref) {
  return DeviceRemoteDataSource(ref.read(networkClientProvider));
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepositoryImpl(ref.read(_deviceDataSourceProvider));
});

final validateDeviceProvider = Provider<ValidateDevice>((ref) {
  return ValidateDevice(ref.read(deviceRepositoryProvider));
});

final executeIReachUpdateProvider = Provider<ExecuteIReachUpdate>((ref) {
  return ExecuteIReachUpdate(ref.read(deviceRepositoryProvider));
});
