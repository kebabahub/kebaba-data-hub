import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/auth_provider.dart';
import '../core/theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/action_card.dart';

final _naira = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2);

const _whatsappSupportLink = 'https://chat.whatsapp.com/EEJ7LRa2NTb9FearP8lb4P';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _balanceVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(authProvider.notifier).refreshBalance());
  }

  Future<void> _openWhatsapp() async {
    final uri = Uri.parse(_whatsappSupportLink);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();
    final firstName = user.fullname.split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(authProvider.notifier).refreshBalance(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: brand mark + account menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(width: 34, height: 34, decoration: const BoxDecoration(color: AppColors.brand600, shape: BoxShape.circle), child: const Icon(Icons.bolt, color: Colors.white, size: 18)),
                      const SizedBox(width: 8),
                      const Text('KEBABADATAHUB', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    ]),
                    IconButton(icon: const Icon(Icons.logout, size: 20), onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Hi, $firstName 👋', style: Theme.of(context).textTheme.headlineSmall),
                const Text('What would you like to buy today?', style: TextStyle(color: AppColors.inkLight500)),
                const SizedBox(height: 20),

                // Wallet card — mirrors .wallet-card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.brand600, AppColors.brand700], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [BoxShadow(color: AppColors.brand600.withOpacity(.35), blurRadius: 24, offset: const Offset(0, 12))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _balanceVisible ? _naira.format(user.balance) : '₦••••••',
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                          ),
                          Row(children: [
                            IconButton(
                              icon: Icon(_balanceVisible ? Icons.visibility_off : Icons.visibility, color: Colors.white, size: 20),
                              onPressed: () => setState(() => _balanceVisible = !_balanceVisible),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/wallet/fund'),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Funds'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.brand600, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                            ),
                          ]),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
                  TextButton(onPressed: () => context.push('/services'), child: const Text('More services →')),
                ]),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ActionCard(
                        icon: Icons.phone_android,
                        title: 'Buy Airtime',
                        subtitle: 'All networks, instant',
                        variant: ActionCardVariant.airtime,
                        onTap: () => context.push('/buy/airtime'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActionCard(
                        icon: Icons.wifi,
                        title: 'Buy Data',
                        subtitle: 'MTN, Glo, Airtel, 9mobile',
                        variant: ActionCardVariant.data,
                        onTap: () => context.push('/buy/data'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openWhatsapp,
        backgroundColor: const Color(0xFF25D366),
        icon: const Icon(Icons.chat, color: Colors.white),
        label: const Text('Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
