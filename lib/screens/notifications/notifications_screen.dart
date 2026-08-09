import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final notifications = state.notifications;
    return Scaffold(
      appBar: AppBar(
        title: Text(t('profile_notifications')),
        foregroundColor: AppColors.text,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(t('notifications_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < notifications.length; i++) ...[
                  if (i > 0) const Divider(height: 21),
                  NotifRow(color: notifications[i].kind.color, text: notifications[i].title, time: t(notifications[i].timeAgo)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
