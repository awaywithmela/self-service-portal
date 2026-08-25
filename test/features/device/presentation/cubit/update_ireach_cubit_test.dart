import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_service_portal/core/errors/failures.dart';
import 'package:self_service_portal/core/errors/result.dart';
import 'package:self_service_portal/features/device/data/ireach/ireach_service.dart';
import 'package:self_service_portal/features/device/domain/entities/device_entity.dart';
import 'package:self_service_portal/features/device/domain/repositories/device_repository.dart';
import 'package:self_service_portal/features/device/presentation/cubit/update_ireach_cubit.dart';
import 'package:self_service_portal/features/device/presentation/cubit/update_ireach_state.dart';

class _FakeAdapter implements HttpClientAdapter {
  final Map<String, dynamic> responses;
  final List<RequestOptions> requests = [];

  _FakeAdapter(this.responses);

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
        jsonEncode({'error': 'Not found'}),
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    final isPlain = response is String && !response.startsWith('{') && !response.startsWith('[');
    return ResponseBody.fromString(
      response is String ? response : jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [
          isPlain ? 'text/plain' : Headers.jsonContentType,
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Fakes the proxy-backed device repository so cubit tests don't need a
/// running tool/dev_api_proxy.dart instance.
class _FakeDeviceRepository implements DeviceRepository {
  Result<String> executeResult =
      const Success('I-Reach has been updated. You can now reopen it.');
  final List<({String deviceId, String sessionToken})> executeCalls = [];

  @override
  Future<Result<DeviceEntity>> validateDevice(String deviceId) async =>
      throw UnimplementedError();

  @override
  Future<Result<String>> executeIReachUpdate(
      String deviceId, String sessionToken) async {
    executeCalls.add((deviceId: deviceId, sessionToken: sessionToken));
    return executeResult;
  }
}

void main() {
  group('UpdateIreachCubit', () {
    late IreachService service;
    late _FakeAdapter smAdapter;
    late _FakeDeviceRepository deviceRepository;

    setUp(() {
      smAdapter = _FakeAdapter({
        'Authentication': '"test-token"',
        'Users/GetCurrentUserData': {
          'computerNumber': 'IPLT569',
          'name': 'Jane Interviewer',
        },
      });

      service = IreachService(
        smClient: Dio()..httpClientAdapter = smAdapter,
        api2Client: Dio(),
        api2Key: 'valid-api-key',
      );

      deviceRepository = _FakeDeviceRepository();
    });

    test('initial state is idle and step is login', () {
      final cubit =
          UpdateIreachCubit(service: service, deviceRepository: deviceRepository);
      expect(cubit.state.status, UpdateIreachStatus.idle);
      expect(cubit.state.currentStep, UpdateIreachStep.login);
      expect(cubit.state.token, isNull);
      expect(cubit.state.deviceConfirmed, isFalse);
      expect(cubit.state.syncedAndClosed, isFalse);
    });

    test('login Step 1 and auto load user Step 2 transitions to confirmDevice Step 3', () async {
      final cubit =
          UpdateIreachCubit(service: service, deviceRepository: deviceRepository);

      await cubit.login('surveyor', 'secret');

      expect(cubit.state.token, 'test-token');
      expect(cubit.state.computerNumber, 'IPLT569');
      expect(cubit.state.name, 'Jane Interviewer');
      expect(cubit.state.status, UpdateIreachStatus.idle);
      expect(cubit.state.currentStep, UpdateIreachStep.confirmDevice);
      expect(cubit.state.deviceConfirmed, isFalse);
    });

    test('login with empty username or password emits error', () async {
      final cubit =
          UpdateIreachCubit(service: service, deviceRepository: deviceRepository);

      await cubit.login('', '');

      expect(cubit.state.isError, isTrue);
      expect(cubit.state.errorMessage, contains('Please enter both username and password'));
    });

    test('missing computerNumber halts with "No device on file — please contact help desk."', () async {
      smAdapter = _FakeAdapter({
        'Authentication': '"test-token"',
        'Users/GetCurrentUserData': {
          'computerNumber': '',
          'name': 'No Device User',
        },
      });
      service = IreachService(
        smClient: Dio()..httpClientAdapter = smAdapter,
        api2Client: Dio(),
        api2Key: 'valid-api-key',
      );
      final cubit =
          UpdateIreachCubit(service: service, deviceRepository: deviceRepository);

      await cubit.login('surveyor', 'secret');

      expect(cubit.state.isError, isTrue);
      expect(cubit.state.errorMessage, 'No device on file — please contact help desk.');
    });

    test('GATE 1: confirmDevice sets deviceConfirmed to true and moves to syncAndClose', () async {
      final cubit =
          UpdateIreachCubit(service: service, deviceRepository: deviceRepository);
      await cubit.login('surveyor', 'secret');

      cubit.confirmDevice();

      expect(cubit.state.deviceConfirmed, isTrue);
      expect(cubit.state.currentStep, UpdateIreachStep.syncAndClose);
    });

    test('returnToLogin on Step 3 resets state to login', () async {
      final cubit =
          UpdateIreachCubit(service: service, deviceRepository: deviceRepository);
      await cubit.login('surveyor', 'secret');

      cubit.returnToLogin();

      expect(cubit.state.currentStep, UpdateIreachStep.login);
      expect(cubit.state.token, isNull);
    });

    test('GATE 2: setSyncedAndClosed sets syncedAndClosed', () async {
      final cubit =
          UpdateIreachCubit(service: service, deviceRepository: deviceRepository);
      await cubit.login('surveyor', 'secret');
      cubit.confirmDevice();

      cubit.setSyncedAndClosed(true);

      expect(cubit.state.syncedAndClosed, isTrue);
    });

    test('GATE 2 hard guard: startUpdate does not fire if not confirmed or not synced', () async {
      final cubit =
          UpdateIreachCubit(service: service, deviceRepository: deviceRepository);
      await cubit.login('surveyor', 'secret');

      // deviceConfirmed is false, syncedAndClosed is false
      await cubit.startUpdate();
      expect(cubit.state.status, UpdateIreachStatus.idle);
      expect(deviceRepository.executeCalls, isEmpty);

      // confirm device but not synced
      cubit.confirmDevice();
      await cubit.startUpdate();
      expect(cubit.state.status, UpdateIreachStatus.idle);
      expect(deviceRepository.executeCalls, isEmpty);
    });

    test('Step 5 & 6 run through the device repository -> Step 7 (success)', () async {
      final cubit =
          UpdateIreachCubit(service: service, deviceRepository: deviceRepository);
      await cubit.login('surveyor', 'secret');
      cubit.confirmDevice();
      cubit.setSyncedAndClosed(true);

      await cubit.startUpdate();

      expect(cubit.state.status, UpdateIreachStatus.success);
      expect(cubit.state.currentStep, UpdateIreachStep.result);
      expect(deviceRepository.executeCalls, [
        (deviceId: 'IPLT569', sessionToken: 'test-token'),
      ]);
    });

    test('device not registered sets the repository failure message', () async {
      deviceRepository.executeResult = const Err(
        DeviceFailure('No managed device was found for IPLT569. Please contact the Help Desk.'),
      );
      final cubit =
          UpdateIreachCubit(service: service, deviceRepository: deviceRepository);
      await cubit.login('surveyor', 'secret');
      cubit.confirmDevice();
      cubit.setSyncedAndClosed(true);

      await cubit.startUpdate();

      expect(cubit.state.isError, isTrue);
      expect(cubit.state.currentStep, UpdateIreachStep.result);
      expect(
        cubit.state.errorMessage,
        contains('No managed device was found for IPLT569'),
      );
    });

    test('Step 7 failure allows retryUpdate() from Step 5', () async {
      deviceRepository.executeResult =
          const Err(DeviceFailure('Script timeout'));
      final cubit =
          UpdateIreachCubit(service: service, deviceRepository: deviceRepository);
      await cubit.login('surveyor', 'secret');
      cubit.confirmDevice();
      cubit.setSyncedAndClosed(true);

      await cubit.startUpdate();
      expect(cubit.state.isError, isTrue);
      expect(cubit.state.currentStep, UpdateIreachStep.result);

      // Now fix the repository response and retry
      deviceRepository.executeResult =
          const Success('I-Reach has been updated. You can now reopen it.');

      await cubit.retryUpdate();
      expect(cubit.state.isSuccess, isTrue);
      expect(cubit.state.currentStep, UpdateIreachStep.result);
    });

    test('session-expired failure on Start Update routes back to Step 1 login', () async {
      deviceRepository.executeResult = const Err(
        DeviceFailure('Your session has expired. Please log in again.'),
      );
      final cubit =
          UpdateIreachCubit(service: service, deviceRepository: deviceRepository);
      await cubit.login('surveyor', 'secret');
      cubit.confirmDevice();
      cubit.setSyncedAndClosed(true);

      await cubit.startUpdate();

      expect(cubit.state.isError, isTrue);
      expect(cubit.state.token, isNull);
      expect(cubit.state.currentStep, UpdateIreachStep.login);
    });
  });
}
