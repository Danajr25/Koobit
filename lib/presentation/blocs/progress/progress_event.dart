import 'package:equatable/equatable.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/question_model.dart';

/// Base class for progress events
abstract class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

/// Event to save worksheet results
class WorksheetResultSaveRequested extends ProgressEvent {
  final ChildModel child;
  final int levelNumber;
  final String worksheetId;
  final List<QuestionModel> questions;
  final Map<int, String> answers;
  final Map<int, bool?> results;
  final int correctCount;
  final int totalQuestions;
  final int timeSpentSeconds;
  final int stars;
  final bool passed;

  const WorksheetResultSaveRequested({
    required this.child,
    required this.levelNumber,
    required this.worksheetId,
    required this.questions,
    required this.answers,
    required this.results,
    required this.correctCount,
    required this.totalQuestions,
    required this.timeSpentSeconds,
    required this.stars,
    required this.passed,
  });

  @override
  List<Object?> get props => [
        child,
        levelNumber,
        worksheetId,
        questions,
        answers,
        results,
        correctCount,
        totalQuestions,
        timeSpentSeconds,
        stars,
        passed,
      ];
}

/// Event to load child progress
class ChildProgressLoadRequested extends ProgressEvent {
  final String childId;

  const ChildProgressLoadRequested({required this.childId});

  @override
  List<Object?> get props => [childId];
}

/// Event to update child's level
class ChildLevelUpdateRequested extends ProgressEvent {
  final String childId;
  final int newLevel;

  const ChildLevelUpdateRequested({
    required this.childId,
    required this.newLevel,
  });

  @override
  List<Object?> get props => [childId, newLevel];
}
