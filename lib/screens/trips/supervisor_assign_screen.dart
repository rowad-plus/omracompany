import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class SupervisorAssignScreen extends StatefulWidget {
  final ApiTrip trip;
  const SupervisorAssignScreen({super.key, required this.trip});

  @override
  State<SupervisorAssignScreen> createState() => _SupervisorAssignScreenState();
}

class _SupervisorAssignScreenState extends State<SupervisorAssignScreen> {
  late Set<int> selectedIds = widget.trip.supervisors.map((s) => s['id'] as int).toSet();
  bool saving = false;

  Future<void> _save() async {
    setState(() => saving = true);
    final result = await context.read<AppState>().assignTripSupervisors(widget.trip.id, selectedIds.toList());
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
      appBar: AppBar(title: Text(t('supervisor_assign_title')), foregroundColor: AppColors.text),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(widget.trip.title, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          if (state.apiEmployeesForAssign.isEmpty)
            Text(t('no_supervisors_yet'), style: const TextStyle(color: AppColors.textSecondary))
          else
            for (final employee in state.apiEmployeesForAssign)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: selectedIds.contains(employee.id),
                title: Text(employee.name),
                onChanged: (v) => setState(() {
                  if (v == true) {
                    selectedIds.add(employee.id);
                  } else {
                    selectedIds.remove(employee.id);
                  }
                }),
              ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saving ? null : _save,
            child: saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(t('action_save_supervisors')),
          ),
        ],
      ),
    );
  }
}
