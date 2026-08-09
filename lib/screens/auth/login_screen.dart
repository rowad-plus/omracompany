import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

enum _LoginMode { email, phone }

class _CountryOption {
  final String dialCode;
  final String isoCode;
  final String flag;
  const _CountryOption(this.dialCode, this.isoCode, this.flag);
}

const _countryOptions = [
  _CountryOption('+966', 'SA', '🇸🇦'),
  _CountryOption('+20', 'EG', '🇪🇬'),
  _CountryOption('+971', 'AE', '🇦🇪'),
  _CountryOption('+965', 'KW', '🇰🇼'),
];

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoggedIn;
  const LoginScreen({super.key, required this.onLoggedIn});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _LoginMode mode = _LoginMode.phone;
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool obscurePassword = true;
  bool loading = false;
  String? error;
  late String countryCode;

  @override
  void initState() {
    super.initState();
    countryCode = _detectDefaultCountryCode();
  }

  /// بيحدد مفتاح الدولة الافتراضي حسب إعدادات لغة/منطقة الجهاز اللي داخل
  /// منه المستخدم — مع إمكانية تغييره يدويًا من القائمة أسفل حقل الجوال.
  String _detectDefaultCountryCode() {
    final deviceCountry = PlatformDispatcher.instance.locale.countryCode;
    final match = _countryOptions.where((c) => c.isoCode == deviceCountry);
    return match.isNotEmpty ? match.first.dialCode : _countryOptions.first.dialCode;
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = passwordCtrl.text;
    final email = emailCtrl.text.trim();
    final phone = phoneCtrl.text.trim();

    if (password.isEmpty || (mode == _LoginMode.email ? email.isEmpty : phone.isEmpty)) {
      setState(() => error = 'الرجاء إدخال البيانات المطلوبة وكلمة المرور');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final result = await context.read<AppState>().login(
          email: mode == _LoginMode.email ? email : null,
          phone: mode == _LoginMode.phone ? '$countryCode$phone' : null,
          password: password,
        );

    if (!mounted) return;
    setState(() => loading = false);

    if (result == null) {
      widget.onLoggedIn();
    } else {
      setState(() => error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: const Text('رب',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                        const SizedBox(height: 12),
                        const Text('رواد بلس', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(t('login_subtitle'),
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SegmentedButton<_LoginMode>(
                    segments: [
                      ButtonSegment(value: _LoginMode.phone, label: Text(t('login_with_phone'))),
                      ButtonSegment(value: _LoginMode.email, label: Text(t('login_with_email'))),
                    ],
                    selected: {mode},
                    onSelectionChanged: (s) => setState(() => mode = s.first),
                  ),
                  const SizedBox(height: 18),
                  if (error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(error!, style: const TextStyle(fontSize: 12.5, color: AppColors.danger)),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (mode == _LoginMode.phone)
                    Row(
                      children: [
                        SizedBox(
                          width: 132,
                          child: DropdownButtonFormField<String>(
                            value: countryCode,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: t('login_country_code'),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                            items: _countryOptions
                                .map((c) => DropdownMenuItem(
                                      value: c.dialCode,
                                      child: Text('${c.flag} ${c.dialCode}', overflow: TextOverflow.visible),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => countryCode = v ?? countryCode),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(labelText: t('login_phone')),
                          ),
                        ),
                      ],
                    )
                  else
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: t('field_email')),
                    ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: obscurePassword,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: t('login_password'),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20),
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
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
                        : Text(t('login_button')),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
