import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_service_portal/features/device/data/ireach/ireach_exceptions.dart';
import 'package:self_service_portal/features/device/data/ireach/ireach_service.dart';

class _FakeAdapter implements HttpClientAdapter {
  final String basePath;
  final List<RequestOptions> requests = [];
  final Map<String, dynamic> responses;
  final Set<String> plainResponsePaths;

  _FakeAdapter(
    this.basePath,
    this.responses, {
    this.plainResponsePaths = const {},
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final response = responses[options.path];
    if (response == null) {
      return ResponseBody.fromString(
        jsonEncode({'error': 'not found'}),
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      response is String ? response : jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [
          plainResponsePaths.contains(options.path)
              ? 'text/plain'
              : Headers.jsonContentType,
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('chains SM computerNumber to API2 agent_id and runscript', () async {
    final sm = _FakeAdapter('/', {
      'Authentication': '"sm-token"',
      'Users/GetCurrentUserData': {'computerNumber': ' iplt569 '},
    });
    final api2 = _FakeAdapter('/', {
      'agents': [
        {'hostname': 'OTHER', 'agent_id': 'wrong'},
        {'hostname': 'IPLT569', 'agent_id': 'agent-569'},
      ],
      'agents/agent-569/runscript/': {'id': 'run-1', 'status': 'queued'},
    });

    final service = IreachService(
      smClient: Dio()..httpClientAdapter = sm,
      api2Client: Dio()..httpClientAdapter = api2,
      api2Key: 'test-key',
    );

    final result = await service.updateMyDevice('surveyor', 'password');

    expect(result, {'id': 'run-1', 'status': 'queued'});
    expect(sm.requests.map((request) => request.path), [
      'Authentication',
      'Users/GetCurrentUserData',
    ]);
    expect(api2.requests.map((request) => request.path), [
      'agents',
      'agents/agent-569/runscript/',
    ]);
    expect(api2.requests.last.data, {
      'output': 'wait',
      'emails': [],
      'emailMode': 'default',
      'custom_field': null,
      'save_all_output': false,
      'script': 130,
      'args': [],
      'env_vars': [],
      'run_as_user': false,
      'timeout': 90,
    });
    expect(sm.requests.first.headers['accept'], 'text/plain');
    expect(sm.requests.first.responseType, ResponseType.plain);
    expect(sm.requests[1].headers['sm-authorize'], 'sm-token');
    expect(service.token, 'sm-token');
    expect(api2.requests.last.headers['X-API-KEY'], 'test-key');
    expect(api2.requests.last.path, 'agents/agent-569/runscript/');
  });

  test('extracts token when Authentication returns JSON session payload', () async {
    final sm = _FakeAdapter('/', {
      'Authentication': jsonEncode({
        'code': 0,
        'data': {'session': 'sm-json-token'},
      }),
    });
    final service = IreachService(smClient: Dio()..httpClientAdapter = sm);

    final token = await service.authenticate('surveyor', 'password');
    expect(token, 'sm-json-token');
  });

  test('throws AuthException when Authentication returns JSON error structure', () async {
    final sm = _FakeAdapter('/', {
      'Authentication': jsonEncode({
        'code': -101,
        'data': {'session': ''},
        'errorMessage': 'Authentication Failed. Please try again',
      }),
    });
    final service = IreachService(smClient: Dio()..httpClientAdapter = sm);

    expect(
      () => service.authenticate('wrong-user', 'wrong-pass'),
      throwsA(
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Authentication Failed. Please try again',
        ),
      ),
    );
  });

  test('accepts an agents response wrapped in results', () async {
    final api2 = _FakeAdapter('/', {
      'agents': {
        'results': [
          {'hostname': 'iplt569', 'agent_id': 'agent-569'},
        ],
      },
    });
    final service = IreachService(
      api2Client: Dio()..httpClientAdapter = api2,
      api2Key: 'test-key',
    );

    expect(await service.resolveAgentId(' IPLT569 '), 'agent-569');
  });

  test('decodes current-user JSON returned as text/plain', () async {
    final sm = _FakeAdapter(
      '/',
      {
        'Users/GetCurrentUserData': '{"computerNumber":"IPLT569"}',
      },
      plainResponsePaths: {'Users/GetCurrentUserData'},
    );
    final service = IreachService(smClient: Dio()..httpClientAdapter = sm);

    final user = await service.getCurrentUser('sm-token');

    expect(user.computerNumber, 'IPLT569');
    expect(sm.requests.single.headers['sm-authorize'], 'sm-token');
  });

  test('throws a typed exception when no hostname matches', () async {
    final api2 = _FakeAdapter('/', {
      'agents': [
        {'hostname': 'OTHER', 'agent_id': 'agent-other'},
      ],
    });
    final service = IreachService(
      api2Client: Dio()..httpClientAdapter = api2,
      api2Key: 'test-key',
    );

    expect(
      () => service.resolveAgentId('IPLT569'),
      throwsA(isA<AgentNotFoundException>()),
    );
  });
}
