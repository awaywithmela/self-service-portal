import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_service_portal/core/errors/result.dart';
import 'package:self_service_portal/features/auth/domain/entities/user_entity.dart';
import 'package:self_service_portal/features/auth/presentation/providers/auth_notifier.dart';
import 'package:self_service_portal/features/auth/presentation/providers/auth_state.dart';
import 'package:self_service_portal/features/device/data/ireach/ireach_service.dart';
import 'package:self_service_portal/features/device/domain/entities/device_entity.dart';
import 'package:self_service_portal/features/device/domain/repositories/device_repository.dart';
import 'package:self_service_portal/features/device/presentation/pages/update_ireach_page.dart';

/// Simulates having already authenticated on the existing-interviewer login
/// screen, so UpdateIReachPage can read a real session back out of
/// authNotifierProvider instead of hitting the network.
class _SeededAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(
        isAuthenticated: true,
        user: UserEntity(
          id: 'surveyor',
          username: 'surveyor',
          displayName: 'Jane Interviewer',
          type: UserType.existingInterviewer,
          deviceId: 'IPLT569',
          sessionToken: 'test-token',
        ),
      );
}

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

    final isPlain = response is String &&
        !response.startsWith('{') &&
        !response.startsWith('[');
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

/// Fakes the proxy-backed device repository so the widget test doesn't need
/// a running tool/dev_api_proxy.dart instance.
class _FakeDeviceRepository implements DeviceRepository {
  @override
  Future<Result<DeviceEntity>> validateDevice(String deviceId) async =>
      throw UnimplementedError();

  @override
  Future<Result<String>> executeIReachUpdate(
          String deviceId, String sessionToken) async =>
      const Success('I-Reach has been updated. You can now reopen it.');
}

void main() {
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
      api2Key: 'test-key',
    );

    deviceRepository = _FakeDeviceRepository();
  });

  testWidgets(
    'UpdateIReachPage does not show a second login when the session is missing',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: UpdateIReachPage(
              service: service,
              deviceRepository: deviceRepository,
            ),
          ),
        ),
      );

      expect(find.text('Existing Interviewer Login'), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      expect(
        find.text(
          'Your session has expired. Please sign in again to continue.',
        ),
        findsOneWidget,
      );
      expect(find.text('Return to sign in'), findsOneWidget);
    },
  );

  testWidgets(
    'UpdateIReachPage skips the login step and shows the computer name when '
    'a session already exists from the existing-interviewer login screen',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(_SeededAuthNotifier.new),
          ],
          child: MaterialApp(
            home: UpdateIReachPage(
              service: service,
              deviceRepository: deviceRepository,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Straight to Step 3 (Confirm Device) — no second login form at all.
      expect(find.text('Existing Interviewer Login'), findsNothing);
      expect(find.text('Update I-Reach application'), findsWidgets);
      expect(find.text('IPLT569'), findsOneWidget);

      final continueButton = find.text('Continue');
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();
      expect(find.text('Double-check I-Reach is closed'), findsOneWidget);
      await tester.tap(find.text('Yes, it is closed'));
      await tester.pumpAndSettle();

      final startButtonFinder = find.ancestor(
        of: find.text('Start Update'),
        matching: find.byWidgetPredicate((w) => w is ElevatedButton),
      );
      await tester.ensureVisible(startButtonFinder);
      await tester.tap(startButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('I-Reach update triggered.'), findsOneWidget);
    },
  );
}
