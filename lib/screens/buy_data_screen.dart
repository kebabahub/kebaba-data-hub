import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../core/api_client.dart';
import '../core/auth_provider.dart';
import '../core/theme.dart';
import '../models/data_plan.dart';
import '../widgets/receipt_card.dart';

const _networks = ['MTN', 'Airtel', 'Glo', '9mobile'];

class BuyDataScreen extends ConsumerStatefulWidget {
  const BuyDataScreen({super.key});
  @override
  ConsumerState<BuyDataScreen> createState() => _BuyDataScreenState();
}

class _BuyDataScreenState extends ConsumerState<BuyDataScreen> {
  String _network = 'MTN';
  final _phoneCtrl = TextEditingController();
  List<DataPlan> _plans = [];
  DataPlan? _selectedPlan;
  bool _plansLoading = true;
  bool _submitting = false;
  String? _error;
  String? _successRef;
  DateTime? _successAt;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _plansLoading = true;
      _selectedPlan = null;
    });
    try {
      final res = await ApiClient.instance.getPlans(_network.toLowerCase() == '9mobile' ? 'mobile9' : _network.toLowerCase());
      final list = (res.data['data'] as List).map((j) => DataPlan.fromJson(j)).toList();
      setState(() => _plans = list);
    } catch (_) {
      setState(() => _plans = []);
    } finally {
      if (mounted) setState(() => _plansLoading = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedPlan == null) {
      setState(() => _error = 'Choose a data plan.');
      return;
    }
    if (_phoneCtrl.text.trim().length < 10) {
      setState(() => _error = 'Enter a valid phone number.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.buyData(
        network: _network.toLowerCase() == '9mobile' ? 'mobile9' : _network.toLowerCase(),
        plan: _selectedPlan!.id.toString(),
        phone: _phoneCtrl.text.trim(),
      );
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
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buy Data')),
      body: SafeArea(
        child: _successRef != null ? _buildSuccess(context) : _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                    onTap: () {
                      setState(() => _network = n);
                      _loadPlans();
                    },
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
              const SizedBox(height: 16),
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
              const Text('Select Plan', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        Expanded(
          child: _plansLoading
              ? const Center(child: CircularProgressIndicator())
              : _plans.isEmpty
                  ? const Center(child: Text('No plans available for this network right now.', style: TextStyle(color: AppColors.inkLight500)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      itemCount: _plans.length,
                      itemBuilder: (context, i) {
                        final p = _plans[i];
                        final active = _selectedPlan?.id == p.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            onTap: () => setState(() => _selectedPlan = p),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: active ? AppColors.brand50 : AppColors.cardLight,
                                border: Border.all(color: active ? AppColors.brand600 : AppColors.borderLight, width: active ? 1.5 : 1),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5))),
                                  Text('₦${p.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.brand600)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.dangerBgLight, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text(_selectedPlan == null ? 'Buy Data' : 'Buy ${_selectedPlan!.name} — ₦${_selectedPlan!.price.toStringAsFixed(0)}'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final plan = _selectedPlan;
    final receipt = ReceiptCard(
      serviceLabel: plan?.name ?? 'Data Purchase',
      amount: plan?.price.toStringAsFixed(0),
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
              _selectedPlan = null;
            }),
            child: const Text('Buy Again'),
          ),
        ],
      ),
    );
  }
}
