import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final nameCtrl = TextEditingController();
  final licenseCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  bool saving = false;
  bool uploadingLogo = false;
  bool _initialized = false;
  final _picker = ImagePicker();

  Future<void> _pickLogo() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => uploadingLogo = true);
    final bytes = await picked.readAsBytes();
    final result = await context.read<AppState>().uploadCompanyLogo(bytes);
    if (!mounted) return;
    setState(() => uploadingLogo = false);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    licenseCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  void _fillFrom(AppState state) {
    final c = state.companyInfo;
    if (c == null) return;
    nameCtrl.text = c.name;
    licenseCtrl.text = c.commercialRegister ?? '';
    emailCtrl.text = c.email ?? '';
    phoneCtrl.text = c.phone ?? '';
  }

  Future<void> _save() async {
    final t = context.read<AppState>().t;
    setState(() => saving = true);
    final result = await context.read<AppState>().updateCompanyInfo(
          name: nameCtrl.text.trim(),
          commercialRegister: licenseCtrl.text.trim().isEmpty ? null : licenseCtrl.text.trim(),
          email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
          phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result ?? t('company_saved_snackbar'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;

    if (!_initialized && state.companyInfo == null && !state.companyInfoLoading) {
      state.fetchCompanyInfo();
    }
    if (!_initialized && state.companyInfo != null) {
      _fillFrom(state);
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: Text(t('profile_company')), foregroundColor: AppColors.text),
      body: state.companyInfoLoading && state.companyInfo == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(t('company_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Center(
                  child: InkWell(
                    onTap: uploadingLogo ? null : _pickLogo,
                    borderRadius: BorderRadius.circular(50),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface2,
                            border: Border.all(color: AppColors.border),
                            image: state.companyInfo?.logo != null
                                ? DecorationImage(image: NetworkImage(state.companyInfo!.logo!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: state.companyInfo?.logo == null
                              ? const Icon(Icons.apartment_outlined, size: 32, color: AppColors.textMuted)
                              : null,
                        ),
                        if (uploadingLogo)
                          const CircularProgressIndicator(strokeWidth: 2)
                        else
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t('field_company_name'))),
                const SizedBox(height: 14),
                TextField(controller: licenseCtrl, decoration: InputDecoration(labelText: t('field_license_number'))),
                const SizedBox(height: 14),
                TextField(controller: emailCtrl, decoration: InputDecoration(labelText: t('field_email'))),
                const SizedBox(height: 14),
                TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: t('field_contact_number'))),
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
