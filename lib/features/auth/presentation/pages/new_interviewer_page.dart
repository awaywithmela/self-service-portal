import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/loading_dialog.dart';
import '../../../../core/widgets/page_content.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_notifier.dart';

class NewInterviewerPage extends ConsumerStatefulWidget {
  const NewInterviewerPage({super.key});

  @override
  ConsumerState<NewInterviewerPage> createState() => _NewInterviewerPageState();
}

class _NewInterviewerPageState extends ConsumerState<NewInterviewerPage> {
  final _emailController = TextEditingController();
  final _lastFourController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _lastFourController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingDialog(message: 'Verifying details...'),
    );

    final success = await ref
        .read(authNotifierProvider.notifier)
        .authenticateNewInterviewer(
          _emailController.text.trim(),
          _lastFourController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
    if (!success) {
      final error = ref.read(authNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Verification failed. Please check your details.'),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
    }
  }

  void _returnToStart() {
    ref.read(authNotifierProvider.notifier).logout();
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final isVerifiedNewInterviewer = user?.type == UserType.newInterviewer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Interviewer Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _returnToStart,
        ),
      ),
      body: PageContent(
        maxWidth: 780,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width < 600 ? 20 : 32,
          vertical: 28,
        ),
        child: isVerifiedNewInterviewer
            ? _buildSetupGuide(context, user!)
            : _buildVerificationForm(context),
      ),
    );
  }

  Widget _buildVerificationForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppTheme.tealMuted, width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          size: 30,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verify your identity',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'New Interviewer Device Setup',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightText,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Enter the email address registered with Ipsos and the last 4 digits of your mobile number. We will use this to find your assigned device, generate your login PIN, and provide setup instructions.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Email Address',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'e.g. yourname@ipsos.com',
              prefixIcon: Icon(Icons.email_outlined, size: 24),
            ),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) {
                return 'Email address is required';
              }
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Mobile Phone',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _lastFourController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 4,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: const InputDecoration(
              labelText: 'Last 4 digits of mobile number',
              hintText: 'e.g. 2235',
              prefixIcon: Icon(Icons.phone_iphone_rounded, size: 24),
              counterText: '',
            ),
            onFieldSubmitted: (_) => _verify(),
            validator: (value) {
              final digits = value?.trim() ?? '';
              if (!RegExp(r'^\d{4}$').hasMatch(digits)) {
                return 'Enter exactly 4 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 36),
          ElevatedButton.icon(
            onPressed: _verify,
            icon: const Icon(Icons.verified_rounded, size: 22),
            label: const Text('Verify Details'),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () => context.go('/knowledge-base'),
              icon: const Icon(Icons.menu_book_rounded, size: 22),
              label: Text(
                'Need setup help? Check the Knowledge Base',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.tealDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupGuide(BuildContext context, UserEntity user) {
    final firstName = user.displayName.trim().split(RegExp(r'\s+')).first;
    final deviceType = _displayDeviceType(user.deviceType);
    final instructions = _instructionsFor(user.deviceType);
    final pin = user.devicePin?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.tealDark, AppTheme.primaryTeal],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sentiment_satisfied_alt_rounded,
                    size: 36, color: Colors.white),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $firstName!',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your details have been verified. Follow the setup steps below for your assigned device.',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (pin != null && pin.isNotEmpty) ...[
          _buildPinCard(context, pin),
          const SizedBox(height: 20),
        ],
        _buildDeviceSummary(context, user, deviceType),
        const SizedBox(height: 20),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.tealMuted, width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.settings_suggest_rounded,
                        color: AppTheme.tealDark, size: 26),
                    const SizedBox(width: 12),
                    Text(
                      '$deviceType Setup Guide',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                for (int i = 0; i < instructions.length; i++)
                  _buildSetupStep(context, i + 1, instructions[i]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/knowledge-base'),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Knowledge Base'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.go('/support-ticket'),
                icon: const Icon(Icons.support_agent_rounded),
                label: const Text('Contact Support'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceSummary(
    BuildContext context,
    UserEntity user,
    String deviceType,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.tealMuted, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assigned Device Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 18),
            _buildDetailRow(
              context,
              Icons.devices_rounded,
              'Device ID',
              user.deviceId ?? 'Not available',
            ),
            _buildDetailRow(
              context,
              Icons.laptop_mac_rounded,
              'Type',
              deviceType,
            ),
            _buildDetailRow(
              context,
              Icons.work_outline_rounded,
              'Project',
              user.project ?? 'Not available',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinCard(BuildContext context, String pin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.tealSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryTeal, width: 1.8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pin_rounded,
                color: AppTheme.tealDark, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First-Login Device PIN',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pin,
                  style: GoogleFonts.nunito(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.tealDark,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.tealMuted),
            ),
            child: Text(
              'Initial Login',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.tealDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.tealDark, size: 22),
          const SizedBox(width: 12),
          SizedBox(
            width: 88,
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    )),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupStep(BuildContext context, int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.tealSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.tealMuted, width: 1.5),
            ),
            child: Text(
              '$number',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: AppTheme.tealDark,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.4,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayDeviceType(String? rawType) {
    final type = rawType?.trim();
    if (type == null || type.isEmpty) {
      return 'Assigned device';
    }
    if (type.toLowerCase().contains('android')) {
      return 'Android tablet';
    }
    if (type.toLowerCase().contains('win') ||
        type.toLowerCase().contains('laptop')) {
      return 'Windows laptop';
    }
    return type;
  }

  List<String> _instructionsFor(String? rawType) {
    final type = rawType?.toLowerCase() ?? '';
    if (type.contains('android')) {
      return const [
        'Power on the Android tablet and unlock using your assigned device PIN.',
        'Connect to Wi-Fi using your home network credentials.',
        'Open Microsoft Teams and sign in with your Ipsos work email.',
        'Open the I-Reach application and complete first-time interviewer setup.',
        'Perform an initial sync before starting live field interviewing.',
      ];
    }

    return const [
      'Power on your laptop and wait for the Windows sign-in screen.',
      'Enter your assigned first-login PIN shown above to unlock the laptop.',
      'Connect the laptop to your home Wi-Fi network.',
      'Open Microsoft Teams and verify you are connected.',
      'Launch I-Reach from the desktop and complete the first sync before starting fieldwork.',
    ];
  }
}
