import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme.dart';
import '../models/transaction.dart';
import 'status_badge.dart';

final _naira = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2);

IconData _iconFor(String serviceType) {
  switch (serviceType) {
    case 'airtime':
      return Icons.phone_android;
    case 'buy_data':
      return Icons.wifi;
    case 'cable':
      return Icons.tv;
    case 'electricity':
      return Icons.bolt;
    default:
      return Icons.receipt_long;
  }
}

/// Mirrors .transaction-item markup on the website's Transaction History page.
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.tx});
  final AppTransaction tx;

  Future<void> _shareReceipt() async {
    final sign = tx.credit ? '+' : '-';
    final text = 'KEBABADATAHUB Receipt\n\n'
        '${tx.title}\n'
        '${tx.meta}\n'
        'Amount: $sign${_naira.format(tx.amount)}\n'
        'Status: ${tx.status}\n'
        'Reference: ${tx.reference}\n'
        'Date: ${DateFormat('d MMM yyyy, HH:mm').format(tx.createdAt)}';
    await Share.share(text, subject: 'KEBABADATAHUB Receipt — ${tx.reference}');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: _shareReceipt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: (tx.credit ? AppColors.success : AppColors.brand600).withOpacity(.1),
          shape: BoxShape.circle,
        ),
        child: Icon(_iconFor(tx.serviceType), color: tx.credit ? AppColors.success : AppColors.brand600, size: 20),
      ),
      title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
      subtitle: Text('${tx.meta} · ${tx.reference}', style: const TextStyle(fontSize: 12, color: AppColors.inkLight500), overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${tx.credit ? '+' : '-'} ${_naira.format(tx.amount)}',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: tx.credit ? AppColors.success : AppColors.inkLight900),
          ),
          const SizedBox(height: 4),
          StatusBadge(status: tx.status),
        ],
      ),
      onTap: _shareReceipt,
    );
  }
}
