import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  bool busy = false;

  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchAccountSessions();
  }

  String _fmt(DateTime d) => '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _revoke(int id) async {
    setState(() => busy = true);
    final result = await context.read<AppState>().revokeSession(id);
    if (!mounted) return;
    setState(() => busy = false);
    if (result != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  Future<void> _revokeAll() async {
    setState(() => busy = true);
    final result = await context.read<AppState>().revokeOtherSessions();
    if (!mounted) return;
    setState(() => busy = false);
    if (result != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final sessions = state.accountSessions;
    final hasOthers = sessions.any((s) => !s.isCurrent);

    return Scaffold(
      appBar: AppBar(title: Text(t('profile_sessions')), foregroundColor: AppColors.text),
      body: state.sessionsLoading && sessions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(t('sessions_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < sessions.length; i++) ...[
                        if (i > 0) const Divider(height: 25),
                        Row(
                          children: [
                            Icon(Icons.devices_outlined, size: 22, color: sessions[i].isCurrent ? AppColors.primary : AppColors.textMuted),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(sessions[i].name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
                                      if (sessions[i].isCurrent) ...[
                                        const SizedBox(width: 6),
                                        StatusPill.success(t('sessions_current_label')),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    sessions[i].lastUsedAt != null
                                        ? '${t('sessions_last_used')} ${_fmt(sessions[i].lastUsedAt!)}'
                                        : '${t('sessions_created_at')} ${_fmt(sessions[i].createdAt)}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            if (!sessions[i].isCurrent)
                              IconButton(
                                icon: const Icon(Icons.logout, size: 18, color: AppColors.danger),
                                onPressed: busy ? null : () => _revoke(sessions[i].id),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasOthers) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: busy ? null : _revokeAll,
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                    child: Text(t('action_revoke_all_sessions')),
                  ),
                ],
              ],
            ),
    );
  }
}
