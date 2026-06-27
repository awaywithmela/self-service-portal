class DeviceEntity {
  final String deviceId;
  final DeviceType type;
  final String? name;

  const DeviceEntity({
    required this.deviceId,
    required this.type,
    this.name,
  });
}

enum DeviceType {
  windowsLaptop,
  androidTablet,
  iosTablet,
  unknown;

  String get displayName => switch (this) {
        DeviceType.windowsLaptop => 'Windows Laptop',
        DeviceType.androidTablet => 'Android Tablet',
        DeviceType.iosTablet => 'iOS Tablet',
        DeviceType.unknown => 'Unknown Device',
      };

  static DeviceType fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'windows' || 'windows_laptop' || 'windowslaptop' => DeviceType.windowsLaptop,
      'android' || 'android_tablet' || 'androidtablet' => DeviceType.androidTablet,
      'ios' || 'ios_tablet' || 'iostablet' => DeviceType.iosTablet,
      _ => DeviceType.unknown,
    };
  }
}
