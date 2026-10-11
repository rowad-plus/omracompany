import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

/// شاشة تسجيل الحضور والغياب لمعتمري رحلة معيّنة — تعمل على الحجوزات
/// الفعلية لهذه الرحلة (Backend حقيقي).
class AttendanceScreen extends StatefulWidget {
  final ApiTrip trip;
  const AttendanceScreen({super.key, required this.trip});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String query = '';

  /// Chosen departure day (Y-m-d): attendance is per day's bus, not the
  /// whole trip's history.
  String? day;

  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final allTrip = state.bookingsList.where((b) => b['trip_id'] == widget.trip.id && b['status'] != 'cancelled').toList();
    final days = departureDaysOf(allTrip);
    final currentDay = days.contains(day) ? day : defaultDepartureDay(days);
    final dayCounts = {for (final d in days) d: allTrip.where((b) => b['departure_date'] == d).length};
    bool matches(Map<String, dynamic> b) {
      if (query.isEmpty) return true;
      final phone = (b['customer_phone'] ?? (b['user'] as Map<String, dynamic>?)?['phone'] ?? '') as String;
      return bookingName(b).contains(query) || (b['ref'] as String? ?? '').contains(query) || phone.contains(query);
    }
    final bookings = allTrip
        .where((b) => days.length <= 1 || b['departure_date'] == currentDay)
        .where(matches)
        .toList();
    final present = bookings.where((b) => b['attendance_status'] == 'present').length;
    final absent = bookings.where((b) => b['attendance_status'] == 'absent').length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.trip.title), foregroundColor: AppColors.text),
      body: state.bookingsLoading && state.bookingsData == null
          ? const Center(child: CircularProgressIndicator())
          : state.bookingsData == null && state.bookingsError != null
          ? LoadErrorView(message: state.bookingsError!, onRetry: () => context.read<AppState>().fetchBookings())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                if (days.length > 1) ...[
                  DepartureDayBar(days: days, selected: currentDay, counts: dayCounts, onSelect: (d) => setState(() => day = d)),
                  const SizedBox(height: 14),
                ],
                SizedBox(
                  height: 84,
                  child: Row(
                    children: [
                      Expanded(child: StatChip(label: t('attendance_present'), value: '$present', valueColor: AppColors.success)),
                      const SizedBox(width: 10),
                      Expanded(child: StatChip(label: t('attendance_absent'), value: '$absent', valueColor: AppColors.danger)),
                      const SizedBox(width: 10),
                      Expanded(child: StatChip(label: t('attendance_total'), value: '${bookings.length}')),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  decoration: InputDecoration(hintText: t('search_traveler_by_name'), prefixIcon: const Icon(Icons.search, size: 20)),
                  onChanged: (v) => setState(() => query = v),
                ),
                const SizedBox(height: 14),
                for (final b in bookings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        InitialsAvatar(initials: nameInitial(bookingName(b))),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bookingName(b), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
                              Text(bookingDetails(b, t('unit_seat')),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        if (((b['customer_phone'] ?? '') as String).isNotEmpty)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: b['customer_phone'] as String,
                            icon: const Icon(Icons.call_outlined, size: 18, color: AppColors.primary),
                            onPressed: () => launchUrl(Uri.parse('tel:${b['customer_phone']}')),
                          ),
                        _AttendanceToggle(
                          status: b['attendance_status'] as String? ?? 'pending',
                          presentLabel: t('attendance_present'),
                          absentLabel: t('attendance_absent'),
                          onSet: (s) => context.read<AppState>().markAttendance(b['id'] as int, s),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _AttendanceToggle extends StatelessWidget {
  final String status;
  final String presentLabel;
  final String absentLabel;
  final ValueChanged<String> onSet;
  const _AttendanceToggle({required this.status, required this.presentLabel, required this.absentLabel, required this.onSet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(presentLabel, Icons.check, 'present', AppColors.success),
          _segment(absentLabel, Icons.close, 'absent', AppColors.danger),
        ],
      ),
    );
  }

  Widget _segment(String label, IconData icon, String s, Color color) {
    final active = status == s;
    return InkWell(
      onTap: () => onSet(active ? 'pending' : s),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: active ? color : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, size: 14, color: active ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
