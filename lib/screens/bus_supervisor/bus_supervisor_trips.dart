import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'attendance_screen.dart';

class BusSupervisorTrips extends StatefulWidget {
  const BusSupervisorTrips({super.key});

  @override
  State<BusSupervisorTrips> createState() => _BusSupervisorTripsState();
}

class _BusSupervisorTripsState extends State<BusSupervisorTrips> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchApiTrips();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final trips = state.apiTrips.where((tr) => tr.status == 'active').toList();

    return RefreshIndicator(
      onRefresh: () => context.read<AppState>().fetchApiTrips(),
      child: state.apiTripsLoading && state.apiTrips.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.apiTrips.isEmpty && state.apiTripsError != null
          ? ListView(children: [LoadErrorView(message: state.apiTripsError!, onRetry: state.fetchApiTrips)])
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(t('attendance_title'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                Text(t('bs_trips_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                // One row per departure day (next two weeks).
                for (final trip in trips)
                  TripDaysCard(
                    trip: trip,
                    onOpen: (day) => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AttendanceScreen(trip: trip, initialDay: day)),
                    ),
                  ),
              ],
            ),
    );
  }
}
