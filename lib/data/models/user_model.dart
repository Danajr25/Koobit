import 'package:equatable/equatable.dart';

/// User model representing a parent/family account
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? parentPasswordHash;
  final String preferredLanguage;
  final bool notificationsEnabled;
  final DateTime trialStartDate;
  final DateTime? subscriptionEndDate;
  final String subscriptionStatus; // 'trial', 'active', 'expired', 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.parentPasswordHash,
    this.preferredLanguage = 'en',
    this.notificationsEnabled = true,
    required this.trialStartDate,
    this.subscriptionEndDate,
    this.subscriptionStatus = 'trial',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if trial is still active (30 days from start)
  bool get isTrialActive {
    if (subscriptionStatus != 'trial') return false;
    final trialEndDate = trialStartDate.add(const Duration(days: 30));
    return DateTime.now().isBefore(trialEndDate);
  }

  /// Get remaining trial days
  int get trialDaysRemaining {
    if (subscriptionStatus != 'trial') return 0;
    final trialEndDate = trialStartDate.add(const Duration(days: 30));
    final remaining = trialEndDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if user has active subscription or trial
  bool get hasActiveSubscription {
    if (subscriptionStatus == 'trial' && isTrialActive) return true;
    if (subscriptionStatus == 'active' && subscriptionEndDate != null) {
      return DateTime.now().isBefore(subscriptionEndDate!);
    }
    return false;
  }

  /// Create from JSON (Supabase response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      parentPasswordHash: json['parent_password_hash'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      trialStartDate: DateTime.parse(json['trial_start_date'] as String),
      subscriptionEndDate: json['subscription_end_date'] != null
          ? DateTime.parse(json['subscription_end_date'] as String)
          : null,
      subscriptionStatus: json['subscription_status'] as String? ?? 'trial',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'parent_password_hash': parentPasswordHash,
      'preferred_language': preferredLanguage,
      'notifications_enabled': notificationsEnabled,
      'trial_start_date': trialStartDate.toIso8601String(),
      'subscription_end_date': subscriptionEndDate?.toIso8601String(),
      'subscription_status': subscriptionStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with method for immutable updates
  UserModel copyWith({
    String? id,
    String? email,
    String? parentPasswordHash,
    String? preferredLanguage,
    bool? notificationsEnabled,
    DateTime? trialStartDate,
    DateTime? subscriptionEndDate,
    String? subscriptionStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      parentPasswordHash: parentPasswordHash ?? this.parentPasswordHash,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        parentPasswordHash,
        preferredLanguage,
        notificationsEnabled,
        trialStartDate,
        subscriptionEndDate,
        subscriptionStatus,
        createdAt,
        updatedAt,
      ];
}
