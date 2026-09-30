import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class TravelersScreen extends StatefulWidget {
  const TravelersScreen({super.key});

  @override
  State<TravelersScreen> createState() => _TravelersScreenState();
}

class _TravelersScreenState extends State<TravelersScreen> {
  String query = '';

  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final travelers = state.customers;
    final filtered = query.isEmpty ? travelers : travelers.where((c) => c.name.contains(query)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t('travelers_title')),
        foregroundColor: AppColors.text,
        actions: [
          IconButton(
            onPressed: () => showAddTravelerSheet(context),
            icon: const Icon(Icons.person_add_alt_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().fetchCustomers(),
        child: state.customersLoading && travelers.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Text('${travelers.length} ${t('travelers_count_suffix')}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (v) => setState(() => query = v),
                    decoration: InputDecoration(
                      hintText: t('travelers_search_hint'),
                      prefixIcon: const Icon(Icons.search, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(child: Text(t('no_customers_yet'), style: const TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    AppCard(
                      child: Column(
                        children: [
                          for (var i = 0; i < filtered.length; i++) ...[
                            if (i > 0) const Divider(height: 25),
                            InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => showAddTravelerSheet(context, customer: filtered[i]),
                              child: InfoRow(
                                leading: InitialsAvatar(initials: filtered[i].name.isNotEmpty ? filtered[i].name.substring(0, 1) : '؟'),
                                title: filtered[i].name,
                                subtitle:
                                    '${filtered[i].bookingsCount} ${t('travelers_trips_suffix')} · ${filtered[i].totalSpent.toStringAsFixed(0)} ${t('currency_sar')}',
                                trailing: filtered[i].tripTypes.isNotEmpty ? StatusPill.info(filtered[i].tripTypes.first) : null,
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

/// يفتح فورم إضافة معتمر جديد، أو تعديل بيانات معتمر موجود لو اتبعت [customer].
Future<void> showAddTravelerSheet(BuildContext context, {Customer? customer}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _AddTravelerSheet(customer: customer),
  );
}

class _AddTravelerSheet extends StatefulWidget {
  final Customer? customer;
  const _AddTravelerSheet({this.customer});

  @override
  State<_AddTravelerSheet> createState() => _AddTravelerSheetState();
}

class _AddTravelerSheetState extends State<_AddTravelerSheet> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  String countryCode = '+966';
  bool saving = false;
  String? error;

  bool get isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    if (customer != null) {
      nameCtrl.text = customer.name;
      phoneCtrl.text = customer.phone;
      emailCtrl.text = customer.email ?? '';
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
      setState(() => error = context.read<AppState>().t('err_name_phone_required'));
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final state = context.read<AppState>();
    final result = isEdit
        ? await state.updateCustomer(
            id: widget.customer!.id,
            name: nameCtrl.text.trim(),
            phone: phoneCtrl.text.trim(),
            email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
          )
        : await state.createCustomer(
            name: nameCtrl.text.trim(),
            phone: '$countryCode${phoneCtrl.text.trim()}',
            email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
          );
    if (!mounted) return;
    setState(() => saving = false);
    if (result == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEdit ? t('action_edit') : t('add_traveler_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, size: 18)),
                  ],
                ),
                if (error != null) ...[
                  const SizedBox(height: 6),
                  Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                ],
                const SizedBox(height: 14),
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t('field_full_name'))),
                const SizedBox(height: 14),
                if (isEdit)
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: t('field_phone')),
                  )
                else
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: DropdownButtonFormField<String>(
                          value: countryCode,
                          decoration: InputDecoration(labelText: t('login_country_code')),
                          items: const [
                            DropdownMenuItem(value: '+966', child: Text('🇸🇦 +966')),
                            DropdownMenuItem(value: '+20', child: Text('🇪🇬 +20')),
                            DropdownMenuItem(value: '+971', child: Text('🇦🇪 +971')),
                            DropdownMenuItem(value: '+965', child: Text('🇰🇼 +965')),
                          ],
                          onChanged: (v) => setState(() => countryCode = v ?? countryCode),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(labelText: t('field_phone')),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 14),
                TextField(controller: emailCtrl, decoration: InputDecoration(labelText: t('field_email'))),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(t('action_save_traveler')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
