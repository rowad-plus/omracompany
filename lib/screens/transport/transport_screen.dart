import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
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
    final unassigned = state.unassignedBuses;
    final isEmpty = companies.isEmpty && unassigned.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('profile_transport')),
        foregroundColor: AppColors.text,
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => v == 'company' ? _showAddCompanySheet(context) : _showAddBusSheet(context, bus: null),
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'bus', child: Text(t('add_bus_title'))),
              PopupMenuItem(value: 'company', child: Text(t('add_bus_company_title'))),
            ],
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().fetchBusCompanies(),
        child: state.busCompaniesLoading && isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Text(t('transport_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  if (isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(child: Text(t('no_buses_yet'), style: const TextStyle(color: AppColors.textSecondary))),
                    )
                  else ...[
                    if (unassigned.isNotEmpty)
                      AppCard(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < unassigned.length; i++) ...[
                              if (i > 0) const Divider(height: 21),
                              InkWell(
                                onTap: () => _showAddBusSheet(context, bus: unassigned[i]),
                                child: _BusRow(bus: unassigned[i], t: t),
                              ),
                            ],
                          ],
                        ),
                      ),
                    for (final company in companies)
                      AppCard(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => _showAddCompanySheet(context, company: company),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(company.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                        if (company.contact.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Text(company.contact,
                                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.edit_outlined, size: 16, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (var i = 0; i < company.buses.length; i++) ...[
                              if (i > 0) const Divider(height: 21),
                              InkWell(
                                onTap: () => _showAddBusSheet(context, bus: company.buses[i]),
                                child: _BusRow(bus: company.buses[i], t: t),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _BusRow extends StatelessWidget {
  final CompanyBus bus;
  final String Function(String) t;
  const _BusRow({required this.bus, required this.t});

  @override
  Widget build(BuildContext context) {
    return InfoRow(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primaryLight,
        child: const Icon(Icons.directions_bus_outlined, size: 17, color: AppColors.primaryDark),
      ),
      title: bus.busNumber,
      subtitle: '${bus.capacity ?? 0} ${t('unit_passenger')} — ${bus.driverName.isEmpty ? t('transport_no_driver') : bus.driverName}',
      trailing: StatusPill.success(t('transport_available')),
    );
  }
}

void _showAddCompanySheet(BuildContext context, {CompanyBusCompany? company}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _AddCompanySheet(company: company),
  );
}

class _AddCompanySheet extends StatefulWidget {
  final CompanyBusCompany? company;
  const _AddCompanySheet({this.company});

  @override
  State<_AddCompanySheet> createState() => _AddCompanySheetState();
}

class _AddCompanySheetState extends State<_AddCompanySheet> {
  final nameCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  bool saving = false;
  String? error;

  bool get isEdit => widget.company != null;

  @override
  void initState() {
    super.initState();
    final company = widget.company;
    if (company != null) {
      nameCtrl.text = company.name;
      contactCtrl.text = company.contact;
    }
  }

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
    final state = context.read<AppState>();
    final result = isEdit
        ? await state.updateBusCompany(
            id: widget.company!.id,
            name: nameCtrl.text.trim(),
            contact: contactCtrl.text.trim().isEmpty ? null : contactCtrl.text.trim(),
          )
        : await state.createBusCompany(
            name: nameCtrl.text.trim(), contact: contactCtrl.text.trim().isEmpty ? null : contactCtrl.text.trim());
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
              Text(isEdit ? t('action_edit') : t('add_bus_company_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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

void _showAddBusSheet(BuildContext context, {CompanyBus? bus}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _AddBusSheet(bus: bus),
  );
}

class _AddBusSheet extends StatefulWidget {
  final CompanyBus? bus;
  const _AddBusSheet({this.bus});

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

  bool get isEdit => widget.bus != null;

  @override
  void initState() {
    super.initState();
    final bus = widget.bus;
    if (bus != null) {
      numberCtrl.text = bus.busNumber;
      driverCtrl.text = bus.driverName;
      if (bus.capacity != null) capacityCtrl.text = '${bus.capacity}';
      companyId = bus.busCompanyId;
    }
  }

  @override
  void dispose() {
    numberCtrl.dispose();
    driverCtrl.dispose();
    capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (numberCtrl.text.trim().isEmpty) return;
    setState(() {
      saving = true;
      error = null;
    });
    final state = context.read<AppState>();
    final result = isEdit
        ? await state.updateBus(
            id: widget.bus!.id,
            busCompanyId: companyId,
            busNumber: numberCtrl.text.trim(),
            capacity: int.tryParse(capacityCtrl.text.trim()),
            driverName: driverCtrl.text.trim().isEmpty ? null : driverCtrl.text.trim(),
          )
        : await state.createBus(
            busCompanyId: companyId,
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
              Text(isEdit ? t('action_edit') : t('add_bus_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ],
              const SizedBox(height: 12),
              TextField(controller: numberCtrl, decoration: InputDecoration(labelText: t('field_name_or_plate'))),
              if (state.busCompanies.isNotEmpty) ...[
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: companyId,
                  hint: Text(t('supervisor_none_selected')),
                  decoration: InputDecoration(labelText: t('field_bus_company')),
                  items: state.busCompanies.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => companyId = v),
                ),
              ],
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
