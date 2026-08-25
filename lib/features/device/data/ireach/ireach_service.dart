import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'ireach_config.dart';
import 'ireach_exceptions.dart';
import 'ireach_models.dart';

class IreachService {
  IreachService({Dio? smClient, Dio? api2Client, String? api2Key})
      : _sm = smClient ?? _createClient(IreachConfig.smBase),
        _api2 = api2Client ?? _createClient(IreachConfig.api2Base),
        _api2Key = api2Key ?? IreachConfig.api2Key;

  final Dio _sm;
  final Dio _api2;
  final String _api2Key;
  String? _token;

  String? get token => _token;

  static const _scriptBody = <String, dynamic>{
    'output': 'wait',
    'emails': <dynamic>[],
    'emailMode': 'default',
    'custom_field': null,
    'save_all_output': false,
    'script': 130,
    'args': <dynamic>[],
    'env_vars': <dynamic>[],
    'run_as_user': false,
    'timeout': 90,
  };

  static Dio _createClient(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
      sendTimeout: const Duration(seconds: 30),
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log('${options.method} ${options.uri.path}', name: 'iReach');
        handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log(
            '${response.statusCode} ${response.requestOptions.uri.path}',
            name: 'iReach');
        handler.next(response);
      },
      onError: (error, handler) {
        developer.log(
          '${error.response?.statusCode ?? 'network'} '
          '${error.requestOptions.method} ${error.requestOptions.uri.path}',
          name: 'iReach',
        );
        handler.next(error);
      },
    ));
    return dio;
  }

  Future<String> authenticate(String username, String password) async {
    try {
      final response = await _sm.post<String>(
        'Authentication',
        data: {'username': username, 'password': password},
        options: Options(
          headers: {'accept': 'text/plain', 'Content-Type': 'application/json'},
          responseType: ResponseType.plain,
        ),
      );
      final rawBody = (response.data ?? '').trim();
      final token = _extractToken(rawBody);
      _token = token;
      return token;
    } catch (error) {
      if (error is IreachException) {
        rethrow;
      }
      throw _authError(error);
    }
  }

  String _extractToken(String rawBody) {
    if (rawBody.isEmpty) {
      throw const AuthException(
        'Authentication returned an empty response.',
        statusCode: 401,
      );
    }

    if (rawBody.startsWith('{') && rawBody.endsWith('}')) {
      try {
        final decoded = jsonDecode(rawBody);
        if (decoded is Map<String, dynamic>) {
          final errorMessage = decoded['errorMessage'] ??
              decoded['message'] ??
              decoded['error'] ??
              decoded['detail'];
          final code = decoded['code'];

          if (code != null && code != 0) {
            throw AuthException(
              errorMessage?.toString().trim().isNotEmpty == true
                  ? errorMessage.toString().trim()
                  : 'Authentication failed. Please check your credentials.',
              statusCode: 401,
            );
          }

          if (errorMessage != null &&
              errorMessage.toString().trim().isNotEmpty) {
            throw AuthException(
              errorMessage.toString().trim(),
              statusCode: 401,
            );
          }

          final data = decoded['data'];
          if (data is Map<String, dynamic>) {
            final session = data['session'] ??
                data['token'] ??
                data['sessionId'] ??
                data['auth_token'];
            final sessionStr = session?.toString().trim();
            if (sessionStr != null && sessionStr.isNotEmpty) {
              return sessionStr;
            }
          } else if (data is String && data.trim().isNotEmpty) {
            return data.trim();
          }

          final topSession = decoded['session'] ??
              decoded['token'] ??
              decoded['sessionId'] ??
              decoded['auth_token'];
          final topSessionStr = topSession?.toString().trim();
          if (topSessionStr != null && topSessionStr.isNotEmpty) {
            return topSessionStr;
          }

          throw const AuthException(
            'Authentication failed. Please check your credentials.',
            statusCode: 401,
          );
        }
      } on FormatException {
        // Fall through to plain text token extraction.
      }
    }

    final token = _stripQuotes(rawBody);
    if (token.isEmpty) {
      throw const AuthException(
        'Authentication returned an empty token.',
        statusCode: 401,
      );
    }
    return token;
  }

  Future<CurrentUser> getCurrentUser(String token) async {
    try {
      final response = await _sm.get<dynamic>(
        'Users/GetCurrentUserData',
        options: Options(
          headers: {
            'sm-authorize': token,
            'accept': 'application/json, text/plain, */*',
          },
        ),
      );
      final raw = _asMap(response.data);
      final data = raw['data'] is Map || raw['data'] is String
          ? _asMap(raw['data'])
          : raw;
      return CurrentUser.fromJson(data);
    } catch (error) {
      if (error is IreachException) {
        rethrow;
      }
      final dioError = error is DioException ? error : null;
      if (dioError?.response?.statusCode == 401) {
        throw const AuthException(
          'Session expired. Please log in again.',
          statusCode: 401,
        );
      }
      throw _userDataError(error);
    }
  }

  Future<List<Agent>> getAgents() async {
    _requireApiKey();
    try {
      final response = await _api2.get<dynamic>(
        'agents',
        options: Options(headers: _api2Headers),
      );
      final data = _decodeJson(response.data);
      final list = data is List
          ? data
          : data is Map
              ? (_asMap(data)['results'] ??
                  _asMap(data)['agents'] ??
                  _asMap(data)['data'])
              : null;
      if (list is! List) {
        throw const FormatException('Agents response was not a list.');
      }
      return list.whereType<Map<String, dynamic>>().map(Agent.fromJson).toList();
    } catch (error) {
      if (error is IreachException) {
        rethrow;
      }
      final dioError = error is DioException ? error : null;
      if (dioError?.response?.statusCode == 401) {
        throw const AuthException(
          'Session expired or unauthorized.',
          statusCode: 401,
        );
      }
      throw _runScriptError(error);
    }
  }

  Future<String> resolveAgentId(String computerNumber) async {
    final normalized = computerNumber.trim().toLowerCase();
    final agents = await getAgents();
    for (final agent in agents) {
      if (agent.hostname.trim().toLowerCase() == normalized) {
        return agent.agentId;
      }
    }
    throw AgentNotFoundException(
      'Device not registered — please contact help desk.',
      computerNumber.trim(),
    );
  }

  Future<Map<String, dynamic>> runUpdateScript(String agentId) async {
    _requireApiKey();
    try {
      final response = await _api2.post<dynamic>(
        'agents/${Uri.encodeComponent(agentId)}/runscript/',
        data: _scriptBody,
        options: Options(
          headers: _api2Headers,
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
      return _asMap(response.data);
    } catch (error) {
      if (error is IreachException) {
        rethrow;
      }
      final dioError = error is DioException ? error : null;
      if (dioError?.response?.statusCode == 401) {
        throw const AuthException(
          'Session expired or unauthorized.',
          statusCode: 401,
        );
      }
      throw _runScriptError(error);
    }
  }

  Future<Map<String, dynamic>> updateMyDevice(
    String username,
    String password, {
    void Function(String step)? onStep,
  }) async {
    onStep?.call('Authenticating');
    developer.log('Authenticating', name: 'iReach');
    var token = await authenticate(username, password);
    onStep?.call('Fetching user');
    developer.log('Fetching user', name: 'iReach');
    CurrentUser user;
    try {
      user = await getCurrentUser(token);
    } on AuthException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }
      developer.log('Session expired; re-authenticating', name: 'iReach');
      token = await authenticate(username, password);
      user = await getCurrentUser(token);
    }
    onStep?.call('Finding device');
    developer.log('Finding device', name: 'iReach');
    final agentId = await resolveAgentId(user.computerNumber);
    onStep?.call('Running update');
    developer.log('Running update', name: 'iReach');
    return runUpdateScript(agentId);
  }

  Map<String, String> get _api2Headers => {
        'X-API-KEY': _api2Key,
        'Content-Type': 'application/json',
      };

  void _requireApiKey() {
    if (_api2Key.isEmpty) {
      throw const RunScriptException('IPSOS_API2_KEY is not configured.');
    }
  }

  AuthException _authError(Object error) {
    final dioError = error is DioException ? error : null;
    final message = dioError == null
        ? null
        : switch (dioError.type) {
            DioExceptionType.connectionError =>
              'Could not connect to the SM API. Check the network connection and browser CORS configuration.',
            DioExceptionType.connectionTimeout ||
            DioExceptionType.receiveTimeout ||
            DioExceptionType.sendTimeout =>
              'The SM API request timed out. Please try again.',
            _ => null,
          };
    return AuthException(
      message ??
          _safeMessage(
            dioError?.response?.data,
            'Authentication failed. Please check your credentials.',
          ),
      statusCode: dioError?.response?.statusCode,
    );
  }

  UserDataException _userDataError(Object error) {
    final dioError = error is DioException ? error : null;
    final message = dioError == null
        ? null
        : switch (dioError.type) {
            DioExceptionType.connectionError =>
              'Could not connect to the SM API to retrieve user data.',
            DioExceptionType.connectionTimeout ||
            DioExceptionType.receiveTimeout ||
            DioExceptionType.sendTimeout =>
              'The request to fetch user data timed out. Please try again.',
            _ => null,
          };
    return UserDataException(
      message ??
          _safeMessage(
            dioError?.response?.data,
            'Could not retrieve user data.',
          ),
      statusCode: dioError?.response?.statusCode,
    );
  }

  RunScriptException _runScriptError(Object error) {
    final dioError = error is DioException ? error : null;
    final message = dioError == null
        ? null
        : switch (dioError.type) {
            DioExceptionType.connectionError =>
              'Could not connect to the API2 device service. Check the network connection and browser CORS configuration.',
            DioExceptionType.connectionTimeout ||
            DioExceptionType.receiveTimeout ||
            DioExceptionType.sendTimeout =>
              'The API2 device request timed out. Please try again.',
            _ => null,
          };
    return RunScriptException(
      message ??
          _safeMessage(
            dioError?.response?.data,
            'iReach device update failed.',
          ),
      statusCode: dioError?.response?.statusCode,
    );
  }

  String _safeMessage(dynamic data, String fallback) {
    final message = data is Map
        ? (data['message'] ?? data['detail'] ?? data['error'])
        : data;
    final text = message?.toString().trim();
    if (text == null || text.isEmpty) {
      return fallback;
    }
    var safeText = text;
    if (_api2Key.isNotEmpty) {
      safeText = safeText.replaceAll(_api2Key, '[redacted]');
    }
    final token = _token;
    if (token != null && token.isNotEmpty) {
      safeText = safeText.replaceAll(token, '[redacted]');
    }
    return safeText;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    final decoded = _decodeJson(data);
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw const FormatException('API response was not an object.');
  }

  dynamic _decodeJson(dynamic data) {
    if (data is! String) {
      return data;
    }
    final trimmed = data.trim();
    if (trimmed.isEmpty) {
      return data;
    }
    try {
      return jsonDecode(trimmed);
    } on FormatException {
      return data;
    }
  }

  String _stripQuotes(String value) => value.length >= 2 &&
          ((value.startsWith('"') && value.endsWith('"')) ||
              (value.startsWith("'") && value.endsWith("'")))
      ? value.substring(1, value.length - 1).trim()
      : value;
}
