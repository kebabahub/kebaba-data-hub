import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/app_bottom_nav.dart';

class _ServiceItem {
  const _ServiceItem(this.icon, this.color, this.title, this.subtitle, {this.comingSoon = true});
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool comingSoon;
}

// Mirrors services.php's list exactly — Cable TV / Electricity are genuinely
// unavailable (confirmed against the provider, not a placeholder we forgot
// to wire up), same as the rest.
const _services = [
  _ServiceItem(Icons.tv, Color(0xFF9333EA), 'Cable TV', 'Pay for TV subscriptions'),
  _ServiceItem(Icons.bolt, Color(0xFFF59E0B), 'Electricity', 'Pay your bills'),
  _ServiceItem(Icons.school, Color(0xFF3B82F6), 'Education', 'School fee payments'),
  _ServiceItem(Icons.credit_card, Color(0xFF10B981), 'Recharge Card', 'Print recharge PINs'),
  _ServiceItem(Icons.bookmark, Color(0xFFEC4899), 'WAEC', 'Buy WAEC scratch cards'),
  _ServiceItem(Icons.fact_check, Color(0xFF14B8A6), 'NECO', 'Buy NECO scratch cards'),
  _ServiceItem(Icons.article, Color(0xFFEF4444), 'JAMB', 'Buy JAMB PIN'),
  _ServiceItem(Icons.wifi, Color(0xFF6366F1), 'Smile', 'Smile internet recharge'),
  _ServiceItem(Icons.router, Color(0xFF06B6D4), 'Spectranet', 'Spectranet data recharge'),
];

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _services.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final s = _services[i];
            return InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${s.title} is coming soon'))),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.borderLight)),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(color: s.color.withOpacity(.12), shape: BoxShape.circle),
                      child: Icon(s.icon, color: s.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          Text(s.subtitle, style: const TextStyle(color: AppColors.inkLight500, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.inkLight400),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
