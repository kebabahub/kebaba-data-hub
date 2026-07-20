import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Mirrors .action-card / .action-airtime / .action-data in styles.css:
/// gradient tint background, white icon chip, dark title, muted subtitle,
/// circular colored arrow bottom-right.
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.variant,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final ActionCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final isAirtime = variant == ActionCardVariant.airtime;
    final gradient = isAirtime
        ? const LinearGradient(colors: [Color(0xFFE8F0FE), Color(0xFFDCE8FD)], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : const LinearGradient(colors: [Color(0xFFE6F8EC), Color(0xFFD9F4E3)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    final accent = isAirtime ? AppColors.brand600 : const Color(0xFF12A150);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(AppRadius.lg)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: accent.withOpacity(.35), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5, color: AppColors.inkLight900, letterSpacing: -0.2)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.inkLight500)),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: accent.withOpacity(.5), blurRadius: 16, offset: const Offset(0, 8))]),
                  child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ActionCardVariant { airtime, data }
