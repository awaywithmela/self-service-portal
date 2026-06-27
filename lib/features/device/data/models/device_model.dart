import '../../domain/entities/device_entity.dart';

class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.deviceId,
    required super.type,
    super.name,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      deviceId: json['deviceId'] as String,
      type: DeviceType.fromString(json['deviceType'] as String?),
      name: json['deviceName'] as String?,
    );
  }
}
