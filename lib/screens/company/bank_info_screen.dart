import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class BankInfoScreen extends StatefulWidget {
  /// اتفتحت من نافذة الإلزام في RootShell — ترجع تلقائيًا بعد الحفظ.
  final bool fromPrompt;
  const BankInfoScreen({super.key, this.fromPrompt = false});

  @override
  State<BankInfoScreen> createState() => _BankInfoScreenState();
}

class _BankInfoScreenState extends State<BankInfoScreen> {
  final bankNameCtrl = TextEditingController();
  final holderCtrl = TextEditingController();
  final numberCtrl = TextEditingController();
  final ibanCtrl = TextEditingController();
  bool saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    bankNameCtrl.dispose();
    holderCtrl.dispose();
    numberCtrl.dispose();
    ibanCtrl.dispose();
    super.dispose();
  }

  void _fillFrom(AppState state) {
    final b = state.bankInfo;
    if (b == null) return;
    bankNameCtrl.text = b.bankName ?? '';
    holderCtrl.text = b.bankAccountHolder ?? '';
    numberCtrl.text = b.bankAccountNumber ?? '';
    ibanCtrl.text = b.bankIban ?? '';
  }

  Future<void> _save() async {
    if ([bankNameCtrl.text, holderCtrl.text, numberCtrl.text, ibanCtrl.text].any((s) => s.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تعبئة كل الحقول')));
      return;
    }
    final t = context.read<AppState>().t;
    final iban = BankInfo.normalizeIban(ibanCtrl.text);
    if (!BankInfo.isValidIban(iban)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('iban_invalid'))));
      return;
    }
    ibanCtrl.text = iban;
    setState(() => saving = true);
    final result = await context.read<AppState>().updateBankInfo(
          bankName: bankNameCtrl.text.trim(),
          bankAccountHolder: holderCtrl.text.trim(),
          bankAccountNumber: numberCtrl.text.trim(),
          bankIban: iban,
        );
    if (!mounted) return;
    setState(() => saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result ?? t('bank_info_saved_snackbar'))),
    );
    // لما الصفحة اتفتحت من نافذة "لازم تدخل الآيبان" نرجّع بعد الحفظ الناجح.
    if (result == null && widget.fromPrompt) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;

    if (!_initialized && state.bankInfo == null && !state.bankInfoLoading) {
      state.fetchBankInfo();
    }
    if (!_initialized && state.bankInfo != null) {
      _fillFrom(state);
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: Text(t('profile_bank_info')), foregroundColor: AppColors.text),
      body: state.bankInfoLoading && state.bankInfo == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                TextField(controller: bankNameCtrl, decoration: InputDecoration(labelText: t('field_bank_name'))),
                const SizedBox(height: 14),
                TextField(controller: holderCtrl, decoration: InputDecoration(labelText: t('field_bank_account_holder'))),
                const SizedBox(height: 14),
                TextField(controller: numberCtrl, decoration: InputDecoration(labelText: t('field_bank_account_number'))),
                const SizedBox(height: 14),
                TextField(
                  controller: ibanCtrl,
                  textCapitalization: TextCapitalization.characters,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(labelText: t('field_bank_iban'), hintText: 'SA00 0000 0000 0000 0000 0000'),
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
