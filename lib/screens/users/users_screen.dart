import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> with SingleTickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    final state = context.read<AppState>();
    state.fetchEmployees();
    state.fetchRoles();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return Scaffold(
      appBar: AppBar(
        title: Text(t('profile_users')),
        foregroundColor: AppColors.text,
        bottom: TabBar(
          controller: tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [Tab(text: t('tab_employees')), Tab(text: t('tab_roles'))],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [_EmployeesTab(), _RolesTab()],
      ),
    );
  }
}

// ================= الموظفون =================

class _EmployeesTab extends StatefulWidget {
  const _EmployeesTab();

  @override
  State<_EmployeesTab> createState() => _EmployeesTabState();
}

class _EmployeesTabState extends State<_EmployeesTab> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;
    final assignableRoles = state.companyRoles.where((r) => !r.isOwner).toList();
    final filtered = query.isEmpty
        ? state.employees
        : state.employees.where((e) => e.name.contains(query) || e.email.contains(query)).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: assignableRoles.isEmpty
            ? null
            : () => _showEmployeeSheet(context, roles: assignableRoles),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().fetchEmployees(),
        child: state.employeesLoading && state.employees.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Text(t('users_subtitle'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (v) => setState(() => query = v),
                    decoration:
                        InputDecoration(hintText: t('search_by_name'), prefixIcon: const Icon(Icons.search, size: 20)),
                  ),
                  const SizedBox(height: 14),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                          child: Text(t('no_employees_yet'), style: const TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    AppCard(
                      child: Column(
                        children: [
                          for (var i = 0; i < filtered.length; i++) ...[
                            if (i > 0) const Divider(height: 29),
                            _EmployeeRow(
                              employee: filtered[i],
                              onTap: () => _showEmployeeSheet(context, roles: assignableRoles, employee: filtered[i]),
                              onToggle: () => context.read<AppState>().toggleEmployee(filtered[i].id),
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

class _EmployeeRow extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _EmployeeRow({required this.employee, required this.onTap, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialsAvatar(initials: employee.name.substring(0, 1)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(employee.email, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                StatusPill.info(employee.roleName),
              ],
            ),
          ),
          Switch(value: employee.isActive, onChanged: (_) => onToggle(), activeColor: AppColors.primary),
        ],
      ),
    );
  }
}

void _showEmployeeSheet(BuildContext context, {required List<CompanyRole> roles, Employee? employee}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _EmployeeSheet(roles: roles, employee: employee),
  );
}

class _EmployeeSheet extends StatefulWidget {
  final List<CompanyRole> roles;
  final Employee? employee;
  const _EmployeeSheet({required this.roles, this.employee});

  @override
  State<_EmployeeSheet> createState() => _EmployeeSheetState();
}

class _EmployeeSheetState extends State<_EmployeeSheet> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  int? roleId;
  bool saving = false;
  String? error;

  bool get isEdit => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    if (e != null) {
      nameCtrl.text = e.name;
      phoneCtrl.text = e.phone ?? '';
      emailCtrl.text = e.email;
      roleId = e.roleId;
    } else if (widget.roles.isNotEmpty) {
      roleId = widget.roles.first.id;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty || roleId == null) {
      setState(() => error = context.read<AppState>().t('err_user_fields_required'));
      return;
    }
    if (!isEdit && passwordCtrl.text.length < 8) {
      setState(() => error = context.read<AppState>().t('err_password_min_length'));
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    final state = context.read<AppState>();
    final result = isEdit
        ? await state.updateEmployee(
            id: widget.employee!.id,
            name: nameCtrl.text.trim(),
            email: emailCtrl.text.trim(),
            phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
            roleId: roleId!,
            password: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
          )
        : await state.createEmployee(
            name: nameCtrl.text.trim(),
            email: emailCtrl.text.trim(),
            phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
            roleId: roleId!,
            password: passwordCtrl.text,
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
                  child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEdit ? t('edit_employee_title') : t('add_user_title'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, size: 18)),
                  ],
                ),
                if (error != null) ...[
                  const SizedBox(height: 6),
                  Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                ],
                const SizedBox(height: 6),
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t('field_full_name'))),
                const SizedBox(height: 14),
                TextField(controller: emailCtrl, decoration: InputDecoration(labelText: t('field_email'))),
                const SizedBox(height: 14),
                TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: t('field_phone'))),
                const SizedBox(height: 14),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: t('field_password'),
                    helperText: isEdit ? t('password_optional_hint') : null,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: roleId,
                  decoration: InputDecoration(labelText: t('field_role')),
                  items: widget.roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
                  onChanged: (v) => setState(() => roleId = v),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const SizedBox(
                          height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(t('action_save_user')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= الأدوار والصلاحيات =================

class _RolesTab extends StatelessWidget {
  const _RolesTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.t;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRoleSheet(context, groups: state.permissionGroups),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().fetchRoles(),
        child: state.rolesLoading && state.companyRoles.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  if (state.companyRoles.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child:
                          Center(child: Text(t('no_roles_yet'), style: const TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    for (final role in state.companyRoles)
                      AppCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: role.isOwner
                              ? null
                              : () => _showRoleSheet(context, groups: state.permissionGroups, role: role),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(role.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                        if (role.isOwner) ...[
                                          const SizedBox(width: 6),
                                          StatusPill.warning(t('owner_role_badge')),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Text('${role.usersCount}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.people_outline, size: 15, color: AppColors.textSecondary),
                                  if (!role.isOwner) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.delete_outline, size: 19, color: AppColors.danger),
                                      onPressed: () => _confirmDeleteRole(context, role),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: role.permissions.map((p) => StatusPill.info(p)).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
      ),
    );
  }
}

void _confirmDeleteRole(BuildContext context, CompanyRole role) {
  showDialog(
    context: context,
    builder: (ctx) {
      final t = context.read<AppState>().t;
      return AlertDialog(
        title: Text(t('confirm_delete_role_title')),
        content: Text(t('confirm_delete_role_message')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('action_cancel'))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await context.read<AppState>().deleteRole(role.id);
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

void _showRoleSheet(BuildContext context, {required Map<String, PermissionGroup> groups, CompanyRole? role}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _RoleSheet(groups: groups, role: role),
  );
}

class _RoleSheet extends StatefulWidget {
  final Map<String, PermissionGroup> groups;
  final CompanyRole? role;
  const _RoleSheet({required this.groups, this.role});

  @override
  State<_RoleSheet> createState() => _RoleSheetState();
}

class _RoleSheetState extends State<_RoleSheet> {
  final nameCtrl = TextEditingController();
  final Set<String> selectedPermissions = {};
  bool saving = false;
  String? error;

  bool get isEdit => widget.role != null;

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      nameCtrl.text = widget.role!.name;
      selectedPermissions.addAll(widget.role!.permissions);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameCtrl.text.trim().isEmpty) {
      setState(() => error = context.read<AppState>().t('err_role_name_required'));
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    final state = context.read<AppState>();
    final result = isEdit
        ? await state.updateRole(id: widget.role!.id, name: nameCtrl.text.trim(), permissionNames: selectedPermissions.toList())
        : await state.createRole(name: nameCtrl.text.trim(), permissionNames: selectedPermissions.toList());

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
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(18),
            children: [
              Center(
                child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEdit ? t('edit_role_title') : t('add_role_title'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, size: 18)),
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ],
              const SizedBox(height: 6),
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t('field_role_name'))),
              const SizedBox(height: 16),
              Text(t('permissions_label'), style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              for (final group in widget.groups.values) ...[
                Text(group.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: group.permissions.entries.map((perm) {
                    final selected = selectedPermissions.contains(perm.key);
                    return FilterChip(
                      label: Text(perm.value, style: const TextStyle(fontSize: 11.5)),
                      selected: selected,
                      onSelected: (_) => setState(() {
                        if (selected) {
                          selectedPermissions.remove(perm.key);
                        } else {
                          selectedPermissions.add(perm.key);
                        }
                      }),
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primaryDark,
                      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
              ],
              ElevatedButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox(
                        height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(t('action_save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
