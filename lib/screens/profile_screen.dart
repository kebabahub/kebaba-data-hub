import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import '../core/auth_provider.dart';
import '../core/theme.dart';
import '../services/biometric_service.dart';
import '../widgets/app_bottom_nav.dart';

final _naira = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _biometricSupported = false;
  bool _biometricEnabled = false;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final supported = await BiometricService.instance.isDeviceSupported();
    final enabled = await BiometricService.instance.isEnabled();
    if (mounted) setState(() {
      _biometricSupported = supported;
      _biometricEnabled = enabled;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final ok = await BiometricService.instance.authenticate(reason: 'Confirm to enable biometric login');
      if (!ok) return;
    }
    await BiometricService.instance.setEnabled(value);
    setState(() => _biometricEnabled = value);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      await ref.read(authProvider.notifier).uploadPhoto(picked.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiException.describe(e))));
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take a photo'), onTap: () {
            Navigator.pop(context);
            _pickPhoto(ImageSource.camera);
          }),
          ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choose from gallery'), onTap: () {
            Navigator.pop(context);
            _pickPhoto(ImageSource.gallery);
          }),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();
    final initials = user.fullname.isNotEmpty ? user.fullname[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _uploadingPhoto ? null : _showPhotoOptions,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.brand600,
                      backgroundImage: user.photoUrl != null ? NetworkImage('https://kebabadatahub.com.ng${user.photoUrl}') : null,
                      child: user.photoUrl == null
                          ? Text(initials, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppColors.cta500, shape: BoxShape.circle),
                        child: _uploadingPhoto
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text(user.fullname, style: Theme.of(context).textTheme.titleLarge)),
            Center(child: Text(user.email, style: const TextStyle(color: AppColors.inkLight500, fontSize: 13))),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.borderLight)),
              child: Column(children: [
                _infoRow('Wallet balance', _naira.format(user.balance)),
                const Divider(),
                _infoRow('Phone', user.phone),
                const Divider(),
                _infoRow('Role', user.role[0].toUpperCase() + user.role.substring(1)),
              ]),
            ),
            const SizedBox(height: 16),

            if (_biometricSupported)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.borderLight)),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Biometric login', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('Use Face ID / fingerprint to open the app', style: TextStyle(fontSize: 12)),
                  value: _biometricEnabled,
                  onChanged: _toggleBiometric,
                ),
              ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text('Logout', style: TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _confirmDeleteAccount(context),
              child: const Text('Delete account', style: TextStyle(color: AppColors.inkLight500, fontSize: 12, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final passwordCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete your account?'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('This permanently deletes your account. If you have a wallet balance, contact support first — it cannot be recovered after deletion.', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 16),
          TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm your password')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ApiClient.instance.deleteAccount(passwordCtrl.text);
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiException.describe(e))));
      }
    }
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: AppColors.inkLight500, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      );
}
