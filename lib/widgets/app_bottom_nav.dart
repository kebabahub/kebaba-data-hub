import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

/// Mirrors dashboard.php's <nav class="bottom-nav"> exactly: Home,
/// Transactions, Services, Account — same order, same icons.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});
  final int currentIndex; // 0=Home, 1=Transactions, 2=Services, 3=Account

  static const _routes = ['/dashboard', '/transactions', '/services', '/profile'];
  static const _icons = [Icons.home_outlined, Icons.history, Icons.grid_view_outlined, Icons.person_outline];
  static const _activeIcons = [Icons.home, Icons.history, Icons.grid_view, Icons.person];
  static const _labels = ['Home', 'Transactions', 'Services', 'Account'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(4, (i) {
              final active = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: active ? null : () => context.go(_routes[i]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(active ? _activeIcons[i] : _icons[i], color: active ? AppColors.brand600 : AppColors.inkLight500, size: 22),
                      const SizedBox(height: 2),
                      Text(
                        _labels[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? AppColors.brand600 : AppColors.inkLight500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
