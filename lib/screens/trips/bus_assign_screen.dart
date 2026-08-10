import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

/// شاشة تسكين الباصات على مستوى البرنامج (أي الباصات المخصصة لخدمة هذه
/// الرحلة). تسكين المعتمرين أنفسهم في باص معيّن يتم لكل حجز على حدة من
/// شاشة الحجوزات/الحضور والغياب.
class BusAssignScreen extends StatefulWidget {
  final ApiTrip trip;
  const BusAssignScreen({super.key, required this.trip});

  @override
  State<BusAssignScreen> createState() => _BusAssignScreenState();
}

class _BusAssignScreenState extends State<BusAssignScreen> {
  late Set<int> selectedBusIds =
      widget.trip.buses.map((b) => b['id'] as int).toSet();
  bool saving = false;

  Future<void> _save() async {
    setState(() => saving = true);
    final result = await context.read<AppState>().assignTripBuses(widget.trip.id, selectedBusIds.toList());
    if (!mounted) return;
    setState(() => saving = false);
    if (result == null) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    return Scaffold(
      appBar: AppBar(title: Text(t('bus_assign_title')), foregroundColor: AppColors.text),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(widget.trip.title, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          Text(t('bus_assign_buses_label'), style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          if (state.apiBuses.isEmpty)
            Text(t('no_buses_yet'), style: const TextStyle(color: AppColors.textSecondary))
          else
            for (final bus in state.apiBuses)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: selectedBusIds.contains(bus.id),
                    title: Text(bus.company.isEmpty ? bus.number : '${bus.number} — ${bus.company}',
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5)),
                    subtitle: Text('${bus.capacity} ${t('unit_passenger')}', style: const TextStyle(fontSize: 11.5)),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        selectedBusIds.add(bus.id);
                      } else {
                        selectedBusIds.remove(bus.id);
                      }
                    }),
                  ),
                ),
              ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saving ? null : _save,
            child: saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(t('action_save')),
          ),
        ],
      ),
    );
  }
}
