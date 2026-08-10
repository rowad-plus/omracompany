import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final notifications = state.notifications;
    final hasUnread = state.unreadNotificationsCount > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('profile_notifications')),
        foregroundColor: AppColors.text,
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () => context.read<AppState>().markAllNotificationsRead(),
              child: Text(t('action_mark_all_read')),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().fetchNotifications(),
        child: state.notificationsLoading && notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Text(t('notifications_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  if (notifications.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(t('no_notifications_yet'), style: const TextStyle(color: AppColors.textSecondary)),
                      ),
                    )
                  else
                    AppCard(
                      child: Column(
                        children: [
                          for (var i = 0; i < notifications.length; i++) ...[
                            if (i > 0) const Divider(height: 21),
                            InkWell(
                              onTap: () => context.read<AppState>().markNotificationRead(notifications[i].id),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: NotifRow(
                                      color: notifications[i].kind.color,
                                      text: notifications[i].title + (notifications[i].body != null ? '\n${notifications[i].body}' : ''),
                                      time: notifications[i].timeAgo,
                                    ),
                                  ),
                                  if (!notifications[i].isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(left: 4),
                                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
