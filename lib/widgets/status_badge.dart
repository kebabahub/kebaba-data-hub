import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Mirrors status_badge() in includes/layout.php — same three states, same colors.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    late Color fg;
    late Color bg;
    switch (status) {
      case 'success':
        fg = AppColors.success;
        bg = AppColors.successBgLight;
        break;
      case 'failed':
        fg = AppColors.danger;
        bg = AppColors.dangerBgLight;
        break;
      default: // processing / pending
        fg = AppColors.warning;
        bg = AppColors.warningBgLight;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
