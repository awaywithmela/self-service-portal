import '../../../../core/network/network_client.dart';
import '../../domain/entities/device_entity.dart';
import '../models/device_model.dart';

class DeviceRemoteDataSource {
  // ignore: unused_field
  final NetworkClient _client;
  const DeviceRemoteDataSource(this._client);

  // Test devices — replace with real RMM API calls when ready
  static const _testDevices = {
    'WIN-001': (type: 'windows', name: 'Laptop-WIN-001'),
    'WIN-002': (type: 'windows', name: 'Laptop-WIN-002'),
    'LAP-ABC-12345': (type: 'windows', name: 'Laptop-LAP-ABC'),
    'AND-001': (type: 'android', name: 'Tablet-AND-001'),
    'AND-002': (type: 'android', name: 'Tablet-AND-002'),
    'IOS-001': (type: 'ios', name: 'iPad-IOS-001'),
    'IOS-002': (type: 'ios', name: 'iPad-IOS-002'),
  };

  Future<DeviceModel> validateDevice(String deviceId) async {
    // TODO: replace with real RMM API call
    // final response = await _client.get('/api/devices/validate/$deviceId');
    // return DeviceModel.fromJson(response.data as Map<String, dynamic>);
    await Future.delayed(const Duration(milliseconds: 600));

    final device = _testDevices[deviceId.trim().toUpperCase()];
    if (device == null) {
      throw Exception('Device ID "$deviceId" not found. Please check the ID and try again.');
    }

    return DeviceModel(
      deviceId: deviceId,
      type: DeviceType.fromString(device.type),
      name: device.name,
    );
  }

  Future<String> executeIReachUpdate(String deviceId) async {
    // TODO: replace with real RMM API call
    // await _client.post('/api/updates/ireach/execute/$deviceId');
    await Future.delayed(const Duration(milliseconds: 1200));
    return 'iReach update started successfully on $deviceId';
  }
}
