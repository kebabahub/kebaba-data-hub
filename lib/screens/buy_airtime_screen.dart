import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../core/api_client.dart';
import '../core/auth_provider.dart';
import '../core/theme.dart';
import '../widgets/receipt_card.dart';

const _networks = ['MTN', 'Airtel', 'Glo', '9mobile'];
const _quickAmounts = [100, 200, 500, 1000, 2000, 5000];

class BuyAirtimeScreen extends ConsumerStatefulWidget {
  const BuyAirtimeScreen({super.key});
  @override
  ConsumerState<BuyAirtimeScreen> createState() => _BuyAirtimeScreenState();
}

class _BuyAirtimeScreenState extends ConsumerState<BuyAirtimeScreen> {
  String _network = 'MTN';
  final _phoneCtrl = TextEditingController();
  int? _selectedAmount;
  final _customCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _successRef;
  DateTime? _successAt;

  Future<void> _submit() async {
    final amount = _selectedAmount ?? int.tryParse(_customCtrl.text);
    if (amount == null || amount < 50) {
      setState(() => _error = 'Choose or enter a valid amount (minimum ₦50).');
      return;
    }
    if (_phoneCtrl.text.trim().length < 10) {
      setState(() => _error = 'Enter a valid phone number.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.buyAirtime(network: _network.toLowerCase(), amount: amount, phone: _phoneCtrl.text.trim());
      if (res.data['success'] == true) {
        await ref.read(authProvider.notifier).refreshBalance();
        setState(() {
          _successRef = res.data['reference'];
          _successAt = DateTime.now();
        });
      } else {
        setState(() => _error = res.data['error'] ?? 'Purchase failed');
      }
    } catch (e) {
      setState(() => _error = ApiException.describe(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buy Airtime')),
      body: SafeArea(
        child: _successRef != null ? _buildSuccess(context) : _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Select Network', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.4,
            children: _networks.map((n) {
              final active = _network == n;
              return InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: () => setState(() => _network = n),
                child: Container(
                  decoration: BoxDecoration(
                    color: active ? AppColors.brand600 : AppColors.cardLight,
                    border: Border.all(color: active ? AppColors.brand600 : AppColors.borderLight, width: 1.5),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: Text(n, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: active ? Colors.white : AppColors.inkLight900)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: '080XXXXXXXX', counterText: ''),
          ),
          const SizedBox(height: 16),
          const Text('Amount', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
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
          const SizedBox(height: 12),
          TextField(
            controller: _customCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(prefixText: '₦ ', hintText: 'Enter a custom amount'),
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Buy Airtime'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final amount = _selectedAmount ?? int.tryParse(_customCtrl.text);
    final receipt = ReceiptCard(
      serviceLabel: 'Airtime Purchase',
      amount: amount?.toString(),
      network: _network,
      phone: _phoneCtrl.text.trim(),
      reference: _successRef!,
      dateText: DateFormat('MMM d, yyyy, h:mm a').format(_successAt ?? DateTime.now()),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          receipt,
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Share.share(receipt.toShareText()),
            icon: const Icon(Icons.share),
            label: const Text('Share Receipt'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => setState(() {
              _successRef = null;
              _successAt = null;
              _phoneCtrl.clear();
              _selectedAmount = null;
              _customCtrl.clear();
            }),
            child: const Text('Buy Again'),
          ),
        ],
      ),
    );
  }
}
