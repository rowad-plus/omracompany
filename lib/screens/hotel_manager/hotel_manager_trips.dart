import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'room_assign_screen.dart';

class HotelManagerTrips extends StatefulWidget {
  const HotelManagerTrips({super.key});

  @override
  State<HotelManagerTrips> createState() => _HotelManagerTripsState();
}

class _HotelManagerTripsState extends State<HotelManagerTrips> {
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
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(t('section_upcoming_trips'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                Text(t('hm_trips_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                for (final trip in trips)
                  AppCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => RoomAssignScreen(trip: trip)),
                      ),
                      child: InfoRow(
                        leading: const InitialsAvatar(initials: '🌙', size: 32),
                        title: trip.title,
                        subtitle: trip.hotelName != null
                            ? '${trip.hotelName} · ${trip.bookingsCount} ${t('unit_seat')}'
                            : t('no_hotel_assigned'),
                        trailing: const ForwardChevron(),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
