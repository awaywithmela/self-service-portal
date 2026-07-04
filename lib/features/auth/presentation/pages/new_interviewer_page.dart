import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading_dialog.dart';
import '../../../../core/widgets/page_content.dart';
import '../providers/auth_notifier.dart';

class NewInterviewerPage extends ConsumerStatefulWidget {
  const NewInterviewerPage({super.key});

  @override
  ConsumerState<NewInterviewerPage> createState() => _NewInterviewerPageState();
}

class _NewInterviewerPageState extends ConsumerState<NewInterviewerPage> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingDialog(message: 'Authenticating...'),
    );

    final success = await ref
        .read(authNotifierProvider.notifier)
        .authenticateNewInterviewer(
            _emailController.text, _phoneController.text);

    if (mounted) {
      Navigator.of(context).pop();
      if (success) {
        context.go('/device-setup');
      } else {
        final error = ref.read(authNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Authentication failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Interviewer Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/auth'),
        ),
      ),
      body: PageContent(
        maxWidth: 720,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width < 600 ? 24 : 40,
          vertical: 28,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified_user,
                              size: 36, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text('Welcome to Ipsos',
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'We will verify your new interviewer record before opening the device knowledge guide. Your device has already been prepared in the backend and assigned a device ID.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 18),
                      _buildSetupSummary(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Your Email Address',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'your.email@example.com',
                  prefixIcon: Icon(Icons.email, size: 28),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              Text(
                'Last 4 Digits of Your Mobile Number',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  hintText: '1234',
                  prefixIcon: Icon(Icons.phone, size: 28),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                    return 'Please enter exactly 4 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.arrow_forward, size: 24),
                label: const Text('Open Knowledge Guide'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupSummary(BuildContext context) {
    final items = [
      (Icons.badge_outlined, 'Confirm your interviewer credentials'),
      (Icons.devices_outlined, 'Enter the device ID from the package'),
      (Icons.pin_outlined, 'Get PIN and first-login guidance'),
      (Icons.wifi_rounded, 'Connect WiFi, Teams, and Ipsos apps'),
    ];

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(item.$1, size: 22, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.$2,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
