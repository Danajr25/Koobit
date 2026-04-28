import 'package:equatable/equatable.dart';

/// Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check current auth status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Sign up with email and password
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String preferredLanguage;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.preferredLanguage = 'en',
  });

  @override
  List<Object?> get props => [email, password, preferredLanguage];
}

/// Sign in with email and password
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Sign out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Password reset requested
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Update user profile
class AuthUpdateProfileRequested extends AuthEvent {
  final String? preferredLanguage;
  final bool? notificationsEnabled;

  const AuthUpdateProfileRequested({
    this.preferredLanguage,
    this.notificationsEnabled,
  });

  @override
  List<Object?> get props => [preferredLanguage, notificationsEnabled];
}

/// Set parent password
class AuthSetParentPasswordRequested extends AuthEvent {
  final String password;

  const AuthSetParentPasswordRequested({required this.password});

  @override
  List<Object?> get props => [password];
}

/// Verify parent password
class AuthVerifyParentPasswordRequested extends AuthEvent {
  final String password;

  const AuthVerifyParentPasswordRequested({required this.password});

  @override
  List<Object?> get props => [password];
}
