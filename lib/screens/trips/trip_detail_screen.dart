import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/departure_point_sheet.dart';
import '../../widgets/shared_widgets.dart';
import '../dashboard/bookings_screen.dart';
import '../wizard/trip_wizard_screen.dart';
import 'bus_assign_screen.dart';
import 'hotel_assign_screen.dart';
import 'trip_program_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final ApiTrip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late ApiTrip trip = widget.trip;
  bool busy = false;
  Map<String, dynamic>? editData;
  Map<String, dynamic>? activitiesData;
  bool programLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgram();
  }

  Future<void> _loadProgram() async {
    setState(() => programLoading = true);
    final state = context.read<AppState>();
    final results = await Future.wait([state.fetchTripEditData(trip.id), state.fetchTripActivities(trip.id)]);
    if (!mounted) return;
    setState(() {
      editData = results[0] ?? editData;
      activitiesData = results[1] ?? activitiesData;
      programLoading = false;
    });
  }

  void _refreshTripFromState() {
    final matches = context.read<AppState>().apiTrips.where((t) => t.id == trip.id);
    if (matches.isNotEmpty) setState(() => trip = matches.first);
  }

  Future<void> _push(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) _refreshTripFromState();
  }

  Future<void> _editProgram() async {
    await _push(TripWizardScreen(editingTripId: trip.id, initialStep: 3));
    if (mounted) _loadProgram();
  }

  Future<void> _toggleStopped(String Function(String) t) async {
    setState(() => busy = true);
    final result = await context.read<AppState>().toggleApiTrip(trip.id);
    if (!mounted) return;
    setState(() => busy = false);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      return;
    }
    final matches = context.read<AppState>().apiTrips.where((t) => t.id == trip.id);
    if (matches.isNotEmpty) setState(() => trip = matches.first);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(trip.status == 'active' ? t('trip_resumed_snackbar') : t('trip_stopped_snackbar'))),
    );
  }

  Future<void> _deleteTrip(String Function(String) t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('confirm_delete_trip_title')),
        content: Text(t('confirm_delete_trip_message')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('action_cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('action_delete_trip'), style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => busy = true);
    final result = await context.read<AppState>().deleteApiTrip(trip.id);
    if (!mounted) return;
    setState(() => busy = false);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('trip_deleted_snackbar'))));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final isStopped = trip.status != 'active';
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await _push(TripWizardScreen(editingTripId: trip.id));
              if (mounted) _loadProgram();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: (trip.thumbnail != null && trip.thumbnail!.isNotEmpty)
                ? Image.network(
                    trip.thumbnail!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _heroPlaceholder(isStopped),
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : SizedBox(height: 160, child: _heroPlaceholder(isStopped)),
                  )
                : _heroPlaceholder(isStopped),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _push(TripBookingsScreen(trip: trip)),
              icon: const Icon(Icons.groups_outlined, size: 20),
              label: Text('${t('trip_pilgrims')} (${trip.bookingsCount})'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TripProgramBanner(
            data: editData,
            activitiesData: activitiesData,
            loading: programLoading,
            onOpen: () async {
              if (editData == null) return;
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TripProgramScreen(
                  tripId: trip.id,
                  title: trip.title,
                  data: editData!,
                  onEditText: _editProgram,
                ),
              ));
              if (mounted) _loadProgram();
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AssignButton(
                  icon: Icons.apartment_outlined,
                  label: t('action_assign_hotel'),
                  value: trip.hotelName,
                  onTap: () => _push(HotelAssignScreen(trip: trip)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AssignButton(
                  icon: Icons.directions_bus_outlined,
                  label: t('action_assign_buses'),
                  value: trip.buses.isEmpty ? null : '${trip.buses.length} ${t('unit_bus')}',
                  onTap: () => _push(BusAssignScreen(trip: trip)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 24,
              runSpacing: 14,
              children: [
                _fact(t('fact_duration'), '${trip.durationDays} ${t('unit_days')}'),
                _fact(t('fact_price_per_person'), '${trip.price.toStringAsFixed(0)} ${trip.currency}'),
                _fact(t('fact_seats'), '${trip.bookingsCount} / ${trip.totalSeats}'),
                _fact(t('fact_hotel_mecca'), trip.hotelName ?? '—'),
                _fact(t('fact_hotel_medina'), trip.hotelNameMadinah ?? '—'),
                _fact(t('fact_trip_date'), trip.nextDate?.split('T').first ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DetailActionIcon(
                        icon: isStopped ? Icons.play_circle_outline : Icons.pause_circle_outline,
                        label: t(isStopped ? 'action_continue_trip' : 'action_stop_trip'),
                        onTap: () => _toggleStopped(t),
                      ),
                      _DetailActionIcon(
                        icon: Icons.delete_outline,
                        label: t('action_delete_trip'),
                        onTap: () => _deleteTrip(t),
                        color: AppColors.danger,
                      ),
                      _DetailActionIcon(
                        icon: Icons.location_on_outlined,
                        label: t('action_departure_point'),
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.surface,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                          builder: (ctx) => DeparturePointSheet(trip: trip),
                        ),
                      ),
                    ],
                  ),
          ),
          if (trip.buses.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(t('bus_assign_buses_label'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            AppCard(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: trip.buses.map((b) => StatusPill.info(b['label'] as String? ?? '')).toList(),
              ),
            ),
          ],
          if (trip.supervisors.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(t('supervisor_assign_title'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            AppCard(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: trip.supervisors.map((s) => StatusPill.info(s['label'] as String? ?? '')).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroPlaceholder(bool isStopped) => Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isStopped
                ? [const Color(0xFF5C655F), const Color(0xFF1B211F)]
                : [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.nightlight_round, color: Colors.white, size: 30),
      );

  Widget _fact(String label, String value) => SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

class _DetailActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _DetailActionIcon({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.primaryDark;
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
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withValues(alpha: .12),
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: tint),
            ),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _AssignButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  const _AssignButton({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 19, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      value ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
