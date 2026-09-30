import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool saving = false;
  String? error;
  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.read<AppState>().t;
    if (currentCtrl.text.isEmpty || newCtrl.text.isEmpty) {
      setState(() => error = t('err_password_fields_required'));
      return;
    }
    if (newCtrl.text.length < 8) {
      setState(() => error = t('err_new_password_min_length'));
      return;
    }
    if (newCtrl.text != confirmCtrl.text) {
      setState(() => error = t('err_password_mismatch'));
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    final result = await context.read<AppState>().changePassword(
          currentPassword: currentCtrl.text,
          newPassword: newCtrl.text,
        );

    if (!mounted) return;
    setState(() => saving = false);

    if (result == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('password_changed_snackbar'))));
    } else {
      setState(() => error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return Scaffold(
      appBar: AppBar(title: Text(t('profile_change_password')), foregroundColor: AppColors.text),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(10)),
              child: Text(error!, style: const TextStyle(fontSize: 12.5, color: AppColors.danger)),
            ),
            const SizedBox(height: 14),
          ],
          TextField(
            controller: currentCtrl,
            obscureText: obscureCurrent,
            decoration: InputDecoration(
              labelText: t('field_current_password'),
              suffixIcon: IconButton(
                icon: Icon(obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                onPressed: () => setState(() => obscureCurrent = !obscureCurrent),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: newCtrl,
            obscureText: obscureNew,
            decoration: InputDecoration(
              labelText: t('field_new_password'),
              suffixIcon: IconButton(
                icon: Icon(obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                onPressed: () => setState(() => obscureNew = !obscureNew),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: confirmCtrl,
            obscureText: obscureConfirm,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: t('field_confirm_password'),
              suffixIcon: IconButton(
                icon: Icon(obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saving ? null : _save,
            child: saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(t('action_save_changes')),
          ),
        ],
      ),
    );
  }
}
