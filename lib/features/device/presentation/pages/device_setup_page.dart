import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/device_entity.dart';
import '../../../../core/widgets/loading_dialog.dart';
import '../../../../core/widgets/page_content.dart';
import '../providers/device_notifier.dart';
import '../widgets/setup_instruction.dart';

class DeviceSetupPage extends ConsumerStatefulWidget {
  const DeviceSetupPage({super.key});

  @override
  ConsumerState<DeviceSetupPage> createState() => _DeviceSetupPageState();
}

class _DeviceSetupPageState extends ConsumerState<DeviceSetupPage> {
  final _deviceIdController = TextEditingController();

  @override
  void dispose() {
    _deviceIdController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(deviceNotifierProvider.notifier).reset();
            context.go('/auth');
          },
        ),
      ),
      body: PageContent(
        child: deviceState.isValidated
            ? _buildSetupInstructions(context, deviceState.device!)
            : _buildDeviceIdEntry(context),
      ),
    );
  }

  Widget _buildDeviceIdEntry(BuildContext context) {
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
                    Icon(Icons.devices,
                        size: 36, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('Enter Your Device ID',
                          style: Theme.of(context).textTheme.headlineSmall),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'You can find your device ID on your device or in the setup package provided to you.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'Device ID',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _deviceIdController,
          decoration: const InputDecoration(
            hintText: 'e.g., LAP-ABC-12345',
            prefixIcon: Icon(Icons.devices, size: 28),
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton.icon(
          onPressed: _validateDevice,
          icon: const Icon(Icons.check, size: 24),
          label: const Text('Validate Device'),
        ),
      ],
    );
  }

  Widget _buildSetupInstructions(BuildContext context, DeviceEntity device) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green.shade700, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device Validated',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text('Device Type: ${device.type.displayName}',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Setup Instructions',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        switch (device.type) {
          DeviceType.windowsLaptop => _buildWindowsInstructions(),
          DeviceType.androidTablet => _buildAndroidInstructions(),
          DeviceType.iosTablet => _buildIosInstructions(),
          DeviceType.unknown => _buildGenericInstructions(context),
        },
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(deviceNotifierProvider.notifier).reset();
            context.go('/auth');
          },
          icon: const Icon(Icons.check),
          label: const Text('Setup Complete'),
        ),
      ],
    );
  }

  Widget _buildWindowsInstructions() {
    return const Column(children: [
      SetupInstruction(
          number: 1,
          title: 'Connect to WiFi',
          description:
              'Click the WiFi icon in the system tray and select your network',
          details: '''
1. Look for the WiFi icon in the bottom-right corner
2. Click on it and wait for available networks to appear
3. Select your home network from the list
4. Enter the WiFi password if required
5. Wait for connection confirmation'''),
      SizedBox(height: 16),
      SetupInstruction(
          number: 2,
          title: 'Login to MS Teams',
          description: 'Open Microsoft Teams and sign in with your credentials',
          details: '''
1. Click on the Start menu and search for "Teams"
2. Open Microsoft Teams
3. Enter your work email address
4. When prompted, enter your password
5. Complete any two-factor authentication if required
6. You're ready to use Teams!'''),
      SizedBox(height: 16),
      SetupInstruction(
          number: 3,
          title: 'Install Ipsos Apps',
          description: 'Download and install the required Ipsos applications',
          details: '''
1. Open your web browser
2. Navigate to the Ipsos app portal
3. Download the iReach application
4. Run the installer and follow the prompts
5. Sign in with your credentials when prompted'''),
      SizedBox(height: 16),
      SetupInstruction(
          number: 4,
          title: 'Sync to Android Showcard',
          description: 'Connect your Android tablet for data synchronization',
          details: '''
1. Install the Ipsos Sync app on your Android tablet
2. Open the app and note the device code
3. On your laptop, open Ipsos Sync settings
4. Enter the device code from your tablet
5. Confirm the connection on both devices'''),
      SizedBox(height: 16),
      SetupInstruction(
          number: 5,
          title: 'Helpdesk Contact',
          description: 'Save the helpdesk contact information',
          details: '''
Email: helpdesk@ipsos.com
Phone: 1-800-IPSOS-HELP
Hours: Monday-Friday, 8AM-6PM (Your Local Time)'''),
    ]);
  }

  Widget _buildAndroidInstructions() {
    return const Column(children: [
      SetupInstruction(
          number: 1,
          title: 'Connect to WiFi',
          description: 'Connect your tablet to your home WiFi network',
          details: '''
1. Swipe down from the top to open Settings
2. Tap "WiFi"
3. Select your home network
4. Enter the WiFi password
5. Wait for connection confirmation'''),
      SizedBox(height: 16),
      SetupInstruction(
          number: 2,
          title: 'Install Microsoft Teams',
          description: 'Download Teams from Google Play Store',
          details: '''
1. Open Google Play Store
2. Search for "Microsoft Teams"
3. Tap Install
4. Once installed, tap Open
5. Sign in with your work email'''),
      SizedBox(height: 16),
      SetupInstruction(
          number: 3,
          title: 'Install Ipsos Apps',
          description: 'Install the required Ipsos applications',
          details: '''
1. Open Google Play Store
2. Search for "Ipsos iReach"
3. Tap Install
4. Once installed, open the app
5. Sign in with your credentials'''),
      SizedBox(height: 16),
      SetupInstruction(
          number: 4,
          title: 'Helpdesk Contact',
          description: 'Save the helpdesk contact information',
          details: '''
Email: helpdesk@ipsos.com
Phone: 1-800-IPSOS-HELP
Hours: Monday-Friday, 8AM-6PM (Your Local Time)'''),
    ]);
  }

  Widget _buildIosInstructions() {
    return const Column(children: [
      SetupInstruction(
          number: 1,
          title: 'Connect to WiFi',
          description: 'Connect your iPad to your home WiFi network',
          details: '''
1. Go to Settings
2. Tap WiFi
3. Select your home network
4. Enter the WiFi password
5. Wait for connection confirmation'''),
      SizedBox(height: 16),
      SetupInstruction(
          number: 2,
          title: 'Install Microsoft Teams',
          description: 'Download Teams from App Store',
          details: '''
1. Open App Store
2. Search for "Microsoft Teams"
3. Tap Get then Install
4. Once installed, tap Open
5. Sign in with your work email'''),
      SizedBox(height: 16),
      SetupInstruction(
          number: 3,
          title: 'Install Ipsos Apps',
          description: 'Install the required Ipsos applications',
          details: '''
1. Open App Store
2. Search for "Ipsos iReach"
3. Tap Get then Install
4. Once installed, open the app
5. Sign in with your credentials'''),
      SizedBox(height: 16),
      SetupInstruction(
          number: 4,
          title: 'Helpdesk Contact',
          description: 'Save the helpdesk contact information',
          details: '''
Email: helpdesk@ipsos.com
Phone: 1-800-IPSOS-HELP
Hours: Monday-Friday, 8AM-6PM (Your Local Time)'''),
    ]);
  }

  Widget _buildGenericInstructions(BuildContext context) {
    return Column(children: [
      Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Device type could not be determined. Please contact helpdesk for assistance.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      const SetupInstruction(
        number: 1,
        title: 'Contact Helpdesk',
        description: 'Reach out for device-specific setup assistance',
        details: '''
Email: helpdesk@ipsos.com
Phone: 1-800-IPSOS-HELP
Hours: Monday-Friday, 8AM-6PM (Your Local Time)

Please have your device ID ready when you contact us.''',
      ),
    ]);
  }
}
