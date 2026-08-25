import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/page_content.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/ireach/ireach_service.dart';
import '../../domain/repositories/device_repository.dart';
import '../cubit/update_ireach_cubit.dart';
import '../cubit/update_ireach_state.dart';
import '../providers/device_providers.dart';

class UpdateIReachPage extends ConsumerWidget {
  final IreachService? service;
  final DeviceRepository? deviceRepository;

  const UpdateIReachPage({super.key, this.service, this.deviceRepository});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    return BlocProvider(
      create: (_) => UpdateIreachCubit(
        service: service,
        deviceRepository:
            deviceRepository ?? ref.read(deviceRepositoryProvider),
        seedToken: user?.sessionToken,
        seedComputerNumber: user?.deviceId,
        seedName: user?.displayName,
      ),
      child: const _UpdateIReachView(),
    );
  }
}

class _UpdateIReachView extends StatelessWidget {
  const _UpdateIReachView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateIreachCubit, UpdateIreachState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Update I-Reach application'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: state.currentStep == UpdateIreachStep.login
                  ? () => context.go('/existing-interviewer')
                  : state.isLoading
                      ? null
                      : state.currentStep == UpdateIreachStep.syncAndClose
                          ? () => context
                              .read<UpdateIreachCubit>()
                              .backToDeviceConfirmation()
                          : () => context.go(
                                '/existing-interviewer-dashboard',
                              ),
            ),
          ),
          body: PageContent(
            maxWidth: 760,
            padding: const EdgeInsets.all(28),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildStep(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(BuildContext context, UpdateIreachState state) {
    if (state.currentStep == UpdateIreachStep.login) {
      return const _SessionRequiredStep(key: ValueKey('session-required'));
    }
    if (state.currentStep == UpdateIreachStep.confirmDevice) {
      return _ConfirmDeviceStep(key: const ValueKey('confirm'), state: state);
    }
    if (state.currentStep == UpdateIreachStep.syncAndClose) {
      return _SyncCloseStep(key: const ValueKey('sync'), state: state);
    }
    return _ResultStep(key: const ValueKey('result'), state: state);
  }
}

class _SessionRequiredStep extends StatelessWidget {
  const _SessionRequiredStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header('Update I-Reach application'),
        const SizedBox(height: 20),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your session has expired. Please sign in again to continue.',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/existing-interviewer'),
                child: const Text('Return to sign in'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfirmDeviceStep extends StatelessWidget {
  const _ConfirmDeviceStep({super.key, required this.state});
  final UpdateIreachState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header('Update I-Reach application'),
        const SizedBox(height: 20),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please confirm that your device ID is ${state.computerNumber} by clicking Continue. If this is not your current device, please contact help desk.',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              _readOnlyRow(
                  'Computer Number', state.computerNumber ?? 'Unknown'),
              const SizedBox(height: 20),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        context.go('/existing-interviewer-dashboard'),
                    child: const Text('Return to Home'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<UpdateIreachCubit>().confirmDevice(),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SyncCloseStep extends StatelessWidget {
  const _SyncCloseStep({super.key, required this.state});
  final UpdateIreachState state;

  @override
  Widget build(BuildContext context) {
    final loading = state.isLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header('Update I-Reach application'),
        const SizedBox(height: 20),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Follow these steps:',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              const _ChecklistInstruction(
                number: '1',
                title: 'Sync I-Reach',
                description: 'Save your latest work to the server.',
              ),
              const SizedBox(height: 12),
              const _ChecklistInstruction(
                number: '2',
                title: 'Close I-Reach',
                description: 'Make sure the application is fully closed.',
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Transform.translate(
                      offset: const Offset(0, -6),
                      child: Checkbox(
                        value: state.syncedAndClosed,
                        onChanged: loading
                            ? null
                            : (value) {
                                if (value != true) {
                                  context
                                      .read<UpdateIreachCubit>()
                                      .setSyncedAndClosed(false);
                                  return;
                                }
                                _confirmIreachClosed(context);
                              },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'I have synced and closed I-Reach and am ready for update',
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.errorMessage != null) _error(state.errorMessage!),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: loading
                        ? null
                        : () => context
                            .read<UpdateIreachCubit>()
                            .backToDeviceConfirmation(),
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: state.deviceConfirmed &&
                            state.syncedAndClosed &&
                            !loading
                        ? () => context.read<UpdateIreachCubit>().startUpdate()
                        : null,
                    child: Text(loading ? 'Starting...' : 'Start Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmIreachClosed(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Double-check I-Reach is closed'),
        content: const Text(
          'Please make sure I-Reach is fully closed and your latest work has been synced before continuing the update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yes, it is closed'),
          ),
        ],
      ),
    );

    if (!context.mounted || confirmed != true) return;
    context.read<UpdateIreachCubit>().setSyncedAndClosed(true);
  }
}

class _ResultStep extends StatelessWidget {
  const _ResultStep({super.key, required this.state});
  final UpdateIreachState state;

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == UpdateIreachStatus.loading;
    final isSuccess = state.status == UpdateIreachStatus.success;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header('Update I-Reach application'),
        const SizedBox(height: 20),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 20),
              ],
              Text(
                isLoading
                    ? 'Starting the I-Reach update...'
                    : isSuccess
                        ? 'I-Reach update triggered.'
                        : (state.errorMessage ??
                            'I-Reach update failed. Please contact help desk.'),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Text(
                  'This may take up to two minutes. Please keep this page open.',
                )
              else if (!isSuccess)
                const Text('Please contact help desk.'),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        context.go('/existing-interviewer-dashboard'),
                    child: const Text('Return to Home'),
                  ),
                  const SizedBox(width: 12),
                  if (!isSuccess && !isLoading)
                    ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () =>
                              context.read<UpdateIreachCubit>().retryUpdate(),
                      child: const Text('Retry'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChecklistInstruction extends StatelessWidget {
  const _ChecklistInstruction({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          child: Text(number),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(description),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _header(String title) => Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      ),
    );

Widget _card({required Widget child}) => Card(
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );

Widget _error(String message) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE57373)),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xFF8A1F1F))),
    );

Widget _readOnlyRow(String label, String value) => Row(
      children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
