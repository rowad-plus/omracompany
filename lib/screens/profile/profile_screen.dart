import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../company/bank_info_screen.dart';
import '../company/branches_screen.dart';
import '../company/company_screen.dart';
import 'account_screen.dart';
import 'change_password_screen.dart';
import 'sessions_screen.dart';
import '../hotels/hotels_screen.dart';
import '../notifications/notifications_screen.dart';
import '../reports/reports_screen.dart';
import '../transport/transport_screen.dart';
import '../travelers/travelers_screen.dart';
import '../users/users_screen.dart';
import '../wallet/tickets_screen.dart';
import '../wallet/wallet_screen.dart';
import '../subscription/subscription_screen.dart';
import '../../widgets/shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final roles = state.currentRoles;
    final primaryRole = state.primaryRole;
    final t = state.t;
    final ownerOrTripManager = roles.contains(UserRole.owner) || roles.contains(UserRole.tripManager);
    final ownerOnly = roles.contains(UserRole.owner);
    final onlyTripManager = roles.contains(UserRole.tripManager) && !roles.contains(UserRole.owner);
    final canManageUsers = ownerOnly || state.permissions.contains('employees.view') || state.permissions.contains('roles.view');
    final displayName = state.accountName.isNotEmpty ? state.accountName : primaryRole.demoName;
    final initials = displayName.trim().isNotEmpty ? displayName.trim().substring(0, 1) : primaryRole.initials;

    void push(Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SizedBox(height: 24),
        // الشعار: المالك يضغط عليه يروح لبيانات الشركة (تغيير الشعار والاسم).
        Center(
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: ownerOnly ? () => push(const CompanyScreen()) : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.primary,
                  foregroundImage: (state.companyLogo ?? '').isNotEmpty ? NetworkImage(state.companyLogo!) : null,
                  child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                ),
                if (ownerOnly)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.bg, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_outlined, size: 13, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => push(const AccountScreen()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(displayName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ),
        if ((state.companyName ?? '').isNotEmpty)
          Center(child: Text(state.companyName!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        Center(
          child: Text(
            UserRole.values.where(roles.contains).map((r) => t('role_${r.name}_title')).join(' · '),
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        _menuItem(context, Icons.people_outline, t('profile_travelers'), () => push(const TravelersScreen())),
        if (ownerOrTripManager) _menuItem(context, Icons.apartment_outlined, t('profile_hotels'), () => push(const HotelsScreen())),
        if (ownerOrTripManager) _menuItem(context, Icons.directions_bus_outlined, t('profile_transport'), () => push(const TransportScreen())),
        if (ownerOrTripManager)
          _menuItem(context, Icons.bar_chart_outlined, onlyTripManager ? t('profile_my_reports') : t('profile_reports'),
              () => push(const ReportsScreen())),
        if (canManageUsers) _menuItem(context, Icons.manage_accounts_outlined, t('profile_users'), () => push(const UsersScreen())),
        if (ownerOnly) _menuItem(context, Icons.business_outlined, t('profile_company'), () => push(const CompanyScreen())),
        if (ownerOnly)
          SubscriptionMenuEntry(
            builder: (featured) => _menuItem(context, Icons.workspace_premium_outlined,
                featured ? '${t('sub_title')} ★' : t('sub_title'), () => push(const SubscriptionScreen())),
          ),
        if (ownerOnly) _menuItem(context, Icons.account_balance_wallet_outlined, t('profile_wallet'), () => push(const WalletScreen())),
        if (ownerOnly) _menuItem(context, Icons.support_agent_outlined, t('tickets_title'), () => push(const TicketsScreen())),
        if (ownerOnly) _menuItem(context, Icons.account_balance_outlined, t('profile_bank_info'), () => push(const BankInfoScreen())),
        if (ownerOnly) _menuItem(context, Icons.store_outlined, t('profile_branches'), () => push(const BranchesScreen())),
        _menuItem(context, Icons.notifications_outlined, t('profile_notifications'), () => push(const NotificationsScreen())),
        _menuItem(context, Icons.badge_outlined, t('profile_my_account'), () => push(const AccountScreen())),
        _menuItem(context, Icons.lock_outline, t('profile_change_password'), () => push(const ChangePasswordScreen())),
        _menuItem(context, Icons.devices_outlined, t('profile_sessions'), () => push(const SessionsScreen())),
        _menuItem(context, Icons.language_outlined, t('profile_language'), () => _showLanguageSheet(context, state)),
        _menuItem(context, Icons.logout, t('profile_logout'), onLogout, danger: true),
      ],
    );
  }

  void _showLanguageSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Text(state.t('language_sheet_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                for (final lang in AppLanguage.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        state.setLanguage(lang);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: state.language == lang ? AppColors.primaryLight : AppColors.surface,
                          border: Border.all(color: state.language == lang ? AppColors.primary : AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(lang.flag, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(lang.nativeName, style: const TextStyle(fontWeight: FontWeight.w500))),
                            if (state.language == lang) const Icon(Icons.check, color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool danger = false}) {
    final color = danger ? AppColors.danger : AppColors.text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                Icon(icon, size: 19, color: danger ? AppColors.danger : AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: TextStyle(fontSize: 13.5, color: color))),
                if (!danger) const ForwardChevron(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
