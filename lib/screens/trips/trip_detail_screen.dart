import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../wizard/trip_wizard_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final ApiTrip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late ApiTrip trip = widget.trip;
  bool busy = false;

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
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TripWizardScreen(editingTripId: trip.id)),
              );
              if (!mounted) return;
              final matches = context.read<AppState>().apiTrips.where((t) => t.id == trip.id);
              if (matches.isNotEmpty) setState(() => trip = matches.first);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: isStopped
                    ? [const Color(0xFF5C655F), const Color(0xFF1B211F)]
                    : [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.nightlight_round, color: Colors.white, size: 30),
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
