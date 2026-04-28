import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

/// Auth status
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Auth state
class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isPasswordResetSent;
  final bool isParentPasswordVerified;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isPasswordResetSent = false,
    this.isParentPasswordVerified = false,
  });

  /// Initial state
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  /// Loading state
  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  /// Authenticated state
  factory AuthState.authenticated(UserModel user) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  /// Unauthenticated state
  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Error state
  factory AuthState.error(String message) {
    return AuthState(
      status: AuthStatus.error,
      errorMessage: message,
    );
  }

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  /// Check if loading
  bool get isLoading => status == AuthStatus.loading;

  /// Check if user has parent password set
  bool get hasParentPassword => 
      user?.parentPasswordHash != null && user!.parentPasswordHash!.isNotEmpty;

  /// Copy with method
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isPasswordResetSent,
    bool? isParentPasswordVerified,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isPasswordResetSent: isPasswordResetSent ?? this.isPasswordResetSent,
      isParentPasswordVerified: isParentPasswordVerified ?? this.isParentPasswordVerified,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        errorMessage,
        isPasswordResetSent,
        isParentPasswordVerified,
      ];
}
