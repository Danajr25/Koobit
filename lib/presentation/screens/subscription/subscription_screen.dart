import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/billplz_config.dart';
import '../../../core/services/billplz_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../blocs/auth/auth.dart';
import '../../widgets/cyber_widgets.dart';

/// Subscription management screen – Billplz payment gateway.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final AuthRepository _authRepo = AuthRepository();
  final BillplzService _billplz = BillplzService.instance;

  UserModel? _user;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;

  // Tracks a pending bill so the user can verify payment after returning
  String? _pendingBillId;

  // Which plan the user tapped – 'monthly' or 'yearly'
  String _selectedPlan = 'monthly';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authState = context.read<AuthBloc>().state;
    if (authState.status != AuthStatus.authenticated ||
        authState.user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final user = await _authRepo.getUserProfile(authState.user!.id);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  bool get _isActive {
    if (kDebugMode) return true; // bypass in debug
    if (_user == null) return false;
    return _user!.subscriptionStatus == 'active' &&
        (_user!.subscriptionEndDate?.isAfter(DateTime.now()) ?? false);
  }

  bool get _isTrialActive {
    if (kDebugMode) return false;
    if (_user == null) return false;
    return _user!.isTrialActive;
  }

  int get _trialDaysLeft {
    if (_user == null) return 0;
    final end = _user!.trialStartDate.add(const Duration(days: 30));
    return end.difference(DateTime.now()).inDays.clamp(0, 30);
  }

  int get _amountCents => _selectedPlan == 'yearly'
      ? (BillplzConfig.yearlyPriceRm * 100).toInt()
      : (BillplzConfig.monthlyPriceRm * 100).toInt();

  String get _planLabel => _selectedPlan == 'yearly'
      ? 'Koobit Yearly Plan'
      : 'Koobit Monthly Plan';

  // ── actions ─────────────────────────────────────────────────────────────

  Future<void> _subscribe() async {
    final authState = context.read<AuthBloc>().state;
    if (authState.user == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    if (BillplzConfig.apiKey == 'YOUR_BILLPLZ_API_KEY') {
      // Credentials not yet configured – show placeholder message
      setState(() {
        _isProcessing = false;
        _errorMessage =
            'Billplz credentials not configured yet.\n'
            'Open lib/core/constants/billplz_config.dart and fill in '
            'your API key & collection ID.';
      });
      return;
    }

    try {
      final bill = await _billplz.createBill(
          email: authState.user!.email,
        name: 'Koobit Parent',
        amountCents: _amountCents,
        description: _planLabel,
      );

      setState(() {
        _pendingBillId = bill.id;
        _isProcessing = false;
      });

      await _openPaymentUrl(bill.url);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _openPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      setState(() => _errorMessage = 'Could not open payment page.\nURL: $url');
    }
  }

  Future<void> _verifyPayment() async {
    if (_pendingBillId == null) return;

    final authBloc = context.read<AuthBloc>();

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final bill = await _billplz.getBill(_pendingBillId!);

      if (bill.paid) {
        // Update Supabase with active subscription
        final authState = authBloc.state;
        if (authState.user != null) {
          final endDate = _selectedPlan == 'yearly'
              ? DateTime.now().add(const Duration(days: 365))
              : DateTime.now().add(const Duration(days: 30));
          await _authRepo.updateSubscription(
            userId: authState.user!.id,
            status: 'active',
            endDate: endDate,
          );
          await _loadUser();
        }

        setState(() {
          _pendingBillId = null;
          _isProcessing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment verified! Subscription activated.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage =
              'Payment not yet received (status: ${bill.state}).\n'
              'Complete payment in browser then tap Verify again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Subscription',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: CyberGridBackground()),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  _buildBenefits(),
                  const SizedBox(height: 20),
                  if (!_isActive) ...[
                    _buildPlanCards(),
                    const SizedBox(height: 20),
                    _buildSubscribeButton(),
                    if (_pendingBillId != null) ...[
                      const SizedBox(height: 12),
                      _buildVerifyButton(),
                    ],
                  ] else ...[
                    _buildActiveDetails(),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorBox(),
                  ],
                  if (BillplzConfig.sandbox) ...[
                    const SizedBox(height: 12),
                    _buildSandboxBadge(),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── widgets ──────────────────────────────────────────────────────────────

  Widget _buildStatusCard() {
    final Color statusColor;
    final String statusLabel;
    final String statusSub;

    if (kDebugMode) {
      statusColor = AppColors.success;
      statusLabel = 'DEBUG — All features unlocked';
      statusSub = 'kDebugMode bypass active';
    } else if (_isActive) {
      statusColor = AppColors.success;
      statusLabel = 'Active Subscription';
      final end = _user?.subscriptionEndDate;
      statusSub = end != null
          ? 'Renews ${end.day}/${end.month}/${end.year}'
          : 'Subscription active';
    } else if (_isTrialActive) {
      statusColor = AppColors.warning;
      statusLabel = 'Free Trial';
      statusSub = '$_trialDaysLeft days remaining';
    } else {
      statusColor = AppColors.error;
      statusLabel = 'No Active Subscription';
      statusSub = 'Subscribe to unlock all levels';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isActive || kDebugMode
                  ? Icons.verified_rounded
                  : _isTrialActive
                      ? Icons.hourglass_top_rounded
                      : Icons.lock_outline_rounded,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusSub,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    const benefits = [
      (Icons.all_inclusive_rounded, 'Unlimited access to all 62 levels'),
      (Icons.people_rounded, 'Multiple child profiles'),
      (Icons.bar_chart_rounded, 'Detailed progress reports'),
      (Icons.sports_esports_rounded, 'All arcade mini-games'),
      (Icons.block_rounded, 'No advertisements'),
      (Icons.support_agent_rounded, 'Priority support'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What you get',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...benefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(b.$1, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    b.$2,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCards() {
    return Row(
      children: [
        Expanded(
          child: _PlanCard(
            label: 'Monthly',
            price: 'RM ${BillplzConfig.monthlyPriceRm.toStringAsFixed(2)}',
            period: '/month',
            badge: null,
            selected: _selectedPlan == 'monthly',
            onTap: () => setState(() => _selectedPlan = 'monthly'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PlanCard(
            label: 'Yearly',
            price: 'RM ${BillplzConfig.yearlyPriceRm.toStringAsFixed(2)}',
            period: '/year',
            badge:
                'Save ${BillplzConfig.yearlySavingPct.toStringAsFixed(0)}%',
            selected: _selectedPlan == 'yearly',
            onTap: () => setState(() => _selectedPlan = 'yearly'),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton() {
    return CyberButton(
      text: _isProcessing ? 'Creating bill…' : 'Subscribe — $_planLabel',
      icon: Icons.credit_card_rounded,
      onPressed: _isProcessing ? null : _subscribe,
      color: AppColors.primary,
    );
  }

  Widget _buildVerifyButton() {
    return OutlinedButton.icon(
      onPressed: _isProcessing ? null : _verifyPayment,
      icon: const Icon(Icons.check_circle_outline_rounded),
      label: Text(_isProcessing ? 'Checking…' : "I've paid — Verify Payment"),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.success,
        side: const BorderSide(color: AppColors.success),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildActiveDetails() {
    final end = _user?.subscriptionEndDate;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Plan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          if (end != null)
            Text(
              'Valid until ${end.day}/${end.month}/${end.year}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _showCancelDialog(),
            icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
            label: const Text(
              'Cancel Subscription',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style:
                  const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.error),
            onPressed: () => setState(() => _errorMessage = null),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSandboxBadge() {
    return Center(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.science_rounded,
                size: 14, color: AppColors.warning),
            SizedBox(width: 6),
            Text(
              'Billplz Sandbox Mode — no real charges',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cancel Subscription',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Are you sure you want to cancel?\nYou will keep access until the end of your billing period.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authState = context.read<AuthBloc>().state;
              if (authState.user != null) {
                await _authRepo.updateSubscription(
                  userId: authState.user!.id,
                  status: 'cancelled',
                );
                await _loadUser();
              }
            },
            child: const Text('Cancel Subscription',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── helper widgets ───────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final String label;
  final String price;
  final String period;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.label,
    required this.price,
    required this.period,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? AppColors.primary : AppColors.border;
    final bgColor = selected
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.surface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: TextStyle(
                color:
                    selected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              period,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20)
            else
              const Icon(Icons.radio_button_unchecked_rounded,
                  color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// CyberButton is provided by ../../widgets/cyber_widgets.dart
