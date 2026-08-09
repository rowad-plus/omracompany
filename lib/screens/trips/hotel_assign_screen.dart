import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class HotelAssignScreen extends StatefulWidget {
  final ApiTrip trip;
  const HotelAssignScreen({super.key, required this.trip});

  @override
  State<HotelAssignScreen> createState() => _HotelAssignScreenState();
}

class _HotelAssignScreenState extends State<HotelAssignScreen> {
  int? meccaHotelId;
  int? medinaHotelId;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    final meccaMatch = state.apiHotels.where((h) => h.name == widget.trip.hotelName);
    if (meccaMatch.isNotEmpty) meccaHotelId = meccaMatch.first.id;
    final medinaMatch = state.apiHotels.where((h) => h.name == widget.trip.hotelNameMadinah);
    if (medinaMatch.isNotEmpty) medinaHotelId = medinaMatch.first.id;
  }

  Future<void> _save() async {
    setState(() => saving = true);
    final state = context.read<AppState>();
    final mecca = state.apiHotels.where((h) => h.id == meccaHotelId);
    final medina = state.apiHotels.where((h) => h.id == medinaHotelId);

    final data = <String, dynamic>{
      'hotel_name': mecca.isNotEmpty ? mecca.first.name : null,
      'hotel_stars': mecca.isNotEmpty ? mecca.first.stars : null,
      'hotel_location': mecca.isNotEmpty ? mecca.first.city : null,
      'distance_from_haram': mecca.isNotEmpty ? int.tryParse(mecca.first.distanceHaram ?? '') : null,
      'hotel_name_madinah': medina.isNotEmpty ? medina.first.name : null,
      'hotel_stars_madinah': medina.isNotEmpty ? medina.first.stars : null,
      'hotel_location_madinah': medina.isNotEmpty ? medina.first.city : null,
      'distance_from_haram_madinah': medina.isNotEmpty ? int.tryParse(medina.first.distanceHaram ?? '') : null,
    };

    final result = await state.assignTripHotel(widget.trip.id, data);
    if (!mounted) return;
    setState(() => saving = false);

    if (result == null) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    return Scaffold(
      appBar: AppBar(title: Text(t('hotel_assign_title')), foregroundColor: AppColors.text),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(widget.trip.title, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Text(t('hotel_mecca_label'), style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          for (final h in state.apiHotels)
            _hotelOption(h, meccaHotelId, (v) => setState(() => meccaHotelId = v)),
          const SizedBox(height: 16),
          Text(t('hotel_medina_label'), style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          for (final h in state.apiHotels)
            _hotelOption(h, medinaHotelId, (v) => setState(() => medinaHotelId = v)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saving ? null : _save,
            child: saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(t('action_save')),
          ),
        ],
      ),
    );
  }

  Widget _hotelOption(AssignableHotel hotel, int? selectedId, ValueChanged<int?> onSelect) {
    final isSelected = selectedId == hotel.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onSelect(isSelected ? null : hotel.id),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.surface,
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.apartment_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('${hotel.name} — ${hotel.stars}★', style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
