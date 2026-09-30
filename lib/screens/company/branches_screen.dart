import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchBranches();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final branches = state.branches;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('profile_branches')),
        foregroundColor: AppColors.text,
        actions: [
          IconButton(onPressed: () => _showBranchSheet(context), icon: const Icon(Icons.add)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().fetchBranches(),
        child: state.branchesLoading && branches.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  if (branches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(child: Text(t('no_branches_yet'), style: const TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    AppCard(
                      child: Column(
                        children: [
                          for (var i = 0; i < branches.length; i++) ...[
                            if (i > 0) const Divider(height: 25),
                            InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _showBranchSheet(context, branch: branches[i]),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(branches[i].name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 2),
                                        Text(
                                          [branches[i].city, branches[i].phone].where((s) => s != null && s.isNotEmpty).join(' · '),
                                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 19, color: AppColors.danger),
                                    onPressed: () => _confirmDelete(context, branches[i]),
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

void _confirmDelete(BuildContext context, CompanyBranchInfo branch) {
  showDialog(
    context: context,
    builder: (ctx) {
      final t = context.read<AppState>().t;
      return AlertDialog(
        title: Text(t('action_delete')),
        content: Text(branch.name),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('action_cancel'))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await context.read<AppState>().deleteBranch(branch.id);
              if (result != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
              }
            },
            child: Text(t('action_delete'), style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      );
    },
  );
}

void _showBranchSheet(BuildContext context, {CompanyBranchInfo? branch}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _BranchSheet(branch: branch),
  );
}

class _BranchSheet extends StatefulWidget {
  final CompanyBranchInfo? branch;
  const _BranchSheet({this.branch});

  @override
  State<_BranchSheet> createState() => _BranchSheetState();
}

class _BranchSheetState extends State<_BranchSheet> {
  final nameCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final managerCtrl = TextEditingController();
  bool saving = false;
  String? error;

  bool get isEdit => widget.branch != null;

  @override
  void initState() {
    super.initState();
    final branch = widget.branch;
    if (branch != null) {
      nameCtrl.text = branch.name;
      cityCtrl.text = branch.city ?? '';
      phoneCtrl.text = branch.phone ?? '';
      managerCtrl.text = branch.manager ?? '';
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    cityCtrl.dispose();
    phoneCtrl.dispose();
    managerCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameCtrl.text.trim().isEmpty) {
      setState(() => error = context.read<AppState>().t('err_branch_name_required'));
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final state = context.read<AppState>();
    final result = isEdit
        ? await state.updateBranch(
            id: widget.branch!.id,
            name: nameCtrl.text.trim(),
            city: cityCtrl.text.trim().isEmpty ? null : cityCtrl.text.trim(),
            phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
            manager: managerCtrl.text.trim().isEmpty ? null : managerCtrl.text.trim(),
          )
        : await state.createBranch(
            name: nameCtrl.text.trim(),
            city: cityCtrl.text.trim().isEmpty ? null : cityCtrl.text.trim(),
            phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
            manager: managerCtrl.text.trim().isEmpty ? null : managerCtrl.text.trim(),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
                ),
                Text(isEdit ? t('action_edit') : t('add_branch_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                if (error != null) ...[
                  const SizedBox(height: 6),
                  Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                ],
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t('field_branch_name'))),
                const SizedBox(height: 12),
                TextField(controller: cityCtrl, decoration: InputDecoration(labelText: t('field_city'))),
                const SizedBox(height: 12),
                TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: t('field_contact_number'))),
                const SizedBox(height: 12),
                TextField(controller: managerCtrl, decoration: InputDecoration(labelText: t('field_branch_manager'))),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(t('action_save')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
