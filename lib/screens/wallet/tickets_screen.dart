import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

/// تذاكر الدعم بين الشركة وإدارة المنصة (أساسًا: تأخر تحويل المستحقات).
class TicketsScreen extends StatefulWidget {
  /// يفتح نموذج تذكرة جديدة مباشرة (من زر "فتح تذكرة" في شاشة الرصيد).
  final bool openNew;
  const TicketsScreen({super.key, this.openNew = false});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  List<Map<String, dynamic>> tickets = [];
  List<Map<String, dynamic>> categories = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load().then((_) {
      if (widget.openNew && mounted) _newTicket();
    });
  }

  Future<void> _load() async {
    try {
      final res = await context.read<AppState>().api.get('/tickets') as Map<String, dynamic>;
      setState(() {
        tickets = (res['data'] as List).cast<Map<String, dynamic>>();
        categories = (res['categories'] as List).cast<Map<String, dynamic>>();
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _newTicket() async {
    final created = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _NewTicketSheet(categories: categories),
    );
    if (created == null || !mounted) return;
    await _load();
    if (!mounted) return;
    _openTicket(created['id'] as int);
  }

  Future<void> _openTicket(int id) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TicketDetailScreen(ticketId: id)));
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;

    return Scaffold(
      appBar: AppBar(title: Text(t('tickets_title')), foregroundColor: AppColors.text),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loading ? null : _newTicket,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(t('tickets_open_new')),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                children: [
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(error!, style: const TextStyle(color: AppColors.danger)),
                    ),
                  if (tickets.isEmpty && error == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(child: Text(t('tickets_empty'), style: const TextStyle(color: AppColors.textSecondary))),
                    ),
                  for (final tk in tickets)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: EdgeInsets.zero,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _openTicket(tk['id'] as int),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tk['subject'] ?? '',
                                          style: TextStyle(
                                              fontWeight: tk['unread'] == true ? FontWeight.w800 : FontWeight.w600,
                                              fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text('${tk['ref']} · ${tk['category_label']}',
                                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                if (tk['unread'] == true)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  ),
                                _statusPill(tk['status'] as String?, tk['status_label'] as String? ?? ''),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

Widget _statusPill(String? status, String label) {
  final (bg, fg) = switch (status) {
    'open' => (AppColors.dangerLight, AppColors.danger),
    'in_progress' => (AppColors.accentLight, AppColors.accent),
    _ => (AppColors.surface2, AppColors.textSecondary),
  };
  return StatusPill(text: label, background: bg, foreground: fg);
}

class _NewTicketSheet extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  const _NewTicketSheet({required this.categories});

  @override
  State<_NewTicketSheet> createState() => _NewTicketSheetState();
}

class _NewTicketSheetState extends State<_NewTicketSheet> {
  final subjectCtrl = TextEditingController();
  final refCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  String category = 'payout_delay';
  bool sending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subjectCtrl.text.isEmpty) subjectCtrl.text = context.read<AppState>().t('ticket_default_subject');
  }

  @override
  void dispose() {
    subjectCtrl.dispose();
    refCtrl.dispose();
    bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = context.read<AppState>().t;
    if (subjectCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('ticket_fill_required'))));
      return;
    }
    setState(() => sending = true);
    try {
      final res = await context.read<AppState>().api.post('/tickets', {
        'subject': subjectCtrl.text.trim(),
        'category': category,
        'reference': refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim(),
        'body': bodyCtrl.text.trim(),
      }) as Map<String, dynamic>;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${res['message'] ?? ''}')));
      Navigator.pop(context, res['ticket'] as Map<String, dynamic>);
    } catch (e) {
      if (!mounted) return;
      setState(() => sending = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t('tickets_open_new'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              if (widget.categories.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: InputDecoration(labelText: t('ticket_category')),
                  items: [
                    for (final c in widget.categories)
                      DropdownMenuItem(value: c['value'] as String, child: Text(c['label'] as String)),
                  ],
                  onChanged: (v) => setState(() => category = v ?? category),
                ),
                const SizedBox(height: 12),
              ],
              TextField(controller: subjectCtrl, maxLength: 200, decoration: InputDecoration(labelText: t('ticket_subject'))),
              const SizedBox(height: 4),
              TextField(controller: refCtrl, maxLength: 100, decoration: InputDecoration(labelText: t('ticket_reference'))),
              const SizedBox(height: 4),
              TextField(
                controller: bodyCtrl,
                minLines: 4,
                maxLines: 8,
                maxLength: 5000,
                decoration: InputDecoration(labelText: t('ticket_body'), alignLabelWithHint: true),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: sending ? null : _send,
                child: sending
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(t('ticket_send')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  Map<String, dynamic>? ticket;
  String? error;
  bool sending = false;
  final replyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res = await context.read<AppState>().api.get('/tickets/${widget.ticketId}') as Map<String, dynamic>;
      setState(() {
        ticket = res['ticket'] as Map<String, dynamic>;
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  Future<void> _reply() async {
    final body = replyCtrl.text.trim();
    if (body.isEmpty) return;
    setState(() => sending = true);
    try {
      final res = await context.read<AppState>().api.post('/tickets/${widget.ticketId}/messages', {'body': body})
          as Map<String, dynamic>;
      replyCtrl.clear();
      setState(() => ticket = res['ticket'] as Map<String, dynamic>);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> _close() async {
    try {
      final res = await context.read<AppState>().api.post('/tickets/${widget.ticketId}/close') as Map<String, dynamic>;
      setState(() => ticket = res['ticket'] as Map<String, dynamic>);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final tk = ticket;
    final closed = tk?['status'] == 'closed';
    final messages = ((tk?['messages'] as List?) ?? []).cast<Map<String, dynamic>>();

    return Scaffold(
      appBar: AppBar(
        title: Text(tk?['ref'] ?? ''),
        foregroundColor: AppColors.text,
        actions: [
          if (tk != null && !closed)
            IconButton(tooltip: t('ticket_close'), onPressed: _close, icon: const Icon(Icons.check_circle_outline)),
        ],
      ),
      body: tk == null
          ? Center(
              child: error != null
                  ? Text(error!, style: const TextStyle(color: AppColors.danger))
                  : const CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tk['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(
                              [tk['category_label'], if (tk['reference'] != null) '# ${tk['reference']}'].join(' · '),
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      _statusPill(tk['status'] as String?, tk['status_label'] as String? ?? ''),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.all(14),
                      children: [
                        for (final m in messages) _bubble(m),
                        if (closed)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Center(
                              child: Text(t('ticket_closed_note'),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: replyCtrl,
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(hintText: t('ticket_reply_hint'), isDense: true),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton.filled(
                          onPressed: sending ? null : _reply,
                          style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                          icon: sending
                              ? const SizedBox(
                                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _bubble(Map<String, dynamic> m) {
    final mine = m['from'] == 'company';
    final d = DateTime.tryParse('${m['created_at']}')?.toLocal();
    String two(int x) => x.toString().padLeft(2, '0');
    final time = d == null ? '' : '${d.year}/${two(d.month)}/${two(d.day)} ${two(d.hour)}:${two(d.minute)}';

    return Align(
      alignment: mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mine ? AppColors.primaryLight : AppColors.surface,
          border: Border.all(color: mine ? AppColors.primaryLight : AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${m['sender_name'] ?? ''} · $time', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(m['body'] ?? '', style: const TextStyle(fontSize: 13.5, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
