import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/result.dart';
import '../../data/ireach/ireach_exceptions.dart';
import '../../data/ireach/ireach_service.dart';
import '../../domain/repositories/device_repository.dart';
import 'update_ireach_state.dart';

class UpdateIreachCubit extends Cubit<UpdateIreachState> {
  UpdateIreachCubit({
    IreachService? service,
    required DeviceRepository deviceRepository,
    String? seedToken,
    String? seedComputerNumber,
    String? seedName,
  })  : _service = service ?? IreachService(),
        _deviceRepository = deviceRepository,
        super(
          seedToken != null && seedToken.trim().isNotEmpty
              ? UpdateIreachState(
                  token: seedToken.trim(),
                  computerNumber: seedComputerNumber?.trim(),
                  name: seedName?.trim(),
                )
              : const UpdateIreachState.initial(),
        );

  final IreachService _service;
  final DeviceRepository _deviceRepository;

  // Step 1 — Login, Step 2 — load user (auto). Kept for API-layer parity and
  // test coverage: the live UI now seeds this cubit straight from the
  // existing-interviewer login screen's session instead of calling this
  // directly, but the flow it drives (SM_BASE Authentication ->
  // GetCurrentUserData, both routed through the CORS-safe local proxy via
  // IreachConfig) is the same one that screen uses.
  Future<void> login(String username, String password) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty || password.isEmpty) {
      emit(state.copyWith(
        status: UpdateIreachStatus.error,
        errorMessage: 'Please enter both username and password.',
      ));
      return;
    }

    emit(state.copyWith(status: UpdateIreachStatus.loading, clearError: true));
    try {
      final token = await _service.authenticate(cleanUsername, password);
      final user = await _service.getCurrentUser(token);
      if (user.computerNumber.trim().isEmpty) {
        emit(state.copyWith(
          status: UpdateIreachStatus.error,
          errorMessage: 'No device on file — please contact help desk.',
          clearToken: true,
        ));
        return;
      }
      emit(UpdateIreachState(
        token: token,
        computerNumber: user.computerNumber.trim(),
        name: user.name,
      ));
    } on AuthException catch (error) {
      emit(state.copyWith(
        status: UpdateIreachStatus.error,
        errorMessage: error.message,
        clearToken: true,
      ));
    } on UserDataException catch (error) {
      emit(state.copyWith(
        status: UpdateIreachStatus.error,
        errorMessage: error.message,
        clearToken: error.statusCode == 401,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: UpdateIreachStatus.error,
        errorMessage: 'An unexpected error occurred. Please try again.',
        clearToken: true,
      ));
    }
  }

  void confirmDevice() {
    emit(state.copyWith(deviceConfirmed: true, clearError: true));
  }

  void setSyncedAndClosed(bool value) {
    emit(state.copyWith(syncedAndClosed: value, clearError: true));
  }

  void backToDeviceConfirmation() {
    emit(state.copyWith(
      deviceConfirmed: false,
      syncedAndClosed: false,
      status: UpdateIreachStatus.idle,
      clearAgentId: true,
      clearError: true,
    ));
  }

  void backToLogin() {
    emit(const UpdateIreachState.initial());
  }

  void returnToLogin() => backToLogin();

  // Step 5 & 6 — resolve the agent and run the update script. This always
  // goes through the proxy-backed DeviceRepository (POST /update-ireach),
  // which keeps the RMM system token server-side and never calls
  // api2.ipsos.co.nz directly from the browser.
  Future<void> startUpdate() async {
    if (!state.deviceConfirmed || !state.syncedAndClosed) return;
    final token = state.token;
    final computerNumber = state.computerNumber;
    if (token == null || token.isEmpty) {
      emit(const UpdateIreachState.initial());
      return;
    }
    if (computerNumber == null || computerNumber.trim().isEmpty) {
      emit(state.copyWith(
        status: UpdateIreachStatus.error,
        errorMessage: 'No device on file — please contact help desk.',
      ));
      return;
    }

    emit(state.copyWith(status: UpdateIreachStatus.loading, clearError: true));

    final result =
        await _deviceRepository.executeIReachUpdate(computerNumber, token);
    switch (result) {
      case Success():
        emit(state.copyWith(
          status: UpdateIreachStatus.success,
          clearError: true,
        ));
      case Err(:final failure):
        if (failure.message.contains('session has expired')) {
          emit(state.copyWith(
            status: UpdateIreachStatus.error,
            errorMessage: failure.message,
            clearToken: true,
          ));
        } else {
          emit(state.copyWith(
            status: UpdateIreachStatus.error,
            errorMessage: failure.message,
          ));
        }
    }
  }

  Future<void> retryUpdate() => startUpdate();
}
