import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/location_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class _DialCode {
  final String dial;
  final String iso;
  final String flag;
  const _DialCode(this.dial, this.iso, this.flag);
}

const _dialCodes = [
  _DialCode('+966', 'SA', '🇸🇦'),
  _DialCode('+20', 'EG', '🇪🇬'),
  _DialCode('+971', 'AE', '🇦🇪'),
  _DialCode('+965', 'KW', '🇰🇼'),
  _DialCode('+974', 'QA', '🇶🇦'),
  _DialCode('+973', 'BH', '🇧🇭'),
  _DialCode('+968', 'OM', '🇴🇲'),
  _DialCode('+962', 'JO', '🇯🇴'),
  _DialCode('+964', 'IQ', '🇮🇶'),
  _DialCode('+967', 'YE', '🇾🇪'),
  _DialCode('+961', 'LB', '🇱🇧'),
  _DialCode('+970', 'PS', '🇵🇸'),
  _DialCode('+218', 'LY', '🇱🇾'),
  _DialCode('+216', 'TN', '🇹🇳'),
  _DialCode('+213', 'DZ', '🇩🇿'),
  _DialCode('+212', 'MA', '🇲🇦'),
  _DialCode('+249', 'SD', '🇸🇩'),
  _DialCode('+90', 'TR', '🇹🇷'),
  _DialCode('+92', 'PK', '🇵🇰'),
  _DialCode('+91', 'IN', '🇮🇳'),
  _DialCode('+880', 'BD', '🇧🇩'),
  _DialCode('+62', 'ID', '🇮🇩'),
  _DialCode('+60', 'MY', '🇲🇾'),
  _DialCode('+44', 'GB', '🇬🇧'),
  _DialCode('+1', 'US', '🇺🇸'),
];

/// تسجيل شركة جديدة — الخطوة الأولى (بيانات المالك)، زي صفحة الانضمام في
/// الموقع. بعد النجاح بيدخل على طول، و AuthGate بيعرض خطوة بيانات الشركة.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final nationalIdCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool obscure = true;
  bool loading = false;
  String? error;
  late String dialCode;

  @override
  void initState() {
    super.initState();
    final deviceCountry = PlatformDispatcher.instance.locale.countryCode;
    dialCode = _dialCodes.firstWhere((c) => c.iso == deviceCountry, orElse: () => _dialCodes.first).dial;
    _refineFromIp();
  }

  Future<void> _refineFromIp() async {
    final before = dialCode;
    final code = await LocationService.detectCountryCode();
    if (!mounted || code == null || dialCode != before) return;
    final match = _dialCodes.where((c) => c.iso == code);
    if (match.isNotEmpty) setState(() => dialCode = match.first.dial);
  }

  @override
  void dispose() {
    for (final c in [nameCtrl, nationalIdCtrl, emailCtrl, phoneCtrl, passwordCtrl, confirmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final state = context.read<AppState>();
    final t = state.t;
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final phone = phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^0+'), '');
    final password = passwordCtrl.text;

    String? problem;
    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      problem = t('reg_err_required');
    } else if (email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      problem = t('reg_err_email');
    } else if (password.length < 8) {
      problem = t('reg_err_password_short');
    } else if (password != confirmCtrl.text) {
      problem = t('reg_err_password_match');
    }
    if (problem != null) {
      setState(() => error = problem);
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });
    final result = await state.register(
      fullName: name,
      nationalId: nationalIdCtrl.text.trim(),
      email: email,
      phone: '$dialCode$phone',
      password: password,
    );
    if (!mounted) return;
    if (result == null) {
      // AuthGate (under this route) now shows the company-details step.
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      setState(() {
        loading = false;
        error = result;
      });
    }
  }

  Widget _steps(String Function(String) t) {
    Widget chip(String label, bool current) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: current ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: current ? AppColors.primary : AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: current ? Colors.white : AppColors.textSecondary,
                )),
          ),
        );
    return Row(children: [chip(t('reg_step_owner'), true), const SizedBox(width: 8), chip(t('reg_step_company'), false)]);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return Scaffold(
      appBar: AppBar(title: Text(t('reg_title'))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t('reg_subtitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  _steps(t),
                  const SizedBox(height: 18),
                  if (error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(10)),
                      child: Text(error!, style: const TextStyle(fontSize: 12.5, color: AppColors.danger)),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextField(
                    controller: nameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: '${t('reg_full_name')} *'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nationalIdCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: t('reg_national_id')),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(labelText: t('reg_email_optional')),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      SizedBox(
                        width: 132,
                        child: DropdownButtonFormField<String>(
                          value: dialCode,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: t('login_country_code'),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          items: _dialCodes
                              .map((c) => DropdownMenuItem(
                                    value: c.dial,
                                    child: Text('${c.flag} ${c.dial}', overflow: TextOverflow.visible),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => dialCode = v ?? dialCode),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(labelText: '${t('login_phone')} *'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: obscure,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: '${t('login_password')} *',
                      helperText: t('reg_password_hint'),
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: obscure,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(labelText: '${t('reg_password_confirm')} *'),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(t('reg_button')),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: loading ? null : () => Navigator.of(context).pop(),
                    child: Text(t('reg_have_account')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
