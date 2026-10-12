import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'arrivals_screen.dart';

/// "التسكين": the buses arriving in the coming days across every company this
/// account houses for — open a bus, put its pilgrims in a hotel, then rooms.
class HotelManagerTrips extends StatelessWidget {
  const HotelManagerTrips({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return ArrivalsList(
      header: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('hm_upcoming_buses'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            Text(t('hm_trips_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
