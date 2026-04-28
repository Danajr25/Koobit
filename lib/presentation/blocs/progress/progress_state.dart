import 'package:equatable/equatable.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/worksheet_model.dart';

/// Progress status enumeration
enum ProgressStatus {
  initial,
  loading,
  saving,
  saved,
  loaded,
  error,
}

/// Progress state
class ProgressState extends Equatable {
  final ProgressStatus status;
  final ChildModel? updatedChild;
  final WorksheetModel? savedWorksheet;
  final List<WorksheetModel> worksheetHistory;
  final String? errorMessage;
  final bool levelAdvanced;

  const ProgressState({
    this.status = ProgressStatus.initial,
    this.updatedChild,
    this.savedWorksheet,
    this.worksheetHistory = const [],
    this.errorMessage,
    this.levelAdvanced = false,
  });

  /// Initial state
  factory ProgressState.initial() {
    return const ProgressState();
  }

  /// Loading state
  factory ProgressState.loading() {
    return const ProgressState(status: ProgressStatus.loading);
  }

  /// Saving state
  factory ProgressState.saving() {
    return const ProgressState(status: ProgressStatus.saving);
  }

  /// Saved state
  factory ProgressState.saved({
    required ChildModel updatedChild,
    required WorksheetModel savedWorksheet,
    required bool levelAdvanced,
  }) {
    return ProgressState(
      status: ProgressStatus.saved,
      updatedChild: updatedChild,
      savedWorksheet: savedWorksheet,
      levelAdvanced: levelAdvanced,
    );
  }

  /// Loaded state
  factory ProgressState.loaded({
    required ChildModel child,
    required List<WorksheetModel> worksheetHistory,
  }) {
    return ProgressState(
      status: ProgressStatus.loaded,
      updatedChild: child,
      worksheetHistory: worksheetHistory,
    );
  }

  /// Error state
  factory ProgressState.error(String message) {
    return ProgressState(
      status: ProgressStatus.error,
      errorMessage: message,
    );
  }

  /// Copy with method
  ProgressState copyWith({
    ProgressStatus? status,
    ChildModel? updatedChild,
    WorksheetModel? savedWorksheet,
    List<WorksheetModel>? worksheetHistory,
    String? errorMessage,
    bool? levelAdvanced,
  }) {
    return ProgressState(
      status: status ?? this.status,
      updatedChild: updatedChild ?? this.updatedChild,
      savedWorksheet: savedWorksheet ?? this.savedWorksheet,
      worksheetHistory: worksheetHistory ?? this.worksheetHistory,
      errorMessage: errorMessage ?? this.errorMessage,
      levelAdvanced: levelAdvanced ?? this.levelAdvanced,
    );
  }

  /// Computed properties
  bool get isLoading => status == ProgressStatus.loading;
  bool get isSaving => status == ProgressStatus.saving;
  bool get isSaved => status == ProgressStatus.saved;
  bool get isLoaded => status == ProgressStatus.loaded;
  bool get hasError => status == ProgressStatus.error;

  @override
  List<Object?> get props => [
        status,
        updatedChild,
        savedWorksheet,
        worksheetHistory,
        errorMessage,
        levelAdvanced,
      ];
}
