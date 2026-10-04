import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

/// يوم واحد في برنامج الرحلة (من /umrah-trips/{id}/edit-data → programs).
class ProgramDay {
  final int dayNumber;
  final String title;
  final String location;
  final List<String> steps;
  const ProgramDay({required this.dayNumber, required this.title, required this.location, required this.steps});

  static List<ProgramDay> listFrom(Map<String, dynamic>? data) {
    final raw = (data?['programs'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final days = raw
        .map((d) => ProgramDay(
              dayNumber: d['day_number'] as int? ?? 0,
              title: d['title'] as String? ?? '',
              location: d['location'] as String? ?? '',
              steps: (d['steps'] as List<dynamic>? ?? [])
                  .map((s) => '$s'.trim())
                  .where((s) => s.isNotEmpty)
                  .toList(),
            ))
        .where((d) => d.title.isNotEmpty || d.location.isNotEmpty || d.steps.isNotEmpty)
        .toList();
    days.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return days;
  }
}

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


/// نشاط في جدول الرحلة: انطلاق / مزار / تنقل... في يوم معين بوقت وباص.
class TripActivity {
  final int id;
  final int dayNumber;
  final String? time; // HH:mm
  final String type;
  final String? place;
  final int? busId;
  final String? busLabel;
  final String? busName;
  final String? notes;
  const TripActivity({
    required this.id,
    required this.dayNumber,
    required this.time,
    required this.type,
    this.place,
    this.busId,
    this.busLabel,
    this.busName,
    this.notes,
  });

  factory TripActivity.fromJson(Map<String, dynamic> j) => TripActivity(
        id: j['id'] as int,
        dayNumber: (j['day_number'] as num?)?.toInt() ?? 1,
        time: j['time'] as String?,
        type: j['type'] as String? ?? 'other',
        place: j['place'] as String?,
        busId: (j['bus_id'] as num?)?.toInt(),
        busLabel: j['bus_label'] as String?,
        busName: j['bus_name'] as String?,
        notes: j['notes'] as String?,
      );

  static List<TripActivity> listFrom(Map<String, dynamic>? data) =>
      (data?['activities'] as List<dynamic>? ?? [])
          .map((a) => TripActivity.fromJson(a as Map<String, dynamic>))
          .toList();

  /// دقائق من بداية اليوم (للترتيب والمقارنة)؛ بدون وقت = آخر اليوم.
  int get minutes {
    final parts = (time ?? '').split(':');
    if (parts.length < 2) return 24 * 60;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  Map<String, dynamic> toPayload() => {
        'day_number': dayNumber,
        'time': time,
        'type': type,
        'place': place,
        'bus_id': busId,
        'bus_label': busLabel,
        'notes': notes,
      };
}

const activityTypes = ['departure', 'ziyara', 'transfer', 'arrival', 'return', 'other'];

IconData activityIcon(String type) => switch (type) {
      'departure' => Icons.flight_takeoff,
      'ziyara' => Icons.mosque_outlined,
      'transfer' => Icons.directions_bus_outlined,
      'arrival' => Icons.hotel_outlined,
      'return' => Icons.flight_land,
      _ => Icons.event_note_outlined,
    };

/// "4:30 م" / "4:30 PM".
String formatActivityTime(String? hhmm, String Function(String) t) {
  final parts = (hhmm ?? '').split(':');
  if (parts.length < 2) return '';
  final h = int.tryParse(parts[0]) ?? 0;
  final m = parts[1].padLeft(2, '0');
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:$m ${t(h < 12 ? 'time_am' : 'time_pm')}';
}

/// "مزار: جبل أحد" — نوع النشاط ومكانه.
String activityHeadline(TripActivity a, String Function(String) t) {
  final type = t('activity_type_${a.type}');
  final place = (a.place ?? '').trim();
  return place.isEmpty ? type : '$type: $place';
}

/// النشاط التالي من الآن (لرحلة جارية) — أو أول نشاط في البرنامج.
TripActivity? nextActivity(List<TripActivity> list, TripRun? run, DateTime now) {
  if (list.isEmpty) return null;
  final sorted = [...list]..sort((a, b) {
      final d = a.dayNumber.compareTo(b.dayNumber);
      return d != 0 ? d : a.minutes.compareTo(b.minutes);
    });
  if (run == null || !run.isCurrent) return sorted.first;
  final today = run.dayNumber(now);
  final nowMin = now.hour * 60 + now.minute;
  for (final a in sorted) {
    if (a.dayNumber > today || (a.dayNumber == today && a.minutes >= nowMin)) return a;
  }
  return null;
}

String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

/// بنر "برنامج الرحلة" في صفحة الرحلة — زي التتبع: اليوم الحالي + التالي + شريط تقدم.
class TripProgramBanner extends StatelessWidget {
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? activitiesData;
  final bool loading;
  final VoidCallback onOpen;
  const TripProgramBanner({
    super.key,
    required this.data,
    required this.activitiesData,
    required this.loading,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final now = DateTime.now();
    final days = ProgramDay.listFrom(data);
    final activities = TripActivity.listFrom(activitiesData);
    final run = TripRun.from(data, now);
    final hasProgram = days.isNotEmpty || activities.isNotEmpty;

    String headline;
    String? sub;
    double? progress;
    if (loading && data == null) {
      headline = t('program_banner_title');
    } else if (!hasProgram) {
      headline = t('program_not_defined');
      sub = t('program_define_hint');
    } else if (run != null && run.isCurrent) {
      final d = run.dayNumber(now);
      final today = days.where((p) => p.dayNumber == d);
      headline = t('trip_day_of').replaceAll('{d}', '$d').replaceAll('{n}', '${run.durationDays}');
      sub = today.isEmpty ? null : [today.first.title, today.first.location].where((s) => s.isNotEmpty).join(' — ');
      progress = (d / run.durationDays).clamp(0.0, 1.0);
    } else if (run != null) {
      final n = run.daysUntil(now);
      headline = n == 0
          ? t('trip_starts_today')
          : n == 1
              ? t('trip_starts_tomorrow')
              : t('trip_in_days').replaceAll('{n}', '$n');
      sub = _fmtDate(run.start);
      progress = 0;
    } else {
      headline = t('program_banner_title');
    }

    final next = hasProgram ? nextActivity(activities, run, now) : null;

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
                    child: Icon(hasProgram ? Icons.route_outlined : Icons.edit_calendar_outlined,
                        color: Colors.white, size: 21),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(hasProgram ? t('program_view') : t('program_define'),
                          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
              if (sub != null && sub.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(sub, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: .9))),
              ],
              if (next != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(activityIcon(next.type), size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          [
                            '${t('activity_next')}:',
                            if (run == null || !run.isCurrent || next.dayNumber != run.dayNumber(now))
                              '${t('program_day')} ${next.dayNumber}',
                            formatActivityTime(next.time, t),
                            activityHeadline(next, t),
                            if ((next.busName ?? '').isNotEmpty) '🚌 ${next.busName}',
                          ].where((s) => s.isNotEmpty).join('  '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

/// صفحة البرنامج كخط زمني (تتبع): كل يوم بتاريخه، وصف البرنامج، وجدول
/// الأنشطة بالوقت والباص. الأيام المنتهية ✓ واليوم الحالي مميز.
class TripProgramScreen extends StatefulWidget {
  final int tripId;
  final String title;
  final Map<String, dynamic> data; // edit-data
  final VoidCallback onEditText;
  const TripProgramScreen({
    super.key,
    required this.tripId,
    required this.title,
    required this.data,
    required this.onEditText,
  });

  @override
  State<TripProgramScreen> createState() => _TripProgramScreenState();
}

class _TripProgramScreenState extends State<TripProgramScreen> {
  Map<String, dynamic>? activitiesData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await context.read<AppState>().fetchTripActivities(widget.tripId);
    if (!mounted) return;
    setState(() {
      activitiesData = data ?? activitiesData;
      loading = false;
    });
  }

  int get _durationDays => ((widget.data['duration_days'] as num?)?.toInt() ?? 1).clamp(1, 365);

  Future<void> _openEditor({TripActivity? activity, int? day}) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => TripActivitySheet(
        tripId: widget.tripId,
        activity: activity,
        initialDay: day ?? activity?.dayNumber ?? 1,
        maxDay: _durationDays,
        buses: (activitiesData?['buses'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>(),
        ziyarat: (activitiesData?['ziyarat'] as List<dynamic>? ?? []).map((z) => '$z').toList(),
      ),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final now = DateTime.now();
    final programDays = ProgramDay.listFrom(widget.data);
    final activities = TripActivity.listFrom(activitiesData);
    final run = TripRun.from(widget.data, now);
    final currentDay = (run != null && run.isCurrent) ? run.dayNumber(now) : null;

    var lastDay = _durationDays;
    for (final p in programDays) {
      if (p.dayNumber > lastDay) lastDay = p.dayNumber;
    }
    for (final a in activities) {
      if (a.dayNumber > lastDay) lastDay = a.dayNumber;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t('program_banner_title')),
        foregroundColor: AppColors.text,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: t('program_edit_text'),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onEditText();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: activitiesData == null && !loading ? null : () => _openEditor(day: currentDay ?? 1),
        icon: const Icon(Icons.add),
        label: Text(t('activity_add')),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            if (run != null) ...[
              const SizedBox(height: 4),
              Text(
                '${_fmtDate(run.start)} → ${_fmtDate(run.start.add(Duration(days: run.durationDays - 1)))}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
            if (!loading && activitiesData == null) ...[
              const SizedBox(height: 12),
              Text(t('activity_load_failed'), style: const TextStyle(color: AppColors.danger, fontSize: 12)),
            ],
            const SizedBox(height: 18),
            if (loading) const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
            for (var d = 1; d <= lastDay; d++)
              _TimelineDay(
                dayNumber: d,
                program: programDays.where((p) => p.dayNumber == d).firstOrNull,
                activities: activities.where((a) => a.dayNumber == d).toList()
                  ..sort((a, b) => a.minutes.compareTo(b.minutes)),
                date: run?.start.add(Duration(days: d - 1)),
                state: currentDay == null
                    ? _DayState.upcoming
                    : d < currentDay
                        ? _DayState.done
                        : d == currentDay
                            ? _DayState.current
                            : _DayState.upcoming,
                isLast: d == lastDay,
                onAdd: activitiesData == null ? null : () => _openEditor(day: d),
                onTapActivity: (a) => _openEditor(activity: a),
              ),
          ],
        ),
      ),
    );
  }
}

enum _DayState { done, current, upcoming }

class _TimelineDay extends StatelessWidget {
  final int dayNumber;
  final ProgramDay? program;
  final List<TripActivity> activities;
  final DateTime? date;
  final _DayState state;
  final bool isLast;
  final VoidCallback? onAdd;
  final ValueChanged<TripActivity> onTapActivity;
  const _TimelineDay({
    required this.dayNumber,
    required this.program,
    required this.activities,
    required this.date,
    required this.state,
    required this.isLast,
    required this.onAdd,
    required this.onTapActivity,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final color = switch (state) {
      _DayState.done => AppColors.success,
      _DayState.current => AppColors.primary,
      _DayState.upcoming => AppColors.border,
    };
    final title = (program?.title ?? '').isNotEmpty ? program!.title : '${t('program_day')} $dayNumber';
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: state == _DayState.upcoming ? AppColors.surface : color,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: state == _DayState.done
                      ? const Icon(Icons.check, size: 15, color: Colors.white)
                      : Text('$dayNumber',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: state == _DayState.current ? Colors.white : AppColors.textSecondary,
                          )),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: state == _DayState.done ? AppColors.success : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                        if (state == _DayState.current) StatusPill.success(t('program_today')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        '${t('program_day')} $dayNumber',
                        if (date != null) _fmtDate(date!),
                        if ((program?.location ?? '').isNotEmpty) program!.location,
                      ].join(' · '),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    if (program != null && program!.steps.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      for (final s in program!.steps)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Icon(Icons.circle, size: 5, color: AppColors.textMuted),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(s, style: const TextStyle(fontSize: 12.5))),
                            ],
                          ),
                        ),
                    ],
                    if (activities.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      for (final a in activities) _ActivityTile(activity: a, onTap: () => onTapActivity(a)),
                    ],
                    if (onAdd != null)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: onAdd,
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(t('activity_add'), style: const TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final TripActivity activity;
  final VoidCallback onTap;
  const _ActivityTile({required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final time = formatActivityTime(activity.time, t);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(activityIcon(activity.type), size: 18, color: AppColors.primaryDark),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activityHeadline(activity, t),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    if ((activity.busName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.directions_bus_outlined, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(activity.busName!,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                    ],
                    if ((activity.notes ?? '').isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(activity.notes!, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              if (time.isNotEmpty)
                Text(time, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            ],
          ),
        ),
      ),
    );
  }
}

/// إضافة/تعديل نشاط: النوع، اليوم، الساعة، المكان (المزار)، والباص — يختاره
/// من باصات الرحلة أو يكتب اسمه.
class TripActivitySheet extends StatefulWidget {
  final int tripId;
  final TripActivity? activity;
  final int initialDay;
  final int maxDay;
  final List<Map<String, dynamic>> buses;
  final List<String> ziyarat;
  const TripActivitySheet({
    super.key,
    required this.tripId,
    required this.activity,
    required this.initialDay,
    required this.maxDay,
    required this.buses,
    required this.ziyarat,
  });

  @override
  State<TripActivitySheet> createState() => _TripActivitySheetState();
}

class _TripActivitySheetState extends State<TripActivitySheet> {
  late String type = widget.activity?.type ?? 'departure';
  late int day = widget.initialDay.clamp(1, _maxDay);
  late TimeOfDay? time = _parseTime(widget.activity?.time);
  late final placeCtrl = TextEditingController(text: widget.activity?.place ?? '');
  late final notesCtrl = TextEditingController(text: widget.activity?.notes ?? '');
  late final busLabelCtrl = TextEditingController(text: widget.activity?.busLabel ?? '');
  late int? busId = widget.activity?.busId;
  late bool customBus = widget.activity?.busId == null && (widget.activity?.busLabel ?? '').isNotEmpty;
  bool saving = false;

  int get _maxDay {
    final d = widget.activity?.dayNumber ?? 1;
    return widget.maxDay > d ? widget.maxDay : d;
  }

  static TimeOfDay? _parseTime(String? s) {
    final p = (s ?? '').split(':');
    if (p.length < 2) return null;
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    return (h == null || m == null) ? null : TimeOfDay(hour: h, minute: m);
  }

  @override
  void dispose() {
    placeCtrl.dispose();
    notesCtrl.dispose();
    busLabelCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.read<AppState>().t;
    setState(() => saving = true);
    final hhmm = time == null
        ? null
        : '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}';
    final label = busLabelCtrl.text.trim();
    final payload = TripActivity(
      id: widget.activity?.id ?? 0,
      dayNumber: day,
      time: hhmm,
      type: type,
      place: placeCtrl.text.trim().isEmpty ? null : placeCtrl.text.trim(),
      busId: customBus ? null : busId,
      busLabel: customBus && label.isNotEmpty ? label : null,
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
    ).toPayload();
    final err = await context
        .read<AppState>()
        .saveTripActivity(widget.tripId, payload, activityId: widget.activity?.id);
    if (!mounted) return;
    setState(() => saving = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(true);
    messenger.showSnackBar(SnackBar(content: Text(t('activity_saved'))));
  }

  Future<void> _delete() async {
    final t = context.read<AppState>().t;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('activity_delete_confirm')),
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
    setState(() => saving = true);
    final err = await context.read<AppState>().deleteTripActivity(widget.tripId, widget.activity!.id);
    if (!mounted) return;
    setState(() => saving = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    Widget label(String key) => Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(t(key), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        );
    final suggestions = type == 'ziyara' ? widget.ziyarat : const <String>[];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(t(widget.activity == null ? 'activity_add' : 'activity_edit'),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                  if (widget.activity != null)
                    IconButton(
                      onPressed: saving ? null : _delete,
                      icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                    ),
                ],
              ),
              label('activity_type'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final ty in activityTypes)
                    ChoiceChip(
                      avatar: Icon(activityIcon(ty), size: 16),
                      label: Text(t('activity_type_$ty')),
                      selected: type == ty,
                      onSelected: (_) => setState(() => type = ty),
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label('program_day'),
                        DropdownButtonFormField<int>(
                          initialValue: day,
                          isExpanded: true,
                          items: [
                            for (var d = 1; d <= _maxDay; d++)
                              DropdownMenuItem(value: d, child: Text('${t('program_day')} $d')),
                          ],
                          onChanged: (v) => setState(() => day = v ?? day),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label('activity_time'),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: time ?? const TimeOfDay(hour: 8, minute: 0),
                            );
                            if (picked != null) setState(() => time = picked);
                          },
                          icon: const Icon(Icons.schedule, size: 18),
                          label: Text(time == null
                              ? t('activity_pick_time')
                              : formatActivityTime('${time!.hour}:${time!.minute}', t)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              label(type == 'ziyara' ? 'activity_ziyara_name' : 'activity_place'),
              TextField(
                controller: placeCtrl,
                decoration: InputDecoration(
                  hintText: t(type == 'ziyara' ? 'activity_ziyara_hint' : 'activity_place_hint'),
                ),
              ),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final z in suggestions)
                      ActionChip(
                        label: Text(z, style: const TextStyle(fontSize: 12)),
                        onPressed: () => setState(() => placeCtrl.text = z),
                      ),
                  ],
                ),
              ],
              label('activity_bus'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ChoiceChip(
                    label: Text(t('activity_no_bus')),
                    selected: !customBus && busId == null,
                    onSelected: (_) => setState(() {
                      customBus = false;
                      busId = null;
                    }),
                  ),
                  for (final b in widget.buses)
                    ChoiceChip(
                      avatar: const Icon(Icons.directions_bus_outlined, size: 16),
                      label: Text('${b['label'] ?? ''}'),
                      selected: !customBus && busId == b['id'],
                      onSelected: (_) => setState(() {
                        customBus = false;
                        busId = b['id'] as int?;
                      }),
                    ),
                  ChoiceChip(
                    avatar: const Icon(Icons.edit_outlined, size: 16),
                    label: Text(t('activity_bus_other')),
                    selected: customBus,
                    onSelected: (_) => setState(() {
                      customBus = true;
                      busId = null;
                    }),
                  ),
                ],
              ),
              if (widget.buses.isEmpty && !customBus)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(t('activity_no_trip_buses'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ),
              if (customBus) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: busLabelCtrl,
                  decoration: InputDecoration(hintText: t('activity_bus_name_hint')),
                ),
              ],
              label('activity_notes'),
              TextField(
                controller: notesCtrl,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(hintText: t('activity_notes_hint')),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: saving ? null : _save,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(t('action_save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
