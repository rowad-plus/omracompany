import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

double _num(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

String _fmtCurrency(dynamic v) => '${_num(v).round()}';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final roles = state.currentRoles;
    final onlyTripManager = roles.contains(UserRole.tripManager) && !roles.contains(UserRole.owner);
    final data = state.reportsData;

    return Scaffold(
      appBar: AppBar(
        title: Text(onlyTripManager ? t('profile_my_reports') : t('profile_reports')),
        foregroundColor: AppColors.text,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().fetchReports(),
        child: state.reportsLoading && data == null
            ? const Center(child: CircularProgressIndicator())
            : data == null
                ? ListView(children: const [SizedBox(height: 200), Center(child: Icon(Icons.wifi_off, size: 40))])
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
                        child: Text(t('reports_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ),
                      _RevenueSection(revenue: data['revenue'] as Map<String, dynamic>? ?? {}),
                      _TripsSection(trips: data['trips'] as Map<String, dynamic>? ?? {}),
                      _CustomersSection(customers: data['customers'] as Map<String, dynamic>? ?? {}),
                      _SupervisorsSection(supervisors: data['supervisors'] as Map<String, dynamic>? ?? {}),
                      _OccupancySection(occupancy: data['occupancy'] as Map<String, dynamic>? ?? {}),
                    ],
                  ),
      ),
    );
  }
}

class _RevenueSection extends StatelessWidget {
  final Map<String, dynamic> revenue;
  const _RevenueSection({required this.revenue});

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppState>().t;
    final chart = (revenue['monthly_chart'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final byCategory = (revenue['by_category'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final transactions = (revenue['transactions'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final maxRev = chart.isEmpty ? 1.0 : chart.map((m) => _num(m['value'])).fold(1.0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: t('reports_section_revenue')),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            children: [
              StatChip(label: t('stat_total_revenue'), value: _fmtCurrency(revenue['total_revenue'])),
              const SizedBox(width: 10),
              StatChip(label: t('stat_pending_revenue'), value: _fmtCurrency(revenue['pending_revenue'])),
              const SizedBox(width: 10),
              StatChip(label: t('stat_confirmed_bookings'), value: '${revenue['confirmed_count'] ?? 0}'),
              const SizedBox(width: 10),
              StatChip(label: t('stat_avg_booking'), value: _fmtCurrency(revenue['avg_booking'])),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          child: SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chart.map((m) {
                final h = (_num(m['value']) / maxRev * 90).clamp(2.0, 90.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${(_num(m['value']) / 1000).toStringAsFixed(0)}ك', style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Container(height: h, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3))),
                        const SizedBox(height: 4),
                        Text('${m['label']}', style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (byCategory.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: byCategory.map((c) {
                final total = _num(revenue['total_revenue']);
                final pct = total > 0 ? (_num(c['revenue']) / total * 100).round() : 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${c['label']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(_fmtCurrency(c['revenue']), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: pct / 100, minHeight: 6, backgroundColor: AppColors.border, color: AppColors.primary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        if (transactions.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                for (var i = 0; i < transactions.length; i++) ...[
                  if (i > 0) const Divider(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${transactions[i]['customer']}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                            Text('${transactions[i]['trip']}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Text('${_fmtCurrency(transactions[i]['total'])} ${transactions[i]['currency']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TripsSection extends StatelessWidget {
  final Map<String, dynamic> trips;
  const _TripsSection({required this.trips});

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppState>().t;
    final rows = (trips['rows'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: t('reports_section_trips')),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            children: [
              StatChip(label: t('stat_total_trips'), value: '${trips['total'] ?? 0}'),
              const SizedBox(width: 10),
              StatChip(label: t('stat_active_trips'), value: '${trips['active'] ?? 0}'),
              const SizedBox(width: 10),
              StatChip(label: t('stat_travelers'), value: '${trips['total_pilgrims'] ?? 0}'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          child: rows.isEmpty
              ? Padding(padding: const EdgeInsets.all(8), child: Text(t('no_data_yet'), style: const TextStyle(color: AppColors.textSecondary)))
              : Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      if (i > 0) const Divider(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${rows[i]['title']}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text('${rows[i]['booked']}/${rows[i]['seats']} ${t('unit_seat')} — ${rows[i]['occupancy']}%', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          Text(_fmtCurrency(rows[i]['revenue']), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _CustomersSection extends StatelessWidget {
  final Map<String, dynamic> customers;
  const _CustomersSection({required this.customers});

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppState>().t;
    final top = (customers['top_customers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: t('reports_section_customers')),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            children: [
              StatChip(label: t('stat_total_customers'), value: '${customers['total_customers'] ?? 0}'),
              const SizedBox(width: 10),
              StatChip(label: t('stat_total_spent'), value: _fmtCurrency(customers['total_spent'])),
              const SizedBox(width: 10),
              StatChip(label: t('stat_returning_customers'), value: '${customers['returning'] ?? 0}'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          child: top.isEmpty
              ? Padding(padding: const EdgeInsets.all(8), child: Text(t('no_data_yet'), style: const TextStyle(color: AppColors.textSecondary)))
              : Column(
                  children: [
                    for (var i = 0; i < top.length; i++) ...[
                      if (i > 0) const Divider(height: 18),
                      InfoRow(
                        leading: InitialsAvatar(initials: '${i + 1}', size: 30),
                        title: '${top[i]['name']}',
                        subtitle: '${top[i]['trips']} ${t('unit_trip_count')}',
                        trailing: Text(_fmtCurrency(top[i]['spent']), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _SupervisorsSection extends StatelessWidget {
  final Map<String, dynamic> supervisors;
  const _SupervisorsSection({required this.supervisors});

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppState>().t;
    final rows = (supervisors['rows'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: t('reports_section_supervisors')),
        AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(height: 18),
                InfoRow(
                  leading: InitialsAvatar(initials: ('${rows[i]['name']}').isNotEmpty ? ('${rows[i]['name']}')[0] : '?', size: 30),
                  title: '${rows[i]['name']}',
                  subtitle: '${rows[i]['trips_count']} ${t('unit_trip_count')} — ${rows[i]['total_pilgrims']} ${t('unit_traveler')}',
                  trailing: (rows[i]['is_active'] == true) ? StatusPill.success(t('status_active')) : StatusPill.danger(t('status_inactive')),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OccupancySection extends StatelessWidget {
  final Map<String, dynamic> occupancy;
  const _OccupancySection({required this.occupancy});

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppState>().t;
    final trips = (occupancy['trips'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final hotels = (occupancy['hotels'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: t('reports_section_occupancy')),
        AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          child: trips.isEmpty
              ? Padding(padding: const EdgeInsets.all(8), child: Text(t('no_data_yet'), style: const TextStyle(color: AppColors.textSecondary)))
              : Column(
                  children: trips.map((tr) {
                    final occ = (tr['occupancy'] as num? ?? 0).toInt();
                    final color = occ > 80 ? AppColors.danger : (occ > 60 ? AppColors.accent : AppColors.success);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text('${tr['title']}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              Text('$occ%', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: color)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(value: occ / 100, minHeight: 6, backgroundColor: AppColors.border, color: color),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        if (hotels.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                for (var i = 0; i < hotels.length; i++) ...[
                  if (i > 0) const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${hotels[i]['name']} ${'★' * ((hotels[i]['stars'] as num?)?.toInt() ?? 0)}',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('${hotels[i]['bookings_count']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
