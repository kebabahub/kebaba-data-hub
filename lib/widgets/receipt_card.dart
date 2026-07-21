import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Bank-style transaction receipt — mirrors the receipt shown on the website
/// right after a purchase (dashboard.php) and on past transactions.
class ReceiptCard extends StatelessWidget {
  const ReceiptCard({
    super.key,
    this.status = 'success', // 'success' | 'failed' | 'processing'
    this.amount,
    required this.serviceLabel,
    this.network,
    this.phone,
    required this.reference,
    required this.dateText,
    this.extraRows = const [],
  });

  final String status;
  final String? amount;
  final String serviceLabel;
  final String? network;
  final String? phone;
  final String reference;
  final String dateText;
  final List<MapEntry<String, String>> extraRows;

  static const _statusCopy = {'success': 'Transaction Successful', 'failed': 'Transaction Failed', 'processing': 'Processing'};
  static const _statusIcon = {'success': Icons.check, 'failed': Icons.close, 'processing': Icons.hourglass_top};

  Color get _statusColor => switch (status) {
        'failed' => AppColors.danger,
        'processing' => AppColors.brand600,
        _ => AppColors.success,
      };

  Color get _statusBg => switch (status) {
        'failed' => AppColors.dangerBgLight,
        'processing' => AppColors.brand50,
        _ => AppColors.successBgLight,
      };

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String?>>[
      MapEntry('Service', serviceLabel),
      MapEntry('Network', network),
      MapEntry('Phone Number', phone),
      ...extraRows,
      MapEntry('Reference', reference),
      MapEntry('Date & Time', dateText),
      MapEntry('Status', _statusCopy[status] ?? status),
    ].where((r) => (r.value ?? '').isNotEmpty).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: AppColors.brand600, size: 16),
                    const SizedBox(width: 4),
                    Text('KEBABADATAHUB', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.brand600)),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: _statusBg, shape: BoxShape.circle),
                  child: Icon(_statusIcon[status] ?? Icons.check, color: _statusColor, size: 26),
                ),
                const SizedBox(height: 10),
                if ((amount ?? '').isNotEmpty)
                  Text('₦$amount', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 26)),
                const SizedBox(height: 4),
                Text(_statusCopy[status] ?? status, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _statusColor)),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderLight),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(rows[i].key, style: const TextStyle(color: AppColors.inkLight500, fontSize: 12.5)),
                        Flexible(child: Text(rows[i].value!, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                      ],
                    ),
                  ),
                  if (i != rows.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderLight),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Thank you for using KEBABADATAHUB', style: TextStyle(fontSize: 11, color: AppColors.inkLight500)),
          ),
        ],
      ),
    );
  }

  /// Plain-text version for sharing — matches transaction_tile.dart's format.
  String toShareText() {
    final statusLabel = _statusCopy[status] ?? status;
    final buf = StringBuffer('KEBABADATAHUB Receipt\n\n');
    buf.writeln(serviceLabel);
    if ((network ?? '').isNotEmpty || (phone ?? '').isNotEmpty) {
      buf.writeln([network, phone].where((v) => (v ?? '').isNotEmpty).join(' · '));
    }
    if ((amount ?? '').isNotEmpty) buf.writeln('Amount: ₦$amount');
    buf.writeln('Status: $statusLabel');
    buf.writeln('Reference: $reference');
    buf.write('Date: $dateText');
    return buf.toString();
  }
}
