import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchCompanyHotels();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final hotels = state.companyHotels;
    return Scaffold(
      appBar: AppBar(
        title: Text(t('profile_hotels')),
        foregroundColor: AppColors.text,
        actions: [
          IconButton(
            onPressed: state.saudiCities.isEmpty ? null : () => _showHotelSheet(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().fetchCompanyHotels(),
        child: state.companyHotelsLoading && hotels.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Text(t('hotels_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  if (hotels.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(child: Text(t('no_hotels_yet'), style: const TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    for (final h in hotels) _HotelCard(hotel: h),
                ],
              ),
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  final CompanyHotel hotel;
  const _HotelCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 90,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF185FA5), Color(0xFF042C53)],
              ),
            ),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.apartment_outlined, color: Colors.white, size: 28)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(hotel.cityName,
                        style: const TextStyle(fontSize: 10, color: AppColors.primaryDark, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_outline, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text('${hotel.stars} ${t('unit_stars')}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(width: 10),
                    const Icon(Icons.directions_walk, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(hotel.distanceHaram, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(hotel.contact.isEmpty ? '—' : hotel.contact, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showHotelSheet(context, hotel: hotel),
                          child: Text(t('action_edit'), style: const TextStyle(fontSize: 10.5, color: AppColors.primary)),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _confirmDelete(context, hotel),
                          child: Text(t('action_delete'), style: const TextStyle(fontSize: 10.5, color: AppColors.danger)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _confirmDelete(BuildContext context, CompanyHotel hotel) {
  showDialog(
    context: context,
    builder: (ctx) {
      final t = context.read<AppState>().t;
      return AlertDialog(
        title: Text(t('action_delete')),
        content: Text(hotel.name),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('action_cancel'))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await context.read<AppState>().deleteCompanyHotel(hotel.id);
              if (result != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
              }
            },
            child: Text(t('action_delete'), style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      );
    },
  );
}

void _showHotelSheet(BuildContext context, {CompanyHotel? hotel}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _AddHotelSheet(hotel: hotel),
  );
}

class _AddHotelSheet extends StatefulWidget {
  final CompanyHotel? hotel;
  const _AddHotelSheet({this.hotel});

  @override
  State<_AddHotelSheet> createState() => _AddHotelSheetState();
}

class _AddHotelSheetState extends State<_AddHotelSheet> {
  final nameCtrl = TextEditingController();
  final distanceCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  int? cityId;
  int stars = 5;
  bool saving = false;
  String? error;

  bool get isEdit => widget.hotel != null;

  @override
  void initState() {
    super.initState();
    final hotel = widget.hotel;
    if (hotel != null) {
      nameCtrl.text = hotel.name;
      distanceCtrl.text = hotel.distanceHaram;
      contactCtrl.text = hotel.contact;
      cityId = hotel.cityId;
      stars = hotel.stars;
    } else {
      final cities = context.read<AppState>().saudiCities;
      if (cities.isNotEmpty) cityId = cities.first.id;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    distanceCtrl.dispose();
    contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameCtrl.text.trim().isEmpty || cityId == null || distanceCtrl.text.trim().isEmpty) {
      setState(() => error = context.read<AppState>().t('err_hotel_fields_required'));
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final state = context.read<AppState>();
    final result = isEdit
        ? await state.updateCompanyHotel(
            id: widget.hotel!.id,
            name: nameCtrl.text.trim(),
            cityId: cityId!,
            stars: stars,
            distanceHaram: distanceCtrl.text.trim(),
            contact: contactCtrl.text.trim().isEmpty ? null : contactCtrl.text.trim(),
          )
        : await state.createCompanyHotel(
            name: nameCtrl.text.trim(),
            cityId: cityId!,
            stars: stars,
            distanceHaram: distanceCtrl.text.trim(),
            contact: contactCtrl.text.trim().isEmpty ? null : contactCtrl.text.trim(),
          );
    if (!mounted) return;
    setState(() => saving = false);
    if (result == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEdit ? t('action_edit') : t('add_hotel_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, size: 18)),
                  ],
                ),
                if (error != null) ...[
                  const SizedBox(height: 6),
                  Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                ],
                const SizedBox(height: 6),
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t('field_hotel_name'))),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: cityId,
                  decoration: InputDecoration(labelText: t('field_city')),
                  items: state.saudiCities.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => cityId = v),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: stars,
                  decoration: InputDecoration(labelText: t('field_star_count')),
                  items: [
                    DropdownMenuItem(value: 5, child: Text('5 ${t('unit_stars')}')),
                    DropdownMenuItem(value: 4, child: Text('4 ${t('unit_stars')}')),
                    DropdownMenuItem(value: 3, child: Text('3 ${t('unit_stars')}')),
                    DropdownMenuItem(value: 2, child: Text('2 ${t('unit_stars')}')),
                    DropdownMenuItem(value: 1, child: Text('1 ${t('unit_stars')}')),
                  ],
                  onChanged: (v) => setState(() => stars = v ?? stars),
                ),
                const SizedBox(height: 14),
                TextField(controller: distanceCtrl, decoration: InputDecoration(labelText: t('field_distance_from_haram'))),
                const SizedBox(height: 14),
                TextField(controller: contactCtrl, decoration: InputDecoration(labelText: t('field_contact_number'))),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(t('action_save_hotel')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
