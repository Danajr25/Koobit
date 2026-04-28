import 'package:equatable/equatable.dart';
import '../../../data/models/child_model.dart';

/// Child loading status
enum ChildStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Child state
class ChildState extends Equatable {
  final ChildStatus status;
  final List<ChildModel> children;
  final ChildModel? selectedChild;
  final String? errorMessage;

  const ChildState({
    this.status = ChildStatus.initial,
    this.children = const [],
    this.selectedChild,
    this.errorMessage,
  });

  /// Initial state
  factory ChildState.initial() {
    return const ChildState(status: ChildStatus.initial);
  }

  /// Loading state
  factory ChildState.loading() {
    return const ChildState(status: ChildStatus.loading);
  }

  /// Loaded state
  factory ChildState.loaded(List<ChildModel> children, {ChildModel? selectedChild}) {
    return ChildState(
      status: ChildStatus.loaded,
      children: children,
      selectedChild: selectedChild,
    );
  }

  /// Error state
  factory ChildState.error(String message) {
    return ChildState(
      status: ChildStatus.error,
      errorMessage: message,
    );
  }

  /// Check if has children
  bool get hasChildren => children.isNotEmpty;

  /// Check if a child is selected
  bool get hasSelectedChild => selectedChild != null;

  /// Check if loading
  bool get isLoading => status == ChildStatus.loading;

  /// Copy with method
  ChildState copyWith({
    ChildStatus? status,
    List<ChildModel>? children,
    ChildModel? selectedChild,
    String? errorMessage,
  }) {
    return ChildState(
      status: status ?? this.status,
      children: children ?? this.children,
      selectedChild: selectedChild ?? this.selectedChild,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, children, selectedChild, errorMessage];
}
