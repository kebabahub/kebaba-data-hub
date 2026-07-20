import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/api_client.dart';
import '../core/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiClient.instance.forgotPassword(_identifierCtrl.text.trim());
      setState(() => _sent = true);
    } catch (e) {
      setState(() => _error = ApiException.describe(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Reset your password', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              const Text("Enter the email or phone number on your account and we'll send a reset code to your email.", style: TextStyle(color: AppColors.inkLight500)),
              const SizedBox(height: 24),
              if (_sent) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.successBgLight, borderRadius: BorderRadius.circular(AppRadius.sm)),
                  child: const Text('If that account exists, a reset code is on its way to the email on file. Check your inbox — it expires in 10 minutes.', style: TextStyle(color: AppColors.success)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => context.push('/reset-password'), child: const Text('I have my code')),
              ] else ...[
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.dangerBgLight, borderRadius: BorderRadius.circular(AppRadius.sm)),
                    child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                  ),
                  const SizedBox(height: 16),
                ],
                Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    const Text('Email or phone number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _identifierCtrl,
                      decoration: const InputDecoration(hintText: 'you@example.com or 080XXXXXXXX'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('Send reset code'),
                    ),
                  ]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
