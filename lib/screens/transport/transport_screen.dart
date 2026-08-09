import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchBusCompanies();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final companies = state.busCompanies;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('profile_transport')),
        foregroundColor: AppColors.text,
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => v == 'company' ? _showAddCompanySheet(context) : _showAddBusSheet(context),
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'company', child: Text(t('add_bus_company_title'))),
              if (companies.isNotEmpty) PopupMenuItem(value: 'bus', child: Text(t('add_bus_title'))),
            ],
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().fetchBusCompanies(),
        child: state.busCompaniesLoading && companies.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Text(t('transport_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  if (companies.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(child: Text(t('no_buses_yet'), style: const TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    for (final company in companies)
                      AppCard(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(company.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            if (company.contact.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(company.contact, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                              ),
                            const SizedBox(height: 8),
                            for (var i = 0; i < company.buses.length; i++) ...[
                              if (i > 0) const Divider(height: 21),
                              InfoRow(
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primaryLight,
                                  child: const Icon(Icons.directions_bus_outlined, size: 17, color: AppColors.primaryDark),
                                ),
                                title: company.buses[i].busNumber,
                                subtitle: '${company.buses[i].capacity ?? 0} ${t('unit_passenger')} — ${company.buses[i].driverName.isEmpty ? t('transport_no_driver') : company.buses[i].driverName}',
                                trailing: StatusPill.success(t('transport_available')),
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

void _showAddCompanySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => const _AddCompanySheet(),
  );
}

class _AddCompanySheet extends StatefulWidget {
  const _AddCompanySheet();

  @override
  State<_AddCompanySheet> createState() => _AddCompanySheetState();
}

class _AddCompanySheetState extends State<_AddCompanySheet> {
  final nameCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  bool saving = false;
  String? error;

  @override
  void dispose() {
    nameCtrl.dispose();
    contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameCtrl.text.trim().isEmpty) return;
    setState(() {
      saving = true;
      error = null;
    });
    final result = await context
        .read<AppState>()
        .createBusCompany(name: nameCtrl.text.trim(), contact: contactCtrl.text.trim().isEmpty ? null : contactCtrl.text.trim());
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t('add_bus_company_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ],
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t('field_name_or_plate'))),
              const SizedBox(height: 14),
              TextField(controller: contactCtrl, decoration: InputDecoration(labelText: t('field_contact_number'))),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(t('action_save_generic')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showAddBusSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => const _AddBusSheet(),
  );
}

class _AddBusSheet extends StatefulWidget {
  const _AddBusSheet();

  @override
  State<_AddBusSheet> createState() => _AddBusSheetState();
}

class _AddBusSheetState extends State<_AddBusSheet> {
  final numberCtrl = TextEditingController();
  final driverCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();
  int? companyId;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final companies = context.read<AppState>().busCompanies;
    if (companies.isNotEmpty) companyId = companies.first.id;
  }

  @override
  void dispose() {
    numberCtrl.dispose();
    driverCtrl.dispose();
    capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (numberCtrl.text.trim().isEmpty || companyId == null) return;
    setState(() {
      saving = true;
      error = null;
    });
    final result = await context.read<AppState>().createBus(
          busCompanyId: companyId!,
          busNumber: numberCtrl.text.trim(),
          capacity: int.tryParse(capacityCtrl.text.trim()),
          driverName: driverCtrl.text.trim().isEmpty ? null : driverCtrl.text.trim(),
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
    final state = context.watch<AppState>();
    final t = state.t;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t('add_bus_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: companyId,
                decoration: InputDecoration(labelText: t('field_bus_company')),
                items: state.busCompanies.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => companyId = v),
              ),
              const SizedBox(height: 14),
              TextField(controller: numberCtrl, decoration: InputDecoration(labelText: t('field_name_or_plate'))),
              const SizedBox(height: 14),
              TextField(controller: driverCtrl, decoration: InputDecoration(labelText: t('field_driver'))),
              const SizedBox(height: 14),
              TextField(
                controller: capacityCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t('field_capacity')),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(t('action_save_generic')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
