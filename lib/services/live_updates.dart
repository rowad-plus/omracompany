import 'dart:async';

import 'package:flutter/widgets.dart';

/// إشارة "البيانات ممكن تكون اتغيرت على السيرفر" — الشاشات بتسمعها وتحدّث
/// نفسها في اللحظة من غير ما المستخدم يعمل رفرش أو يخرج ويدخل.
///
/// بتضرب في 3 حالات:
///  1. وصل إشعار Push والتطبيق مفتوح (حجز جديد، تأكيد، تسكين، دفع...) — فوري.
///  2. التطبيق رجع من الخلفية (المستخدم فتحه تاني أو داس على إشعار).
///  3. احتياطي: كل 30 ثانية والتطبيق مفتوح، لو الـ Push مش متاح على الجهاز
///     (إذن الإشعارات مرفوض مثلًا) — وكل 90 ثانية لو الـ Push شغال.
class LiveUpdates with WidgetsBindingObserver {
  LiveUpdates._();
  static final LiveUpdates instance = LiveUpdates._();

  final StreamController<void> _controller = StreamController<void>.broadcast();
  Timer? _timer;
  DateTime _lastPing = DateTime.fromMillisecondsSinceEpoch(0);
  bool _started = false;

  /// يتغيّر لـ true لما توكن الـ Push يتسجّل على السيرفر بنجاح.
  bool pushActive = false;

  Stream<void> get stream => _controller.stream;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (t) {
      // مع الـ Push شغال بنكتفي بتحديث كل 90 ثانية (كل تالت نبضة).
      if (pushActive && t.tick % 3 != 0) return;
      ping();
    });
  }

  /// يبلّغ كل الشاشات إن فيه تحديث. أكتر من نداء ورا بعض (إشعارين في نفس
  /// اللحظة مثلًا) بيتحسبوا تحديث واحد.
  void ping() {
    final now = DateTime.now();
    if (now.difference(_lastPing) < const Duration(seconds: 2)) return;
    _lastPing = now;
    _controller.add(null);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimer();
      ping();
    } else if (state == AppLifecycleState.paused) {
      // مفيش داعي نسحب بيانات والتطبيق في الخلفية — الـ Push بيكفي.
      _timer?.cancel();
    }
  }
}

/// لأي شاشة بتحمّل بياناتها بنفسها: بتنادي [onLiveUpdate] كل ما يحصل تحديث.
mixin LiveReload<T extends StatefulWidget> on State<T> {
  StreamSubscription<void>? _liveSub;

  Future<void> onLiveUpdate();

  @override
  void initState() {
    super.initState();
    _liveSub = LiveUpdates.instance.stream.listen((_) {
      if (mounted) onLiveUpdate();
    });
  }

  @override
  void dispose() {
    _liveSub?.cancel();
    super.dispose();
  }
}
