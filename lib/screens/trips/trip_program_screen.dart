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

String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

/// بنر "البرنامج" في صفحة الرحلة — زي التتبع: اليوم الحالي + شريط تقدم.
class TripProgramBanner extends StatelessWidget {
  final Map<String, dynamic>? data;
  final bool loading;
  final VoidCallback onOpen;
  final VoidCallback onDefine;
  const TripProgramBanner({
    super.key,
    required this.data,
    required this.loading,
    required this.onOpen,
    required this.onDefine,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final days = ProgramDay.listFrom(data);
    final run = TripRun.from(data, DateTime.now());
    final hasProgram = days.isNotEmpty;

    String headline;
    String? sub;
    double? progress;
    if (loading && data == null) {
      headline = t('program_banner_title');
    } else if (!hasProgram) {
      headline = t('program_not_defined');
      sub = t('program_define_hint');
    } else if (run != null && run.isCurrent) {
      final d = run.dayNumber(DateTime.now());
      final today = days.where((p) => p.dayNumber == d);
      headline = t('trip_day_of').replaceAll('{d}', '$d').replaceAll('{n}', '${run.durationDays}');
      sub = today.isEmpty ? null : [today.first.title, today.first.location].where((s) => s.isNotEmpty).join(' — ');
      progress = (d / run.durationDays).clamp(0.0, 1.0);
    } else if (run != null) {
      final n = run.daysUntil(DateTime.now());
      headline = n == 0
          ? t('trip_starts_today')
          : n == 1
              ? t('trip_starts_tomorrow')
              : t('trip_in_days').replaceAll('{n}', '$n');
      sub = '${_fmtDate(run.start)} — ${days.length} ${t('unit_days')}';
      progress = 0;
    } else {
      headline = t('program_banner_title');
      sub = '${days.length} ${t('unit_days')}';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasProgram ? onOpen : onDefine,
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

/// صفحة البرنامج كخط زمني (تتبع): الأيام المنتهية ✓، اليوم الحالي مميز، والباقي قادم.
class TripProgramScreen extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  const TripProgramScreen({super.key, required this.title, required this.data, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    final days = ProgramDay.listFrom(data);
    final run = TripRun.from(data, DateTime.now());
    final currentDay = (run != null && run.isCurrent) ? run.dayNumber(DateTime.now()) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('program_banner_title')),
        foregroundColor: AppColors.text,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: t('program_define'),
            onPressed: () {
              Navigator.of(context).pop();
              onEdit();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          if (run != null) ...[
            const SizedBox(height: 4),
            Text(
              '${_fmtDate(run.start)} → ${_fmtDate(run.start.add(Duration(days: run.durationDays - 1)))}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 18),
          for (var i = 0; i < days.length; i++)
            _TimelineDay(
              day: days[i],
              date: run?.start.add(Duration(days: days[i].dayNumber - 1)),
              state: currentDay == null
                  ? _DayState.upcoming
                  : days[i].dayNumber < currentDay
                      ? _DayState.done
                      : days[i].dayNumber == currentDay
                          ? _DayState.current
                          : _DayState.upcoming,
              isLast: i == days.length - 1,
              t: t,
            ),
        ],
      ),
    );
  }
}

enum _DayState { done, current, upcoming }

class _TimelineDay extends StatelessWidget {
  final ProgramDay day;
  final DateTime? date;
  final _DayState state;
  final bool isLast;
  final String Function(String) t;
  const _TimelineDay({required this.day, required this.date, required this.state, required this.isLast, required this.t});

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _DayState.done => AppColors.success,
      _DayState.current => AppColors.primary,
      _DayState.upcoming => AppColors.border,
    };
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
                      : Text('${day.dayNumber}',
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
                          child: Text(
                            day.title.isNotEmpty ? day.title : '${t('program_day')} ${day.dayNumber}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (state == _DayState.current) StatusPill.success(t('program_today')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        '${t('program_day')} ${day.dayNumber}',
                        if (date != null) _fmtDate(date!),
                        if (day.location.isNotEmpty) day.location,
                      ].join(' · '),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    if (day.steps.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      for (final s in day.steps)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Icon(Icons.circle, size: 5, color: color == AppColors.border ? AppColors.textMuted : color),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(s, style: const TextStyle(fontSize: 12.5))),
                            ],
                          ),
                        ),
                    ],
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
