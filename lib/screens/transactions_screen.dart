import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../models/transaction.dart';
import '../services/cache_service.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  static const _cacheKey = 'transactions_page_1';
  List<AppTransaction> _transactions = [];
  int _page = 1;
  int _totalPages = 1;
  bool _loading = true;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1}) async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.getTransactions(page: page);
      final list = (res.data['data'] as List).map((j) => AppTransaction.fromJson(j)).toList();
      setState(() {
        _transactions = list;
        _page = page;
        _totalPages = res.data['meta']['total_pages'];
        _offline = false;
      });
      if (page == 1) {
        await CacheService.instance.putJson(_cacheKey, res.data['data']);
        await CacheService.instance.markUpdated(_cacheKey);
      }
    } catch (_) {
      // No connection — fall back to whatever we last cached for page 1.
      if (page == 1) {
        final cached = CacheService.instance.getJson<List<AppTransaction>>(
          _cacheKey,
          (decoded) => (decoded as List).map((j) => AppTransaction.fromJson(j)).toList(),
        );
        if (cached != null) {
          setState(() {
            _transactions = cached;
            _offline = true;
          });
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: SafeArea(
        child: Column(
          children: [
            if (_offline)
              Container(
                width: double.infinity,
                color: AppColors.warningBgLight,
                padding: const EdgeInsets.all(10),
                child: const Text('Showing saved data — you appear to be offline.', style: TextStyle(color: AppColors.warning), textAlign: TextAlign.center),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _transactions.isEmpty
                      ? const Center(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.inbox_outlined, size: 48, color: AppColors.inkLight400),
                            SizedBox(height: 12),
                            Text('No transactions yet.', style: TextStyle(color: AppColors.inkLight500)),
                          ]),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _load(page: 1),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _transactions.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) => TransactionTile(tx: _transactions[i]),
                          ),
                        ),
            ),
            if (_totalPages > 1 && !_offline)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _page > 1 ? () => _load(page: _page - 1) : null,
                      icon: const Icon(Icons.chevron_left, size: 18),
                      label: const Text('Newer'),
                    ),
                    Text('Page $_page of $_totalPages', style: const TextStyle(color: AppColors.inkLight500, fontSize: 12)),
                    TextButton.icon(
                      onPressed: _page < _totalPages ? () => _load(page: _page + 1) : null,
                      label: const Text('Older'),
                      icon: const Icon(Icons.chevron_right, size: 18),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
