import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/loading_dialog.dart';
import '../providers/auth_notifier.dart';

class ExistingInterviewerPage extends ConsumerStatefulWidget {
  const ExistingInterviewerPage({super.key});

  @override
  ConsumerState<ExistingInterviewerPage> createState() =>
      _ExistingInterviewerPageState();
}

class _ExistingInterviewerPageState
    extends ConsumerState<ExistingInterviewerPage> {
  static const _helpDeskNumber = '0800 478 783';

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingDialog(
        message: 'Checking your interviewer account...',
      ),
    );

    final success = await ref
        .read(authNotifierProvider.notifier)
        .authenticateExistingInterviewer(
          _usernameController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;
    Navigator.of(context).pop();

    if (success) {
      context.go('/update-ireach');
      return;
    }

    final error = ref.read(authNotifierProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'Authentication failed. Please check your credentials.',
        ),
        backgroundColor: const Color(0xFFB42318),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _LoginBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 760;
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 10,
                        shadowColor: AppTheme.tealDark.withValues(alpha: 0.14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                          side: BorderSide(
                            color: AppTheme.tealMuted.withValues(alpha: 0.75),
                          ),
                        ),
                        child: wide
                            ? IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Expanded(
                                      flex: 4,
                                      child: _LoginIntroduction(),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: _buildForm(context),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  const _LoginIntroduction(compact: true),
                                  _buildForm(context),
                                ],
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sign in',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.darkText,
                      fontSize: 28,
                    ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _usernameController,
                autofillHints: const [AutofillHints.username],
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Username',
                ),
                validator: (value) {
                  final username = value?.trim() ?? '';
                  if (username.isEmpty) return 'Username is required';
                  if (!RegExp(r'^[A-Za-z0-9._-]{2,64}$').hasMatch(username)) {
                    return 'Enter a valid username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _passwordController,
                autofillHints: const [AutofillHints.password],
                obscureText: _obscurePassword,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _authenticate(),
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      tooltip:
                          _obscurePassword ? 'Show password' : 'Hide password',
                      style: IconButton.styleFrom(
                        foregroundColor: AppTheme.tealDark,
                        backgroundColor:
                            AppTheme.tealMuted.withValues(alpha: 0.28),
                        hoverColor:
                            AppTheme.primaryTeal.withValues(alpha: 0.18),
                      ),
                      icon: CustomPaint(
                        size: const Size.square(24),
                        painter: _EyeIconPainter(hidden: !_obscurePassword),
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length > 128) return 'Password is too long';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _authenticate,
                child: const Text('Sign in'),
              ),
              const SizedBox(height: 18),
              TextButton.icon(
                onPressed: _showHelpDeskDialog,
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('Contact Help Desk'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDeskDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.support_agent_rounded),
        title: const Text('Contact Help Desk'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Call us for help with your account or device.'),
            SizedBox(height: 16),
            SelectableText(
              _helpDeskNumber,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.tealDark,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _EyeIconPainter extends CustomPainter {
  const _EyeIconPainter({required this.hidden});

  final bool hidden;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.tealDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final center = Offset(size.width / 2, size.height / 2);
    final eye = Path()
      ..moveTo(2, center.dy)
      ..quadraticBezierTo(center.dx, 3, size.width - 2, center.dy)
      ..quadraticBezierTo(center.dx, size.height - 3, 2, center.dy);
    canvas.drawPath(eye, paint);
    canvas.drawCircle(center, 3.2, paint);

    if (hidden) {
      canvas.drawLine(
          const Offset(3, 3), Offset(size.width - 3, size.height - 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EyeIconPainter oldDelegate) {
    return oldDelegate.hidden != hidden;
  }
}

class _LoginIntroduction extends StatelessWidget {
  const _LoginIntroduction({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 28 : 38),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.tealDark, Color(0xFF1B6F73)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            child: const Icon(
              Icons.system_update_alt_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Update I-Reach',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontSize: compact ? 28 : 34,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to continue.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.tealSurface,
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.2,
          colors: [Color(0xFFD9F2F1), AppTheme.tealSurface],
        ),
      ),
    );
  }
}
