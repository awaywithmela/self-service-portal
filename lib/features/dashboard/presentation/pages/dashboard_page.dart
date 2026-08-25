import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/page_content.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interviewer dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
                context.go('/auth');
              },
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Sign out'),
            ),
          ),
        ],
      ),
      body: PageContent(
        maxWidth: 1080,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WelcomePanel(
              name: user?.displayName,
              deviceId: user?.deviceId,
            ),
            const SizedBox(height: 30),
            Text(
              'Self-service tools',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.darkText,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose what you need help with today.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 840 ? 3 : 1;
                final width = columns == 3
                    ? (constraints.maxWidth - 32) / 3
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _DashboardAction(
                      width: width,
                      featured: true,
                      title: 'Update I-Reach',
                      description:
                          'Confirm this device and run the update checklist.',
                      icon: Icons.system_update_alt_rounded,
                      actionLabel: 'Start update',
                      onTap: () => context.go('/update-ireach'),
                    ),
                    _DashboardAction(
                      width: width,
                      title: 'Knowledge Base',
                      description:
                          'Find guidance for sync, updates, and connectivity.',
                      icon: Icons.menu_book_rounded,
                      actionLabel: 'Browse guides',
                      onTap: () => context.go('/knowledge-base'),
                    ),
                    _DashboardAction(
                      width: width,
                      title: 'Help Desk',
                      description:
                          'Create a support request with your account context.',
                      icon: Icons.support_agent_rounded,
                      actionLabel: 'Get support',
                      onTap: () => context.go('/support-ticket'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.name, required this.deviceId});

  final String? name;
  final String? deviceId;

  @override
  Widget build(BuildContext context) {
    final cleanName = name?.trim();
    final cleanDevice = deviceId?.trim();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.tealDark, Color(0xFF176D72)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppTheme.tealDark.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final greeting = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SIGNED IN',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.tealLight,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                cleanName == null || cleanName.isEmpty
                    ? 'Welcome back'
                    : 'Welcome back, $cleanName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 27,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your interviewer tools are ready.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
              ),
            ],
          );
          final device = Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.laptop_windows_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned device',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                    ),
                    Text(
                      cleanDevice == null || cleanDevice.isEmpty
                          ? 'Not available'
                          : cleanDevice,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [greeting, const SizedBox(height: 22), device],
            );
          }
          return Row(
            children: [
              Expanded(child: greeting),
              const SizedBox(width: 24),
              device,
            ],
          );
        },
      ),
    );
  }
}

class _DashboardAction extends StatelessWidget {
  const _DashboardAction({
    required this.width,
    required this.title,
    required this.description,
    required this.icon,
    required this.actionLabel,
    required this.onTap,
    this.featured = false,
  });

  final double width;
  final String title;
  final String description;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 290,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: featured ? AppTheme.primaryTeal : AppTheme.tealMuted,
                width: featured ? 2 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.tealDark.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                        featured ? AppTheme.primaryTeal : AppTheme.tealSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: featured
                          ? Colors.white.withValues(alpha: 0.22)
                          : AppTheme.tealMuted,
                    ),
                  ),
                  child: title == 'Knowledge Base'
                      ? const CustomPaint(
                          size: Size.square(30),
                          painter: _KnowledgeBaseIconPainter(),
                        )
                      : Icon(
                          icon,
                          color: featured ? Colors.white : AppTheme.tealDark,
                          size: 30,
                        ),
                ),
                const SizedBox(height: 18),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(description,
                    style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      actionLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.tealDark,
                            fontSize: 15,
                          ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppTheme.tealDark,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KnowledgeBaseIconPainter extends CustomPainter {
  const _KnowledgeBaseIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.tealDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final center = size.width / 2;

    final leftPage = Path()
      ..moveTo(center, 7)
      ..cubicTo(11, 5, 7, 5, 4, 7)
      ..lineTo(4, 24)
      ..cubicTo(8, 22, 12, 22, center, 25);
    final rightPage = Path()
      ..moveTo(center, 7)
      ..cubicTo(19, 5, 23, 5, 26, 7)
      ..lineTo(26, 24)
      ..cubicTo(22, 22, 18, 22, center, 25);

    canvas.drawPath(leftPage, paint);
    canvas.drawPath(rightPage, paint);
    canvas.drawLine(Offset(center, 7), Offset(center, 25), paint);
  }

  @override
  bool shouldRepaint(covariant _KnowledgeBaseIconPainter oldDelegate) => false;
}
