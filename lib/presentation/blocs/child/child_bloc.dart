import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/child_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import 'child_event.dart';
import 'child_state.dart';

/// Child BLoC
class ChildBloc extends Bloc<ChildEvent, ChildState> {
  final ChildRepository _childRepository;
  final AuthRepository _authRepository;

  ChildBloc({
    required ChildRepository childRepository,
    required AuthRepository authRepository,
  })  : _childRepository = childRepository,
        _authRepository = authRepository,
        super(ChildState.initial()) {
    on<ChildrenLoadRequested>(_onChildrenLoadRequested);
    on<ChildSelected>(_onChildSelected);
    on<ChildAddRequested>(_onChildAddRequested);
    on<ChildUpdateRequested>(_onChildUpdateRequested);
    on<ChildDeleteRequested>(_onChildDeleteRequested);
  }

  /// Load children
  Future<void> _onChildrenLoadRequested(
    ChildrenLoadRequested event,
    Emitter<ChildState> emit,
  ) async {
    emit(ChildState.loading());

    try {
      final userId = _authRepository.currentUserId;
      if (userId == null) {
        emit(ChildState.error('User not authenticated'));
        return;
      }

      final children = await _childRepository.getChildren(userId);
      emit(ChildState.loaded(children));
    } catch (e) {
      emit(ChildState.error(e.toString()));
    }
  }

  /// Select child
  Future<void> _onChildSelected(
    ChildSelected event,
    Emitter<ChildState> emit,
  ) async {
    emit(state.copyWith(selectedChild: event.child));
  }

  /// Add child
  Future<void> _onChildAddRequested(
    ChildAddRequested event,
    Emitter<ChildState> emit,
  ) async {
    emit(state.copyWith(status: ChildStatus.loading));

    try {
      final userId = _authRepository.currentUserId;
      if (userId == null) {
        emit(state.copyWith(
          status: ChildStatus.error,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      final newChild = await _childRepository.createChild(
        userId: userId,
        name: event.name,
        avatarUrl: event.avatarUrl,
      );

      final updatedChildren = [...state.children, newChild];
      emit(ChildState.loaded(updatedChildren, selectedChild: newChild));
    } catch (e) {
      emit(state.copyWith(
        status: ChildStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Update child
  Future<void> _onChildUpdateRequested(
    ChildUpdateRequested event,
    Emitter<ChildState> emit,
  ) async {
    try {
      if (event.name != null) {
        await _childRepository.updateChildName(event.childId, event.name!);
      }
      if (event.avatarUrl != null) {
        await _childRepository.updateChildAvatar(event.childId, event.avatarUrl);
      }

      // Reload children
      add(const ChildrenLoadRequested());
    } catch (e) {
      emit(state.copyWith(
        status: ChildStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Delete child
  Future<void> _onChildDeleteRequested(
    ChildDeleteRequested event,
    Emitter<ChildState> emit,
  ) async {
    emit(state.copyWith(status: ChildStatus.loading));

    try {
      await _childRepository.deleteChild(event.childId);

      final updatedChildren = state.children
          .where((c) => c.id != event.childId)
          .toList();

      // Clear selected child if deleted
      final selectedChild = state.selectedChild?.id == event.childId
          ? null
          : state.selectedChild;

      emit(ChildState.loaded(updatedChildren, selectedChild: selectedChild));
    } catch (e) {
      emit(state.copyWith(
        status: ChildStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
