import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'arrivals_screen.dart';

/// Hotel housing manager's home: greeting, totals and the next buses.
class HotelManagerHome extends StatelessWidget {
  const HotelManagerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    return ArrivalsList(
      limit: 4,
      header: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t('greeting_hello')}، ${state.accountName}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(t('hm_home_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
