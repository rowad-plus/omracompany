import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/departure_point_sheet.dart';
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
                              leading: InitialsAvatar(initials: '🌙', size: 36, imageUrl: trips[i].thumbnail),
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
                  GridView.count(
                    crossAxisCount: 5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 6,
                    childAspectRatio: 0.8,
                    children: [
                      _TripActionButton(
                        icon: Icons.apartment_outlined,
                        label: t('action_assign_hotel'),
                        onTap: () => _openActionSelection(context, widget.trip, _TripAction.hotel),
                      ),
                      _TripActionButton(
                        icon: Icons.meeting_room_outlined,
                        label: t('action_assign_room'),
                        onTap: () => _openActionSelection(context, widget.trip, _TripAction.room),
                      ),
                      _TripActionButton(
                        icon: Icons.directions_bus_outlined,
                        label: t('action_assign_buses'),
                        onTap: () => _openActionSelection(context, widget.trip, _TripAction.bus),
                      ),
                      _TripActionButton(
                        icon: Icons.how_to_reg_outlined,
                        label: t('action_attendance'),
                        onTap: () => _openActionSelection(context, widget.trip, _TripAction.attendance),
                      ),
                      _TripActionButton(
                        icon: Icons.location_on_outlined,
                        label: t('action_departure_point'),
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.surface,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                          builder: (ctx) => DeparturePointSheet(trip: widget.trip),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
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
                    AppCard(
                      child: Column(
                        children: [
                          for (var i = 0; i < bookings.length; i++) ...[
                            if (i > 0) const Divider(height: 25),
                            _BookingRow(booking: bookings[i], pillFor: _pillFor),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _TripActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _TripActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  final Map<String, dynamic> booking;
  final StatusPill Function(String, String) pillFor;
  const _BookingRow({required this.booking, required this.pillFor});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final name = (booking['user'] as Map<String, dynamic>?)?['name'] as String? ?? '—';
    final status = booking['status'] as String? ?? 'pending';
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _openBookingDetail(context, booking),
      child: InfoRow(
        leading: InitialsAvatar(initials: name.isNotEmpty ? name.substring(0, 1) : '؟'),
        title: name,
        subtitle: '${booking['persons_count']} ${t('unit_seat')} · ${booking['total_price']} ${booking['tripCurrency'] ?? ''}',
        trailing: pillFor(status, t('status_$status')),
      ),
    );
  }
}

enum _TripAction { hotel, room, bus, attendance }

void _openActionSelection(BuildContext context, ApiTrip trip, _TripAction action) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => _ActionSelectionScreen(trip: trip, action: action)),
  );
}

/// شاشة اختيار المعتمرين لتنفيذ إجراء واحد (فندق/غرفة/باص/حضور) على أكتر
/// من حجز مرة واحدة — بدل ما تدخل على كل حجز لوحده.
class _ActionSelectionScreen extends StatefulWidget {
  final ApiTrip trip;
  final _TripAction action;
  const _ActionSelectionScreen({required this.trip, required this.action});

  @override
  State<_ActionSelectionScreen> createState() => _ActionSelectionScreenState();
}

class _ActionSelectionScreenState extends State<_ActionSelectionScreen> {
  final Set<int> selected = {};
  String query = '';

  String _titleFor(String Function(String) t) {
    switch (widget.action) {
      case _TripAction.hotel:
        return t('action_assign_hotel');
      case _TripAction.room:
        return t('action_assign_room');
      case _TripAction.bus:
        return t('action_assign_buses');
      case _TripAction.attendance:
        return t('action_attendance');
    }
  }

  Future<void> _continue() async {
    final chosen = context
        .read<AppState>()
        .bookingsList
        .where((b) => selected.contains(b['id']))
        .toList();
    if (chosen.isEmpty) return;

    switch (widget.action) {
      case _TripAction.hotel:
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (ctx) => _BulkHotelSheet(bookings: chosen),
        );
        break;
      case _TripAction.room:
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (ctx) => _BulkRoomSheet(bookings: chosen),
        );
        break;
      case _TripAction.bus:
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (ctx) => _BulkBusSheet(bookings: chosen),
        );
        break;
      case _TripAction.attendance:
        await showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (ctx) => _BulkAttendanceSheet(bookings: chosen),
        );
        break;
    }
    if (mounted) setState(() => selected.clear());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final bookings = state.bookingsList.where((b) {
      if (b['trip_id'] != widget.trip.id || b['status'] == 'cancelled') return false;
      if (query.isEmpty) return true;
      final name = (b['user'] as Map<String, dynamic>?)?['name'] as String? ?? '';
      return name.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(_titleFor(t)), foregroundColor: AppColors.text),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(widget.trip.title, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setState(() => query = v),
                  decoration: InputDecoration(
                    hintText: t('search_traveler_by_name'),
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
                  AppCard(
                    child: Column(
                      children: [
                        for (var i = 0; i < bookings.length; i++) ...[
                          if (i > 0) const Divider(height: 8),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: selected.contains(bookings[i]['id']),
                            title: Text(
                              (bookings[i]['user'] as Map<String, dynamic>?)?['name'] as String? ?? '—',
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text('${bookings[i]['persons_count']} ${t('unit_seat')}', style: const TextStyle(fontSize: 11.5)),
                            onChanged: (v) => setState(() {
                              if (v == true) {
                                selected.add(bookings[i]['id'] as int);
                              } else {
                                selected.remove(bookings[i]['id']);
                              }
                            }),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            decoration: const BoxDecoration(color: AppColors.bg, border: Border(top: BorderSide(color: AppColors.border))),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Text('${t('selected_count_prefix')} ${selected.length}',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  ),
                  ElevatedButton(
                    onPressed: selected.isEmpty ? null : _continue,
                    child: Text(t('action_continue')),
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

/// تسكين فندق لعدة معتمرين مرة واحدة — كل حجز بياخد نفس الفندق، وأي غرفة
/// متسكنة قبل كده بتفضل زي ما هي.
class _BulkHotelSheet extends StatefulWidget {
  final List<Map<String, dynamic>> bookings;
  const _BulkHotelSheet({required this.bookings});

  @override
  State<_BulkHotelSheet> createState() => _BulkHotelSheetState();
}

class _BulkHotelSheetState extends State<_BulkHotelSheet> {
  int? hotelId;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    if (context.read<AppState>().saudiCities.isEmpty) {
      context.read<AppState>().fetchCompanyHotels();
    }
  }

  Future<void> _addNewHotel() async {
    final newId = await showDialog<int>(context: context, builder: (ctx) => const _QuickAddHotelDialog());
    if (newId != null) setState(() => hotelId = newId);
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

    final state = context.read<AppState>();
    final results = await Future.wait(
      widget.bookings.map((b) => state.assignBookingHotel(bookingId: b['id'] as int, hotelId: hotelId!)),
    );
    final errors = results.whereType<String>().toList();
    final firstError = errors.isNotEmpty ? errors.first : null;

    if (!mounted) return;
    setState(() => saving = false);
    if (firstError == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => error = firstError);
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
              Text('${t('action_assign_hotel')} (${widget.bookings.length})',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ],
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: hotelId,
                      decoration: InputDecoration(labelText: t('hotel_mecca_label')),
                      items: state.bookingHotels.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))).toList(),
                      onChanged: (v) => setState(() => hotelId = v),
                    ),
                  ),
                  IconButton(
                    tooltip: t('action_add_new_hotel'),
                    onPressed: _addNewHotel,
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                  ),
                ],
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

/// تسكين غرفة واحدة لكل المعتمرين المختارين مع بعض — بيستخدم أول حجز
/// كأساسي والباقي كـ"مرافقين" في نفس الغرفة، عشان يتحفظوا في استدعاء واحد.
/// لازم كل المعتمرين المختارين يكونوا متسكنين في فندق قبل كده.
class _BulkRoomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> bookings;
  const _BulkRoomSheet({required this.bookings});

  @override
  State<_BulkRoomSheet> createState() => _BulkRoomSheetState();
}

class _BulkRoomSheetState extends State<_BulkRoomSheet> {
  final roomCtrl = TextEditingController();
  bool saving = false;
  String? error;

  @override
  void dispose() {
    roomCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final missingHotel = widget.bookings.where((b) => b['hotel_id'] == null);
    if (missingHotel.isNotEmpty) {
      setState(() => error = context.read<AppState>().t('assign_hotel_first_hint'));
      return;
    }
    if (roomCtrl.text.trim().isEmpty) {
      setState(() => error = context.read<AppState>().t('err_room_number_required'));
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    final primary = widget.bookings.first;
    final companionIds = widget.bookings.skip(1).map((b) => b['id'] as int).toList();

    final result = await context.read<AppState>().assignBookingHotel(
          bookingId: primary['id'] as int,
          hotelId: primary['hotel_id'] as int,
          roomNumber: roomCtrl.text.trim(),
          roomCapacity: widget.bookings.length,
          companionIds: companionIds,
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
    final t = context.watch<AppState>().t;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('${t('action_assign_room')} (${widget.bookings.length})',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ],
              const SizedBox(height: 12),
              TextField(controller: roomCtrl, decoration: InputDecoration(labelText: t('field_room_number'))),
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

/// تسكين باص لعدة معتمرين مرة واحدة.
class _BulkBusSheet extends StatefulWidget {
  final List<Map<String, dynamic>> bookings;
  const _BulkBusSheet({required this.bookings});

  @override
  State<_BulkBusSheet> createState() => _BulkBusSheetState();
}

class _BulkBusSheetState extends State<_BulkBusSheet> {
  int? busId;
  bool saving = false;
  String? error;

  Future<void> _addNewBus() async {
    final newId = await showDialog<int>(context: context, builder: (ctx) => const _QuickAddBusDialog());
    if (newId != null) setState(() => busId = newId);
  }

  Future<void> _save() async {
    if (busId == null) return;
    setState(() {
      saving = true;
      error = null;
    });

    final state = context.read<AppState>();
    final results = await Future.wait(
      widget.bookings.map((b) => state.assignBookingBus(b['id'] as int, busId!)),
    );
    final errors = results.whereType<String>().toList();
    final firstError = errors.isNotEmpty ? errors.first : null;

    if (!mounted) return;
    setState(() => saving = false);
    if (firstError == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => error = firstError);
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
              Text('${t('action_assign_buses')} (${widget.bookings.length})',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ],
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: busId,
                      hint: Text(t('supervisor_none_selected')),
                      items: state.bookingBuses
                          .map((bus) => DropdownMenuItem(
                                value: bus.id,
                                child: Text(bus.company.isEmpty ? bus.number : '${bus.number} — ${bus.company}'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => busId = v),
                    ),
                  ),
                  IconButton(
                    tooltip: t('add_bus_title'),
                    onPressed: _addNewBus,
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                  ),
                ],
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

/// تسجيل حضور/غياب لعدة معتمرين مرة واحدة.
class _BulkAttendanceSheet extends StatefulWidget {
  final List<Map<String, dynamic>> bookings;
  const _BulkAttendanceSheet({required this.bookings});

  @override
  State<_BulkAttendanceSheet> createState() => _BulkAttendanceSheetState();
}

class _BulkAttendanceSheetState extends State<_BulkAttendanceSheet> {
  bool saving = false;
  String? error;

  Future<void> _apply(String status) async {
    setState(() {
      saving = true;
      error = null;
    });

    final state = context.read<AppState>();
    final results = await Future.wait(
      widget.bookings.map((b) => state.markAttendance(b['id'] as int, status)),
    );
    final errors = results.whereType<String>().toList();
    final firstError = errors.isNotEmpty ? errors.first : null;

    if (!mounted) return;
    setState(() => saving = false);
    if (firstError == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => error = firstError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${t('action_attendance')} (${widget.bookings.length})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            if (error != null) ...[
              const SizedBox(height: 6),
              Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
            ],
            const SizedBox(height: 16),
            if (saving)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _apply('present'),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(t('attendance_present')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _apply('absent'),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(t('attendance_absent')),
                    ),
                  ),
                ],
              ),
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
                Text(t('action_assign_hotel'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  hotelId != null ? ((b['hotel'] as Map<String, dynamic>?)?['name'] as String? ?? '—') : t('supervisor_none_selected'),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () => _showHotelOnlySheet(context, b),
                  child: Text(t('action_assign_hotel')),
                ),
                const SizedBox(height: 16),
                Text(t('action_assign_room'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  b['room_number'] != null ? '${b['room_number']} (${b['room_capacity'] ?? '—'})' : t('supervisor_none_selected'),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: hotelId == null ? null : () => _showRoomOnlySheet(context, b),
                      child: Text(t('action_assign_room')),
                    ),
                    if (hotelId != null) ...[
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () => _run(() => state.clearBookingHotel(b['id'] as int)),
                        child: Text(t('action_clear_assignment')),
                      ),
                    ],
                  ],
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

void _showHotelOnlySheet(BuildContext context, Map<String, dynamic> booking) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _HotelOnlySheet(booking: booking),
  );
}

/// تسكين الفندق بس — بدون رقم/سعة الغرفة. الاتنين إجراءان منفصلان في
/// الواجهة حسب طلب المستخدم، رغم إن الـ API بتاعهم واحد.
class _HotelOnlySheet extends StatefulWidget {
  final Map<String, dynamic> booking;
  const _HotelOnlySheet({required this.booking});

  @override
  State<_HotelOnlySheet> createState() => _HotelOnlySheetState();
}

class _HotelOnlySheetState extends State<_HotelOnlySheet> {
  int? hotelId;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    hotelId = widget.booking['hotel_id'] as int?;
    if (context.read<AppState>().saudiCities.isEmpty) {
      context.read<AppState>().fetchCompanyHotels();
    }
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
    final result = await context.read<AppState>().assignBookingHotel(
          bookingId: widget.booking['id'] as int,
          hotelId: hotelId!,
        );
    if (!mounted) return;
    setState(() => saving = false);
    if (result == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => error = result);
    }
  }

  Future<void> _addNewHotel() async {
    final newId = await showDialog<int>(context: context, builder: (ctx) => const _QuickAddHotelDialog());
    if (newId != null) setState(() => hotelId = newId);
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
              Text(t('action_assign_hotel'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ],
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: hotelId,
                      decoration: InputDecoration(labelText: t('hotel_mecca_label')),
                      items: state.bookingHotels.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))).toList(),
                      onChanged: (v) => setState(() => hotelId = v),
                    ),
                  ),
                  IconButton(
                    tooltip: t('action_add_new_hotel'),
                    onPressed: _addNewHotel,
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                  ),
                ],
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

/// إضافة فندق سريعة — بتظهر جوه شاشة تسكين الفندق لو الفندق المطلوب مش
/// موجود في القايمة، وبترجع id الفندق الجديد عشان يتحدد تلقائيًا.
class _QuickAddHotelDialog extends StatefulWidget {
  const _QuickAddHotelDialog();

  @override
  State<_QuickAddHotelDialog> createState() => _QuickAddHotelDialogState();
}

class _QuickAddHotelDialogState extends State<_QuickAddHotelDialog> {
  final nameCtrl = TextEditingController();
  final distanceCtrl = TextEditingController();
  int? cityId;
  int stars = 5;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final cities = context.read<AppState>().saudiCities;
    if (cities.isNotEmpty) cityId = cities.first.id;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    distanceCtrl.dispose();
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
    final (newId, err) = await context.read<AppState>().quickAddHotelForBooking(
          name: nameCtrl.text.trim(),
          cityId: cityId!,
          stars: stars,
          distanceHaram: distanceCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => saving = false);
    if (err == null) {
      Navigator.of(context).pop(newId);
    } else {
      setState(() => error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    return AlertDialog(
      title: Text(t('add_hotel_title')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null) ...[
              Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              const SizedBox(height: 8),
            ],
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t('field_hotel_name'))),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: cityId,
              decoration: InputDecoration(labelText: t('field_city')),
              items: state.saudiCities.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => cityId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: stars,
              decoration: InputDecoration(labelText: t('field_star_count')),
              items: [5, 4, 3, 2, 1].map((s) => DropdownMenuItem(value: s, child: Text('$s ${t('unit_stars')}'))).toList(),
              onChanged: (v) => setState(() => stars = v ?? stars),
            ),
            const SizedBox(height: 12),
            TextField(controller: distanceCtrl, decoration: InputDecoration(labelText: t('field_distance_from_haram'))),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t('action_cancel'))),
        ElevatedButton(
          onPressed: saving ? null : _save,
          child: saving
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(t('action_save')),
        ),
      ],
    );
  }
}

void _showRoomOnlySheet(BuildContext context, Map<String, dynamic> booking) {
  if (booking['hotel_id'] == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.read<AppState>().t('assign_hotel_first_hint'))),
    );
    return;
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _RoomOnlySheet(booking: booking),
  );
}

/// تسكين الغرفة بس — بيفترض إن الفندق متسكن بالفعل ويبعت نفس الـ hotel_id
/// الحالي مع رقم/سعة الغرفة الجديدة.
class _RoomOnlySheet extends StatefulWidget {
  final Map<String, dynamic> booking;
  const _RoomOnlySheet({required this.booking});

  @override
  State<_RoomOnlySheet> createState() => _RoomOnlySheetState();
}

class _RoomOnlySheetState extends State<_RoomOnlySheet> {
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
  }

  @override
  void dispose() {
    roomCtrl.dispose();
    capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final capacity = int.tryParse(capacityCtrl.text);
    if (roomCtrl.text.trim().isEmpty || capacity == null) {
      setState(() => error = context.read<AppState>().t('err_room_number_capacity_required'));
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final result = await context.read<AppState>().assignBookingHotel(
          bookingId: widget.booking['id'] as int,
          hotelId: widget.booking['hotel_id'] as int,
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
    final t = context.watch<AppState>().t;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t('action_assign_room'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ],
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

  Future<void> _addNewBus() async {
    final newId = await showDialog<int>(context: context, builder: (ctx) => const _QuickAddBusDialog());
    if (newId != null) setState(() => busId = newId);
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: busId,
                      hint: Text(t('supervisor_none_selected')),
                      items: state.bookingBuses
                          .map((bus) => DropdownMenuItem(
                                value: bus.id,
                                child: Text(bus.company.isEmpty ? bus.number : '${bus.number} — ${bus.company}'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => busId = v),
                    ),
                  ),
                  IconButton(
                    tooltip: t('add_bus_title'),
                    onPressed: _addNewBus,
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                  ),
                ],
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

/// إضافة باص سريعة — بس رقم الباص (وسعة اختيارية)، مفيش شركة نقل مطلوبة.
/// بترجع id الباص الجديد عشان يتحدد تلقائيًا.
class _QuickAddBusDialog extends StatefulWidget {
  const _QuickAddBusDialog();

  @override
  State<_QuickAddBusDialog> createState() => _QuickAddBusDialogState();
}

class _QuickAddBusDialogState extends State<_QuickAddBusDialog> {
  final numberCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();
  bool saving = false;
  String? error;

  @override
  void dispose() {
    numberCtrl.dispose();
    capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (numberCtrl.text.trim().isEmpty) {
      setState(() => error = context.read<AppState>().t('err_bus_number_required'));
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    final (newBusId, busErr) = await context.read<AppState>().quickAddBusForBooking(
          busNumber: numberCtrl.text.trim(),
          capacity: int.tryParse(capacityCtrl.text.trim()),
        );

    if (!mounted) return;
    setState(() => saving = false);

    if (busErr == null) {
      Navigator.of(context).pop(newBusId);
    } else {
      setState(() => error = busErr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return AlertDialog(
      title: Text(t('add_bus_title')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null) ...[
              Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              const SizedBox(height: 8),
            ],
            TextField(controller: numberCtrl, decoration: InputDecoration(labelText: t('field_name_or_plate'))),
            const SizedBox(height: 12),
            TextField(
              controller: capacityCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t('field_capacity')),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t('action_cancel'))),
        ElevatedButton(
          onPressed: saving ? null : _save,
          child: saving
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(t('action_save')),
        ),
      ],
    );
  }
}
