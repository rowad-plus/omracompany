import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

/// الباقة المميزة: نفس صفحة /provider/subscription في لوحة الويب
/// (GET/POST /company/subscription، POST /company/subscription/cancel).
/// الشركة المشتركة تظهر أولاً هي ورحلاتها، وعلى رحلاتها علامة "مقترح".
/// لو الباقة مش مفعّلة لدولة الشركة الـ API بيرجع 404 والصفحة مش بتظهر
/// أصلاً في القائمة (انظر [SubscriptionMenuEntry]).
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  static const _gold = Color(0xFFB8892F);
  static const _goldSoft = Color(0xFFFBF5E8);
  static const _goldLine = Color(0xFFEEDDB8);

  Map<String, dynamic>? data;
  String? error;
  bool loading = true;
  bool busy = false;
  String? cycle;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<AppState>().api;
    setState(() {
      loading = data == null;
      error = null;
    });
    try {
      final res = await api.get('/company/subscription') as Map<String, dynamic>;
      final cycles = (res['plan']?['cycles'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      setState(() {
        data = res;
        cycle ??= cycles.isNotEmpty ? cycles.last['cycle'] as String : null;
      });
    } catch (e) {
      if (mounted) setState(() => error = e is ApiException ? e.message : e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _request() async {
    if (cycle == null) return;
    final api = context.read<AppState>().api;
    setState(() => busy = true);
    try {
      final res = await api.post('/company/subscription', {'billing_cycle': cycle}) as Map<String, dynamic>;
      setState(() => data = res);
      _toast(res['message'] as String? ?? '');
    } catch (e) {
      _toast(e is ApiException ? e.message : e.toString(), error: true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _cancelPending() async {
    final t = context.read<AppState>().t;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('sub_cancel_title')),
        content: Text(t('sub_cancel_body')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('sub_back'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('sub_cancel_confirm'), style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final api = context.read<AppState>().api;
    setState(() => busy = true);
    try {
      final res = await api.post('/company/subscription/cancel') as Map<String, dynamic>;
      setState(() => data = res);
      _toast(res['message'] as String? ?? '');
    } catch (e) {
      _toast(e is ApiException ? e.message : e.toString(), error: true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted || msg.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.danger : AppColors.text,
    ));
  }

  String _num(dynamic v) {
    final d = double.tryParse('$v') ?? 0;
    final s = d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toStringAsFixed(2);
    return s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(t('sub_title')), foregroundColor: AppColors.text),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null && data == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      OutlinedButton(onPressed: _load, child: Text(t('sub_retry'))),
                    ]),
                  ),
                )
              : RefreshIndicator(onRefresh: _load, child: _body(t)),
    );
  }

  Widget _body(String Function(String) t) {
    final d = data!;
    final plan = d['plan'] as Map<String, dynamic>?;
    final current = d['current'] as Map<String, dynamic>?;
    final scheduled = d['scheduled'] as Map<String, dynamic>?;
    final pending = d['pending'] as Map<String, dynamic>?;
    final history = (d['history'] as List? ?? []).cast<Map<String, dynamic>>();
    final featured = d['is_featured'] == true;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // ── Header card ──
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(colors: [Color(0xFFB78B32), Color(0xFFE6C66F)]),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.workspace_premium, color: Color(0xFF1A1408)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(plan?['name'] as String? ?? t('sub_title'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A1408))),
              ),
              if (featured)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF1A1408), borderRadius: BorderRadius.circular(20)),
                  child: Text('★ ${t('sub_featured_now')}',
                      style: const TextStyle(color: Color(0xFFEFD47D), fontSize: 11.5, fontWeight: FontWeight.w800)),
                ),
            ]),
            if ((plan?['description'] as String?)?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(plan!['description'] as String,
                  style: const TextStyle(color: Color(0xFF2A2210), height: 1.6, fontSize: 13)),
            ],
          ]),
        ),
        const SizedBox(height: 14),

        // ── Current / scheduled / pending ──
        if (current != null)
          _statusCard(
            icon: Icons.verified,
            color: AppColors.success,
            bg: AppColors.successLight,
            title: '${t('sub_active')} — ${current['cycle_label']}',
            lines: [
              '${t('sub_from')} ${current['starts_at']}  ${t('sub_to')} ${current['ends_at']}',
              if (current['days_left'] != null) '${t('sub_days_left')}: ${current['days_left']}',
            ],
          ),
        if (scheduled != null)
          _statusCard(
            icon: Icons.schedule,
            color: AppColors.info,
            bg: AppColors.infoLight,
            title: '${t('sub_scheduled')} — ${scheduled['cycle_label']}',
            lines: ['${t('sub_from')} ${scheduled['starts_at']}  ${t('sub_to')} ${scheduled['ends_at']}'],
          ),
        if (pending != null)
          _statusCard(
            icon: Icons.hourglass_top,
            color: AppColors.accent,
            bg: AppColors.accentLight,
            title: '${t('sub_pending')} — ${pending['cycle_label']}',
            lines: [
              '${_num(pending['price'])} ${pending['currency']}',
              t('sub_pending_hint'),
            ],
            action: TextButton(
              onPressed: busy ? null : _cancelPending,
              child: Text(t('sub_cancel_request'), style: const TextStyle(color: AppColors.danger)),
            ),
          ),

        // ── Features ──
        if (plan != null) ...[
          _sectionTitle(t('sub_benefits')),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              for (final f in (plan['features'] as List? ?? []).cast<String>())
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.check_circle, size: 18, color: _gold),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: const TextStyle(height: 1.5))),
                  ]),
                ),
            ]),
          ),

          // ── Choose a period + request ──
          if (pending == null) ...[
            _sectionTitle(current != null ? t('sub_renew') : t('sub_choose')),
            for (final c in (plan['cycles'] as List? ?? []).cast<Map<String, dynamic>>())
              _cycleTile(c, plan['currency'] as String? ?? '', t),
            const SizedBox(height: 10),
            if ((plan['payment_instructions'] as String?)?.isNotEmpty ?? false)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('sub_how_to_pay'), style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  SelectableText(plan['payment_instructions'] as String, style: const TextStyle(height: 1.6)),
                ]),
              ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: busy || cycle == null ? null : _request,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: busy
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(current != null ? t('sub_renew_btn') : t('sub_subscribe_btn'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 6),
            Text(t('sub_after_request'),
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ] else if (current == null && pending == null)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(t('sub_not_offered'), textAlign: TextAlign.center),
          ),

        // ── History ──
        if (history.isNotEmpty) ...[
          _sectionTitle(t('sub_history')),
          for (final h in history)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${h['cycle_label']} · ${_num(h['price'])} ${h['currency']}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (h['starts_at'] != null)
                      Text('${h['starts_at']} → ${h['ends_at']}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                ),
                Text(h['status_label'] as String? ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
              ]),
            ),
        ],
      ],
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 18, 2, 8),
        child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      );

  Widget _statusCard({
    required IconData icon,
    required Color color,
    required Color bg,
    required String title,
    required List<String> lines,
    Widget? action,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
            for (final l in lines)
              Padding(padding: const EdgeInsets.only(top: 3), child: Text(l, style: const TextStyle(fontSize: 12.5))),
            if (action != null) Align(alignment: AlignmentDirectional.centerEnd, child: action),
          ]),
        ),
      ]),
    );
  }

  Widget _cycleTile(Map<String, dynamic> c, String currency, String Function(String) t) {
    final selected = cycle == c['cycle'];
    return GestureDetector(
      onTap: () => setState(() => cycle = c['cycle'] as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _goldSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _gold : _goldLine, width: selected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: _gold),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c['label'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w800)),
              Text('${t('sub_monthly_eq')} ${_num(c['monthly_equivalent'])} $currency',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ),
          Text('${_num(c['price'])} $currency',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _gold)),
        ]),
      ),
    );
  }
}

/// Profile-menu entry for the subscription. It only appears when the server
/// says the feature exists for this company (GET /company/subscription
/// returns 200); a 404 means the admin hasn't enabled a plan for the
/// company's country, so nothing is shown at all.
class SubscriptionMenuEntry extends StatefulWidget {
  final Widget Function(bool featured) builder;
  const SubscriptionMenuEntry({super.key, required this.builder});

  @override
  State<SubscriptionMenuEntry> createState() => _SubscriptionMenuEntryState();
}

class _SubscriptionMenuEntryState extends State<SubscriptionMenuEntry> {
  bool visible = false;
  bool featured = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final res = await context.read<AppState>().api.get('/company/subscription') as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          visible = true;
          featured = res['is_featured'] == true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => visible = false);
    }
  }

  @override
  Widget build(BuildContext context) => visible ? widget.builder(featured) : const SizedBox.shrink();
}
