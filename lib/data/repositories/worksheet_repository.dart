import 'package:uuid/uuid.dart';
import '../../core/services/supabase_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/worksheet_model.dart';
import '../models/question_model.dart';

/// Repository for worksheet operations
class WorksheetRepository {
  final SupabaseService _supabase;
  final Uuid _uuid = const Uuid();

  WorksheetRepository({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService.instance;

  /// Get worksheet by ID
  Future<WorksheetModel?> getWorksheet(String worksheetId) async {
    final response = await _supabase.selectById('worksheets', worksheetId);
    if (response == null) return null;
    return WorksheetModel.fromJson(response);
  }

  /// Get worksheet with questions
  Future<WorksheetModel?> getWorksheetWithQuestions(String worksheetId) async {
    final worksheetResponse = await _supabase.selectById('worksheets', worksheetId);
    if (worksheetResponse == null) return null;

    final questionsResponse = await _supabase.select(
      'questions',
      filters: {'worksheet_id': worksheetId},
      orderBy: 'question_number',
      ascending: true,
    );

    final questions = questionsResponse
        .map((json) => QuestionModel.fromJson(json))
        .toList();

    return WorksheetModel.fromJson(worksheetResponse).copyWith(
      questions: questions,
    );
  }

  /// Get today's worksheet for a child
  Future<WorksheetModel?> getTodayWorksheet(String childId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _supabase.select(
      'worksheets',
      filters: {
        'child_id': childId,
        'worksheet_date': today,
      },
      limit: 1,
    );

    if (response.isEmpty) return null;
    return WorksheetModel.fromJson(response.first);
  }

  /// Get worksheets for a child
  Future<List<WorksheetModel>> getChildWorksheets(
    String childId, {
    int? limit,
    int? offset,
  }) async {
    final response = await _supabase.select(
      'worksheets',
      filters: {'child_id': childId},
      orderBy: 'worksheet_date',
      ascending: false,
      limit: limit,
      offset: offset,
    );
    return response.map((json) => WorksheetModel.fromJson(json)).toList();
  }

  /// Get worksheets by level
  Future<List<WorksheetModel>> getWorksheetsByLevel(
    String childId,
    int level,
  ) async {
    final response = await _supabase.select(
      'worksheets',
      filters: {
        'child_id': childId,
        'level': level,
      },
      orderBy: 'worksheet_date',
      ascending: false,
    );
    return response.map((json) => WorksheetModel.fromJson(json)).toList();
  }

  /// Get completed worksheets count
  Future<int> getCompletedWorksheetCount(String childId) async {
    final response = await _supabase.select(
      'worksheets',
      columns: 'id',
      filters: {
        'child_id': childId,
        'status': WorksheetStatus.completed.name,
      },
    );
    return response.length;
  }

  /// Create new worksheet
  Future<WorksheetModel> createWorksheet({
    required String childId,
    required int level,
    required int phase,
    required List<QuestionModel> questions,
  }) async {
    final now = DateTime.now();
    final worksheetId = _uuid.v4();
    
    final worksheetData = {
      'id': worksheetId,
      'child_id': childId,
      'level': level,
      'phase': phase,
      'worksheet_date': now.toIso8601String().split('T')[0],
      'status': WorksheetStatus.notStarted.name,
      'total_questions': AppConstants.totalQuestions,
      'correct_count': 0,
      'incorrect_count': 0,
      'corrected_count': 0,
      'score_percentage': 0,
      'passed': false,
      'stars_earned': 0,
      'time_limit_seconds': AppConstants.worksheetTimeLimitMinutes * 60,
      'time_spent_seconds': 0,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    await _supabase.insert('worksheets', worksheetData);

    // Insert questions
    final questionsData = questions.map((q) => {
      'id': _uuid.v4(),
      'worksheet_id': worksheetId,
      'question_number': q.questionNumber,
      'page_number': q.pageNumber,
      'type': q.type.name,
      'question_text': q.questionText,
      'correct_answer': q.correctAnswer,
    }).toList();

    await _supabase.insertMany('questions', questionsData);

    return WorksheetModel.fromJson(worksheetData);
  }

  /// Create worksheet record directly from data map
  Future<WorksheetModel> createWorksheetRecord(Map<String, dynamic> data) async {
    final response = await _supabase.insert('worksheets', data);
    return WorksheetModel.fromJson(response);
  }

  /// Start worksheet
  Future<WorksheetModel> startWorksheet(String worksheetId) async {
    final updateData = {
      'status': WorksheetStatus.inProgress.name,
      'started_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('worksheets', worksheetId, updateData);
    return WorksheetModel.fromJson(response);
  }

  /// Update time spent
  Future<WorksheetModel> updateTimeSpent(String worksheetId, int seconds) async {
    final updateData = {
      'time_spent_seconds': seconds,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('worksheets', worksheetId, updateData);
    return WorksheetModel.fromJson(response);
  }

  /// Submit worksheet
  Future<WorksheetModel> submitWorksheet(String worksheetId) async {
    // Get all questions for this worksheet
    final questionsResponse = await _supabase.select(
      'questions',
      filters: {'worksheet_id': worksheetId},
    );

    final questions = questionsResponse
        .map((json) => QuestionModel.fromJson(json))
        .toList();

    // Calculate scores
    final correctCount = questions.where((q) => q.isCorrect == true).length;
    final incorrectCount = questions.where((q) => q.isCorrect == false).length;
    final scorePercentage = (correctCount / questions.length * 100).round();
    final passed = scorePercentage >= AppConstants.passingScorePercentage;
    final stars = WorksheetModel.calculateStars(scorePercentage);

    final updateData = {
      'status': passed 
          ? WorksheetStatus.completed.name 
          : WorksheetStatus.submitted.name,
      'correct_count': correctCount,
      'incorrect_count': incorrectCount,
      'score_percentage': scorePercentage,
      'passed': passed,
      'stars_earned': stars,
      'submitted_at': DateTime.now().toIso8601String(),
      'completed_at': passed ? DateTime.now().toIso8601String() : null,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('worksheets', worksheetId, updateData);
    return WorksheetModel.fromJson(response);
  }

  /// Start corrections
  Future<WorksheetModel> startCorrections(String worksheetId) async {
    final updateData = {
      'status': WorksheetStatus.correcting.name,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('worksheets', worksheetId, updateData);
    return WorksheetModel.fromJson(response);
  }

  /// Complete worksheet (after corrections)
  Future<WorksheetModel> completeWorksheet(String worksheetId) async {
    // Get corrected count
    final questionsResponse = await _supabase.select(
      'questions',
      filters: {
        'worksheet_id': worksheetId,
        'is_corrected': true,
      },
    );

    final updateData = {
      'status': WorksheetStatus.completed.name,
      'corrected_count': questionsResponse.length,
      'completed_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.update('worksheets', worksheetId, updateData);
    return WorksheetModel.fromJson(response);
  }

  /// Get worksheet statistics for a child
  Future<Map<String, dynamic>> getStatistics(String childId) async {
    final worksheets = await getChildWorksheets(childId);
    
    if (worksheets.isEmpty) {
      return {
        'total_worksheets': 0,
        'completed_worksheets': 0,
        'average_score': 0,
        'total_stars': 0,
        'perfect_scores': 0,
      };
    }

    final completed = worksheets.where((w) => 
        w.status == WorksheetStatus.completed).toList();
    
    final totalScore = completed.fold<int>(
        0, (sum, w) => sum + w.scorePercentage);
    final averageScore = completed.isNotEmpty 
        ? (totalScore / completed.length).round() 
        : 0;
    
    final totalStars = worksheets.fold<int>(
        0, (sum, w) => sum + w.starsEarned);
    
    final perfectScores = worksheets.where((w) => 
        w.scorePercentage == 100).length;

    return {
      'total_worksheets': worksheets.length,
      'completed_worksheets': completed.length,
      'average_score': averageScore,
      'total_stars': totalStars,
      'perfect_scores': perfectScores,
    };
  }

  /// Get worksheets by date range
  Future<List<WorksheetModel>> getWorksheetsByDateRange(
    String childId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _supabase.client
        .from('worksheets')
        .select()
        .eq('child_id', childId)
        .gte('worksheet_date', startDate.toIso8601String().split('T')[0])
        .lte('worksheet_date', endDate.toIso8601String().split('T')[0])
        .order('worksheet_date', ascending: true);

    return (response as List)
        .map((json) => WorksheetModel.fromJson(json))
        .toList();
  }
}
