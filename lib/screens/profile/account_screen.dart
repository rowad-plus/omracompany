import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

/// بيانات الحساب الشخصي لأي مستخدم (مالك أو موظف): الاسم والبريد والجوال.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final TextEditingController nameCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController phoneCtrl;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    nameCtrl = TextEditingController(text: s.accountName);
    emailCtrl = TextEditingController(text: s.accountEmail);
    phoneCtrl = TextEditingController(text: s.accountPhone);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.read<AppState>().t;
    if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('account_fill_required'))));
      return;
    }
    setState(() => saving = true);
    final result = await context.read<AppState>().updateProfile(
          name: nameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result ?? t('account_saved_snackbar'))));
    if (result == null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return Scaffold(
      appBar: AppBar(title: Text(t('profile_my_account')), foregroundColor: AppColors.text),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t('account_field_name'))),
          const SizedBox(height: 14),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(labelText: t('field_email')),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(labelText: t('field_contact_number')),
          ),
          const SizedBox(height: 18),
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
