import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_service_portal/features/auth/domain/entities/user_entity.dart';
import 'package:self_service_portal/features/auth/presentation/providers/auth_notifier.dart';
import 'package:self_service_portal/features/auth/presentation/providers/auth_state.dart';
import 'package:self_service_portal/features/dashboard/presentation/pages/dashboard_page.dart';

class _DashboardAuthNotifier extends AuthNotifier {
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

void main() {
  for (final size in const [Size(1600, 1000), Size(430, 900)]) {
    testWidgets('renders dashboard without layout errors at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(_DashboardAuthNotifier.new),
          ],
          child: const MaterialApp(home: DashboardPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Interviewer dashboard'), findsOneWidget);
      expect(find.text('Welcome back, Jane Interviewer'), findsOneWidget);
      expect(find.text('IPLT569'), findsOneWidget);
      expect(find.text('Update I-Reach'), findsOneWidget);
      expect(find.text('Knowledge Base'), findsOneWidget);
      expect(find.text('Help Desk'), findsOneWidget);
    });
  }
}
