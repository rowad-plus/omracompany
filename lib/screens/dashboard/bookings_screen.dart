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
                  // Each departure day of the next two weeks is its own row:
                  // "today's trip", "tomorrow's trip", …
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        for (final trip in trips)
                          TripDaysCard(
                            trip: trip,
                            collapsible: true,
                            onOpen: (day) => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => TripBookingsScreen(trip: trip, day: day)),
                            ),
                          ),
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

  /// Departure day (Y-m-d) this screen is for; null = all days.
  final String? day;
  const TripBookingsScreen({super.key, required this.trip, this.day});

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
      if (widget.day != null && b['departure_date'] != widget.day) return false;
      if (query.isEmpty) return true;
      final phone = (b['customer_phone'] ?? (b['user'] as Map<String, dynamic>?)?['phone'] ?? '') as String;
      return bookingName(b).contains(query) || (b['ref'] as String? ?? '').contains(query) || phone.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.trip.title, style: const TextStyle(fontSize: 16)),
            if (widget.day != null)
              Text(departureDayLabel(context, widget.day!),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        foregroundColor: AppColors.text,
      ),
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
                        onTap: () => _openActionSelection(context, widget.trip, _TripAction.hotel, widget.day),
                      ),
                      _TripActionButton(
                        icon: Icons.meeting_room_outlined,
                        label: t('action_assign_room'),
                        onTap: () => _openActionSelection(context, widget.trip, _TripAction.room, widget.day),
                      ),
                      _TripActionButton(
                        icon: Icons.directions_bus_outlined,
                        label: t('action_assign_buses'),
                        onTap: () => _openActionSelection(context, widget.trip, _TripAction.bus, widget.day),
                      ),
                      _TripActionButton(
                        icon: Icons.how_to_reg_outlined,
                        label: t('action_attendance'),
                        onTap: () => _openActionSelection(context, widget.trip, _TripAction.attendance, widget.day),
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
        subtitle: [
          '${booking['persons_count']} ${t('unit_seat')}',
          if (booking['total_price'] != null) '${booking['total_price']} ${booking['tripCurrency'] ?? ''}',
          if (booking['departure_date'] != null) booking['departure_date'],
          if (booking['ref'] != null) booking['ref'],
        ].join(' · '),
        trailing: pillFor(status, t('status_$status')),
      ),
    );
  }
}

enum _TripAction { hotel, room, bus, attendance }

void _openActionSelection(BuildContext context, ApiTrip trip, _TripAction action, [String? day]) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => _ActionSelectionScreen(trip: trip, action: action, initialDay: day)),
  );
}

/// شاشة اختيار المعتمرين لتنفيذ إجراء واحد (فندق/غرفة/باص/حضور) على أكتر
/// من حجز مرة واحدة — بدل ما تدخل على كل حجز لوحده.
class _ActionSelectionScreen extends StatefulWidget {
  final ApiTrip trip;
  final _TripAction action;
  final String? initialDay;
  const _ActionSelectionScreen({required this.trip, required this.action, this.initialDay});

  @override
  State<_ActionSelectionScreen> createState() => _ActionSelectionScreenState();
}

class _ActionSelectionScreenState extends State<_ActionSelectionScreen> {
  final Set<int> selected = {};
  String query = '';

  /// Departure day being worked on — daily/recurring trips must never mix
  /// pilgrims of different days in one room / bus.
  late String? day = widget.initialDay;

  /// Current hotel / room / bus of a booking, so the list shows who is done.
  String _statusLine(Map<String, dynamic> b, String Function(String) t) {
    final hotel = (b['hotel'] as Map<String, dynamic>?)?['name'] as String?;
    final room = b['room_number'] as String?;
    final bus = (b['bus'] as Map<String, dynamic>?)?['bus_number'];
    switch (widget.action) {
      case _TripAction.hotel:
      case _TripAction.room:
        if (hotel == null) return '';
        return room == null ? hotel : '$hotel · ${t('room_word')} $room';
      case _TripAction.bus:
        return bus == null ? '' : '${t('bus_word')} $bus';
      case _TripAction.attendance:
        return '';
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final allTrip = state.bookingsList
        .where((b) => b['trip_id'] == widget.trip.id && b['status'] != 'cancelled')
        .toList();
    final days = departureDaysOf(allTrip);
    final currentDay = days.contains(day) ? day : defaultDepartureDay(days);
    final dayCounts = {for (final d in days) d: allTrip.where((b) => b['departure_date'] == d).length};
    final bookings = allTrip.where((b) {
      if (days.length > 1 && b['departure_date'] != currentDay) return false;
      if (query.isEmpty) return true;
      final phone = (b['customer_phone'] ?? (b['user'] as Map<String, dynamic>?)?['phone'] ?? '') as String;
      return bookingName(b).contains(query) || (b['ref'] as String? ?? '').contains(query) || phone.contains(query);
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
                  const SizedBox(height: 12),
                ],
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
                              bookingName(bookings[i]),
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bookingDetails(bookings[i], t('unit_seat')), style: const TextStyle(fontSize: 11.5)),
                                if (_statusLine(bookings[i], t).isNotEmpty)
                                  Text(_statusLine(bookings[i], t),
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              ],
                            ),
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
          // Choose → act right here: hotel / room / bus / attendance controls
          // sit under the list (no extra sheet hidden behind "continue").
          _ActionPanel(
            action: widget.action,
            selectedBookings: state.bookingsList.where((b) => selected.contains(b['id'])).toList(),
            onDone: () => setState(() => selected.clear()),
          ),
        ],
      ),
    );
  }
}

/// The bottom panel of the selection screen. The selected pilgrims are
/// housed in one hotel / one room / one bus, or marked present / absent.
class _ActionPanel extends StatefulWidget {
  final _TripAction action;
  final List<Map<String, dynamic>> selectedBookings;
  final VoidCallback onDone;
  const _ActionPanel({required this.action, required this.selectedBookings, required this.onDone});

  @override
  State<_ActionPanel> createState() => _ActionPanelState();
}

class _ActionPanelState extends State<_ActionPanel> {
  final roomCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();
  int? hotelId;
  int? busId;
  bool saving = false;
  String? error;
  Set<int> _lastIds = {};

  List<Map<String, dynamic>> get _sel => widget.selectedBookings;
  int get _people => _sel.fold<int>(0, (n, b) => n + ((b['persons_count'] as num?)?.toInt() ?? 1));

  @override
  void didUpdateWidget(covariant _ActionPanel old) {
    super.didUpdateWidget(old);
    final ids = _sel.map((b) => b['id'] as int).toSet();
    if (ids.length == _lastIds.length && ids.containsAll(_lastIds)) return;
    _lastIds = ids;
    error = null;
    // Pre-fill from what the selected pilgrims already share.
    final hotels = _sel.map((b) => b['hotel_id'] as int?).toSet();
    if (hotels.length == 1 && hotels.first != null) hotelId = hotels.first;
    final rooms = _sel.map((b) => b['room_number'] as String?).toSet();
    roomCtrl.text = rooms.length == 1 && rooms.first != null ? rooms.first! : '';
    capacityCtrl.text = _sel.isEmpty ? '' : '${_people.clamp(1, 20)}';
    final buses = _sel.map((b) => b['bus_id'] as int?).toSet();
    if (buses.length == 1 && buses.first != null) busId = buses.first;
  }

  @override
  void dispose() {
    roomCtrl.dispose();
    capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String?> Function(AppState) job) async {
    setState(() {
      saving = true;
      error = null;
    });
    final state = context.read<AppState>();
    final result = await job(state);
    if (!mounted) return;
    setState(() => saving = false);
    if (result == null) {
      widget.onDone();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.t('saved_ok'))));
    } else {
      setState(() => error = result);
    }
  }

  Future<String?> _firstError(Iterable<Future<String?>> jobs) async =>
      (await Future.wait(jobs)).whereType<String>().firstOrNull;

  void _saveHotel() {
    final t = context.read<AppState>().t;
    if (hotelId == null) return setState(() => error = t('err_select_hotel'));
    _run((s) => _firstError(_sel.map((b) => s.assignBookingHotel(bookingId: b['id'] as int, hotelId: hotelId!))));
  }

  void _saveRoom() {
    final t = context.read<AppState>().t;
    if (hotelId == null) return setState(() => error = t('err_select_hotel'));
    if (roomCtrl.text.trim().isEmpty) return setState(() => error = t('err_room_number_required'));
    final capacity = (int.tryParse(capacityCtrl.text.trim()) ?? _people).clamp(1, 20);
    _run((s) => s.assignBookingHotel(
          bookingId: _sel.first['id'] as int,
          hotelId: hotelId!,
          roomNumber: roomCtrl.text.trim(),
          // Capacity counts PEOPLE, not bookings.
          roomCapacity: capacity,
          companionIds: _sel.skip(1).map((b) => b['id'] as int).toList(),
        ));
  }

  void _saveBus() {
    if (busId == null) return;
    _run((s) => _firstError(_sel.map((b) => s.assignBookingBus(b['id'] as int, busId!))));
  }

  void _saveAttendance(String status) =>
      _run((s) => _firstError(_sel.map((b) => s.markAttendance(b['id'] as int, status))));

  Future<void> _addHotel() async {
    final id = await showDialog<int>(context: context, builder: (_) => const _QuickAddHotelDialog());
    if (id != null) setState(() => hotelId = id);
  }

  Future<void> _addBus() async {
    final id = await showDialog<int>(context: context, builder: (_) => const _QuickAddBusDialog());
    if (id != null) setState(() => busId = id);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final none = _sel.isEmpty;
    final busy = none || saving;

    Widget mainButton(String label, VoidCallback onTap) => ElevatedButton(
          onPressed: busy ? null : onTap,
          child: saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(label),
        );

    final hotelPicker = Row(children: [
      Expanded(
        child: DropdownButtonFormField<int>(
          value: state.bookingHotels.any((h) => h.id == hotelId) ? hotelId : null,
          isExpanded: true,
          decoration: InputDecoration(labelText: t('hotel_label'), isDense: true),
          items: state.bookingHotels.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))).toList(),
          onChanged: (v) => setState(() => hotelId = v),
        ),
      ),
      IconButton(
        tooltip: t('action_add_new_hotel'),
        onPressed: _addHotel,
        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
      ),
    ]);

    final List<Widget> controls;
    switch (widget.action) {
      case _TripAction.hotel:
        controls = [hotelPicker, const SizedBox(height: 10), mainButton(t('action_house_hotel'), _saveHotel)];
      case _TripAction.room:
        controls = [
          hotelPicker,
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: roomCtrl,
                decoration: InputDecoration(labelText: t('field_room_number'), isDense: true),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 130,
              child: TextField(
                controller: capacityCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t('room_capacity_label'), isDense: true),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          mainButton(t('action_house_room'), _saveRoom),
        ];
      case _TripAction.bus:
        controls = [
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: state.bookingBuses.any((b) => b.id == busId) ? busId : null,
                isExpanded: true,
                decoration: InputDecoration(labelText: t('bus_word'), isDense: true),
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
              onPressed: _addBus,
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            ),
          ]),
          const SizedBox(height: 10),
          mainButton(t('action_house_bus'), _saveBus),
        ];
      case _TripAction.attendance:
        controls = [
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                onPressed: busy ? null : () => _saveAttendance('present'),
                icon: const Icon(Icons.check, size: 18),
                label: Text(t('attendance_present')),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                onPressed: busy ? null : () => _saveAttendance('absent'),
                icon: const Icon(Icons.close, size: 18),
                label: Text(t('attendance_absent')),
              ),
            ),
          ]),
        ];
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              none
                  ? t('select_pilgrims_hint')
                  : '${t('selected_count_prefix')} ${_sel.length} ${t('unit_booking')} · $_people ${t('unit_person')}',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: none ? AppColors.textMuted : AppColors.primary),
            ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
            ],
            const SizedBox(height: 8),
            ...controls,
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
              Text(b['total_price'] == null ? '${b['tripTitle']}' : '${b['tripTitle']} · ${b['total_price']} ${b['tripCurrency'] ?? ''}',
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
                      decoration: InputDecoration(labelText: t('hotel_label')),
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

/// What a trip-level shortcut opens for one departure day.
enum PilgrimAction { bookings, rooms, hotel, bus, attendance }

/// From a program page: when the trip has more than one departure day in
/// the next two weeks, first ask which day; then open that day's pilgrims
/// for [action]. A single-day trip opens straight away.
Future<void> openPilgrimAction(BuildContext context, ApiTrip trip, PilgrimAction action) async {
  final days = trip.upcomingDays;
  String? day;
  if (days.length > 1) {
    day = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _DayPickerSheet(trip: trip),
    );
    if (day == null) return; // dismissed
  } else if (days.length == 1) {
    day = days.first.date;
  }
  if (!context.mounted) return;
  final Widget screen = switch (action) {
    PilgrimAction.bookings => TripBookingsScreen(trip: trip, day: day),
    PilgrimAction.rooms => _ActionSelectionScreen(trip: trip, action: _TripAction.room, initialDay: day),
    PilgrimAction.hotel => _ActionSelectionScreen(trip: trip, action: _TripAction.hotel, initialDay: day),
    PilgrimAction.bus => _ActionSelectionScreen(trip: trip, action: _TripAction.bus, initialDay: day),
    PilgrimAction.attendance => _ActionSelectionScreen(trip: trip, action: _TripAction.attendance, initialDay: day),
  };
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}

class _DayPickerSheet extends StatelessWidget {
  final ApiTrip trip;
  const _DayPickerSheet({required this.trip});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t('choose_departure_day'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(trip.title, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final d in trip.upcomingDays)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 6,
                          height: 34,
                          decoration: BoxDecoration(
                            color: d.bookings > 0 ? AppColors.primary : AppColors.border,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        title: Text(departureDayLabel(context, d.date),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text('${d.bookings} ${t('unit_booking')} · ${d.persons} ${t('unit_person')}'),
                        trailing: const ForwardChevron(),
                        onTap: () => Navigator.of(context).pop(d.date),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
