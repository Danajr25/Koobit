import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';

/// Repository for authentication and user operations
class AuthRepository {
  final SupabaseService _supabase;

  AuthRepository({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService.instance;

  /// Get current user ID
  String? get currentUserId => _supabase.currentUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _supabase.isAuthenticated;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.authStateChanges;

  /// Sign up with email and password
  /// Creates user in Auth and profiles table
  Future<UserModel> signUp({
    required String email,
    required String password,
    String preferredLanguage = 'en',
  }) async {
    try {
      // Create auth user
      final authResponse = await _supabase.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }

      // Create user profile
      final now = DateTime.now();
      final userData = {
        'id': authResponse.user!.id,
        'email': email,
        'preferred_language': preferredLanguage,
        'notifications_enabled': true,
        'trial_start_date': now.toIso8601String(),
        'subscription_status': 'trial',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabase.insert('users', userData);
      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _supabase.signIn(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to sign in');
      }

      // Fetch user profile
      return await getUserProfile(authResponse.user!.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _supabase.signOut();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await _supabase.resetPassword(email);
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    await _supabase.updatePassword(newPassword);
  }

  /// Get user profile by ID
  Future<UserModel?> getUserProfile(String userId) async {
    final response = await _supabase.selectById('users', userId);
    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  /// Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;
    return getUserProfile(userId);
  }

  /// Update user profile
  Future<UserModel> updateUserProfile(UserModel user) async {
    final updateData = {
      'preferred_language': user.preferredLanguage,
      'notifications_enabled': user.notificationsEnabled,
      'parent_password_hash': user.parentPasswordHash,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('users', user.id, updateData);
    return UserModel.fromJson(response);
  }

  /// Set parent password
  Future<UserModel> setParentPassword(String userId, String passwordHash) async {
    final updateData = {
      'parent_password_hash': passwordHash,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('users', userId, updateData);
    return UserModel.fromJson(response);
  }

  /// Update preferred language
  Future<UserModel> updateLanguage(String userId, String languageCode) async {
    final updateData = {
      'preferred_language': languageCode,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('users', userId, updateData);
    return UserModel.fromJson(response);
  }

  /// Update subscription status
  Future<UserModel> updateSubscription({
    required String userId,
    required String status,
    DateTime? endDate,
  }) async {
    final updateData = {
      'subscription_status': status,
      'subscription_end_date': endDate?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('users', userId, updateData);
    return UserModel.fromJson(response);
  }

  /// Check if email is already registered
  Future<bool> isEmailRegistered(String email) async {
    final response = await _supabase.select(
      'users',
      filters: {'email': email},
      limit: 1,
    );
    return response.isNotEmpty;
  }

  /// Verify parent password
  Future<bool> verifyParentPassword(String userId, String passwordHash) async {
    final user = await getUserProfile(userId);
    if (user == null || user.parentPasswordHash == null) return false;
    return user.parentPasswordHash == passwordHash;
  }
}
