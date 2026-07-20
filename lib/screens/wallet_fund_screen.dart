import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/api_client.dart';
import '../core/auth_provider.dart';
import '../core/theme.dart';

const _quickAmounts = [500, 1000, 2000, 5000, 10000, 20000];

class WalletFundScreen extends ConsumerStatefulWidget {
  const WalletFundScreen({super.key});
  @override
  ConsumerState<WalletFundScreen> createState() => _WalletFundScreenState();
}

class _WalletFundScreenState extends ConsumerState<WalletFundScreen> {
  int? _selectedAmount;
  final _customCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _account; // {reference, amount, account_number, account_name, bank_name}
  Timer? _pollTimer;
  bool _completed = false;

  @override
  void dispose() {
    _pollTimer?.cancel();
    _customCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final amount = _selectedAmount ?? int.tryParse(_customCtrl.text);
    if (amount == null || amount < 100) {
      setState(() => _error = 'Choose or enter a valid amount (minimum ₦100).');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.fundWallet(amount.toDouble());
      setState(() => _account = Map<String, dynamic>.from(res.data['data']));
      _startPolling();
    } catch (e) {
      setState(() => _error = ApiException.describe(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_account == null) return;
      try {
        final res = await ApiClient.instance.fundingStatus(_account!['reference']);
        final status = res.data['data']['status'];
        if (status == 'completed') {
          _pollTimer?.cancel();
          await ref.read(authProvider.notifier).refreshBalance();
          if (mounted) setState(() => _completed = true);
        } else if (status == 'expired' || status == 'cancelled' || status == 'failed') {
          _pollTimer?.cancel();
          if (mounted) setState(() => _error = 'This funding request $status. Start over with a new amount.');
        }
      } catch (_) {
        // Transient network error — keep polling, next tick will retry.
      }
    });
  }

  void _reset() {
    _pollTimer?.cancel();
    setState(() {
      _account = null;
      _selectedAmount = null;
      _customCtrl.clear();
      _error = null;
      _completed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Funds')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _completed ? _buildCompleted(context) : (_account != null ? _buildAccountStep(context) : _buildAmountStep(context)),
        ),
      ),
    );
  }

  Widget _buildAmountStep(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Enter how much you want to add — we'll generate a bank account for that exact amount.", style: TextStyle(color: AppColors.inkLight500)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.8,
            children: _quickAmounts.map((amt) {
              final active = _selectedAmount == amt;
              return InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: () => setState(() {
                  _selectedAmount = amt;
                  _customCtrl.clear();
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: active ? AppColors.brand600 : AppColors.cardLight,
                    border: Border.all(color: active ? AppColors.brand600 : AppColors.borderLight, width: 1.5),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: Text('₦$amt', style: TextStyle(fontWeight: FontWeight.w800, color: active ? Colors.white : AppColors.inkLight900)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(prefixText: '₦ ', hintText: 'Enter a custom amount (min ₦100)'),
            onChanged: (_) => setState(() => _selectedAmount = null),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.dangerBgLight, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _generate,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Generate account number'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStep(BuildContext context) {
    final a = _account!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(children: [
              Text('Transfer exactly ₦${a['amount']}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const Text('This account expires after 24 hours or once payment is received.', style: TextStyle(color: AppColors.inkLight500), textAlign: TextAlign.center),
            ]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.borderLight)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Bank', style: TextStyle(color: AppColors.inkLight500, fontSize: 12)),
              Text(a['bank_name'] ?? '—', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 12),
              Text(a['account_number'] ?? '—', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: 1)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Account holder', style: TextStyle(color: AppColors.inkLight500, fontSize: 12)),
                Text(a['account_name'] ?? '—', style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => Clipboard.setData(ClipboardData(text: a['account_number'] ?? '')),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy account number'),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.warningBgLight, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: const Text("Transfer the exact amount shown above — this account won't recognize a different amount.", style: TextStyle(color: AppColors.warning)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.infoBgLight, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: const Row(children: [
              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Expanded(child: Text('Watching for your transfer — your balance updates automatically once received.', style: TextStyle(color: AppColors.info))),
            ]),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: _reset, child: const Text('Use a different amount')),
        ],
      ),
    );
  }

  Widget _buildCompleted(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 64),
          const SizedBox(height: 16),
          Text('Payment received!', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Your wallet balance has been updated.', style: TextStyle(color: AppColors.inkLight500)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => context.pop(), child: const Text('Done')),
        ],
      ),
    );
  }
}
