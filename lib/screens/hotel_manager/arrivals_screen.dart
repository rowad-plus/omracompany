import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

/// Max people in one room (server enforces the same).
const int kMaxRoomPeople = 6;

int _people(Iterable<Map<String, dynamic>> list) =>
    list.fold<int>(0, (n, b) => n + ((b['persons_count'] as num?)?.toInt() ?? 1));

List<Map<String, dynamic>> _arrivalBookings(AppState s) =>
    (s.arrivals?['bookings'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

List<Map<String, dynamic>> _arrivalBuses(AppState s) =>
    (s.arrivals?['buses'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

String busTitle(Map<String, dynamic> g, String Function(String) t) {
  if (g['has_bus'] != true) {
    final trips = (g['trips'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return '${t('hm_no_bus')} — ${trips.isEmpty ? '' : trips.first['title']}';
  }
  final numbers = (g['bus_numbers'] as List<dynamic>? ?? []).join(' / ');
  return '${t('bus_word')} $numbers';
}

/// Small grey company tag — a bus can carry several companies' pilgrims.
class CompanyTag extends StatelessWidget {
  final String name;
  const CompanyTag(this.name, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(20)),
        child: Text(name, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      );
}

/// "الباصات القادمة": every bus arriving in the next two weeks across all the
/// companies this account houses for — same plate on the same day = one bus.
class ArrivalsList extends StatefulWidget {
  /// Home tab shows only the first few buses.
  final int? limit;
  final Widget? header;
  const ArrivalsList({super.key, this.limit, this.header});

  @override
  State<ArrivalsList> createState() => _ArrivalsListState();
}

class _ArrivalsListState extends State<ArrivalsList> {
  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    if (s.arrivals == null) s.fetchArrivals();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final t = s.t;
    var buses = _arrivalBuses(s);
    final total = _people(_arrivalBookings(s));
    final housed = _people(_arrivalBookings(s).where((b) => b['hotel_id'] != null));
    final inRooms = _people(_arrivalBookings(s).where((b) => (b['room_number'] ?? '').toString().isNotEmpty));
    if (widget.limit != null) buses = buses.take(widget.limit!).toList();

    String? lastDate;
    return RefreshIndicator(
      onRefresh: s.fetchArrivals,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (widget.header != null) widget.header!,
          if (s.arrivals == null)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: s.arrivalsError != null && !s.arrivalsLoading
                  ? LoadErrorView(message: s.arrivalsError!, onRetry: s.fetchArrivals)
                  : const Center(child: CircularProgressIndicator()),
            )
          else ...[
            SizedBox(
              height: 92,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  StatChip(label: t('hm_arriving'), value: '$total'),
                  const SizedBox(width: 10),
                  StatChip(label: t('hm_in_hotel'), value: '$housed'),
                  const SizedBox(width: 10),
                  StatChip(label: t('hm_in_rooms'), value: '$inRooms'),
                ],
              ),
            ),
            const SizedBox(height: 6),
            if (buses.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Center(child: Text(t('hm_no_arrivals'), style: const TextStyle(color: AppColors.textSecondary))),
              ),
            for (final g in buses) ...[
              if (g['date'] != lastDate) ...[
                Builder(builder: (context) {
                  lastDate = g['date'] as String?;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(lastDate == null ? '—' : departureDayLabel(context, lastDate!),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                  );
                }),
              ],
              _BusArrivalCard(group: g),
            ],
          ],
        ],
      ),
    );
  }
}

class _BusArrivalCard extends StatelessWidget {
  final Map<String, dynamic> group;
  const _BusArrivalCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final people = (group['people'] as num?)?.toInt() ?? 0;
    final housed = (group['housed'] as num?)?.toInt() ?? 0;
    final inRooms = (group['in_rooms'] as num?)?.toInt() ?? 0;
    final companies = (group['companies'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final plate = group['plate_number'] as String?;
    final done = people > 0 && inRooms == people;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BusHousingScreen(groupKey: group['key'] as String),
        )),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: Icon(group['has_bus'] == true ? Icons.directions_bus : Icons.groups_outlined,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(busTitle(group, t),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                        if (plate != null && plate.isNotEmpty)
                          Text('${t('hm_plate')}: $plate', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$people', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      Text(t('hm_pilgrims'), style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const ForwardChevron(),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: people == 0 ? 0 : inRooms / people,
                  backgroundColor: AppColors.surface2,
                  color: done ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text('${t('hm_in_hotel')} $housed · ${t('hm_in_rooms')} $inRooms · ${t('hm_waiting')} ${people - housed}',
                  style: TextStyle(fontSize: 11.5, color: done ? AppColors.success : AppColors.textSecondary)),
              if (companies.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 4, runSpacing: 4, children: [for (final c in companies) CompanyTag('${c['name']}')]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One bus: step 1 houses pilgrims in a hotel (the whole bus or part of it —
/// the rest can go to another hotel), step 2 splits a hotel's pilgrims into
/// rooms of 1–6 people.
class BusHousingScreen extends StatefulWidget {
  final String groupKey;
  const BusHousingScreen({super.key, required this.groupKey});

  @override
  State<BusHousingScreen> createState() => _BusHousingScreenState();
}

class _BusHousingScreenState extends State<BusHousingScreen> {
  int step = 0; // 0 = hotel, 1 = rooms
  final Set<int> selected = {};
  String? roomsHotel; // hotel name picked in the rooms step
  bool saving = false;

  List<Map<String, dynamic>> _bookings(AppState s) =>
      _arrivalBookings(s).where((b) => b['group_key'] == widget.groupKey).toList();

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.danger : AppColors.success,
    ));
  }

  /// Hotel names usable for these pilgrims: only hotels every involved
  /// company has (each company keeps its own hotel record).
  Map<String, Map<int, int>> _hotelChoices(AppState s, Iterable<Map<String, dynamic>> list) {
    final hotels = (s.arrivals?['hotels'] as Map<String, dynamic>? ?? {});
    final companies = list.map((b) => (b['company_id'] as num).toInt()).toSet();
    final byName = <String, Map<int, int>>{};
    for (final cid in companies) {
      for (final h in (hotels['$cid'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>()) {
        byName.putIfAbsent('${h['name']}'.trim(), () => {})[cid] = (h['id'] as num).toInt();
      }
    }
    byName.removeWhere((_, m) => !companies.every(m.containsKey));
    return byName;
  }

  Future<void> _houseInHotel(List<Map<String, dynamic>> chosen) async {
    final s = context.read<AppState>();
    final t = s.t;
    final choices = _hotelChoices(s, chosen);
    if (choices.isEmpty) {
      _toast(t('hm_no_common_hotel'), error: true);
      return;
    }
    final name = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(18),
          children: [
            Text('${t('hm_pick_hotel_for')} ${_people(chosen)} ${t('hm_pilgrims')}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            for (final n in choices.keys)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.apartment, color: AppColors.primary),
                title: Text(n),
                onTap: () => Navigator.pop(ctx, n),
              ),
          ],
        ),
      ),
    );
    if (name == null || !mounted) return;
    setState(() => saving = true);
    final err = await s.houseArrivals(bookings: chosen, hotelByCompany: choices[name]!);
    if (!mounted) return;
    setState(() {
      saving = false;
      if (err == null) selected.clear();
    });
    _toast(err ?? '${t('hm_housed_in')} $name', error: err != null);
  }

  Future<void> _houseInRoom(List<Map<String, dynamic>> chosen, List<Map<String, dynamic>> hotelPeople) async {
    final s = context.read<AppState>();
    final t = s.t;
    final ctrl = TextEditingController();
    final room = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${t('hm_room_for')} ${_people(chosen)} ${t('hm_pilgrims')}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(labelText: t('field_room_number')),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: Text(t('action_save'))),
        ],
      ),
    );
    if (room == null || room.isEmpty || !mounted) return;
    // Who is already in that room (any company, same hotel name).
    final already = _people(hotelPeople.where((b) => '${b['room_number'] ?? ''}' == room && !chosen.contains(b)));
    if (already + _people(chosen) > kMaxRoomPeople) {
      _toast('${t('hm_room_full')} ($already + ${_people(chosen)} > $kMaxRoomPeople)', error: true);
      return;
    }
    final hotelIds = <int, int>{
      for (final b in chosen) (b['company_id'] as num).toInt(): (b['hotel_id'] as num).toInt(),
    };
    setState(() => saving = true);
    final err = await s.houseArrivals(bookings: chosen, hotelByCompany: hotelIds, roomNumber: room);
    if (!mounted) return;
    setState(() {
      saving = false;
      if (err == null) selected.clear();
    });
    _toast(err ?? '${t('room_word')} $room ✓', error: err != null);
  }

  Widget _pilgrimTile(Map<String, dynamic> b, {required bool checked, ValueChanged<bool?>? onChanged, Widget? trailing}) {
    final persons = (b['persons_count'] as num?)?.toInt() ?? 1;
    final travelers = (b['travelers'] as List<dynamic>? ?? []).cast<String>();
    final names = travelers.isNotEmpty ? travelers.join('، ') : '${b['name']}';
    return CheckboxListTile(
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      value: checked,
      onChanged: onChanged,
      title: Row(
        children: [
          Expanded(
            child: Text(names, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          if (persons > 1)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 6),
              child: Text('×$persons', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Wrap(
          spacing: 6,
          runSpacing: 3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CompanyTag('${b['company_name'] ?? ''}'),
            Text('${b['ref']}', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
          ],
        ),
      ),
      secondary: trailing,
    );
  }

  Widget _selectAllRow(List<Map<String, dynamic>> list, String label, {int? maxPeople}) {
    final t = context.read<AppState>().t;
    final ids = list.map((b) => (b['id'] as num).toInt()).toList();
    final all = ids.isNotEmpty && ids.every(selected.contains);
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800))),
        if (maxPeople == null && ids.isNotEmpty)
          TextButton(
            onPressed: () => setState(() => all ? selected.removeAll(ids) : selected.addAll(ids)),
            child: Text(all ? t('hm_clear_selection') : t('hm_select_all_waiting'), style: const TextStyle(fontSize: 12)),
          ),
      ],
    );
  }

  Widget _hotelStep(AppState s, List<Map<String, dynamic>> list) {
    final t = s.t;
    final waiting = list.where((b) => b['hotel_id'] == null).toList();
    final byHotel = <String, List<Map<String, dynamic>>>{};
    for (final b in list.where((b) => b['hotel_id'] != null)) {
      byHotel.putIfAbsent('${b['hotel_name'] ?? '—'}', () => []).add(b);
    }
    final chosen = waiting.where((b) => selected.contains(b['id'])).toList();
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            children: [
              _selectAllRow(waiting, '${t('hm_not_in_hotel')} (${_people(waiting)})'),
              if (waiting.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(t('hm_all_in_hotel'), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(children: [
                    for (final b in waiting)
                      _pilgrimTile(b,
                          checked: selected.contains(b['id']),
                          onChanged: (v) => setState(() =>
                              v == true ? selected.add((b['id'] as num).toInt()) : selected.remove(b['id']))),
                  ]),
                ),
              for (final e in byHotel.entries) ...[
                const SizedBox(height: 14),
                Row(children: [
                  const Icon(Icons.apartment, size: 16, color: AppColors.success),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('${e.key} — ${_people(e.value)} ${t('hm_pilgrims')}',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                  ),
                ]),
                const SizedBox(height: 6),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(children: [
                    for (final b in e.value)
                      _pilgrimTile(b,
                          checked: true,
                          trailing: IconButton(
                            tooltip: t('hm_remove_from_hotel'),
                            icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                            onPressed: saving ? null : () => s.removeFromHotel(b),
                          )),
                  ]),
                ),
              ],
            ],
          ),
        ),
        _bottomBar(
          enabled: chosen.isNotEmpty && !saving,
          label: '${t('hm_house_in_hotel')} (${_people(chosen)})',
          icon: Icons.apartment,
          onPressed: () => _houseInHotel(chosen),
        ),
      ],
    );
  }

  Widget _roomsStep(AppState s, List<Map<String, dynamic>> list) {
    final t = s.t;
    final inHotel = list.where((b) => b['hotel_id'] != null).toList();
    final hotelNames = inHotel.map((b) => '${b['hotel_name'] ?? '—'}').toSet().toList()..sort();
    if (hotelNames.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(t('hm_house_hotel_first'), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    final hotel = hotelNames.contains(roomsHotel) ? roomsHotel! : hotelNames.first;
    final people = inHotel.where((b) => '${b['hotel_name'] ?? '—'}' == hotel).toList();
    final noRoom = people.where((b) => '${b['room_number'] ?? ''}'.isEmpty).toList();
    final rooms = <String, List<Map<String, dynamic>>>{};
    for (final b in people.where((b) => '${b['room_number'] ?? ''}'.isNotEmpty)) {
      rooms.putIfAbsent('${b['room_number']}', () => []).add(b);
    }
    final roomKeys = rooms.keys.toList()..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));
    final chosen = noRoom.where((b) => selected.contains(b['id'])).toList();
    final chosenPeople = _people(chosen);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            children: [
              if (hotelNames.length > 1)
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final h in hotelNames)
                    ChoiceChip(
                      label: Text(h, style: const TextStyle(fontSize: 12)),
                      selected: h == hotel,
                      onSelected: (_) => setState(() {
                        roomsHotel = h;
                        selected.clear();
                      }),
                    ),
                ]),
              const SizedBox(height: 8),
              _selectAllRow(noRoom, '${t('hm_without_room')} — $hotel (${_people(noRoom)})', maxPeople: kMaxRoomPeople),
              Text(t('hm_room_hint'), style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              if (noRoom.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(t('hm_all_in_rooms'), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(children: [
                    for (final b in noRoom)
                      _pilgrimTile(b,
                          checked: selected.contains(b['id']),
                          // Never more than 6 people picked for one room.
                          onChanged: !selected.contains(b['id']) &&
                                  chosenPeople + ((b['persons_count'] as num?)?.toInt() ?? 1) > kMaxRoomPeople
                              ? null
                              : (v) => setState(() =>
                                  v == true ? selected.add((b['id'] as num).toInt()) : selected.remove(b['id']))),
                  ]),
                ),
              for (final r in roomKeys) ...[
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.fromLTRB(12, 10, 4, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.bed_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(child: Text('${t('room_word')} $r', style: const TextStyle(fontWeight: FontWeight.w800))),
                        StatusPill.success('${_people(rooms[r]!)} / $kMaxRoomPeople'),
                        const SizedBox(width: 8),
                      ]),
                      for (final b in rooms[r]!)
                        _pilgrimTile(b,
                            checked: true,
                            trailing: IconButton(
                              tooltip: t('hm_remove_from_room'),
                              icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                              onPressed: saving ? null : () => s.removeFromRoom(b),
                            )),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        _bottomBar(
          enabled: chosen.isNotEmpty && !saving,
          label: '${t('hm_house_in_room')} ($chosenPeople/$kMaxRoomPeople)',
          icon: Icons.bed_outlined,
          onPressed: () => _houseInRoom(chosen, people),
        ),
      ],
    );
  }

  Widget _bottomBar({required bool enabled, required String label, required IconData icon, required VoidCallback onPressed}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(color: AppColors.bg, border: Border(top: BorderSide(color: AppColors.border))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: enabled ? onPressed : null,
            icon: saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(icon, size: 18),
            label: Text(label),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final t = s.t;
    final group = _arrivalBuses(s).firstWhere((g) => g['key'] == widget.groupKey, orElse: () => {});
    final list = _bookings(s);
    final companies = (group['companies'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final people = _people(list);
    final housed = _people(list.where((b) => b['hotel_id'] != null));
    final inRooms = _people(list.where((b) => '${b['room_number'] ?? ''}'.isNotEmpty));

    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppColors.text,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.isEmpty ? '' : busTitle(group, t), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            if (group['date'] != null)
              Text(departureDayLabel(context, group['date'] as String),
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: list.isEmpty && s.arrivalsLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$people ${t('hm_pilgrims')} · ${t('hm_in_hotel')} $housed · ${t('hm_in_rooms')} $inRooms',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      if (group['plate_number'] != null && '${group['plate_number']}'.isNotEmpty)
                        Text('${t('hm_plate')}: ${group['plate_number']}',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                      if (companies.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(spacing: 4, runSpacing: 4, children: [for (final c in companies) CompanyTag('${c['name']}')]),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<int>(
                          segments: [
                            ButtonSegment(value: 0, icon: const Icon(Icons.apartment, size: 16), label: Text(t('hm_step_hotel'))),
                            ButtonSegment(value: 1, icon: const Icon(Icons.bed_outlined, size: 16), label: Text(t('hm_step_rooms'))),
                          ],
                          selected: {step},
                          onSelectionChanged: (v) => setState(() {
                            step = v.first;
                            selected.clear();
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: step == 0 ? _hotelStep(s, list) : _roomsStep(s, list)),
              ],
            ),
    );
  }
}
