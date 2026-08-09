import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../notifications/notifications_screen.dart';

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
                      Text('${state.companyName ?? 'رواد بلس'} — ${t('brand_tagline')}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  ),
                  icon: const Icon(Icons.notifications_outlined),
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
          SectionHeader(title: t('section_upcoming_trips')),
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
                            leading: const InitialsAvatar(initials: '🌙', size: 32),
                            title: trip['title'] as String? ?? '',
                            subtitle:
                                '${trip['duration']} ${t('unit_days')} — ${trip['booked']}/${trip['seats']} ${t('unit_seat')}',
                            trailing: StatusPill.warning('${trip['occupancy']}%'),
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
