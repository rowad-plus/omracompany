import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

extension NotificationKindX on NotificationKind {
  Color get color {
    switch (this) {
      case NotificationKind.info:
        return AppColors.info;
      case NotificationKind.warning:
        return AppColors.accent;
      case NotificationKind.danger:
        return AppColors.danger;
      case NotificationKind.success:
        return AppColors.success;
    }
  }
}

/// سهم "عرض التفاصيل" في نهاية صفوف القوائم. Flutter بينعكس تلقائيًا مع
/// اتجاه الصفحة الأساسي (RTL/LTR)، فبنثبّت شكل LTR الطبيعي (سهم لليمين)
/// ونسيب الانعكاس التلقائي يقلبه لليسار في اللغات RTL زي العربي والأردو.
class ForwardChevron extends StatelessWidget {
  final Color color;
  final double size;

  const ForwardChevron({super.key, this.color = AppColors.textMuted, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.chevron_right, size: size, color: color);
  }
}

/// بطاقة إحصائية صغيرة تُستخدم في شرائط الإحصائيات أعلى الشاشات.
class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const StatChip({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 19, fontWeight: FontWeight.bold, color: valueColor ?? AppColors.text)),
        ],
      ),
    );
  }
}

/// حالة نصية ملوّنة (Pill) — مستخدمة لعرض الحالة، الفئة، إلخ.
class StatusPill extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const StatusPill({super.key, required this.text, required this.background, required this.foreground});

  factory StatusPill.success(String text) =>
      StatusPill(text: text, background: AppColors.successLight, foreground: AppColors.success);
  factory StatusPill.warning(String text) =>
      StatusPill(text: text, background: AppColors.accentLight, foreground: AppColors.accent);
  factory StatusPill.danger(String text) =>
      StatusPill(text: text, background: AppColors.dangerLight, foreground: AppColors.danger);
  factory StatusPill.info(String text) =>
      StatusPill(text: text, background: AppColors.infoLight, foreground: AppColors.info);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: foreground)),
    );
  }
}

/// أفاتار دائري بسيط بحروف مبدئية.
class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color background;
  final Color foreground;
  final String? imageUrl;

  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 36,
    this.background = AppColors.primaryLight,
    this.foreground = AppColors.primaryDark,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallback(),
          loadingBuilder: (context, child, progress) => progress == null ? child : _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: background,
      child: Text(initials,
          style: TextStyle(color: foreground, fontWeight: FontWeight.bold, fontSize: size * 0.34)),
    );
  }
}

/// صف عنصر عام (اسم + وصف فرعي + عنصر جانبي اختياري) — بديل .row-item من الويب.
class InfoRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const InfoRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        leading,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
    if (onTap == null) return content;
    return InkWell(borderRadius: BorderRadius.circular(10), onTap: onTap, child: content);
  }
}

/// عنوان قسم مع رابط "عرض الكل" اختياري.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(context.watch<AppState>().t('see_all'),
                  style: const TextStyle(fontSize: 12.5, color: AppColors.primary)),
            ),
        ],
      ),
    );
  }
}

/// صف إشعار واحد (نقطة ملوّنة + نص + الوقت) — يُستخدم في الرئيسية وشاشة الإشعارات.
class NotifRow extends StatelessWidget {
  final Color color;
  final String text;
  final String time;

  const NotifRow({super.key, required this.color, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

/// حاوية بطاقة عامة موحّدة الشكل (بديل .card من الويب).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// Shown instead of an empty list when a load failed — "no data" must never
/// stand in for "couldn't load" or "not allowed".
class LoadErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const LoadErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppState>().t;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(t('retry')),
            ),
          ],
        ],
      ),
    );
  }
}

/// First visible letter of a name ("  Amr" → "A"), "؟" when empty.
String nameInitial(String? name) {
  final n = (name ?? '').trim();
  return n.isEmpty ? '؟' : n.characters.first;
}

/// Display name of a booking: the account holder's name.
String bookingName(Map<String, dynamic> b) =>
    ((b['user'] as Map<String, dynamic>?)?['name'] as String?)?.trim().isNotEmpty == true
        ? (b['user'] as Map<String, dynamic>)['name'] as String
        : '—';

/// "BK-00123 · 2 مقعد · 0501234567" — tells same-named pilgrims apart.
String bookingDetails(Map<String, dynamic> b, String seatUnit) {
  final ref = b['ref'] as String? ?? '#${b['id']}';
  final phone = (b['customer_phone'] ?? (b['user'] as Map<String, dynamic>?)?['phone']) as String?;
  return [
    ref,
    '${b['persons_count'] ?? 1} $seatUnit',
    if (phone != null && phone.isNotEmpty) phone,
  ].join(' · ');
}

/// Distinct departure days (Y-m-d) of [bookings], sorted.
List<String> departureDaysOf(Iterable<Map<String, dynamic>> bookings) {
  final days = bookings.map((b) => b['departure_date'] as String?).whereType<String>().toSet().toList()..sort();
  return days;
}

/// The day to open on: today or the nearest upcoming day, else the latest past one.
String? defaultDepartureDay(List<String> days) {
  if (days.isEmpty) return null;
  final now = DateTime.now();
  final today = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return days.firstWhere((d) => d.compareTo(today) >= 0, orElse: () => days.last);
}

/// Horizontal chips to pick which departure day's pilgrims are shown —
/// daily / recurring trips otherwise mix every day's pilgrims together.
class DepartureDayBar extends StatelessWidget {
  final List<String> days;
  final String? selected;
  final Map<String, int> counts;
  final ValueChanged<String> onSelect;
  const DepartureDayBar({super.key, required this.days, required this.selected, required this.onSelect, this.counts = const {}});

  String _label(String ymd, String Function(String) t) {
    final d = DateTime.tryParse(ymd);
    if (d == null) return ymd;
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) return t('today');
    return '${d.day}/${d.month}';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppState>().t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('departure_day'), style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = days[i];
              final on = d == selected;
              final c = counts[d];
              return ChoiceChip(
                selected: on,
                showCheckmark: false,
                label: Text(c == null ? _label(d, t) : '${_label(d, t)} ($c)'),
                labelStyle: TextStyle(fontSize: 12.5, color: on ? Colors.white : AppColors.text, fontWeight: FontWeight.w600),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                side: BorderSide(color: on ? AppColors.primary : AppColors.border),
                onSelected: (_) => onSelect(d),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// "اليوم" / "بكرة" / localized weekday + date for a Y-m-d departure day.
String departureDayLabel(BuildContext context, String ymd) {
  final d = DateTime.tryParse(ymd);
  if (d == null) return ymd;
  final t = context.read<AppState>().t;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff = DateTime(d.year, d.month, d.day).difference(today).inDays;
  final date = '${d.day}/${d.month}';
  if (diff == 0) return '${t('today')} · $date';
  if (diff == 1) return '${t('tomorrow')} · $date';
  final ml = MaterialLocalizations.of(context);
  // formatMediumDate gives e.g. "الأحد، ١٢ أكتوبر" / "Sun, Oct 12".
  return ml.formatMediumDate(d);
}

/// A trip as its own header with one row per departure day underneath —
/// a daily / recurring trip reads as "today's trip", "tomorrow's trip", …
/// for the next two weeks. [onOpen] gets the chosen day (null = whole trip,
/// used when the trip has no days in the window).
class TripDaysCard extends StatefulWidget {
  final ApiTrip trip;
  final void Function(String? day) onOpen;

  /// When true the day rows are hidden until the trip header is tapped
  /// (a toggle), keeping long trip lists short.
  final bool collapsible;

  /// Show only the first N days (null = all two weeks).
  final int? maxDays;
  const TripDaysCard({super.key, required this.trip, required this.onOpen, this.collapsible = false, this.maxDays});

  @override
  State<TripDaysCard> createState() => _TripDaysCardState();
}

class _TripDaysCardState extends State<TripDaysCard> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppState>().t;
    final trip = widget.trip;
    final onOpen = widget.onOpen;
    final all = trip.upcomingDays;
    final days = widget.maxDays == null ? all : all.take(widget.maxDays!).toList();
    final showDays = !widget.collapsible || open;
    final upcomingBookings = days.fold<int>(0, (n, d) => n + d.bookings);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: days.isEmpty
                ? () => onOpen(null)
                : widget.collapsible
                    ? () => setState(() => open = !open)
                    : null,
            child: InfoRow(
              leading: InitialsAvatar(initials: '🌙', size: 34, imageUrl: trip.thumbnail),
              title: trip.title,
              subtitle: days.isNotEmpty
                  ? '${days.length} ${t('departure_day')} · $upcomingBookings ${t('unit_booking')}'
                  : trip.daysKnown
                      ? t('no_days_in_two_weeks')
                      : '${trip.bookingsCount} ${t('unit_booking')}',
              trailing: days.isEmpty
                  ? const ForwardChevron()
                  : widget.collapsible
                      ? AnimatedRotation(
                          turns: open ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: const Icon(Icons.expand_more, color: AppColors.textSecondary),
                        )
                      : null,
            ),
          ),
          if (showDays)
          for (final d in days) ...[
            const Divider(height: 14, color: AppColors.border),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onOpen(d.date),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 8, top: 2, bottom: 2),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 30,
                      decoration: BoxDecoration(
                        color: d.bookings > 0 ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(departureDayLabel(context, d.date),
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.text)),
                          Text('${d.bookings} ${t('unit_booking')} · ${d.persons} ${t('unit_person')}',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: d.bookings > 0 ? AppColors.textSecondary : AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const ForwardChevron(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
