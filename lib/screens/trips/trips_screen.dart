import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../wizard/trip_wizard_screen.dart';
import 'trip_detail_screen.dart';
import 'bus_assign_screen.dart';
import 'hotel_assign_screen.dart';
import 'supervisor_assign_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String? filterTier; // null = الكل

  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchApiTrips();
  }

  Future<void> _openTierFilter() async {
    final t = context.read<AppState>().t;
    final result = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('tier_filter_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              _tierOption(ctx, null, t('tier_all')),
              _tierOption(ctx, 'economy', t('tier_economy')),
              _tierOption(ctx, 'premium', t('tier_premium')),
              _tierOption(ctx, 'vip', t('tier_vip')),
            ],
          ),
        ),
      ),
    );
    setState(() => filterTier = result);
  }

  Widget _tierOption(BuildContext ctx, String? tier, String label) {
    final selected = filterTier == tier;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.pop(ctx, tier),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.surface,
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final roles = state.currentRoles;
    final trips = state.apiTrips.where((trip) => filterTier == null || trip.type == filterTier).toList();
    final canCreate = roles.contains(UserRole.owner);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().fetchApiTrips(),
        child: state.apiTripsLoading && state.apiTrips.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(t('trips_title'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(onPressed: _openTierFilter, icon: const Icon(Icons.filter_list)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final trip in trips) _TripCard(trip: trip, roles: roles),
                ],
              ),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TripWizardScreen()),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _TripCard extends StatelessWidget {
  final ApiTrip trip;
  final Set<UserRole> roles;
  const _TripCard({required this.trip, required this.roles});

  bool _canSee(List<UserRole> allowed) => allowed.any(roles.contains);

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final active = trip.status == 'active';
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 90,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (trip.thumbnail != null && trip.thumbnail!.isNotEmpty)
                      Image.network(
                        trip.thumbnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _cardHeroGradient(active),
                        loadingBuilder: (context, child, progress) => progress == null ? child : _cardHeroGradient(active),
                      )
                    else
                      _cardHeroGradient(active),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .92),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(active ? t('status_active') : t('status_draft'),
                            style: const TextStyle(fontSize: 10, color: AppColors.primaryDark, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${trip.durationDays} ${t('unit_days')}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(width: 10),
                    Text('${trip.hotelStars} ${t('unit_stars')}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(width: 10),
                    _tierBadge(trip.type, t),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${trip.price.toStringAsFixed(0)} ${trip.currency}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text('${trip.bookingsCount} ${t('bookings_count_suffix')}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                const Divider(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_canSee([UserRole.owner, UserRole.tripManager]))
                      _ActionIcon(
                        icon: Icons.apartment_outlined,
                        label: t('action_assign_hotel'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => HotelAssignScreen(trip: trip)),
                        ),
                      ),
                    if (_canSee([UserRole.owner, UserRole.tripManager, UserRole.departureManager]))
                      _ActionIcon(
                        icon: Icons.directions_bus_outlined,
                        label: t('action_assign_buses'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => BusAssignScreen(trip: trip)),
                        ),
                      ),
                    if (_canSee([UserRole.owner, UserRole.tripManager]))
                      _ActionIcon(
                        icon: Icons.stars_outlined,
                        label: t('action_assign_supervisors'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => SupervisorAssignScreen(trip: trip)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardHeroGradient(bool active) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: active
                ? [AppColors.primary, AppColors.primaryDark]
                : [const Color(0xFF5C655F), const Color(0xFF1B211F)],
          ),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.nightlight_round, color: Colors.white, size: 28),
      );

  Widget _tierBadge(String tier, String Function(String) t) {
    switch (tier) {
      case 'premium':
        return _pill(t('tier_premium'), AppColors.accentLight, AppColors.accent);
      case 'vip':
        return _pill(t('tier_vip'), AppColors.successLight, AppColors.success);
      default:
        return _pill(t('tier_economy'), AppColors.infoLight, AppColors.info);
    }
  }

  Widget _pill(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w500)),
      );
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionIcon({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(11)),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
