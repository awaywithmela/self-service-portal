import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading_dialog.dart';
import '../../../../core/widgets/page_content.dart';
import '../providers/device_notifier.dart';

class UpdateIReachPage extends ConsumerStatefulWidget {
  const UpdateIReachPage({super.key});

  @override
  ConsumerState<UpdateIReachPage> createState() => _UpdateIReachPageState();
}

class _UpdateIReachPageState extends ConsumerState<UpdateIReachPage> {
  final _deviceIdController = TextEditingController();
  bool _iReachClosed = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(deviceNotifierProvider, (_, __) {});
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    ref.read(deviceNotifierProvider.notifier).reset();
    super.dispose();
  }

  Future<void> _validateDevice() async {
    if (_deviceIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a device ID')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingDialog(message: 'Validating device...'),
    );

    final success = await ref
        .read(deviceNotifierProvider.notifier)
        .validateDevice(_deviceIdController.text);

    if (mounted) {
      Navigator.of(context).pop();
      if (!success) {
        final error = ref.read(deviceNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Device not found')),
        );
      }
    }
  }

  Future<void> _executeUpdate() async {
    if (!_iReachClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please confirm iReach is closed before proceeding')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingDialog(message: 'Initiating update...'),
    );

    final success = await ref
        .read(deviceNotifierProvider.notifier)
        .executeIReachUpdate(_deviceIdController.text);

    if (mounted) {
      Navigator.of(context).pop();
      if (!success) {
        final error = ref.read(deviceNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Update failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update iReach'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(deviceNotifierProvider.notifier).reset();
            context.go('/existing-interviewer-dashboard');
          },
        ),
      ),
      body: PageContent(
        child: deviceState.updateStarted
            ? _buildUpdateSuccess(context,
                deviceState.updateMessage ?? 'Update started successfully')
            : deviceState.isValidated
                ? _buildUpdatePrompt(context)
                : _buildDeviceEntry(context),
      ),
    );
  }

  Widget _buildDeviceEntry(BuildContext context) {
    return Column(
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
                    Icon(Icons.system_update,
                        size: 36, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Text('Update iReach Application',
                            style: Theme.of(context).textTheme.headlineSmall)),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'A new version of iReach is available. Enter your device ID to start the update process.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 48),
        Text('Device ID',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        TextField(
          controller: _deviceIdController,
          decoration: const InputDecoration(
            hintText: 'e.g., TAB-DEF-67890',
            prefixIcon: Icon(Icons.devices, size: 28),
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton.icon(
          onPressed: _validateDevice,
          icon: const Icon(Icons.arrow_forward, size: 24),
          label: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildUpdatePrompt(BuildContext context) {
    return Column(
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
                    Icon(Icons.warning_amber_rounded,
                        size: 36, color: Colors.orange.shade700),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Important: Close iReach First',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Before we can update iReach, you must close the application completely to avoid losing any data.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Follow These Steps:',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildStep(
                    context, 'Locate the iReach application on your device'),
                _buildStep(context, 'Close all iReach windows and dialogues'),
                _buildStep(context, 'Make sure iReach is completely closed'),
                _buildStep(context, 'Return here when done'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        CheckboxListTile(
          value: _iReachClosed,
          onChanged: (value) => setState(() => _iReachClosed = value ?? false),
          title: Text('I have closed iReach',
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text('Confirm that iReach is completely closed',
              style: Theme.of(context).textTheme.bodyMedium),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _iReachClosed ? _executeUpdate : null,
          icon: const Icon(Icons.play_arrow, size: 24),
          label: const Text('Start Update'),
        ),
      ],
    );
  }

  Widget _buildUpdateSuccess(BuildContext context, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.green.shade600, size: 80),
                const SizedBox(height: 24),
                Text(
                  'Update Started Successfully',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.green.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200, width: 2),
                  ),
                  child: Text(
                    'Estimated time: 5-10 minutes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 32, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'What to Expect Next',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStep(
                    context, 'iReach will automatically close and update'),
                _buildStep(context, 'Please do not turn off your device'),
                _buildStep(
                    context, 'Your device may restart during the process'),
                _buildStep(
                    context, 'iReach will reopen automatically when complete'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(deviceNotifierProvider.notifier).reset();
            context.go('/existing-interviewer-dashboard');
          },
          icon: const Icon(Icons.home, size: 24),
          label: const Text('Return to Dashboard'),
        ),
      ],
    );
  }

  Widget _buildStep(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.check, size: 20, color: Colors.green.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}
