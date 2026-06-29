import '../../domain/entities/device_entity.dart';

class DeviceModel {
  final String deviceId;
  final String deviceType;
  final String? deviceName;

  const DeviceModel({
    required this.deviceId,
    required this.deviceType,
    this.deviceName,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      deviceId: json['deviceId'] as String,
      deviceType: json['deviceType'] as String? ?? 'unknown',
      deviceName: json['deviceName'] as String?,
    );
  }

  DeviceEntity toEntity() => DeviceEntity(
        deviceId: deviceId,
        type: DeviceType.fromString(deviceType),
        name: deviceName,
      );
}
