import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/child_model.dart';
import '../../blocs/child/child.dart';
import '../../blocs/auth/auth.dart';

/// Child selection screen
class ChildSelectionScreen extends StatefulWidget {
  final Function(ChildModel) onChildSelected;
  final VoidCallback onLogout;

  const ChildSelectionScreen({
    super.key,
    required this.onChildSelected,
    required this.onLogout,
  });

  @override
  State<ChildSelectionScreen> createState() => _ChildSelectionScreenState();
}

class _ChildSelectionScreenState extends State<ChildSelectionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChildBloc>().add(const ChildrenLoadRequested());
  }

  void _showAddChildDialog() {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context);
    final childBloc = context.read<ChildBloc>(); // Capture bloc before dialog

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addChild),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.childName,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.enterChildName;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                childBloc.add(
                      ChildAddRequested(name: nameController.text.trim()),
                    );
                Navigator.pop(dialogContext);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ChildModel child) {
    final l10n = AppLocalizations.of(context);
    final childBloc = context.read<ChildBloc>(); // Capture bloc before dialog

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteChild),
        content: Text(l10n.confirmDeleteChild),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              childBloc.add(ChildDeleteRequested(child.id));
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectChild),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
              widget.onLogout();
            },
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: BlocConsumer<ChildBloc, ChildState>(
        listener: (context, state) {
          if (state.status == ChildStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!state.hasChildren) {
            return _buildEmptyState(context, l10n);
          }

          return _buildChildList(context, state.children, l10n);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddChildDialog,
        icon: const Icon(Icons.add),
        label: Text(l10n.addChild),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    offset: const Offset(0, 8),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.child_care_rounded,
                size: 68,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noChildren,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addFirstChild,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _showAddChildDialog,
              icon: const Icon(Icons.add),
              label: Text(l10n.addChild),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildList(
    BuildContext context,
    List<ChildModel> children,
    AppLocalizations l10n,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        return _ChildCard(
          child: child,
          onTap: () => widget.onChildSelected(child),
          onDelete: () => _showDeleteConfirmation(child),
        );
      },
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildModel child;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ChildCard({
    required this.child,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with rainbow ring
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.neonGradient,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.surface,
                  backgroundImage: child.avatarUrl != null
                      ? NetworkImage(child.avatarUrl!)
                      : null,
                  child: child.avatarUrl == null
                      ? Text(
                          child.name.isNotEmpty
                              ? child.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontFamily: 'Nunito',
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStat(
                          context,
                          Icons.star,
                          child.totalStars.toString(),
                          AppColors.gold,
                        ),
                        const SizedBox(width: 16),
                        _buildStat(
                          context,
                          Icons.local_fire_department,
                          '${child.currentStreak}',
                          AppColors.accent,
                        ),
                        const SizedBox(width: 16),
                        _buildStat(
                          context,
                          Icons.school,
                          'Lv ${child.currentLevel}',
                          AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    IconData icon,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
