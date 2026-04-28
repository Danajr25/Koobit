import 'package:equatable/equatable.dart';
import '../../../data/models/child_model.dart';

/// Child events
abstract class ChildEvent extends Equatable {
  const ChildEvent();

  @override
  List<Object?> get props => [];
}

/// Load all children for current user
class ChildrenLoadRequested extends ChildEvent {
  const ChildrenLoadRequested();
}

/// Select a child
class ChildSelected extends ChildEvent {
  final ChildModel child;

  const ChildSelected(this.child);

  @override
  List<Object?> get props => [child];
}

/// Add new child
class ChildAddRequested extends ChildEvent {
  final String name;
  final String? avatarUrl;

  const ChildAddRequested({
    required this.name,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [name, avatarUrl];
}

/// Update child
class ChildUpdateRequested extends ChildEvent {
  final String childId;
  final String? name;
  final String? avatarUrl;

  const ChildUpdateRequested({
    required this.childId,
    this.name,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [childId, name, avatarUrl];
}

/// Delete child
class ChildDeleteRequested extends ChildEvent {
  final String childId;

  const ChildDeleteRequested(this.childId);

  @override
  List<Object?> get props => [childId];
}
