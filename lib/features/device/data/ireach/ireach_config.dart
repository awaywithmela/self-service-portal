import '../../../../core/constants/app_constants.dart';

abstract final class IreachConfig {
  // smstg.ipsos.co.nz sends no Access-Control-Allow-Origin header (confirmed via
  // curl: its OPTIONS preflight returns 405), so a browser blocks every direct
  // request. Default through the CORS-enabled proxy in tool/dev_api_proxy.dart
  // instead; override with --dart-define=IPSOS_SM_BASE=... only for a proxy that
  // actually forwards with CORS headers, never for the bare Ipsos host.
  static const String smBase = String.fromEnvironment(
    'IPSOS_SM_BASE',
    defaultValue: '${AppConstants.baseUrl}/api/v1',
  );
  static const String api2Base = String.fromEnvironment(
    'IPSOS_API2_BASE',
    defaultValue: 'https://api2.ipsos.co.nz',
  );
  static const String api2Key = String.fromEnvironment('IPSOS_API2_KEY');
}
