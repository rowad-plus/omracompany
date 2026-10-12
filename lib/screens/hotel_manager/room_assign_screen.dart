import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

/// شاشة تسكين معتمري رحلة معيّنة في غرف الفندق — تعمل على الحجوزات
/// الفعلية لهذه الرحلة (Backend حقيقي).
class RoomAssignScreen extends StatefulWidget {
  final ApiTrip trip;
  const RoomAssignScreen({super.key, required this.trip});

  @override
  State<RoomAssignScreen> createState() => _RoomAssignScreenState();
}

class _RoomAssignScreenState extends State<RoomAssignScreen> {
  final Set<int> selected = {};
  String query = '';

  /// Chosen departure day (Y-m-d) — null until the bookings load.
  String? day;

  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchBookings();
  }

  List<Map<String, dynamic>> _allTripBookings(AppState state) =>
      state.bookingsList.where((b) => b['trip_id'] == widget.trip.id && b['status'] != 'cancelled').toList();

  /// Only the chosen departure day's pilgrims: a daily trip must never put
  /// people travelling on different days in one room.
  List<Map<String, dynamic>> _tripBookings(AppState state) {
    final all = _allTripBookings(state);
    final days = departureDaysOf(all);
    if (days.length <= 1) return all;
    final d = days.contains(day) ? day : defaultDepartureDay(days);
    return all.where((b) => b['departure_date'] == d).toList();
  }

  bool _matches(Map<String, dynamic> b, String q) {
    if (q.isEmpty) return true;
    final phone = (b['customer_phone'] ?? (b['user'] as Map<String, dynamic>?)?['phone'] ?? '') as String;
    return bookingName(b).contains(q) || (b['ref'] as String? ?? '').contains(q) || phone.contains(q);
  }

  Future<void> _houseSelected(List<Map<String, dynamic>> selectedBookings) async {
    if (selectedBookings.isEmpty) return;
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _RoomDetailsSheet(selectedBookings: selectedBookings),
    );
    if (result == true && mounted) setState(() => selected.clear());
  }

  Future<void> _editGroup(List<Map<String, dynamic>> occupants) async {
    final first = occupants.first;
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _RoomDetailsSheet(
        selectedBookings: occupants,
        initialHotelId: first['hotel_id'] as int?,
        initialRoomNumber: first['room_number'] as String?,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final bookings = _tripBookings(state);
    final unassigned = bookings.where((b) => b['hotel_id'] == null).toList();
    final assignedByRoom = <String, List<Map<String, dynamic>>>{};
    for (final b in bookings.where((b) => b['hotel_id'] != null)) {
      final key = '${b['hotel_id']}|${b['room_number']}';
      assignedByRoom.putIfAbsent(key, () => []).add(b);
    }
    final filteredUnassigned = unassigned.where((b) => _matches(b, query)).toList();
    final allTrip = _allTripBookings(state);
    final days = departureDaysOf(allTrip);
    final currentDay = days.contains(day) ? day : defaultDepartureDay(days);
    final dayCounts = {for (final d in days) d: allTrip.where((b) => b['departure_date'] == d).length};

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.title),
        foregroundColor: AppColors.text,
      ),
      body: state.bookingsLoading && state.bookingsData == null
          ? const Center(child: CircularProgressIndicator())
          : state.bookingsData == null && state.bookingsError != null
          ? LoadErrorView(message: state.bookingsError!, onRetry: () => context.read<AppState>().fetchBookings())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                    children: [
                      if (days.length > 1) ...[
                        DepartureDayBar(
                          days: days,
                          selected: currentDay,
                          counts: dayCounts,
                          onSelect: (d) => setState(() {
                            day = d;
                            selected.clear();
                          }),
                        ),
                        const SizedBox(height: 14),
                      ],
                      Text(t('section_rooms_formed'), style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      if (assignedByRoom.isEmpty)
                        Text(t('no_rooms_yet'), style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted))
                      else
                        for (final entry in assignedByRoom.entries)
                          _RoomCard(occupants: entry.value, onTap: () => _editGroup(entry.value)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                  decoration: const BoxDecoration(
                    color: AppColors.bg,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('section_waiting_housing'), style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        AppCard(
                          child: Column(
                            children: [
                              if (unassigned.isNotEmpty) ...[
                                TextField(
                                  onChanged: (v) => setState(() => query = v),
                                  decoration: InputDecoration(
                                    hintText: t('search_traveler_by_name'),
                                    prefixIcon: const Icon(Icons.search, size: 18),
                                    isDense: true,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              SizedBox(
                                height: unassigned.isEmpty ? 0 : 170,
                                child: unassigned.isEmpty
                                    ? Text(t('all_housed'), style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted))
                                    : filteredUnassigned.isEmpty
                                        ? Center(child: Text(t('no_results'), style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)))
                                        : ListView(
                                            children: [
                                              for (final b in filteredUnassigned)
                                                CheckboxListTile(
                                                  dense: true,
                                                  contentPadding: EdgeInsets.zero,
                                                  value: selected.contains(b['id']),
                                                  title: Text(
                                                    bookingName(b),
                                                    style: const TextStyle(fontSize: 13),
                                                  ),
                                                  subtitle: Text(bookingDetails(b, t('unit_seat')),
                                                      style: const TextStyle(fontSize: 11.5)),
                                                  onChanged: (v) => setState(
                                                      () => v == true ? selected.add(b['id'] as int) : selected.remove(b['id'])),
                                                ),
                                            ],
                                          ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: selected.isEmpty
                                    ? null
                                    : () => _houseSelected(unassigned.where((b) => selected.contains(b['id'])).toList()),
                                icon: const Icon(Icons.meeting_room_outlined, size: 18),
                                label: Text(t('action_house_selected')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _RoomDetailsSheet extends StatefulWidget {
  final List<Map<String, dynamic>> selectedBookings;
  final int? initialHotelId;
  final String? initialRoomNumber;
  const _RoomDetailsSheet({required this.selectedBookings, this.initialHotelId, this.initialRoomNumber});

  @override
  State<_RoomDetailsSheet> createState() => _RoomDetailsSheetState();
}

class _RoomDetailsSheetState extends State<_RoomDetailsSheet> {
  int? hotelId;
  late final roomCtrl = TextEditingController(text: widget.initialRoomNumber ?? '');
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    hotelId = widget.initialHotelId;
  }

  @override
  void dispose() {
    roomCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (hotelId == null) {
      setState(() => error = context.read<AppState>().t('err_select_hotel'));
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });

    final ids = widget.selectedBookings.map((b) => b['id'] as int).toList();
    final roomNumber = roomCtrl.text.trim();
    final result = await context.read<AppState>().assignBookingHotel(
          bookingId: ids.first,
          hotelId: hotelId!,
          roomNumber: roomNumber.isEmpty ? null : roomNumber,
          // Capacity counts PEOPLE (a booking can be 2-3 persons), not bookings.
          roomCapacity: widget.selectedBookings
              .fold<int>(0, (n, b) => n + ((b['persons_count'] as num?)?.toInt() ?? 1))
              .clamp(1, 20),
          companionIds: ids.skip(1).toList(),
        );

    if (!mounted) return;
    setState(() => saving = false);

    if (result == null) {
      Navigator.pop(context, true);
    } else {
      setState(() => error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    return Padding(
      padding: EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 18 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('room_details_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t('room_occupant_count_label'), style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  Text('${widget.selectedBookings.length}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: hotelId,
              decoration: InputDecoration(labelText: t('hotel_label')),
              items: state.bookingHotels.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))).toList(),
              onChanged: (v) => setState(() => hotelId = v),
            ),
            const SizedBox(height: 14),
            TextField(controller: roomCtrl, decoration: InputDecoration(labelText: t('field_room_number_optional'))),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saving ? null : _save,
              child: saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(t('action_confirm_housing')),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final List<Map<String, dynamic>> occupants;
  final VoidCallback onTap;
  const _RoomCard({required this.occupants, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final first = occupants.first;
    final people = occupants.fold<int>(0, (n, b) => n + ((b['persons_count'] as num?)?.toInt() ?? 1));
    final capacity = first['room_capacity'] ?? people;
    final hotelName = (first['hotel'] as Map<String, dynamic>?)?['name'] as String? ?? '—';
    final roomNumber = first['room_number'] as String?;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hotelName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(
                      roomNumber != null ? '${t('room_word')} $roomNumber' : t('room_pending_number'),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: roomNumber != null ? AppColors.textSecondary : AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill.success('$people / $capacity'),
            ],
          ),
          const SizedBox(height: 6),
          for (final o in occupants)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('${bookingName(o)}  ·  ${o['ref'] ?? '#${o['id']}'}',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                  onPressed: () => context.read<AppState>().clearBookingHotel(o['id'] as int),
                ),
              ],
            ),
        ],
        ),
      ),
    );
  }
}
