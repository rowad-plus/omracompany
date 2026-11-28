import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../notifications/notifications_screen.dart';
import 'bookings_screen.dart';
import '../trips/trip_detail_screen.dart';
import '../wizard/trip_wizard_screen.dart';
import '../hotels/hotels_screen.dart';
import '../transport/transport_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchDashboard();
    context.read<AppState>().fetchApiTrips();
    context.read<AppState>().fetchBookings();
  }

  Future<void> _refreshAll() async {
    final s = context.read<AppState>();
    await Future.wait([s.fetchDashboard(), s.fetchApiTrips(), s.fetchBookings()]);
  }

  Future<void> _openTrip(int? id) async {
    if (id == null) return;
    final state = context.read<AppState>();
    var match = state.apiTrips.where((t) => t.id == id);
    if (match.isEmpty) {
      await state.fetchApiTrips();
      match = state.apiTrips.where((t) => t.id == id);
    }
    if (match.isEmpty || !mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripDetailScreen(trip: match.first)));
    if (mounted) context.read<AppState>().fetchDashboard();
  }

  Color _activityColor(String key) {
    switch (key) {
      case 'red':
        return AppColors.danger;
      case 'green':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }

  bool _may(AppState s, String permission) =>
      s.currentRoles.contains(UserRole.owner) || s.permissions.contains(permission);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final data = state.dashboardData;

    if (state.dashboardLoading && data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (data == null) {
      return RefreshIndicator(
        onRefresh: () async {
          final s = context.read<AppState>();
          await Future.wait([s.fetchDashboard(), s.fetchApiTrips()]);
        },
        child: ListView(children: [
          const SizedBox(height: 120),
          LoadErrorView(
            message: state.dashboardError ?? t('load_failed'),
            onRetry: () => context.read<AppState>().fetchDashboard(),
          ),
        ]),
      );
    }

    final kpis = data['kpis'] as Map<String, dynamic>;
    final upcomingTrips = (data['upcomingTrips'] as List<dynamic>).cast<Map<String, dynamic>>();
    // Each trip's departures in the next 3 days as separate rows ("today's
    // trip", "tomorrow's trip", …) — from the trips list's upcoming_days.
    final now = DateTime.now();
    String ymd(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final windowEnd = ymd(now.add(const Duration(days: 2)));
    final dayRows = <(ApiTrip, TripDay)>[
      for (final trip in state.apiTrips.where((tr) => tr.status == 'active'))
        for (final d in trip.upcomingDays)
          if (d.date.compareTo(windowEnd) <= 0) (trip, d),
    ]..sort((a, b) {
        final c = a.$2.date.compareTo(b.$2.date);
        return c != 0 ? c : b.$2.bookings.compareTo(a.$2.bookings);
      });
    final useDayRows = state.apiTrips.any((tr) => tr.daysKnown);
    final recentActivity = (data['recentActivity'] as List<dynamic>).cast<Map<String, dynamic>>().take(3).toList();

    // New bookings nobody has answered yet (pending), newest first.
    final pendingAll = state.bookingsList.where((b) => (b['status'] ?? 'pending') == 'pending').toList()
      ..sort((a, b) => ((b['id'] as num?) ?? 0).compareTo((a['id'] as num?) ?? 0));
    final pending = pendingAll.take(10).toList();
    String tripTitle(Map<String, dynamic> b) {
      final m = state.apiTrips.where((tr) => tr.id == b['trip_id']);
      return m.isEmpty ? '' : m.first.title;
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/omraway_kaaba.png',
                      width: 64, fit: BoxFit.contain),
                  const SizedBox(width: 10),
                  Text(state.language == AppLanguage.ar ? 'طريق العمرة' : 'Omraway',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${t('greeting_hello')}، ${state.accountName}',
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${state.companyName ?? 'Omraway'} — ${t('brand_tagline')}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                        if (context.mounted) context.read<AppState>().fetchUnreadNotificationsCount();
                      },
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                    if (state.unreadNotificationsCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(10)),
                          constraints: const BoxConstraints(minWidth: 16),
                          child: Text(
                            state.unreadNotificationsCount > 9 ? '9+' : '${state.unreadNotificationsCount}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              children: [
                // The server leaves revenue out for accounts without money
                // permissions — hide the card rather than show "0".
                if (kpis.containsKey('total_revenue')) ...[
                  StatChip(label: t('stat_total_revenue'), value: _fmtNumber(kpis['total_revenue'])),
                  const SizedBox(width: 10),
                ],
                StatChip(label: t('stat_bookings'), value: '${kpis['total_bookings']}'),
                const SizedBox(width: 10),
                StatChip(label: t('stat_travelers'), value: '${kpis['total_pilgrims']}'),
                const SizedBox(width: 10),
                StatChip(label: t('stat_pending_bookings'), value: '${kpis['pending_bookings']}'),
              ],
            ),
          ),
          // 2026-11-27: quick add — trip, then hotel, then bus (owner or matching permission).
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_may(state, 'umrah.manage'))
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TripWizardScreen()));
                      if (context.mounted) _refreshAll();
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(t('action_add_new_trip')),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  ),
                if (_may(state, 'hotels.manage')) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final s = context.read<AppState>();
                      if (s.saudiCities.isEmpty) await s.fetchCompanyHotels();
                      if (context.mounted) showHotelSheet(context);
                    },
                    icon: const Icon(Icons.hotel_outlined),
                    label: Text(t('action_add_hotel_home')),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                ],
                if (_may(state, 'transport.manage')) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final s = context.read<AppState>();
                      if (s.busCompanies.isEmpty) await s.fetchBusCompanies();
                      if (context.mounted) showAddBusSheet(context);
                    },
                    icon: const Icon(Icons.directions_bus_outlined),
                    label: Text(t('action_add_bus_home')),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                ],
              ],
            ),
          ),
          SectionHeader(title: t('section_current_upcoming_trips')),
          AppCard(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            child: useDayRows
                ? (dayRows.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(t('no_upcoming_trips'), style: const TextStyle(color: AppColors.textSecondary)),
                      )
                    : Column(
                        children: [
                          for (final (trip, d) in dayRows)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InfoRow(
                                leading: InitialsAvatar(initials: '🌙', size: 32, imageUrl: trip.thumbnail),
                                title: trip.title,
                                subtitle:
                                    '${departureDayLabel(context, d.date)}${trip.departureTimes.isEmpty ? '' : ' ⏰ ${busTimesLabel(context, trip.departureTimes)}'} — ${d.bookings} ${t('unit_booking')} · ${d.persons} ${t('unit_person')}',
                                trailing: _dayPill(d.date, t),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => TripBookingsScreen(trip: trip, day: d.date)),
                                ),
                              ),
                            ),
                        ],
                      ))
                : upcomingTrips.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(t('no_upcoming_trips'), style: const TextStyle(color: AppColors.textSecondary)),
                  )
                : Column(
                    children: [
                      for (final trip in upcomingTrips)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InfoRow(
                            leading: InitialsAvatar(initials: '🌙', size: 32, imageUrl: trip['thumbnail'] as String?),
                            title: trip['title'] as String? ?? '',
                            subtitle: _tripSubtitle(trip, t),
                            trailing: _tripPill(trip, t),
                            onTap: () => _openTrip(trip['id'] as int?),
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          SectionHeader(title: t('section_new_bookings')),
          AppCard(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            child: state.bookingsLoading && state.bookingsData == null
                ? const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()))
                : pending.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(t('no_pending_bookings'), style: const TextStyle(color: AppColors.textSecondary)),
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < pending.length; i++) ...[
                            if (i > 0) const Divider(height: 22),
                            InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => openBookingDetail(context, pending[i]),
                              child: InfoRow(
                                leading: InitialsAvatar(
                                  initials: bookingName(pending[i]).isNotEmpty ? bookingName(pending[i]).substring(0, 1) : '؟',
                                ),
                                title: bookingName(pending[i]),
                                subtitle: [
                                  if (tripTitle(pending[i]).isNotEmpty) tripTitle(pending[i]),
                                  '${pending[i]['persons_count'] ?? 1} ${t('unit_person')}',
                                  if (pending[i]['departure_date'] != null) departureDayLabel(context, pending[i]['departure_date'] as String),
                                  if (pending[i]['source'] == 'whatsapp') t('whatsapp_booking'),
                                ].join(' · '),
                                trailing: StatusPill.warning(t('status_pending')),
                                below: roomTypeBadge(pending[i], t),
                              ),
                            ),
                          ],
                          if (pendingAll.length > pending.length)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                t('more_pending_bookings').replaceAll('{n}', '${pendingAll.length - pending.length}'),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
          ),
          const SizedBox(height: 16),
          SectionHeader(title: t('section_latest_notifications')),
          AppCard(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            child: recentActivity.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(t('no_recent_activity'), style: const TextStyle(color: AppColors.textSecondary)),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < recentActivity.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        NotifRow(
                          color: _activityColor(recentActivity[i]['color'] as String? ?? 'blue'),
                          text: recentActivity[i]['message'] as String? ?? '',
                          time: recentActivity[i]['time'] as String? ?? '',
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

/// "12/10 — Day 3 of 10 — 18/40 seats" for current trips,
/// "12/10 — 10 days — 18/40 seats" for upcoming ones.
String _tripSubtitle(Map<String, dynamic> trip, String Function(String) t) {
  final parts = <String>[];
  final start = DateTime.tryParse(trip['start_date'] as String? ?? '');
  if (start != null) parts.add('${start.day}/${start.month}');
  final dayNumber = trip['day_number'] as num?;
  if (trip['phase'] == 'current' && dayNumber != null) {
    parts.add(t('trip_day_of').replaceAll('{d}', '$dayNumber').replaceAll('{n}', '${trip['duration']}'));
  } else {
    parts.add('${trip['duration']} ${t('unit_days')}');
  }
  parts.add('${trip['booked']}/${trip['seats']} ${t('unit_seat')}');
  return parts.join(' — ');
}

/// ["14:30","20:00"] → "2:30 م، 8:00 م" (Arabic) / "2:30 PM, 8:00 PM".
String busTimesLabel(BuildContext context, List<String> times) {
  final ar = Localizations.localeOf(context).languageCode == 'ar' || Directionality.of(context) == TextDirection.rtl;
  final out = <String>[];
  for (final s in times) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(s);
    if (m == null) continue;
    final h = int.parse(m.group(1)!);
    final h12 = h % 12 == 0 ? 12 : h % 12;
    out.add('$h12:${m.group(2)} ${ar ? (h < 12 ? 'ص' : 'م') : (h < 12 ? 'AM' : 'PM')}');
  }
  return out.join(ar ? '، ' : ', ');
}

/// "today" / "tomorrow" / "in N days" pill for a departure day.
Widget _dayPill(String ymd, String Function(String) t) {
  final d = DateTime.tryParse(ymd);
  if (d == null) return const SizedBox.shrink();
  final now = DateTime.now();
  final diff = DateTime(d.year, d.month, d.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  if (diff <= 0) return StatusPill.success(t('trip_starts_today'));
  if (diff == 1) return StatusPill.info(t('trip_starts_tomorrow'));
  return StatusPill.warning(t('trip_in_days').replaceAll('{n}', '$diff'));
}

Widget _tripPill(Map<String, dynamic> trip, String Function(String) t) {
  if (trip['phase'] == 'current') return StatusPill.success(t('trip_phase_current'));
  final days = trip['days_until'] as num?;
  if (days == null) return StatusPill.warning('${trip['occupancy']}%');
  if (days == 0) return StatusPill.info(t('trip_starts_today'));
  if (days == 1) return StatusPill.info(t('trip_starts_tomorrow'));
  return StatusPill.warning(t('trip_in_days').replaceAll('{n}', '$days'));
}

String _fmtNumber(dynamic value) {
  final n = (value as num?)?.toDouble() ?? 0;
  final s = n.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
