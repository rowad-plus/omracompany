import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../company/bank_info_screen.dart';
import 'tickets_screen.dart';

/// رصيد الشركة: المستحق لها، الداخل (نصيبها من كل حجز مدفوع بعد العمولة)،
/// الخارج (التحويلات لحسابها + الاستردادات)، وكشف الحركات. ومنها تفتح
/// تذكرة لو التحويل اتأخر.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Map<String, dynamic>? data;
  List<Map<String, dynamic>> entries = [];
  String? error;
  bool loading = true;
  bool loadingMore = false;
  int page = 1;
  int lastPage = 1;
  String type = 'all';
  String? currency;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    final api = context.read<AppState>().api;
    setState(() {
      if (more) {
        loadingMore = true;
      } else {
        loading = data == null;
        error = null;
      }
    });
    try {
      final p = more ? page + 1 : 1;
      final q = <String>['page=$p', 'type=$type', if (currency != null) 'currency=$currency'];
      final res = await api.get('/wallet?${q.join('&')}') as Map<String, dynamic>;
      final e = res['entries'] as Map<String, dynamic>;
      final list = (e['data'] as List).cast<Map<String, dynamic>>();
      setState(() {
        data = res;
        currency = res['currency'] as String?;
        page = e['current_page'] as int;
        lastPage = e['last_page'] as int;
        entries = more ? [...entries, ...list] : list;
      });
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
          loadingMore = false;
        });
      }
    }
  }

  void _openTickets({bool newTicket = false}) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TicketsScreen(openNew: newTicket)));
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('profile_wallet')),
        foregroundColor: AppColors.text,
        actions: [
          IconButton(
            tooltip: t('tickets_title'),
            onPressed: () => _openTickets(),
            icon: Badge(
              isLabelVisible: ((data?['open_tickets'] as int?) ?? 0) > 0,
              label: Text('${data?['open_tickets'] ?? ''}'),
              child: const Icon(Icons.support_agent_outlined),
            ),
          ),
        ],
      ),
      floatingActionButton: data == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openTickets(newTicket: true),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.confirmation_number_outlined),
              label: Text(t('tickets_open_new')),
            ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null && data == null
              ? _ErrorView(message: error!, onRetry: _load)
              : RefreshIndicator(onRefresh: _load, child: _body(t)),
    );
  }

  Widget _body(String Function(String) t) {
    final s = data!['summary'] as Map<String, dynamic>;
    final cur = s['currency'] as String;
    final bank = data!['bank'] as Map<String, dynamic>;
    final currencies = (data!['currencies'] as List).cast<Map<String, dynamic>>();
    final balance = double.tryParse('${s['balance']}') ?? 0;
    final dueDays = data!['payout_due_days'] ?? 3;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        if (currencies.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Wrap(
              spacing: 8,
              children: [
                for (final c in currencies)
                  ChoiceChip(
                    label: Text(c['currency'] as String),
                    selected: c['currency'] == cur,
                    onSelected: (_) {
                      currency = c['currency'] as String;
                      _load();
                    },
                  ),
              ],
            ),
          ),

        // ── الرصيد ──
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('wallet_balance'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_money(s['balance']),
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                          color: balance < 0 ? const Color(0xFFFFC9C9) : Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(cur, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _heroStat(Icons.south_west, t('wallet_in'), s['total_in'])),
                  Container(width: 1, height: 34, color: Colors.white24),
                  Expanded(child: _heroStat(Icons.north_east, t('wallet_out'), s['total_out'])),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (s['overdue'] == true)
          _Notice(
            color: AppColors.danger,
            background: AppColors.dangerLight,
            icon: Icons.schedule,
            text: t('wallet_overdue').replaceAll('{d}', '$dueDays'),
            action: t('tickets_open_new'),
            onTap: () => _openTickets(newTicket: true),
          ),
        if (bank['complete'] != true)
          _Notice(
            color: AppColors.accent,
            background: AppColors.accentLight,
            icon: Icons.account_balance_outlined,
            text: t('wallet_no_bank'),
            action: t('profile_bank_info'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BankInfoScreen())).then((_) => _load()),
          ),

        // ── تفاصيل ──
        AppCard(
          child: Column(
            children: [
              _row(t('wallet_sales'), '${_money(s['sales'])} $cur'),
              _row(t('wallet_commission'), '− ${_money(s['commission'])} $cur'),
              const Divider(height: 18),
              _row(t('wallet_paid_out'), '${_money(s['paid_out'])} $cur'),
              if ((double.tryParse('${s['refunded']}') ?? 0) > 0) _row(t('wallet_refunded'), '${_money(s['refunded'])} $cur'),
              _row(t('wallet_pending_count'), '${s['pending_count']}'),
              _row(t('wallet_last_payout'), s['last_payout_at'] != null ? _date(s['last_payout_at']) : '—'),
              if (bank['complete'] == true) ...[
                const Divider(height: 18),
                _row(t('wallet_bank_to'), '${bank['bank_name'] ?? ''}  ${bank['masked_iban'] ?? ''}'.trim()),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── كشف الحركات ──
        Row(
          children: [
            Expanded(child: Text(t('wallet_statement'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
            SegmentedButton<String>(
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: [
                ButtonSegment(value: 'all', label: Text(t('wallet_filter_all'))),
                ButtonSegment(value: 'in', label: Text(t('wallet_in'))),
                ButtonSegment(value: 'out', label: Text(t('wallet_out'))),
              ],
              selected: {type},
              onSelectionChanged: (v) {
                type = v.first;
                _load();
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(child: Text(t('wallet_no_entries'), style: const TextStyle(color: AppColors.textSecondary))),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _EntryTile(entry: entries[i], t: t),
                ],
              ],
            ),
          ),
        if (page < lastPage)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: loadingMore
                  ? const CircularProgressIndicator()
                  : TextButton(onPressed: () => _load(more: true), child: Text(t('wallet_load_more'))),
            ),
          ),
      ],
    );
  }

  Widget _heroStat(IconData icon, String label, dynamic value) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(_money(value),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
            Text(value, textDirection: TextDirection.ltr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      );
}

class _EntryTile extends StatelessWidget {
  final Map<String, dynamic> entry;
  final String Function(String) t;
  const _EntryTile({required this.entry, required this.t});

  @override
  Widget build(BuildContext context) {
    final isIn = entry['direction'] == 'in';
    final status = entry['status'] as String?;
    final color = isIn ? AppColors.success : AppColors.danger;
    final icon = switch (entry['type']) {
      'payout' => Icons.account_balance_outlined,
      'refund' => Icons.undo,
      _ => Icons.receipt_long_outlined,
    };
    final (pillText, pillBg, pillFg) = switch (status) {
      'pending' => (t('wallet_status_pending'), AppColors.accentLight, AppColors.accent),
      'paid_out' => (t('wallet_status_paid_out'), AppColors.successLight, AppColors.success),
      'refunded' => (t('wallet_status_refunded'), AppColors.surface2, AppColors.textSecondary),
      'processing' => (t('wallet_status_processing'), AppColors.infoLight, AppColors.info),
      _ => (null, null, null),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isIn ? AppColors.successLight : AppColors.dangerLight,
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(entry['subtitle'] ?? '', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                if (entry['reference'] != null)
                  Text('# ${entry['reference']}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(_date(entry['date']), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    if (pillText != null) ...[
                      const SizedBox(width: 8),
                      StatusPill(text: pillText, background: pillBg!, foreground: pillFg!),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${isIn ? '+' : '−'}${_money(entry['amount'])}',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text('${t('wallet_balance_after')} ${_money(entry['balance_after'])}',
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final Color color;
  final Color background;
  final IconData icon;
  final String text;
  final String action;
  final VoidCallback onTap;
  const _Notice({
    required this.color,
    required this.background,
    required this.icon,
    required this.text,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 12.5))),
            TextButton(onPressed: onTap, child: Text(action, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: const Icon(Icons.refresh)),
            ],
          ),
        ),
      );
}

String _money(dynamic v) {
  final n = double.tryParse('$v') ?? 0;
  final neg = n < 0;
  final parts = n.abs().toStringAsFixed(2).split('.');
  final whole = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '${neg ? '-' : ''}$whole.${parts[1]}';
}

String _date(dynamic iso) {
  final d = DateTime.tryParse('$iso')?.toLocal();
  if (d == null) return '';
  String two(int x) => x.toString().padLeft(2, '0');
  return '${d.year}/${two(d.month)}/${two(d.day)}  ${two(d.hour)}:${two(d.minute)}';
}
