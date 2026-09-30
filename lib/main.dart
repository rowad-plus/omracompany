import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'models/models.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'theme/system_bars.dart';
import 'screens/auth/login_screen.dart';
import 'screens/root_shell.dart';
import 'screens/notifications/notifications_screen.dart';
import 'services/live_updates.dart';
import 'services/push_service.dart';

/// مفتاح الـ Navigator عشان نفتح شاشة الإشعارات لما المستخدم يدوس على
/// إشعار وصل للهاتف (من خارج شجرة الـ widgets).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushService.instance.init();
  LiveUpdates.instance.start();
  runApp(const RowadPlusApp());
}

class RowadPlusApp extends StatelessWidget {
  const RowadPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, state, _) {
          final lang = state.language;
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Omraway Business',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: Locale(lang.localeCode),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
              Locale('tr'),
              Locale('ur'),
            ],
            builder: (context, child) => Directionality(
              textDirection: lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: safeAppFrame(child!),
            ),
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

/// يقرر يعرض شاشة تحميل، تسجيل الدخول، أو الـ Shell الرئيسي — حسب وجود
/// جلسة محفوظة (توكن) من قبل.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<Map<String, dynamic>>? _pushTapSub;

  @override
  void initState() {
    super.initState();
    _pushTapSub = PushService.instance.onTap.listen((_) => _openNotifications());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AppState>().restoreSession();
      if (PushService.instance.pendingLaunchTap != null) {
        PushService.instance.pendingLaunchTap = null;
        _openNotifications();
      }
    });
  }

  @override
  void dispose() {
    _pushTapSub?.cancel();
    super.dispose();
  }

  /// أي إشعار (حجز جديد، إلغاء، دفع، تسكين...) بيفتح شاشة الإشعارات.
  void _openNotifications() {
    final state = context.read<AppState>();
    if (!state.isLoggedIn) return;
    navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
    state.fetchUnreadNotificationsCount();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.sessionLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!state.isLoggedIn) {
      return LoginScreen(onLoggedIn: () => setState(() {}));
    }
    return RootShell(onLogout: () async {
      await context.read<AppState>().logout();
      setState(() {});
    });
  }
}
