import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

/// شاشة إنشاء برنامج عمرة جديد بالحقول الأساسية (Backend حقيقي). الإعدادات
/// المتقدمة (برنامج الأيام، الصور، الأسعار العائلية، الزيارات) تبقى متاحة
/// فقط من لوحة تحكم الويب حاليًا.
class TripWizardScreen extends StatefulWidget {
  const TripWizardScreen({super.key});

  @override
  State<TripWizardScreen> createState() => _TripWizardScreenState();
}

class _TripWizardScreenState extends State<TripWizardScreen> {
  final titleCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
  final seatsCtrl = TextEditingController();
  final hotelMeccaCtrl = TextEditingController();
  final hotelMedinaCtrl = TextEditingController();

  int? cityId;
  String type = 'economy';
  String status = 'draft';
  String destMode = 'makkah_madinah';
  int hotelStarsMecca = 4;
  int hotelStarsMedina = 4;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    state.fetchTripFormOptions();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    priceCtrl.dispose();
    durationCtrl.dispose();
    seatsCtrl.dispose();
    hotelMeccaCtrl.dispose();
    hotelMedinaCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = context.read<AppState>().t;
    final price = double.tryParse(priceCtrl.text.trim());
    final duration = int.tryParse(durationCtrl.text.trim());
    if (titleCtrl.text.trim().isEmpty || cityId == null || price == null || duration == null) {
      setState(() => error = 'الرجاء إدخال اسم البرنامج، مدينة الانطلاق، السعر، وعدد الأيام');
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    final data = <String, dynamic>{
      'departure_city_id': cityId,
      'title': titleCtrl.text.trim(),
      'trip_category': 'umrah',
      'type': type,
      'status': status,
      'schedule_type': 'daily',
      'price': price,
      'duration_days': duration,
      'dest_mode': destMode,
      'total_seats': int.tryParse(seatsCtrl.text.trim()),
      if (hotelMeccaCtrl.text.trim().isNotEmpty) 'hotel_name': hotelMeccaCtrl.text.trim(),
      if (hotelMeccaCtrl.text.trim().isNotEmpty) 'hotel_stars': hotelStarsMecca,
      if (destMode == 'makkah_madinah' && hotelMedinaCtrl.text.trim().isNotEmpty) 'hotel_name_madinah': hotelMedinaCtrl.text.trim(),
      if (destMode == 'makkah_madinah' && hotelMedinaCtrl.text.trim().isNotEmpty) 'hotel_stars_madinah': hotelStarsMedina,
    };

    final result = await context.read<AppState>().createTrip(data);
    if (!mounted) return;
    setState(() => saving = false);

    if (result == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('wizard_published_snackbar'))));
    } else {
      setState(() => error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;

    return Scaffold(
      appBar: AppBar(title: Text(t('wizard_title')), foregroundColor: AppColors.text),
      body: state.tripFormOptionsLoading && state.tripFormCities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                TextField(controller: titleCtrl, decoration: InputDecoration(labelText: t('field_program_name'))),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: cityId,
                  decoration: InputDecoration(labelText: t('field_departure_city')),
                  items: state.tripFormCities.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => cityId = v),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(labelText: t('field_trip_class')),
                  items: [
                    DropdownMenuItem(value: 'economy', child: Text(t('tier_economy'))),
                    DropdownMenuItem(value: 'premium', child: Text(t('tier_premium'))),
                    DropdownMenuItem(value: 'vip', child: Text(t('opt_luxury_vip'))),
                  ],
                  onChanged: (v) => setState(() => type = v ?? type),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(labelText: t('field_status')),
                  items: [
                    DropdownMenuItem(value: 'draft', child: Text(t('status_draft'))),
                    DropdownMenuItem(value: 'active', child: Text(t('status_active'))),
                  ],
                  onChanged: (v) => setState(() => status = v ?? status),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: t('field_price_per_person')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: durationCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: t('fact_duration')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: seatsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: t('fact_seats')),
                ),
                const SizedBox(height: 18),
                Text(t('destination_label'), style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        value: 'makkah_madinah',
                        groupValue: destMode,
                        title: Text(t('destination_both_title'), style: const TextStyle(fontSize: 12.5)),
                        onChanged: (v) => setState(() => destMode = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        value: 'makkah_only',
                        groupValue: destMode,
                        title: Text(t('destination_mecca_title'), style: const TextStyle(fontSize: 12.5)),
                        onChanged: (v) => setState(() => destMode = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(controller: hotelMeccaCtrl, decoration: InputDecoration(labelText: t('fact_hotel_mecca'))),
                const SizedBox(height: 14),
                if (destMode == 'makkah_madinah')
                  TextField(controller: hotelMedinaCtrl, decoration: InputDecoration(labelText: t('fact_hotel_medina'))),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: saving ? null : _submit,
                  child: saving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(t('wizard_publish')),
                ),
              ],
            ),
    );
  }
}
