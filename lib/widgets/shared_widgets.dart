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
