import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/child_model.dart';
import '../../../data/models/worksheet_model.dart';
import '../../../data/repositories/child_repository.dart';
import '../../../data/repositories/worksheet_repository.dart';
import 'progress_event.dart';
import 'progress_state.dart';

/// Progress BLoC for handling worksheet results and child progress
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final ChildRepository _childRepository;
  final WorksheetRepository _worksheetRepository;

  ProgressBloc({
    required ChildRepository childRepository,
    required WorksheetRepository worksheetRepository,
  })  : _childRepository = childRepository,
        _worksheetRepository = worksheetRepository,
        super(ProgressState.initial()) {
    on<WorksheetResultSaveRequested>(_onWorksheetResultSaveRequested);
    on<ChildProgressLoadRequested>(_onChildProgressLoadRequested);
    on<ChildLevelUpdateRequested>(_onChildLevelUpdateRequested);
  }

  /// Save worksheet results and update child progress
  Future<void> _onWorksheetResultSaveRequested(
    WorksheetResultSaveRequested event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressState.saving());

    try {
      final now = DateTime.now();
      final scorePercentage = event.totalQuestions > 0
          ? (event.correctCount / event.totalQuestions * 100).round()
          : 0;

      // Create worksheet record
      final worksheetData = {
        'id': event.worksheetId,
        'child_id': event.child.id,
        'level': event.levelNumber,
        'phase': 1, // Phase within level (can be expanded later)
        'worksheet_date': now.toIso8601String().split('T')[0],
        'status': event.passed 
            ? WorksheetStatus.completed.name 
            : WorksheetStatus.submitted.name,
        'total_questions': event.totalQuestions,
        'correct_count': event.correctCount,
        'incorrect_count': event.totalQuestions - event.correctCount,
        'corrected_count': 0,
        'score_percentage': scorePercentage,
        'passed': event.passed,
        'stars_earned': event.stars,
        'time_limit_seconds': 600, // 10 minutes
        'time_spent_seconds': event.timeSpentSeconds,
        'started_at': now.subtract(Duration(seconds: event.timeSpentSeconds)).toIso8601String(),
        'submitted_at': now.toIso8601String(),
        'completed_at': event.passed ? now.toIso8601String() : null,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      // Save worksheet to Supabase
      WorksheetModel savedWorksheet;
      try {
        final response = await _worksheetRepository.createWorksheetRecord(worksheetData);
        savedWorksheet = response;
      } catch (e) {
        // If worksheet saving fails, create a local model for the state
        savedWorksheet = WorksheetModel(
          id: event.worksheetId,
          childId: event.child.id,
          level: event.levelNumber,
          phase: 1,
          worksheetDate: now,
          status: event.passed ? WorksheetStatus.completed : WorksheetStatus.submitted,
          totalQuestions: event.totalQuestions,
          correctCount: event.correctCount,
          incorrectCount: event.totalQuestions - event.correctCount,
          scorePercentage: scorePercentage,
          passed: event.passed,
          starsEarned: event.stars,
          timeSpentSeconds: event.timeSpentSeconds,
          createdAt: now,
          updatedAt: now,
        );
        // Log the error but don't fail completely
        debugPrint('Warning: Could not save worksheet to database: $e');
      }

      // Update child progress
      ChildModel updatedChild = event.child;
      bool levelAdvanced = false;

      try {
        // Update streak
        updatedChild = await _childRepository.updateStreak(event.child.id);

        // Add stars earned
        if (event.stars > 0) {
          updatedChild = await _childRepository.addStars(event.child.id, event.stars);
        }

        // If passed, check if we should advance level
        if (event.passed) {
          final currentLevel = updatedChild.currentLevel;
          if (event.levelNumber >= currentLevel && event.levelNumber < 54) {
            // Advance to next level
            updatedChild = await _childRepository.updateLevel(
              event.child.id,
              event.levelNumber + 1,
            );
            levelAdvanced = true;
          }
        }
      } catch (e) {
        // If child update fails, use the original child data
        debugPrint('Warning: Could not update child progress: $e');
        updatedChild = event.child.copyWith(
          totalStars: event.child.totalStars + event.stars,
          currentLevel: event.passed && event.levelNumber >= event.child.currentLevel
              ? event.levelNumber + 1
              : event.child.currentLevel,
          lastWorksheetDate: now,
        );
        levelAdvanced = event.passed && event.levelNumber >= event.child.currentLevel;
      }

      emit(ProgressState.saved(
        updatedChild: updatedChild,
        savedWorksheet: savedWorksheet,
        levelAdvanced: levelAdvanced,
      ));
    } catch (e) {
      emit(ProgressState.error('Failed to save progress: $e'));
    }
  }

  /// Load child progress and worksheet history
  Future<void> _onChildProgressLoadRequested(
    ChildProgressLoadRequested event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressState.loading());

    try {
      final child = await _childRepository.getChild(event.childId);
      if (child == null) {
        emit(ProgressState.error('Child not found'));
        return;
      }

      final worksheets = await _worksheetRepository.getChildWorksheets(
        event.childId,
        limit: 30, // Last 30 worksheets
      );

      emit(ProgressState.loaded(
        child: child,
        worksheetHistory: worksheets,
      ));
    } catch (e) {
      emit(ProgressState.error('Failed to load progress: $e'));
    }
  }

  /// Update child's level
  Future<void> _onChildLevelUpdateRequested(
    ChildLevelUpdateRequested event,
    Emitter<ProgressState> emit,
  ) async {
    try {
      final updatedChild = await _childRepository.updateLevel(
        event.childId,
        event.newLevel,
      );
      emit(state.copyWith(updatedChild: updatedChild));
    } catch (e) {
      emit(ProgressState.error('Failed to update level: $e'));
    }
  }
}
