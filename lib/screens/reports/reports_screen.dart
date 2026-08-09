import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final roles = state.currentRoles;
    final onlyTripManager = roles.contains(UserRole.tripManager) && !roles.contains(UserRole.owner);
    final data = state.dashboardData;
    final kpis = data?['kpis'] as Map<String, dynamic>?;
    final perfStats = (data?['perfStats'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final occupancy = perfStats.isNotEmpty ? perfStats.first['val'] as String? ?? '—' : '—';

    return Scaffold(
      appBar: AppBar(
        title: Text(onlyTripManager ? t('profile_my_reports') : t('profile_reports')),
        foregroundColor: AppColors.text,
      ),
      body: state.dashboardLoading && data == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(t('reports_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 14),
                SizedBox(
                  height: 92,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      StatChip(label: t('stat_total_revenue'), value: '${((kpis?['total_revenue'] as num?) ?? 0).round()}'),
                      const SizedBox(width: 10),
                      StatChip(label: t('stat_occupancy_rate'), value: occupancy),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (perfStats.isNotEmpty)
                  AppCard(
                    child: Column(
                      children: [
                        for (var i = 0; i < perfStats.length; i++) ...[
                          if (i > 0) const Divider(height: 21),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(perfStats[i]['label'] as String? ?? '', style: const TextStyle(fontSize: 13)),
                              Text('${perfStats[i]['val']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
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
