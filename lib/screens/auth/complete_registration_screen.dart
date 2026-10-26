import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

/// الخطوة التانية من التسجيل (زي نافذة «أكمل بيانات شركتك» في لوحة الموقع):
/// إجبارية — مفيش رجوع منها غير الحفظ أو تسجيل الخروج.
class CompleteRegistrationScreen extends StatefulWidget {
  final Future<void> Function() onLogout;
  const CompleteRegistrationScreen({super.key, required this.onLogout});

  @override
  State<CompleteRegistrationScreen> createState() => _CompleteRegistrationScreenState();
}

class _CompleteRegistrationScreenState extends State<CompleteRegistrationScreen> {
  static const _nominatimHeaders = {'User-Agent': 'RowadPlusProviderApp/1.0'};

  final nameCtrl = TextEditingController();
  final registerCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> cities = [];
  int? countryId;
  int? cityId;
  double? lat;
  double? lng;

  bool loadingLocations = true;
  bool locationsFailed = false;
  bool locating = false;
  bool saving = false;
  String? error;
  String? locateNote;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    registerCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    setState(() {
      loadingLocations = true;
      locationsFailed = false;
    });
    try {
      final res = await context.read<AppState>().fetchLocations();
      countries = (res['countries'] as List).cast<Map<String, dynamic>>();
      cities = (res['cities'] as List).cast<Map<String, dynamic>>();
      // Saudi Arabia first, like the website.
      final sa = countries.where((c) => c['code'] == 'SA' || '${c['name']}'.contains('سعود'));
      countryId ??= sa.isNotEmpty ? (sa.first['id'] as num).toInt() : null;
    } catch (_) {
      locationsFailed = true;
    }
    if (mounted) setState(() => loadingLocations = false);
  }

  List<Map<String, dynamic>> get _countryCities =>
      cities.where((c) => (c['country_id'] as num?)?.toInt() == countryId).toList();

  Future<void> _locate() async {
    final t = context.read<AppState>().t;
    setState(() {
      locating = true;
      locateNote = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => locateNote = t('map_location_off'));
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() => locateNote = t('map_location_denied'));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      lat = pos.latitude;
      lng = pos.longitude;
      if (mounted) setState(() => locateNote = t('cr_located'));
      await _fillAddress(pos.latitude, pos.longitude);
    } catch (_) {
      if (mounted) setState(() => locateNote = t('map_location_failed'));
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  /// Fills the address from the point when the owner hasn't typed one.
  Future<void> _fillAddress(double lat, double lng) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'json',
        'zoom': '18',
        'accept-language': 'ar',
        'lat': '$lat',
        'lon': '$lng',
      });
      final res = await http.get(uri, headers: _nominatimHeaders).timeout(const Duration(seconds: 10));
      if (!mounted || res.statusCode != 200) return;
      final name = (jsonDecode(res.body) as Map<String, dynamic>)['display_name'] as String?;
      if (name != null && addressCtrl.text.trim().isEmpty) addressCtrl.text = name;
    } catch (_) {
      // The address can still be typed by hand.
    }
  }

  Future<void> _save() async {
    final state = context.read<AppState>();
    if (nameCtrl.text.trim().isEmpty ||
        registerCtrl.text.trim().isEmpty ||
        cityId == null ||
        addressCtrl.text.trim().isEmpty) {
      setState(() => error = state.t('cr_err_required'));
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final result = await state.completeRegistration(
      name: nameCtrl.text.trim(),
      commercialRegister: registerCtrl.text.trim(),
      cityId: cityId!,
      address: addressCtrl.text.trim(),
      lat: lat,
      lng: lng,
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        saving = false;
        error = result;
      });
      return;
    }
    // AuthGate swaps this screen for the dashboard (which then asks for the
    // IBAN in its own dialog) — a snackbar tells the owner what's next.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 6),
      content: Text('${state.t('cr_done_title')} — ${state.t('cr_done_body')}'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Expanded(child: _chip('✓ ${t('reg_step_owner').replaceFirst(RegExp(r'^\S+\s'), '')}', false)),
                      const SizedBox(width: 8),
                      Expanded(child: _chip(t('reg_step_company'), true)),
                    ]),
                    const SizedBox(height: 20),
                    Text(t('cr_title'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(t('cr_subtitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 20),
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
                      decoration: InputDecoration(labelText: '${t('cr_name')} *'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: registerCtrl,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: '${t('cr_register')} *'),
                    ),
                    const SizedBox(height: 14),
                    if (loadingLocations)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (locationsFailed)
                      Row(children: [
                        Expanded(child: Text(t('cr_load_failed'), style: const TextStyle(color: AppColors.danger))),
                        TextButton(onPressed: _loadLocations, child: Text(t('retry'))),
                      ])
                    else ...[
                      DropdownButtonFormField<int>(
                        value: countryId,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: '${t('cr_country')} *'),
                        items: countries
                            .map((c) => DropdownMenuItem(value: (c['id'] as num).toInt(), child: Text('${c['name']}')))
                            .toList(),
                        onChanged: (v) => setState(() {
                          countryId = v;
                          cityId = null;
                        }),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        key: ValueKey(countryId),
                        value: cityId,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: '${t('cr_city')} *'),
                        items: _countryCities
                            .map((c) => DropdownMenuItem(value: (c['id'] as num).toInt(), child: Text('${c['name']}')))
                            .toList(),
                        onChanged: (v) => setState(() => cityId = v),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextField(
                      controller: addressCtrl,
                      maxLines: 2,
                      minLines: 1,
                      decoration: InputDecoration(labelText: '${t('cr_address')} *', hintText: t('cr_address_hint')),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: locating ? null : _locate,
                        icon: locating
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.my_location, size: 18),
                        label: Text(t('cr_locate')),
                      ),
                    ),
                    if (locateNote != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: Text(locateNote!,
                            style: TextStyle(
                              fontSize: 12,
                              color: lat != null ? AppColors.success : AppColors.textSecondary,
                            )),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: saving || loadingLocations ? null : _save,
                      child: saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(t('cr_save')),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: saving ? null : widget.onLogout,
                      child: Text(t('profile_logout'), style: const TextStyle(color: AppColors.textMuted)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, bool current) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: current ? AppColors.primary : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: current ? Colors.white : AppColors.primaryDark,
            )),
      );
}
