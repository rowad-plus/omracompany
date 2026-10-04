import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

/// موقع الرحلة زمنيًا اليوم: جارية (رقم اليوم) أو قادمة (بعد كام يوم).
/// نفس منطق DashboardService::currentRunStart/nextTripDate في الباك إند.
class TripRun {
  final DateTime start;
  final int durationDays;
  final bool isCurrent;
  const TripRun(this.start, this.durationDays, this.isCurrent);

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  int dayNumber(DateTime today) => _day(today).difference(start).inDays + 1;
  int daysUntil(DateTime today) => start.difference(_day(today)).inDays;

  static TripRun? from(Map<String, dynamic>? data, DateTime now) {
    if (data == null) return null;
    final today = _day(now);
    final days = ((data['duration_days'] as num?)?.toInt() ?? 1).clamp(1, 365);
    bool inRange(DateTime s) => !s.isAfter(today) && !s.add(Duration(days: days - 1)).isBefore(today);

    final schedule = data['schedule_type'] as String?;
    if (schedule == 'daily') return TripRun(today, days, true);

    if (schedule == 'recurring') {
      final freq = data['recurrence_frequency'] as String?;
      DateTime? last;
      DateTime? next;
      if (freq == 'weekly' && data['recurrence_day_of_week'] != null) {
        final dow = (data['recurrence_day_of_week'] as num).toInt(); // 0 = الأحد
        final back = (today.weekday % 7 - dow + 7) % 7;
        last = today.subtract(Duration(days: back));
        next = back == 0 ? today : last.add(const Duration(days: 7));
      } else if (freq == 'monthly' && data['recurrence_day_of_month'] != null) {
        final dom = (data['recurrence_day_of_month'] as num).toInt();
        DateTime onMonth(int y, int m) {
          final first = DateTime(y, m); // يطبّع الشهر 0/13 للسنة الصحيحة
          return DateTime(first.year, first.month, dom.clamp(1, DateUtils.getDaysInMonth(first.year, first.month)));
        }
        final thisMonth = onMonth(today.year, today.month);
        last = thisMonth.isAfter(today) ? onMonth(today.year, today.month - 1) : thisMonth;
        next = thisMonth.isBefore(today) ? onMonth(today.year, today.month + 1) : thisMonth;
      }
      if (last != null && inRange(last)) return TripRun(last, days, true);
      return next == null ? null : TripRun(next, days, false);
    }

    final dates = (data['trip_dates'] as List<dynamic>? ?? [])
        .map((d) => DateTime.tryParse('${(d as Map)['departure_date']}'))
        .whereType<DateTime>()
        .map(_day)
        .toList()
      ..sort();
    final running = dates.where(inRange).toList();
    if (running.isNotEmpty) return TripRun(running.last, days, true);
    final upcoming = dates.where((d) => !d.isBefore(today));
    return upcoming.isEmpty ? null : TripRun(upcoming.first, days, false);
  }
}


/// موعد في برنامج الرحلة اتبعت للمعتمرين (مزار كذا الساعة كذا — التجمع ...).
class TripAnnouncement {
  final int id;
  final String title;
  final DateTime? eventAt;
  final String? meetingPoint;
  final String? bus;
  final String message;
  final int recipients;
  final int? whatsappCount; // null = ما اتبعتش واتساب
  final String? sentAt;
  const TripAnnouncement({
    required this.id,
    required this.title,
    required this.eventAt,
    required this.meetingPoint,
    required this.bus,
    required this.message,
    required this.recipients,
    required this.whatsappCount,
    required this.sentAt,
  });

  factory TripAnnouncement.fromJson(Map<String, dynamic> j) => TripAnnouncement(
        id: j['id'] as int,
        title: j['title'] as String? ?? '',
        eventAt: DateTime.tryParse('${j['event_at'] ?? ''}'.replaceFirst(' ', 'T')),
        meetingPoint: j['meeting_point'] as String?,
        bus: j['bus'] as String?,
        message: j['message'] as String? ?? '',
        recipients: (j['recipients_count'] as num?)?.toInt() ?? 0,
        whatsappCount: (j['whatsapp_count'] as num?)?.toInt(),
        sentAt: j['sent_at'] as String?,
      );

  static List<TripAnnouncement> listFrom(Map<String, dynamic>? data) =>
      (data?['announcements'] as List<dynamic>? ?? [])
          .map((a) => TripAnnouncement.fromJson(a as Map<String, dynamic>))
          .toList();
}

String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

/// "4:30 م" / "4:30 PM".
String _fmtTime(DateTime d, String Function(String) t) {
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '$h12:${d.minute.toString().padLeft(2, '0')} ${t(d.hour < 12 ? 'time_am' : 'time_pm')}';
}

/// أقرب موعد لسه ما جاش.
TripAnnouncement? _nextAnnouncement(List<TripAnnouncement> list, DateTime now) {
  final upcoming = list.where((a) => a.eventAt != null && !a.eventAt!.isBefore(now)).toList()
    ..sort((a, b) => a.eventAt!.compareTo(b.eventAt!));
  return upcoming.isEmpty ? null : upcoming.first;
}

Future<void> shareOnWhatsApp(String text) =>
    launchUrl(Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}'), mode: LaunchMode.externalApplication);

/// بنر "برنامج الرحلة" في صفحة الرحلة: اليوم الحالي/موعد الانطلاق + أقرب موعد.
class TripProgramBanner extends StatelessWidget {
  final Map<String, dynamic>? data; // edit-data (للتواريخ)
  final Map<String, dynamic>? announcementsData;
  final bool loading;
  final VoidCallback onOpen;
  const TripProgramBanner({
    super.key,
    required this.data,
    required this.announcementsData,
    required this.loading,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final now = DateTime.now();
    final run = TripRun.from(data, now);
    final next = _nextAnnouncement(TripAnnouncement.listFrom(announcementsData), now);

    String headline = t('program_banner_title');
    double? progress;
    if (run != null && run.isCurrent) {
      final d = run.dayNumber(now);
      headline = t('trip_day_of').replaceAll('{d}', '$d').replaceAll('{n}', '${run.durationDays}');
      progress = (d / run.durationDays).clamp(0.0, 1.0);
    } else if (run != null) {
      final n = run.daysUntil(now);
      headline = n == 0
          ? t('trip_starts_today')
          : n == 1
              ? t('trip_starts_tomorrow')
              : t('trip_in_days').replaceAll('{n}', '$n');
    }

    final sub = next != null
        ? '${t('activity_next')}: ${next.title} — ${_fmtTime(next.eventAt!, t)} ${_fmtDate(next.eventAt!)}'
        : t('ann_none_hint');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('program_banner_title'),
                            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .8))),
                        const SizedBox(height: 2),
                        Text(headline,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  if (loading)
                    const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  else
                    const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
              const SizedBox(height: 10),
              Text(sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: .95))),
              if (progress != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: .2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// برنامج الرحلة: زر "موعد جديد" + المواعيد اللي اتبعتت للمعتمرين.
class TripProgramScreen extends StatefulWidget {
  final int tripId;
  final String title;
  final Map<String, dynamic>? data; // edit-data (للتواريخ)
  const TripProgramScreen({super.key, required this.tripId, required this.title, required this.data});

  @override
  State<TripProgramScreen> createState() => _TripProgramScreenState();
}

class _TripProgramScreenState extends State<TripProgramScreen> {
  Map<String, dynamic>? info;
  bool loading = true;

  TripRun? get _run => TripRun.from(widget.data, DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await context.read<AppState>().fetchTripAnnouncements(widget.tripId, departureDate: _run?.start);
    if (!mounted) return;
    setState(() {
      info = data ?? info;
      loading = false;
    });
  }

  Future<void> _new() async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AnnouncementSheet(
        tripId: widget.tripId,
        departureDate: _run?.start,
        buses: (info?['buses'] as List<dynamic>? ?? []).map((b) => '$b').toList(),
        ziyarat: (info?['ziyarat'] as List<dynamic>? ?? []).map((z) => '$z').toList(),
        pilgrims: (info?['pilgrims_count'] as num?)?.toInt() ?? 0,
      ),
    );
    if (sent == true) _load();
  }

  Future<void> _delete(TripAnnouncement a) async {
    final t = context.read<AppState>().t;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('activity_delete_confirm')),
        content: Text(t('ann_delete_note')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('action_cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('action_delete'), style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final err = await context.read<AppState>().deleteTripAnnouncement(widget.tripId, a.id);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final list = TripAnnouncement.listFrom(info);
    final pilgrims = (info?['pilgrims_count'] as num?)?.toInt();

    return Scaffold(
      appBar: AppBar(title: Text(t('program_banner_title')), foregroundColor: AppColors.text),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (pilgrims != null) ...[
              const SizedBox(height: 4),
              Text(t('ann_will_reach').replaceAll('{n}', '$pilgrims'),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: loading && info == null ? null : _new,
                icon: const Icon(Icons.add_alert_outlined),
                label: Text(t('ann_new')),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (loading && info == null)
              const Center(child: CircularProgressIndicator())
            else if (info == null)
              Text(t('activity_load_failed'), style: const TextStyle(color: AppColors.danger))
            else if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Center(
                  child: Text(t('ann_empty'),
                      textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              for (final a in list) _AnnouncementCard(a: a, onDelete: () => _delete(a)),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final TripAnnouncement a;
  final VoidCallback onDelete;
  const _AnnouncementCard({required this.a, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final past = a.eventAt != null && a.eventAt!.isBefore(DateTime.now());
    Widget line(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 12.5))),
            ],
          ),
        );
    return Opacity(
      opacity: past ? .6 : 1,
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(a.title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold))),
                IconButton(
                  tooltip: 'WhatsApp',
                  onPressed: () => shareOnWhatsApp(a.message),
                  icon: const Icon(Icons.share_outlined, size: 20, color: AppColors.success),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                ),
              ],
            ),
            if (a.eventAt != null) line(Icons.schedule, '${_fmtTime(a.eventAt!, t)} — ${_fmtDate(a.eventAt!)}'),
            if ((a.meetingPoint ?? '').isNotEmpty) line(Icons.place_outlined, '${t('ann_meeting')}: ${a.meetingPoint}'),
            if ((a.bus ?? '').isNotEmpty) line(Icons.directions_bus_outlined, '${t('activity_bus')}: ${a.bus}'),
            const SizedBox(height: 6),
            Text(
              [
                t('ann_sent_to').replaceAll('{n}', '${a.recipients}'),
                if (a.whatsappCount != null) t('ann_whatsapp_count').replaceAll('{n}', '${a.whatsappCount}'),
                if (a.sentAt != null) a.sentAt!,
              ].join(' · '),
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// نموذج موعد جديد: الاسم، الساعة، مكان التجمع، الباص — ثم إرسال.
class _AnnouncementSheet extends StatefulWidget {
  final int tripId;
  final DateTime? departureDate;
  final List<String> buses;
  final List<String> ziyarat;
  final int pilgrims;
  const _AnnouncementSheet({
    required this.tripId,
    required this.departureDate,
    required this.buses,
    required this.ziyarat,
    required this.pilgrims,
  });

  @override
  State<_AnnouncementSheet> createState() => _AnnouncementSheetState();
}

class _AnnouncementSheetState extends State<_AnnouncementSheet> {
  final titleCtrl = TextEditingController();
  final meetingCtrl = TextEditingController();
  final busCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  DateTime date = DateTime.now();
  TimeOfDay? time;
  bool notifyApp = true;
  bool whatsappAuto = false;
  bool whatsapp = false;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    if (widget.buses.length == 1) busCtrl.text = widget.buses.first;
    for (final c in [titleCtrl, meetingCtrl, busCtrl, notesCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [titleCtrl, meetingCtrl, busCtrl, notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  DateTime? get _eventAt =>
      time == null ? null : DateTime(date.year, date.month, date.day, time!.hour, time!.minute);

  String _message(String Function(String) t) {
    final at = _eventAt;
    return [
      '📍 ${titleCtrl.text.trim()}',
      if (at != null) '🕓 ${_fmtTime(at, t)} — ${_fmtDate(at)}',
      if (meetingCtrl.text.trim().isNotEmpty) '🚩 ${t('ann_meeting')}: ${meetingCtrl.text.trim()}',
      if (busCtrl.text.trim().isNotEmpty) '🚌 ${t('activity_bus')}: ${busCtrl.text.trim()}',
      if (notesCtrl.text.trim().isNotEmpty) '📝 ${notesCtrl.text.trim()}',
    ].join('\n');
  }

  Future<void> _send() async {
    final state = context.read<AppState>();
    final t = state.t;
    if (titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('ann_title_required'))));
      return;
    }
    final message = _message(t);
    final at = _eventAt;
    setState(() => sending = true);
    final err = await state.sendTripAnnouncement(widget.tripId, {
      'title': titleCtrl.text.trim(),
      'event_at': at == null
          ? null
          : '${at.year}-${_two(at.month)}-${_two(at.day)} ${_two(at.hour)}:${_two(at.minute)}',
      'meeting_point': meetingCtrl.text.trim().isEmpty ? null : meetingCtrl.text.trim(),
      'bus': busCtrl.text.trim().isEmpty ? null : busCtrl.text.trim(),
      'notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      'message': message,
      'departure_date': widget.departureDate == null
          ? null
          : '${widget.departureDate!.year}-${_two(widget.departureDate!.month)}-${_two(widget.departureDate!.day)}',
      'notify': notifyApp,
      'whatsapp': whatsappAuto,
    });
    if (!mounted) return;
    setState(() => sending = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(true);
    messenger.showSnackBar(SnackBar(content: Text(t('ann_sent'))));
    if (whatsapp) await shareOnWhatsApp(message);
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    Widget chips(List<String> items, TextEditingController ctrl) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in items)
                ActionChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  onPressed: () => ctrl.text = s,
                ),
            ],
          ),
        );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t('ann_new'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: t('ann_title'), hintText: t('activity_ziyara_hint')),
              ),
              if (widget.ziyarat.isNotEmpty) chips(widget.ziyarat, titleCtrl),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(now.year, now.month, now.day),
                          lastDate: now.add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => date = picked);
                      },
                      icon: const Icon(Icons.event, size: 18),
                      label: Text(_fmtDate(date)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: time ?? TimeOfDay(hour: (TimeOfDay.now().hour + 1) % 24, minute: 0),
                        );
                        if (picked != null) setState(() => time = picked);
                      },
                      icon: const Icon(Icons.schedule, size: 18),
                      label: Text(_eventAt == null ? t('activity_pick_time') : _fmtTime(_eventAt!, t)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: meetingCtrl, decoration: InputDecoration(labelText: t('ann_meeting'))),
              chips([t('ann_meeting_hotel'), t('ann_meeting_lobby')], meetingCtrl),
              const SizedBox(height: 12),
              TextField(controller: busCtrl, decoration: InputDecoration(labelText: t('ann_bus_optional'))),
              if (widget.buses.isNotEmpty) chips(widget.buses, busCtrl),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(labelText: t('activity_notes'), hintText: t('activity_notes_hint')),
              ),
              if (titleCtrl.text.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_message(t), style: const TextStyle(fontSize: 13, height: 1.5)),
                ),
              ],
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: notifyApp,
                onChanged: (v) => setState(() => notifyApp = v),
                title: Text(t('ann_notify_app'), style: const TextStyle(fontSize: 13.5)),
                subtitle: Text(t('ann_will_reach').replaceAll('{n}', '${widget.pilgrims}'),
                    style: const TextStyle(fontSize: 11.5)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: whatsappAuto,
                onChanged: (v) => setState(() => whatsappAuto = v),
                title: Text(t('ann_whatsapp_auto'), style: const TextStyle(fontSize: 13.5)),
                subtitle: Text(t('ann_whatsapp_auto_hint'), style: const TextStyle(fontSize: 11.5)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: whatsapp,
                onChanged: (v) => setState(() => whatsapp = v),
                title: Text(t('ann_share_whatsapp'), style: const TextStyle(fontSize: 13.5)),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: sending ? null : _send,
                icon: sending
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                label: Text(t('ann_send')),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
