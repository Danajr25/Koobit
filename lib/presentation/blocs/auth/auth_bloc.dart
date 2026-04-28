import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<supabase.AuthState>? _authStateSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthUpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthSetParentPasswordRequested>(_onSetParentPasswordRequested);
    on<AuthVerifyParentPasswordRequested>(_onVerifyParentPasswordRequested);

    // Listen to auth state changes
    _authStateSubscription = _authRepository.authStateChanges.listen((authState) {
      if (authState.event == supabase.AuthChangeEvent.signedOut) {
        add(const AuthCheckRequested());
      }
    });
  }

  /// Hash password using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check auth status
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      if (_authRepository.isAuthenticated) {
        final user = await _authRepository.getCurrentUserProfile();
        if (user != null) {
          emit(AuthState.authenticated(user));
        } else {
          emit(AuthState.unauthenticated());
        }
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Sign up
  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      final user = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        preferredLanguage: event.preferredLanguage,
      );
      emit(AuthState.authenticated(user));
    } on supabase.AuthException catch (e) {
      emit(AuthState.error(_parseAuthError(e.message)));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Sign in
  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.error('Failed to get user profile'));
      }
    } on supabase.AuthException catch (e) {
      emit(AuthState.error(_parseAuthError(e.message)));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Sign out
  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      await _authRepository.signOut();
      emit(AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Password reset
  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      await _authRepository.resetPassword(event.email);
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        isPasswordResetSent: true,
      ));
    } on supabase.AuthException catch (e) {
      emit(AuthState.error(_parseAuthError(e.message)));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Update profile
  Future<void> _onUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null) return;

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final updatedUser = state.user!.copyWith(
        preferredLanguage: event.preferredLanguage ?? state.user!.preferredLanguage,
        notificationsEnabled: event.notificationsEnabled ?? state.user!.notificationsEnabled,
      );

      final user = await _authRepository.updateUserProfile(updatedUser);
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Set parent password
  Future<void> _onSetParentPasswordRequested(
    AuthSetParentPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null) return;

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final hashedPassword = _hashPassword(event.password);
      final user = await _authRepository.setParentPassword(
        state.user!.id,
        hashedPassword,
      );
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Verify parent password
  Future<void> _onVerifyParentPasswordRequested(
    AuthVerifyParentPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null) return;

    final hashedPassword = _hashPassword(event.password);
    final isValid = state.user!.parentPasswordHash == hashedPassword;

    emit(state.copyWith(
      isParentPasswordVerified: isValid,
      errorMessage: isValid ? null : 'Invalid parent password',
    ));
  }

  /// Parse auth error messages
  String _parseAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    }
    if (message.contains('User already registered')) {
      return 'An account with this email already exists';
    }
    if (message.contains('Email not confirmed')) {
      return 'Please verify your email address';
    }
    if (message.contains('Password should be at least')) {
      return 'Password must be at least 6 characters';
    }
    if (message.contains('Invalid email')) {
      return 'Please enter a valid email address';
    }
    return message;
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
