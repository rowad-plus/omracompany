import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../notifications/notifications_screen.dart';
import '../trips/trip_detail_screen.dart';

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
        onRefresh: () => context.read<AppState>().fetchDashboard(),
        child: ListView(children: const [SizedBox(height: 200), Center(child: Icon(Icons.wifi_off, size: 40))]),
      );
    }

    final kpis = data['kpis'] as Map<String, dynamic>;
    final upcomingTrips = (data['upcomingTrips'] as List<dynamic>).cast<Map<String, dynamic>>();
    final recentActivity = (data['recentActivity'] as List<dynamic>).cast<Map<String, dynamic>>().take(3).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<AppState>().fetchDashboard(),
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
                StatChip(label: t('stat_total_revenue'), value: _fmtNumber(kpis['total_revenue'])),
                const SizedBox(width: 10),
                StatChip(label: t('stat_bookings'), value: '${kpis['total_bookings']}'),
                const SizedBox(width: 10),
                StatChip(label: t('stat_travelers'), value: '${kpis['total_pilgrims']}'),
                const SizedBox(width: 10),
                StatChip(label: t('stat_pending_bookings'), value: '${kpis['pending_bookings']}'),
              ],
            ),
          ),
          SectionHeader(title: t('section_current_upcoming_trips')),
          AppCard(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            child: upcomingTrips.isEmpty
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
