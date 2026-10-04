import 'package:flutter_test/flutter_test.dart';
import 'package:rowadplus/screens/trips/trip_program_screen.dart';

void main() {
  final now = DateTime(2026, 10, 4, 15); // الأحد

  test('one-time: in-progress run wins over later date', () {
    final r = TripRun.from({
      'schedule_type': 'one_time',
      'duration_days': 10,
      'trip_dates': [
        {'departure_date': '2026-10-01'},
        {'departure_date': '2026-10-20'},
      ],
    }, now)!;
    expect(r.isCurrent, true);
    expect(r.dayNumber(now), 4);
  });

  test('one-time: upcoming', () {
    final r = TripRun.from({
      'schedule_type': 'one_time',
      'duration_days': 5,
      'trip_dates': [
        {'departure_date': '2026-09-01'},
        {'departure_date': '2026-10-10'},
      ],
    }, now)!;
    expect(r.isCurrent, false);
    expect(r.daysUntil(now), 6);
  });

  test('weekly: departed Thursday, 7 days', () {
    final r = TripRun.from({
      'schedule_type': 'recurring',
      'recurrence_frequency': 'weekly',
      'recurrence_day_of_week': 4,
      'duration_days': 7,
    }, now)!;
    expect(r.isCurrent, true);
    expect(r.dayNumber(now), 4);
  });

  test('monthly: day 28, 3 days → next month in Oct', () {
    final r = TripRun.from({
      'schedule_type': 'recurring',
      'recurrence_frequency': 'monthly',
      'recurrence_day_of_month': 28,
      'duration_days': 3,
    }, now)!;
    expect(r.isCurrent, false);
    expect(r.start, DateTime(2026, 10, 28));
  });

  test('monthly in January looks back to December', () {
    final r = TripRun.from({
      'schedule_type': 'recurring',
      'recurrence_frequency': 'monthly',
      'recurrence_day_of_month': 30,
      'duration_days': 5,
    }, DateTime(2027, 1, 2))!;
    expect(r.isCurrent, true);
    expect(r.start, DateTime(2026, 12, 30));
  });
}
