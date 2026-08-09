import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'room_assign_screen.dart';

class HotelManagerHome extends StatefulWidget {
  const HotelManagerHome({super.key});

  @override
  State<HotelManagerHome> createState() => _HotelManagerHomeState();
}

class _HotelManagerHomeState extends State<HotelManagerHome> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchApiTrips();
    context.read<AppState>().fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final bookings = state.bookingsList.where((b) => b['status'] != 'cancelled').toList();
    final roomsFormed = bookings.where((b) => b['hotel_id'] != null).length;
    final waiting = bookings.where((b) => b['hotel_id'] == null).length;
    final activeTrips = state.apiTrips.where((tr) => tr.status == 'active').take(2).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await state.fetchApiTrips();
        await state.fetchBookings();
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${t('greeting_hello')}، ${state.accountName}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(t('hm_home_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              children: [
                StatChip(label: t('stat_rooms_formed'), value: '$roomsFormed'),
                const SizedBox(width: 10),
                StatChip(label: t('stat_waiting_housing'), value: '$waiting'),
              ],
            ),
          ),
          SectionHeader(title: t('section_upcoming_trips')),
          if (activeTrips.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(t('no_trips_yet'), style: const TextStyle(color: AppColors.textSecondary)),
            )
          else
            AppCard(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  for (var i = 0; i < activeTrips.length; i++) ...[
                    if (i > 0) const Divider(height: 21, thickness: 1, color: AppColors.border),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InfoRow(
                        leading: const InitialsAvatar(initials: '🌙', size: 32),
                        title: activeTrips[i].title,
                        subtitle: activeTrips[i].hotelName ?? t('no_hotel_assigned'),
                        trailing: const ForwardChevron(),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => RoomAssignScreen(trip: activeTrips[i])),
                        ),
                      ),
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
