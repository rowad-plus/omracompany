import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'dashboard/home_dashboard.dart';
import 'dashboard/bookings_screen.dart';
import 'trips/trips_screen.dart';
import 'hotel_manager/hotel_manager_home.dart';
import 'hotel_manager/hotel_manager_trips.dart';
import 'bus_supervisor/bus_supervisor_home.dart';
import 'bus_supervisor/bus_supervisor_trips.dart';
import 'profile/profile_screen.dart';
import 'company/bank_info_screen.dart';

/// الحاوية الرئيسية بعد تسجيل الدخول — تبني شريط تنقل مختلف حسب دور المستخدم،
/// بنفس منطق goHome()/goToProgramsTab() من نسخة الويب.
class RootShell extends StatefulWidget {
  final VoidCallback onLogout;
  const RootShell({super.key, required this.onLogout});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int index = 0;
  Set<UserRole>? lastRoles;

  /// كل دور بيدّي تبويبات "بيت/برامج" خاصة بيه. لو المستخدم عنده دور واحد بس
  /// من (فندق/باص) بياخد تبويبين (رئيسية + برامج) زي أي دور مستقل. لو عنده
  /// دور تاني أساسي أو أكتر من تخصص تشغيلي في نفس الوقت، كل تخصص إضافي بياخد
  /// تبويب واحد بس (شاشة "البرامج" الأشمل) بدل التكرار مع شاشة "الرئيسية".
  List<_Tab> _tabsFor(Set<UserRole> roles, AppState state) {
    final tabs = <_Tab>[];

    if (roles.contains(UserRole.owner) || roles.contains(UserRole.tripManager)) {
      tabs.add(_Tab(state.t('nav_home'), Icons.grid_view_rounded, const HomeDashboard()));
      tabs.add(_Tab(state.t('nav_bookings'), Icons.event_note_outlined, const BookingsScreen()));
      tabs.add(_Tab(state.t('nav_trips'), Icons.nights_stay_outlined, const TripsScreen()));
    } else if (roles.contains(UserRole.departureManager)) {
      tabs.add(_Tab(state.t('nav_trips'), Icons.nights_stay_outlined, const TripsScreen()));
    }

    if (roles.contains(UserRole.hotelManager)) {
      if (tabs.isEmpty) {
        tabs.add(_Tab(state.t('nav_home'), Icons.grid_view_rounded, const HotelManagerHome()));
        tabs.add(_Tab(state.t('nav_trips'), Icons.nights_stay_outlined, const HotelManagerTrips()));
      } else {
        tabs.add(_Tab(state.t('nav_hotel_trips'), Icons.apartment_outlined, const HotelManagerTrips()));
      }
    }

    if (roles.contains(UserRole.busSupervisor)) {
      if (tabs.isEmpty) {
        tabs.add(_Tab(state.t('nav_home'), Icons.grid_view_rounded, const BusSupervisorHome()));
        tabs.add(_Tab(state.t('nav_trips'), Icons.nights_stay_outlined, const BusSupervisorTrips()));
      } else {
        tabs.add(_Tab(state.t('nav_bus_trips'), Icons.directions_bus_outlined, const BusSupervisorTrips()));
      }
    }

    tabs.add(_Tab(state.t('nav_account'), Icons.person_outline, ProfileScreen(onLogout: widget.onLogout)));
    return tabs;
  }

  bool _ibanPromptOpen = false;

  /// مالك الشركة لازم يكون مدخل IBAN صحيح عشان نقدر نحوّل له مستحقاته —
  /// لو مش موجود (أو غلط) بتظهر نافذة ما تتقفلش إلا بالذهاب لصفحة الحساب
  /// البنكي، وبتظهر تاني لو رجع من غير ما يحفظ IBAN صحيح.
  Future<void> _requireIban() async {
    if (_ibanPromptOpen || !mounted) return;
    final state = context.read<AppState>();
    if (!state.currentRoles.contains(UserRole.owner)) return;
    try {
      await state.fetchBankInfo();
    } catch (_) {
      return; // شبكة/سيرفر — ما نقفلش التطبيق على المستخدم بسبب خطأ اتصال.
    }
    if (!mounted || state.bankInfo == null || state.bankInfo!.hasValidIban) return;

    _ibanPromptOpen = true;
    final t = state.t;
    final hasSomething = (state.bankInfo!.bankIban ?? '').trim().isNotEmpty;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          icon: const Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 36),
          title: Text(t('iban_required_title'), textAlign: TextAlign.center),
          content: Text(t(hasSomething ? 'iban_invalid_body' : 'iban_required_body'), textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              onPressed: () => Navigator.of(ctx).pop(),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(t('iban_required_action')),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BankInfoScreen(fromPrompt: true)));
    _ibanPromptOpen = false;
    if (!mounted) return;
    final b = context.read<AppState>().bankInfo;
    if (b == null || !b.hasValidIban) _requireIban();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final roles = state.currentRoles;
    if (!setEquals(lastRoles, roles)) {
      // رجّع لأول تبويب لما تتغيّر الأدوار (بعد تسجيل الدخول من جديد).
      lastRoles = roles;
      index = 0;
      if (roles.contains(UserRole.owner)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _requireIban());
      }
    }
    final tabs = _tabsFor(roles, state);
    final safeIndex = index.clamp(0, tabs.length - 1);

    return Scaffold(
      // IndexedStack instead of swapping the child directly — keeps every
      // tab's screen mounted (and its already-fetched data) across
      // switches, instead of tearing down and re-fetching from scratch
      // each time the user comes back to a tab.
      body: SafeArea(
        child: IndexedStack(
          index: safeIndex,
          children: [for (final tab in tabs) tab.screen],
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryLight,
          labelTextStyle: MaterialStateProperty.resolveWith((states) => TextStyle(
                fontSize: 10.5,
                color: states.contains(MaterialState.selected) ? AppColors.primary : AppColors.textMuted,
              )),
          iconTheme: MaterialStateProperty.resolveWith((states) => IconThemeData(
                color: states.contains(MaterialState.selected) ? AppColors.primary : AppColors.textMuted,
              )),
        ),
        child: NavigationBar(
          height: 66,
          selectedIndex: safeIndex,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: tabs
              .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label))
              .toList(),
        ),
      ),
    );
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final Widget screen;
  const _Tab(this.label, this.icon, this.screen);
}
