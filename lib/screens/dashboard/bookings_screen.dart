import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

/// شاشة الحجوزات: تعرض البرامج أولًا، وجوه كل برنامج تظهر المعتمرين
/// الحاجزين فيه مع إمكانية تسكين الفندق/الغرفة/الباص وتسجيل الحضور.
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String query = '';

  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchApiTrips();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final trips = state.apiTrips.where((tr) => query.isEmpty || tr.title.contains(query)).toList();
    final totalBookings = state.apiTrips.fold<int>(0, (sum, tr) => sum + tr.bookingsCount);

    return RefreshIndicator(
      onRefresh: () => context.read<AppState>().fetchApiTrips(),
      child: state.apiTripsLoading && state.apiTrips.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(t('bookings_title'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                  child: Text('$totalBookings ${t('bookings_count_suffix')}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: TextField(
                    onChanged: (v) => setState(() => query = v),
                    decoration: InputDecoration(
                      hintText: t('bookings_search_hint'),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (trips.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(child: Text(t('no_trips_yet'), style: const TextStyle(color: AppColors.textSecondary))),
                  )
                else
                  AppCard(
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        for (var i = 0; i < trips.length; i++) ...[
                          if (i > 0) const Divider(height: 29),
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => TripBookingsScreen(trip: trips[i])),
                            ),
                            child: InfoRow(
                              leading: const InitialsAvatar(initials: '🌙', size: 36),
                              title: trips[i].title,
                              subtitle: '${trips[i].bookingsCount} ${t('bookings_count_suffix')}',
                              trailing: const ForwardChevron(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

/// حجوزات برنامج معيّن — لكل معتمر: تسكين فندق/غرفة، تسكين باص، وحضور.
class TripBookingsScreen extends StatefulWidget {
  final ApiTrip trip;
  const TripBookingsScreen({super.key, required this.trip});

  @override
  State<TripBookingsScreen> createState() => _TripBookingsScreenState();
}

class _TripBookingsScreenState extends State<TripBookingsScreen> {
  String query = '';

  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchBookings();
  }

  StatusPill _pillFor(String status, String label) {
    switch (status) {
      case 'confirmed':
        return StatusPill.success(label);
      case 'cancelled':
        return StatusPill.danger(label);
      default:
        return StatusPill.warning(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final bookings = state.bookingsList.where((b) {
      if (b['trip_id'] != widget.trip.id) return false;
      if (query.isEmpty) return true;
      final name = (b['user'] as Map<String, dynamic>?)?['name'] as String? ?? '';
      return name.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.trip.title), foregroundColor: AppColors.text),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().fetchBookings(),
        child: state.bookingsLoading && state.bookingsData == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  TextField(
                    onChanged: (v) => setState(() => query = v),
                    decoration: InputDecoration(
                      hintText: t('bookings_search_hint'),
                      prefixIcon: const Icon(Icons.search, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (bookings.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(child: Text(t('no_bookings_yet'), style: const TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    for (final b in bookings) _BookingCard(booking: b, pillFor: _pillFor),
                ],
              ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final StatusPill Function(String, String) pillFor;
  const _BookingCard({required this.booking, required this.pillFor});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final name = (booking['user'] as Map<String, dynamic>?)?['name'] as String? ?? '—';
    final status = booking['status'] as String? ?? 'pending';
    final attendance = booking['attendance_status'] as String? ?? 'pending';
    final hasHotel = booking['hotel_id'] != null;
    final hasBus = booking['bus_id'] != null;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _openBookingDetail(context, booking),
            child: Row(
              children: [
                InitialsAvatar(initials: name.isNotEmpty ? name.substring(0, 1) : '؟'),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('${booking['persons_count']} ${t('unit_seat')} · ${booking['total_price']} ${booking['tripCurrency'] ?? ''}',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                pillFor(status, t('status_$status')),
              ],
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickAction(
                icon: Icons.apartment_outlined,
                label: t('action_assign_hotel'),
                active: hasHotel,
                onTap: () => _showHotelAssignSheet(context, booking),
              ),
              _QuickAction(
                icon: Icons.directions_bus_outlined,
                label: t('action_assign_buses'),
                active: hasBus,
                onTap: () => _showBusAssignSheet(context, booking),
              ),
              _QuickAction(
                icon: Icons.check_circle_outline,
                label: t('attendance_present'),
                active: attendance == 'present',
                activeColor: AppColors.success,
                onTap: () => context.read<AppState>().markAttendance(booking['id'] as int, attendance == 'present' ? 'pending' : 'present'),
              ),
              _QuickAction(
                icon: Icons.cancel_outlined,
                label: t('attendance_absent'),
                active: attendance == 'absent',
                activeColor: AppColors.danger,
                onTap: () => context.read<AppState>().markAttendance(booking['id'] as int, attendance == 'absent' ? 'pending' : 'absent'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 3),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: color)),
          ],
        ),
      ),
    );
  }
}

void _openBookingDetail(BuildContext context, Map<String, dynamic> booking) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _BookingDetailSheet(booking: booking),
  );
}

class _BookingDetailSheet extends StatefulWidget {
  final Map<String, dynamic> booking;
  const _BookingDetailSheet({required this.booking});

  @override
  State<_BookingDetailSheet> createState() => _BookingDetailSheetState();
}

class _BookingDetailSheetState extends State<_BookingDetailSheet> {
  bool busy = false;

  Future<void> _run(Future<String?> Function() action) async {
    setState(() => busy = true);
    final result = await action();
    if (!mounted) return;
    setState(() => busy = false);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final b = widget.booking;
    final name = (b['user'] as Map<String, dynamic>?)?['name'] as String? ?? '—';
    final status = b['status'] as String? ?? 'pending';
    final hotelId = b['hotel_id'] as int?;
    final busId = b['bus_id'] as int?;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
              ),
              Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('${b['tripTitle']} · ${b['total_price']} ${b['tripCurrency'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              if (busy) const Center(child: CircularProgressIndicator()) else ...[
                if (status == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _run(() => state.confirmBooking(b['id'] as int)),
                          child: Text(t('action_confirm_booking')),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _run(() => state.cancelBooking(b['id'] as int)),
                          child: Text(t('action_cancel_booking')),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Text(t('fact_hotel_mecca'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (hotelId != null) ...[
                  Text('${b['room_number'] ?? '—'} (${b['room_capacity'] ?? '—'})',
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  OutlinedButton(
                    onPressed: () => _run(() => state.clearBookingHotel(b['id'] as int)),
                    child: Text(t('action_clear_assignment')),
                  ),
                ] else
                  OutlinedButton(
                    onPressed: () => _showHotelAssignSheet(context, b),
                    child: Text(t('action_assign_hotel')),
                  ),
                const SizedBox(height: 16),
                Text(t('action_assign_buses'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (busId != null)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: () => _run(() => state.clearBookingBus(b['id'] as int)),
                      child: Text(t('action_clear_assignment')),
                    ),
                  )
                else
                  OutlinedButton(
                    onPressed: () => _showBusAssignSheet(context, b),
                    child: Text(t('action_assign_buses')),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

void _showHotelAssignSheet(BuildContext context, Map<String, dynamic> booking) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _HotelAssignSheet(booking: booking),
  );
}

class _HotelAssignSheet extends StatefulWidget {
  final Map<String, dynamic> booking;
  const _HotelAssignSheet({required this.booking});

  @override
  State<_HotelAssignSheet> createState() => _HotelAssignSheetState();
}

class _HotelAssignSheetState extends State<_HotelAssignSheet> {
  int? hotelId;
  final roomCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    roomCtrl.text = widget.booking['room_number'] as String? ?? '';
    final capacity = widget.booking['room_capacity'];
    if (capacity != null) capacityCtrl.text = '$capacity';
    hotelId = widget.booking['hotel_id'] as int?;
  }

  @override
  void dispose() {
    roomCtrl.dispose();
    capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final capacity = int.tryParse(capacityCtrl.text);
    if (hotelId == null || roomCtrl.text.trim().isEmpty || capacity == null) {
      setState(() => error = 'الرجاء اختيار الفندق وإدخال رقم الغرفة والسعة');
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final result = await context.read<AppState>().assignBookingHotel(
          bookingId: widget.booking['id'] as int,
          hotelId: hotelId!,
          roomNumber: roomCtrl.text.trim(),
          roomCapacity: capacity,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t('hotel_assign_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: hotelId,
                decoration: InputDecoration(labelText: t('hotel_mecca_label')),
                items: state.bookingHotels.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))).toList(),
                onChanged: (v) => setState(() => hotelId = v),
              ),
              const SizedBox(height: 12),
              TextField(controller: roomCtrl, decoration: InputDecoration(labelText: t('field_room_number'))),
              const SizedBox(height: 12),
              TextField(
                controller: capacityCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t('room_occupant_count_label')),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(t('action_save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showBusAssignSheet(BuildContext context, Map<String, dynamic> booking) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _BusAssignSheet(booking: booking),
  );
}

class _BusAssignSheet extends StatefulWidget {
  final Map<String, dynamic> booking;
  const _BusAssignSheet({required this.booking});

  @override
  State<_BusAssignSheet> createState() => _BusAssignSheetState();
}

class _BusAssignSheetState extends State<_BusAssignSheet> {
  int? busId;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    busId = widget.booking['bus_id'] as int?;
  }

  Future<void> _save() async {
    if (busId == null) return;
    setState(() {
      saving = true;
      error = null;
    });
    final result = await context.read<AppState>().assignBookingBus(widget.booking['id'] as int, busId!);
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t('action_assign_buses'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: busId,
                hint: Text(t('supervisor_none_selected')),
                items: state.bookingBuses
                    .map((bus) => DropdownMenuItem(value: bus.id, child: Text('${bus.number} — ${bus.company}')))
                    .toList(),
                onChanged: (v) => setState(() => busId = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(t('action_save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
