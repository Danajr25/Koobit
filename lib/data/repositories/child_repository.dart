import 'package:uuid/uuid.dart';
import '../../core/services/supabase_service.dart';
import '../models/child_model.dart';

/// Repository for child profile operations
class ChildRepository {
  final SupabaseService _supabase;
  final Uuid _uuid = const Uuid();

  ChildRepository({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService.instance;

  /// Get all children for a user
  Future<List<ChildModel>> getChildren(String userId) async {
    final response = await _supabase.select(
      'children',
      filters: {'user_id': userId},
      orderBy: 'created_at',
      ascending: true,
    );
    return response.map((json) => ChildModel.fromJson(json)).toList();
  }

  /// Get child by ID
  Future<ChildModel?> getChild(String childId) async {
    final response = await _supabase.selectById('children', childId);
    if (response == null) return null;
    return ChildModel.fromJson(response);
  }

  /// Create new child profile
  Future<ChildModel> createChild({
    required String userId,
    required String name,
    String? avatarUrl,
  }) async {
    final now = DateTime.now();
    final childData = {
      'id': _uuid.v4(),
      'user_id': userId,
      'name': name,
      'avatar_url': avatarUrl,
      'current_level': 1,
      'current_streak': 0,
      'longest_streak': 0,
      'total_stars': 0,
      'game_tokens': 0,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final response = await _supabase.insert('children', childData);
    return ChildModel.fromJson(response);
  }

  /// Update child profile
  Future<ChildModel> updateChild(ChildModel child) async {
    final updateData = {
      'name': child.name,
      'avatar_url': child.avatarUrl,
      'current_level': child.currentLevel,
      'current_streak': child.currentStreak,
      'longest_streak': child.longestStreak,
      'total_stars': child.totalStars,
      'game_tokens': child.gameTokens,
      'last_worksheet_date': child.lastWorksheetDate?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('children', child.id, updateData);
    return ChildModel.fromJson(response);
  }

  /// Update child name
  Future<ChildModel> updateChildName(String childId, String name) async {
    final updateData = {
      'name': name,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('children', childId, updateData);
    return ChildModel.fromJson(response);
  }

  /// Update child avatar
  Future<ChildModel> updateChildAvatar(String childId, String? avatarUrl) async {
    final updateData = {
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('children', childId, updateData);
    return ChildModel.fromJson(response);
  }

  /// Delete child profile
  Future<void> deleteChild(String childId) async {
    // Delete related data first (worksheets, progress, achievements)
    await _supabase.deleteWhere('questions', {'child_id': childId});
    await _supabase.deleteWhere('worksheets', {'child_id': childId});
    await _supabase.deleteWhere('level_progress', {'child_id': childId});
    await _supabase.deleteWhere('achievements', {'child_id': childId});
    await _supabase.deleteWhere('game_scores', {'child_id': childId});
    
    // Delete child
    await _supabase.delete('children', childId);
  }

  /// Update child level
  Future<ChildModel> updateLevel(String childId, int newLevel) async {
    final updateData = {
      'current_level': newLevel,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('children', childId, updateData);
    return ChildModel.fromJson(response);
  }

  /// Update streak after completing worksheet
  Future<ChildModel> updateStreak(String childId) async {
    final child = await getChild(childId);
    if (child == null) throw Exception('Child not found');

    final now = DateTime.now();
    int newStreak;
    int newLongestStreak = child.longestStreak;

    // Calculate new streak
    if (child.lastWorksheetDate == null) {
      newStreak = 1;
    } else {
      final lastDate = child.lastWorksheetDate!;
      final yesterday = now.subtract(const Duration(days: 1));
      
      // Check if last worksheet was today (already counted)
      if (lastDate.year == now.year &&
          lastDate.month == now.month &&
          lastDate.day == now.day) {
        newStreak = child.currentStreak;
      }
      // Check if last worksheet was yesterday (continue streak)
      else if (lastDate.year == yesterday.year &&
               lastDate.month == yesterday.month &&
               lastDate.day == yesterday.day) {
        newStreak = child.currentStreak + 1;
      }
      // Streak broken
      else {
        newStreak = 1;
      }
    }

    // Update longest streak if needed
    if (newStreak > newLongestStreak) {
      newLongestStreak = newStreak;
    }

    final updateData = {
      'current_streak': newStreak,
      'longest_streak': newLongestStreak,
      'last_worksheet_date': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final response = await _supabase.update('children', childId, updateData);
    return ChildModel.fromJson(response);
  }

  /// Add stars to child
  Future<ChildModel> addStars(String childId, int stars) async {
    final child = await getChild(childId);
    if (child == null) throw Exception('Child not found');

    final updateData = {
      'total_stars': child.totalStars + stars,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('children', childId, updateData);
    return ChildModel.fromJson(response);
  }

  /// Add game tokens to child
  Future<ChildModel> addGameTokens(String childId, int tokens) async {
    final child = await getChild(childId);
    if (child == null) throw Exception('Child not found');

    final updateData = {
      'game_tokens': child.gameTokens + tokens,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('children', childId, updateData);
    return ChildModel.fromJson(response);
  }

  /// Use game tokens
  Future<ChildModel> useGameTokens(String childId, int tokens) async {
    final child = await getChild(childId);
    if (child == null) throw Exception('Child not found');
    
    if (child.gameTokens < tokens) {
      throw Exception('Not enough tokens');
    }

    final updateData = {
      'game_tokens': child.gameTokens - tokens,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('children', childId, updateData);
    return ChildModel.fromJson(response);
  }

  /// Get child count for a user
  Future<int> getChildCount(String userId) async {
    final response = await _supabase.select(
      'children',
      columns: 'id',
      filters: {'user_id': userId},
    );
    return response.length;
  }
}
