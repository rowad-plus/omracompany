import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'models/models.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/root_shell.dart';

void main() {
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
            title: 'رواد بلس',
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
              child: child!,
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().restoreSession();
    });
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
