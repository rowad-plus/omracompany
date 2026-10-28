import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class _FamilyPriceRow {
  final personsCtrl = TextEditingController(text: '2');
  final priceCtrl = TextEditingController();
  void dispose() {
    personsCtrl.dispose();
    priceCtrl.dispose();
  }
}

class _ProgramDay {
  int dayNumber;
  final titleCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  List<TextEditingController> stepCtrls = [TextEditingController()];
  _ProgramDay(this.dayNumber);
  void dispose() {
    titleCtrl.dispose();
    locationCtrl.dispose();
    for (final c in stepCtrls) {
      c.dispose();
    }
  }
}

/// معالج إنشاء/تعديل برنامج عمرة — كل الحقول اللي الباك إند بيقبلها فعليًا
/// (جدولة، أسعار عائلية، برنامج يومي، خدمات وزيارات، صور) موصولة بالـ API.
/// لو اتبعت [editingTripId] الشاشة بتفتح في وضع التعديل وبتحمّل بيانات
/// البرنامج الموجودة قبل ما تعرض النموذج.
class TripWizardScreen extends StatefulWidget {
  final int? editingTripId;
  /// يفتح المعالج مباشرة على خطوة معينة (مثلاً 3 = البرنامج).
  final int initialStep;
  const TripWizardScreen({super.key, this.editingTripId, this.initialStep = 0});

  @override
  State<TripWizardScreen> createState() => _TripWizardScreenState();
}

class _TripWizardScreenState extends State<TripWizardScreen> with WidgetsBindingObserver {
  late int step = widget.initialStep;
  bool saving = false;
  bool loadingEditData = false;
  String? error;
  List<Map<String, dynamic>> existingImages = [];

  bool get isEdit => widget.editingTripId != null;

  // مسودة محلية لبرنامج جديد: لو خرج المستخدم في نص المعالج بنحفظ اللي كتبه
  // ونرجّعه أول ما يفتح المعالج تاني (الصور مش بتتحفظ).
  String _draftKey = 'trip_wizard_draft_0';
  bool draftRestored = false;
  bool _published = false;

  // ----- الخطوة 1: بيانات أساسية -----
  final titleCtrl = TextEditingController();
  int? cityId;
  final departureLocationCtrl = TextEditingController();
  String tripCategory = 'umrah';
  String type = 'economy';
  String status = 'active';
  String scheduleType = 'daily'; // one_time | recurring | daily
  final List<DateTime?> specificDates = [null];
  String recurrenceFrequency = 'weekly';
  int recurrenceDayOfWeek = 0;
  int recurrenceDayOfMonth = 1;
  String destMode = 'makkah_madinah';
  String destOrder = 'makkah_first';
  final durationCtrl = TextEditingController();
  final makkahDaysCtrl = TextEditingController();
  final madinahDaysCtrl = TextEditingController();
  final seatsCtrl = TextEditingController();

  // ----- الخطوة 2: التسعير -----
  final priceCtrl = TextEditingController();
  final List<_FamilyPriceRow> familyPrices = [];

  // ----- الخطوة 3: الفندق والغرف -----
  final hotelNameCtrl = TextEditingController();
  int hotelStars = 4;
  final hotelLocationCtrl = TextEditingController();
  final distanceCtrl = TextEditingController();
  final hotelNameMadinahCtrl = TextEditingController();
  int hotelStarsMadinah = 4;
  final hotelLocationMadinahCtrl = TextEditingController();
  final distanceMadinahCtrl = TextEditingController();
  final roomsSingleCtrl = TextEditingController();
  final roomsDoubleCtrl = TextEditingController();
  final roomsTripleCtrl = TextEditingController();
  final roomsQuadCtrl = TextEditingController();

  // ----- الخطوة 4: البرنامج اليومي -----
  final List<_ProgramDay> programs = [];

  // ----- الخطوة 5: الخدمات والزيارات -----
  bool hasGuide = true;
  bool hasVisits = true;
  final List<String> includedServices = [];
  final List<String> excludedServices = [];
  final List<String> ziyarat = [];
  final includedCtrl = TextEditingController();
  final excludedCtrl = TextEditingController();
  final ziyaratCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  // ----- الخطوة 6: الصور -----
  final List<XFile> images = [];
  final _picker = ImagePicker();

  static const stepTitleKeys = [
    'step1_title',
    'step2_title',
    'wizard_step_hotel',
    'step3_title',
    'wizard_step_services',
    'wizard_step_images',
  ];

  @override
  void initState() {
    super.initState();
    context.read<AppState>().fetchTripFormOptions();
    if (isEdit) {
      _loadEditData();
    } else {
      programs.add(_ProgramDay(1));
      _draftKey = 'trip_wizard_draft_${context.read<AppState>().activeCompanyId ?? 0}';
      WidgetsBinding.instance.addObserver(this);
      _restoreDraft();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.paused || s == AppLifecycleState.inactive) _saveDraft();
  }

  Map<String, dynamic> _draftData() => {
        'step': step,
        'title': titleCtrl.text,
        'city_id': cityId,
        'departure_location': departureLocationCtrl.text,
        'trip_category': tripCategory,
        'type': type,
        'status': status,
        'schedule_type': scheduleType,
        'specific_dates': specificDates.map((d) => d?.toIso8601String()).toList(),
        'recurrence_frequency': recurrenceFrequency,
        'recurrence_day_of_week': recurrenceDayOfWeek,
        'recurrence_day_of_month': recurrenceDayOfMonth,
        'dest_mode': destMode,
        'dest_order': destOrder,
        'duration': durationCtrl.text,
        'makkah_days': makkahDaysCtrl.text,
        'madinah_days': madinahDaysCtrl.text,
        'seats': seatsCtrl.text,
        'price': priceCtrl.text,
        'family_prices': [for (final f in familyPrices) {'persons': f.personsCtrl.text, 'price': f.priceCtrl.text}],
        'hotel_name': hotelNameCtrl.text,
        'hotel_stars': hotelStars,
        'hotel_location': hotelLocationCtrl.text,
        'distance': distanceCtrl.text,
        'hotel_name_madinah': hotelNameMadinahCtrl.text,
        'hotel_stars_madinah': hotelStarsMadinah,
        'hotel_location_madinah': hotelLocationMadinahCtrl.text,
        'distance_madinah': distanceMadinahCtrl.text,
        'rooms': [roomsSingleCtrl.text, roomsDoubleCtrl.text, roomsTripleCtrl.text, roomsQuadCtrl.text],
        'programs': [
          for (final p in programs)
            {'day': p.dayNumber, 'title': p.titleCtrl.text, 'location': p.locationCtrl.text, 'steps': p.stepCtrls.map((c) => c.text).toList()},
        ],
        'has_guide': hasGuide,
        'has_visits': hasVisits,
        'included': includedServices,
        'excluded': excludedServices,
        'ziyarat': ziyarat,
        'description': descriptionCtrl.text,
      };

  bool get _hasInput =>
      titleCtrl.text.trim().isNotEmpty ||
      cityId != null ||
      durationCtrl.text.trim().isNotEmpty ||
      priceCtrl.text.trim().isNotEmpty ||
      programs.any((p) => p.titleCtrl.text.trim().isNotEmpty);

  /// Builds the snapshot synchronously (controllers may be disposed right after).
  void _saveDraft() {
    if (isEdit || _published) return;
    final raw = _hasInput ? jsonEncode(_draftData()) : null;
    SharedPreferences.getInstance().then((p) => raw == null ? p.remove(_draftKey) : p.setString(_draftKey, raw));
  }

  Future<void> _clearDraft() async => (await SharedPreferences.getInstance()).remove(_draftKey);

  Future<void> _restoreDraft() async {
    final raw = (await SharedPreferences.getInstance()).getString(_draftKey);
    if (raw == null || !mounted) return;
    final Map<String, dynamic> d;
    try {
      d = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    String s(String k) => d[k] as String? ?? '';
    setState(() {
      draftRestored = true;
      step = (d['step'] as int? ?? 0).clamp(0, stepTitleKeys.length - 1);
      titleCtrl.text = s('title');
      cityId = d['city_id'] as int?;
      departureLocationCtrl.text = s('departure_location');
      tripCategory = d['trip_category'] as String? ?? tripCategory;
      type = d['type'] as String? ?? type;
      status = d['status'] as String? ?? status;
      scheduleType = d['schedule_type'] as String? ?? scheduleType;
      final dates = (d['specific_dates'] as List<dynamic>? ?? []).map((e) => e == null ? null : DateTime.tryParse(e as String)).toList();
      if (dates.isNotEmpty) {
        specificDates
          ..clear()
          ..addAll(dates);
      }
      recurrenceFrequency = d['recurrence_frequency'] as String? ?? recurrenceFrequency;
      recurrenceDayOfWeek = d['recurrence_day_of_week'] as int? ?? recurrenceDayOfWeek;
      recurrenceDayOfMonth = d['recurrence_day_of_month'] as int? ?? recurrenceDayOfMonth;
      destMode = d['dest_mode'] as String? ?? destMode;
      destOrder = d['dest_order'] as String? ?? destOrder;
      durationCtrl.text = s('duration');
      makkahDaysCtrl.text = s('makkah_days');
      madinahDaysCtrl.text = s('madinah_days');
      seatsCtrl.text = s('seats');
      priceCtrl.text = s('price');
      for (final f in (d['family_prices'] as List<dynamic>? ?? [])) {
        final row = _FamilyPriceRow();
        row.personsCtrl.text = f['persons'] as String? ?? '';
        row.priceCtrl.text = f['price'] as String? ?? '';
        familyPrices.add(row);
      }
      hotelNameCtrl.text = s('hotel_name');
      hotelStars = d['hotel_stars'] as int? ?? hotelStars;
      hotelLocationCtrl.text = s('hotel_location');
      distanceCtrl.text = s('distance');
      hotelNameMadinahCtrl.text = s('hotel_name_madinah');
      hotelStarsMadinah = d['hotel_stars_madinah'] as int? ?? hotelStarsMadinah;
      hotelLocationMadinahCtrl.text = s('hotel_location_madinah');
      distanceMadinahCtrl.text = s('distance_madinah');
      final rooms = (d['rooms'] as List<dynamic>? ?? []).cast<String>();
      final roomCtrls = [roomsSingleCtrl, roomsDoubleCtrl, roomsTripleCtrl, roomsQuadCtrl];
      for (var i = 0; i < rooms.length && i < roomCtrls.length; i++) {
        roomCtrls[i].text = rooms[i];
      }
      final days = d['programs'] as List<dynamic>? ?? [];
      if (days.isNotEmpty) {
        for (final p in programs) {
          p.dispose();
        }
        programs.clear();
        for (final p in days) {
          final day = _ProgramDay(p['day'] as int? ?? programs.length + 1);
          day.titleCtrl.text = p['title'] as String? ?? '';
          day.locationCtrl.text = p['location'] as String? ?? '';
          final steps = (p['steps'] as List<dynamic>? ?? []).cast<String>();
          day.stepCtrls = steps.isEmpty ? [TextEditingController()] : steps.map((x) => TextEditingController(text: x)).toList();
          programs.add(day);
        }
      }
      hasGuide = d['has_guide'] as bool? ?? hasGuide;
      hasVisits = d['has_visits'] as bool? ?? hasVisits;
      includedServices.addAll((d['included'] as List<dynamic>? ?? []).cast<String>());
      excludedServices.addAll((d['excluded'] as List<dynamic>? ?? []).cast<String>());
      ziyarat.addAll((d['ziyarat'] as List<dynamic>? ?? []).cast<String>());
      descriptionCtrl.text = s('description');
    });
  }

  Future<void> _startOver() async {
    await _clearDraft();
    _published = true; // don't re-save this screen's data on dispose
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TripWizardScreen()));
  }

  Future<void> _loadEditData() async {
    setState(() => loadingEditData = true);
    final data = await context.read<AppState>().fetchTripEditData(widget.editingTripId!);
    if (!mounted) return;
    setState(() => loadingEditData = false);

    if (data == null) {
      setState(() => error = t('err_trip_load_failed'));
      return;
    }

    setState(() {
      titleCtrl.text = data['title'] as String? ?? '';
      cityId = data['departure_city_id'] as int?;
      departureLocationCtrl.text = data['departure_location'] as String? ?? '';
      tripCategory = data['trip_category'] as String? ?? 'umrah';
      type = data['type'] as String? ?? 'economy';
      status = data['status'] as String? ?? 'draft';
      scheduleType = data['schedule_type'] as String? ?? 'daily';
      recurrenceFrequency = data['recurrence_frequency'] as String? ?? 'weekly';
      recurrenceDayOfWeek = data['recurrence_day_of_week'] as int? ?? 0;
      recurrenceDayOfMonth = data['recurrence_day_of_month'] as int? ?? 1;
      destMode = data['dest_mode'] as String? ?? 'makkah_madinah';
      destOrder = data['dest_order'] as String? ?? 'makkah_first';
      durationCtrl.text = '${data['duration_days'] ?? ''}';
      makkahDaysCtrl.text = '${data['makkah_days'] ?? ''}';
      madinahDaysCtrl.text = '${data['madinah_days'] ?? ''}';
      seatsCtrl.text = '${data['total_seats'] ?? ''}';

      priceCtrl.text = '${data['price'] ?? ''}';
      final prices = (data['family_prices'] as List<dynamic>? ?? []);
      for (final p in prices) {
        final row = _FamilyPriceRow();
        row.personsCtrl.text = '${p['persons_count'] ?? ''}';
        row.priceCtrl.text = '${p['price'] ?? ''}';
        familyPrices.add(row);
      }

      hotelNameCtrl.text = data['hotel_name'] as String? ?? '';
      hotelStars = data['hotel_stars'] as int? ?? 4;
      hotelLocationCtrl.text = data['hotel_location'] as String? ?? '';
      distanceCtrl.text = '${data['distance_from_haram'] ?? ''}';
      hotelNameMadinahCtrl.text = data['hotel_name_madinah'] as String? ?? '';
      hotelStarsMadinah = data['hotel_stars_madinah'] as int? ?? 4;
      hotelLocationMadinahCtrl.text = data['hotel_location_madinah'] as String? ?? '';
      distanceMadinahCtrl.text = '${data['distance_from_haram_madinah'] ?? ''}';
      roomsSingleCtrl.text = '${data['rooms_single'] ?? ''}';
      roomsDoubleCtrl.text = '${data['rooms_double'] ?? ''}';
      roomsTripleCtrl.text = '${data['rooms_triple'] ?? ''}';
      roomsQuadCtrl.text = '${data['rooms_quad'] ?? ''}';

      final days = (data['programs'] as List<dynamic>? ?? []);
      if (days.isEmpty) {
        programs.add(_ProgramDay(1));
      } else {
        for (final d in days) {
          final day = _ProgramDay(d['day_number'] as int? ?? programs.length + 1);
          day.titleCtrl.text = d['title'] as String? ?? '';
          day.locationCtrl.text = d['location'] as String? ?? '';
          final steps = (d['steps'] as List<dynamic>? ?? []);
          day.stepCtrls = steps.isEmpty
              ? [TextEditingController()]
              : steps.map((s) => TextEditingController(text: s as String)).toList();
          programs.add(day);
        }
      }

      hasGuide = data['has_guide'] as bool? ?? true;
      hasVisits = data['has_visits'] as bool? ?? true;
      includedServices.addAll((data['included_services'] as List<dynamic>? ?? []).cast<String>());
      excludedServices.addAll((data['excluded_services'] as List<dynamic>? ?? []).cast<String>());
      ziyarat.addAll((data['ziyarat'] as List<dynamic>? ?? []).cast<String>());
      descriptionCtrl.text = data['description'] as String? ?? '';

      existingImages = (data['images'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    });
  }

  @override
  void dispose() {
    if (!isEdit) {
      _saveDraft();
      WidgetsBinding.instance.removeObserver(this);
    }
    titleCtrl.dispose();
    departureLocationCtrl.dispose();
    durationCtrl.dispose();
    makkahDaysCtrl.dispose();
    madinahDaysCtrl.dispose();
    seatsCtrl.dispose();
    priceCtrl.dispose();
    hotelNameCtrl.dispose();
    hotelLocationCtrl.dispose();
    distanceCtrl.dispose();
    hotelNameMadinahCtrl.dispose();
    hotelLocationMadinahCtrl.dispose();
    distanceMadinahCtrl.dispose();
    roomsSingleCtrl.dispose();
    roomsDoubleCtrl.dispose();
    roomsTripleCtrl.dispose();
    roomsQuadCtrl.dispose();
    includedCtrl.dispose();
    excludedCtrl.dispose();
    ziyaratCtrl.dispose();
    descriptionCtrl.dispose();
    for (final f in familyPrices) {
      f.dispose();
    }
    for (final p in programs) {
      p.dispose();
    }
    super.dispose();
  }

  String t(String key) => context.watch<AppState>().t(key);

  void _next() {
    if (step == 0) {
      if (titleCtrl.text.trim().isEmpty || cityId == null || durationCtrl.text.trim().isEmpty) {
        setState(() => error = t('err_trip_basic_required'));
        return;
      }
    }
    if (step == 1 && priceCtrl.text.trim().isEmpty) {
      setState(() => error = t('err_trip_price_required'));
      return;
    }
    setState(() => error = null);
    if (step < stepTitleKeys.length - 1) {
      setState(() => step++);
      _saveDraft();
    } else {
      _submit();
    }
  }

  void _prev() {
    setState(() => step = (step - 1).clamp(0, stepTitleKeys.length - 1));
    _saveDraft();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) setState(() => images.addAll(picked));
  }

  Future<void> _submit() async {
    setState(() {
      saving = true;
      error = null;
    });

    final data = <String, dynamic>{
      'departure_city_id': cityId,
      if (departureLocationCtrl.text.trim().isNotEmpty) 'departure_location': departureLocationCtrl.text.trim(),
      'title': titleCtrl.text.trim(),
      'trip_category': tripCategory,
      'type': type,
      'status': status,
      'schedule_type': scheduleType,
      'price': double.tryParse(priceCtrl.text.trim()) ?? 0,
      'duration_days': int.tryParse(durationCtrl.text.trim()) ?? 1,
      'dest_mode': destMode,
      'dest_order': destMode == 'makkah_madinah' ? destOrder : null,
      'makkah_days': int.tryParse(makkahDaysCtrl.text.trim()),
      'madinah_days': destMode == 'makkah_madinah' ? int.tryParse(madinahDaysCtrl.text.trim()) : null,
      'total_seats': int.tryParse(seatsCtrl.text.trim()),
      if (scheduleType == 'recurring') 'recurrence_frequency': recurrenceFrequency,
      if (scheduleType == 'recurring' && recurrenceFrequency == 'weekly') 'recurrence_day_of_week': recurrenceDayOfWeek,
      if (scheduleType == 'recurring' && recurrenceFrequency == 'monthly') 'recurrence_day_of_month': recurrenceDayOfMonth,
      if (scheduleType == 'one_time')
        'trip_dates': specificDates
            .where((d) => d != null)
            .map((d) => {'departure_date': d!.toIso8601String().split('T').first})
            .toList(),
      if (hotelNameCtrl.text.trim().isNotEmpty) ...{
        'hotel_name': hotelNameCtrl.text.trim(),
        'hotel_stars': hotelStars,
        'hotel_location': hotelLocationCtrl.text.trim(),
        'distance_from_haram': int.tryParse(distanceCtrl.text.trim()),
      },
      if (destMode == 'makkah_madinah' && hotelNameMadinahCtrl.text.trim().isNotEmpty) ...{
        'hotel_name_madinah': hotelNameMadinahCtrl.text.trim(),
        'hotel_stars_madinah': hotelStarsMadinah,
        'hotel_location_madinah': hotelLocationMadinahCtrl.text.trim(),
        'distance_from_haram_madinah': int.tryParse(distanceMadinahCtrl.text.trim()),
      },
      'rooms_single': int.tryParse(roomsSingleCtrl.text.trim()),
      'rooms_double': int.tryParse(roomsDoubleCtrl.text.trim()),
      'rooms_triple': int.tryParse(roomsTripleCtrl.text.trim()),
      'rooms_quad': int.tryParse(roomsQuadCtrl.text.trim()),
      'has_guide': hasGuide,
      'has_visits': hasVisits,
      'description': descriptionCtrl.text.trim().isEmpty ? null : descriptionCtrl.text.trim(),
      'included_services': includedServices,
      'excluded_services': excludedServices,
      'ziyarat': ziyarat,
      'family_prices': [
        for (final f in familyPrices)
          if (f.personsCtrl.text.trim().isNotEmpty && f.priceCtrl.text.trim().isNotEmpty)
            {'persons_count': int.tryParse(f.personsCtrl.text.trim()), 'price': double.tryParse(f.priceCtrl.text.trim())},
      ],
      'programs': [
        for (final p in programs)
          if (p.titleCtrl.text.trim().isNotEmpty)
            {
              'day_number': p.dayNumber,
              'title': p.titleCtrl.text.trim(),
              'location': p.locationCtrl.text.trim().isEmpty ? null : p.locationCtrl.text.trim(),
              'steps': p.stepCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
            },
      ],
    };

    final imageBytes = <List<int>>[];
    for (final img in images) {
      imageBytes.add(await img.readAsBytes());
    }

    final result = isEdit
        ? await context.read<AppState>().updateTrip(widget.editingTripId!, data, images: imageBytes)
        : await context.read<AppState>().createTrip(data, images: imageBytes);
    if (!mounted) return;
    setState(() => saving = false);

    if (result == null) {
      if (!isEdit) {
        _published = true;
        await _clearDraft();
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? t('wizard_updated_snackbar') : t('wizard_published_snackbar'))));
    } else {
      setState(() => error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? t('wizard_edit_title') : t('wizard_title')), foregroundColor: AppColors.text),
      body: (state.tripFormOptionsLoading && state.tripFormCities.isEmpty) || loadingEditData
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (step + 1) / stepTitleKeys.length,
                          minHeight: 5,
                          backgroundColor: AppColors.surface2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                          '${t('wizard_step_word')} ${step + 1} ${t('wizard_of_word')} ${stepTitleKeys.length} — ${t(stepTitleKeys[step])}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                if (draftRestored)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(Icons.restore, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(t('wizard_draft_restored'), style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary))),
                          TextButton(onPressed: saving ? null : _startOver, child: Text(t('action_start_over'), style: const TextStyle(fontSize: 12))),
                        ],
                      ),
                    ),
                  ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(10)),
                      child: Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [_buildStep(state)],
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                    child: Row(
                      children: [
                        if (step > 0) ...[
                          SizedBox(
                            width: 46,
                            height: 46,
                            child: OutlinedButton(
                              onPressed: saving ? null : _prev,
                              style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                              child: const Icon(Icons.arrow_back, size: 18),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: saving ? null : _next,
                            child: saving
                                ? const SizedBox(
                                    height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(step == stepTitleKeys.length - 1
                                          ? (isEdit ? t('action_save_changes') : t('wizard_publish'))
                                          : t('wizard_next')),
                                      const SizedBox(width: 6),
                                      Icon(step == stepTitleKeys.length - 1 ? Icons.check : Icons.arrow_forward, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStep(AppState state) {
    switch (step) {
      case 0:
        return _stepBasicInfo(state);
      case 1:
        return _stepPricing();
      case 2:
        return _stepHotel();
      case 3:
        return _stepProgram();
      case 4:
        return _stepServices();
      default:
        return _stepImages();
    }
  }

  Widget _stepBasicInfo(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(controller: titleCtrl, decoration: InputDecoration(labelText: t('field_program_name'))),
        const SizedBox(height: 14),
        _cityField(state.tripFormCities),
        const SizedBox(height: 8),
        Text(t('wizard_departure_location_hint'), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        TextField(
          controller: departureLocationCtrl,
          decoration: InputDecoration(labelText: t('wizard_departure_location')),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: tripCategory,
                decoration: InputDecoration(labelText: t('label_program')),
                items: [
                  DropdownMenuItem(value: 'umrah', child: Text(t('trip_category_umrah'))),
                  DropdownMenuItem(value: 'hajj', child: Text(t('trip_category_hajj'))),
                  DropdownMenuItem(value: 'combined', child: Text(t('trip_category_combined'))),
                ],
                onChanged: (v) => setState(() => tripCategory = v ?? tripCategory),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: type,
                decoration: InputDecoration(labelText: t('field_trip_class')),
                items: [
                  DropdownMenuItem(value: 'economy', child: Text(t('tier_economy'))),
                  DropdownMenuItem(value: 'premium', child: Text(t('tier_premium'))),
                  DropdownMenuItem(value: 'vip', child: Text(t('opt_luxury_vip'))),
                ],
                onChanged: (v) => setState(() => type = v ?? type),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: status,
          decoration: InputDecoration(labelText: t('field_status')),
          items: [
            DropdownMenuItem(value: 'active', child: Text(t('status_active'))),
            DropdownMenuItem(value: 'draft', child: Text(t('status_draft'))),
            DropdownMenuItem(value: 'inactive', child: Text(t('status_stopped'))),
          ],
          onChanged: (v) => setState(() => status = v ?? status),
        ),
        const SizedBox(height: 18),
        Text(t('schedule_system_label'), style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _scheduleOption('daily', Icons.repeat, t('schedule_daily_title'), t('schedule_daily_desc'))),
            const SizedBox(width: 8),
            Expanded(child: _scheduleOption('one_time', Icons.push_pin_outlined, t('schedule_specific_title'), t('schedule_specific_desc'))),
            const SizedBox(width: 8),
            Expanded(
                child: _scheduleOption('recurring', Icons.event_repeat_outlined, t('schedule_recurring_title'), t('schedule_recurring_desc'))),
          ],
        ),
        const SizedBox(height: 4),
        if (scheduleType == 'one_time') _specificDatesSection(),
        if (scheduleType == 'recurring') _recurringScheduleSection(),
        const SizedBox(height: 14),
        Text(t('destination_label'), style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        _destinationOption('makkah_madinah', t('destination_both_title'), t('destination_both_desc')),
        _destinationOption('makkah_only', t('destination_mecca_title'), t('destination_mecca_desc')),
        if (destMode == 'makkah_madinah') ...[
          const SizedBox(height: 10),
          Text(t('city_order_label'), style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _cityOrderOption('makkah_first', t('city_order_mecca_first'))),
              const SizedBox(width: 8),
              Expanded(child: _cityOrderOption('madinah_first', t('city_order_medina_first'))),
            ],
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t('fact_duration')),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: seatsCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t('fact_seats')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: makkahDaysCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t('field_days_in_mecca')),
              ),
            ),
            if (destMode == 'makkah_madinah') ...[
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: madinahDaysCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: t('field_days_in_medina')),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Arabic-insensitive key for sorting/searching city names (أ/إ/آ→ا، ة→ه، ى→ي).
  static String _cityKey(String s) => s
      .trim()
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll(RegExp(r'^ال'), '')
      .toLowerCase();

  /// مدينة الانطلاق: قائمة مرتبة أبجديًا مع بحث، بدل القائمة المنسدلة الطويلة.
  Widget _cityField(List<SaudiCity> cities) {
    final selected = cities.where((c) => c.id == cityId).firstOrNull;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _pickCity(cities),
      child: InputDecorator(
        isEmpty: selected == null,
        decoration: InputDecoration(labelText: t('field_departure_city'), suffixIcon: const Icon(Icons.arrow_drop_down)),
        child: Text(selected?.name ?? ''),
      ),
    );
  }

  Future<void> _pickCity(List<SaudiCity> cities) async {
    final sorted = [...cities]..sort((a, b) => _cityKey(a.name).compareTo(_cityKey(b.name)));
    final searchHint = context.read<AppState>().t('search_city_hint');
    final emptyText = context.read<AppState>().t('search_city_empty');
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        var query = '';
        return StatefulBuilder(builder: (ctx, setSheet) {
          final q = _cityKey(query);
          final list = q.isEmpty ? sorted : sorted.where((c) => _cityKey(c.name).contains(q)).toList();
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.75,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(hintText: searchHint, prefixIcon: const Icon(Icons.search)),
                      onChanged: (v) => setSheet(() => query = v),
                    ),
                  ),
                  Expanded(
                    child: list.isEmpty
                        ? Center(child: Text(emptyText, style: const TextStyle(color: AppColors.textMuted)))
                        : ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (_, i) => ListTile(
                              title: Text(list[i].name),
                              trailing: list[i].id == cityId ? const Icon(Icons.check, color: AppColors.primary) : null,
                              onTap: () => Navigator.of(ctx).pop(list[i].id),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
    if (picked != null && mounted) setState(() => cityId = picked);
  }

  /// Compares a private-room row with the shared-room price for the same
  /// group (per-person price × persons), which is what customers pay when
  /// they don't choose a private room.
  Widget _familyRowHint(_FamilyPriceRow row) {
    final n = int.tryParse(row.personsCtrl.text.trim());
    final price = double.tryParse(row.priceCtrl.text.trim());
    final unit = double.tryParse(priceCtrl.text.trim());
    String text = '';
    Color color = AppColors.textSecondary;
    if (n == 1) {
      text = t('family_pricing_one_person_warning');
      color = AppColors.danger;
    } else if (n != null && n > 1 && unit != null && unit > 0) {
      final shared = unit * n;
      if (price != null && price > 0 && price < shared) {
        text = '${t('family_pricing_cheaper_warning')} (${shared.toStringAsFixed(0)})';
        color = AppColors.danger;
      } else {
        text = '${t('family_pricing_shared_hint')} $n × ${unit.toStringAsFixed(0)} = ${shared.toStringAsFixed(0)}';
      }
    }
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 4, left: 4),
      child: Text(text, style: TextStyle(fontSize: 11, color: color)),
    );
  }

  Widget _stepPricing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: priceCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: t('field_price_per_person')),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 18),
        Text(t('family_pricing_label'),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(t('family_pricing_hint'), style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        for (var i = 0; i < familyPrices.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: familyPrices[i].personsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: t('room_occupant_count_label')),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: familyPrices[i].priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: t('field_price_paid')),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppColors.danger),
                      onPressed: () => setState(() {
                        familyPrices[i].dispose();
                        familyPrices.removeAt(i);
                      }),
                    ),
                  ],
                ),
                _familyRowHint(familyPrices[i]),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: familyPrices.length >= 10 ? null : () => setState(() => familyPrices.add(_FamilyPriceRow())),
          icon: const Icon(Icons.add, size: 18),
          label: Text(t('action_add_family_pricing')),
        ),
      ],
    );
  }

  Widget _stepHotel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('fact_hotel_mecca'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(controller: hotelNameCtrl, decoration: InputDecoration(labelText: t('field_hotel_name'))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: hotelStars,
                decoration: InputDecoration(labelText: t('field_star_count')),
                items: [5, 4, 3, 2, 1].map((s) => DropdownMenuItem(value: s, child: Text('$s ${t('unit_stars')}'))).toList(),
                onChanged: (v) => setState(() => hotelStars = v ?? hotelStars),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: distanceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t('field_distance_from_haram')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(controller: hotelLocationCtrl, decoration: InputDecoration(labelText: t('field_city'))),
        if (destMode == 'makkah_madinah') ...[
          const SizedBox(height: 20),
          Text(t('fact_hotel_medina'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: hotelNameMadinahCtrl, decoration: InputDecoration(labelText: t('field_hotel_name'))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: hotelStarsMadinah,
                  decoration: InputDecoration(labelText: t('field_star_count')),
                  items: [5, 4, 3, 2, 1].map((s) => DropdownMenuItem(value: s, child: Text('$s ${t('unit_stars')}'))).toList(),
                  onChanged: (v) => setState(() => hotelStarsMadinah = v ?? hotelStarsMadinah),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: distanceMadinahCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: t('field_distance_from_haram')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(controller: hotelLocationMadinahCtrl, decoration: InputDecoration(labelText: t('field_city'))),
        ],
        const SizedBox(height: 20),
        Text(t('wizard_rooms_label'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: TextField(controller: roomsSingleCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('wizard_room_single')))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: roomsDoubleCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('wizard_room_double')))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: TextField(controller: roomsTripleCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('wizard_room_triple')))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: roomsQuadCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('wizard_room_quad')))),
          ],
        ),
      ],
    );
  }

  Widget _stepProgram() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var di = 0; di < programs.length; di++)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${t('day_word_prefix')} ${programs[di].dayNumber}',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    if (programs.length > 1)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: AppColors.danger),
                        onPressed: () => setState(() {
                          programs[di].dispose();
                          programs.removeAt(di);
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(controller: programs[di].titleCtrl, decoration: InputDecoration(labelText: t('field_day_title'))),
                const SizedBox(height: 10),
                TextField(controller: programs[di].locationCtrl, decoration: InputDecoration(labelText: t('field_city'))),
                const SizedBox(height: 10),
                for (var si = 0; si < programs[di].stepCtrls.length; si++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: programs[di].stepCtrls[si],
                            decoration: InputDecoration(
                                labelText: programs[di].stepCtrls.length > 1 ? '${t('field_activity')} ${si + 1}' : t('field_day_activities')),
                          ),
                        ),
                        if (programs[di].stepCtrls.length > 1)
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                            onPressed: () => setState(() {
                              programs[di].stepCtrls[si].dispose();
                              programs[di].stepCtrls.removeAt(si);
                            }),
                          ),
                      ],
                    ),
                  ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => setState(() => programs[di].stepCtrls.add(TextEditingController())),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(t('action_add_activity')),
                  ),
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: () => setState(() => programs.add(_ProgramDay(programs.length + 1))),
          icon: const Icon(Icons.add, size: 18),
          label: Text(t('action_add_new_day')),
        ),
      ],
    );
  }

  Widget _stepServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: hasGuide,
          title: Text(t('wizard_has_guide'), style: const TextStyle(fontSize: 13)),
          onChanged: (v) => setState(() => hasGuide = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: hasVisits,
          title: Text(t('wizard_has_visits'), style: const TextStyle(fontSize: 13)),
          onChanged: (v) => setState(() => hasVisits = v),
        ),
        const SizedBox(height: 10),
        _tagInput(t('services_label'), includedCtrl, includedServices),
        const SizedBox(height: 16),
        _tagInput(t('wizard_excluded_services'), excludedCtrl, excludedServices),
        const SizedBox(height: 16),
        _tagInput(t('wizard_ziyarat'), ziyaratCtrl, ziyarat),
        const SizedBox(height: 16),
        TextField(
          controller: descriptionCtrl,
          maxLines: 5,
          decoration: InputDecoration(labelText: t('field_detailed_description')),
        ),
      ],
    );
  }

  Widget _tagInput(String label, TextEditingController ctrl, List<String> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) {
                    setState(() {
                      list.add(v.trim());
                      ctrl.clear();
                    });
                  }
                },
                decoration: InputDecoration(hintText: t('wizard_add_tag_hint')),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  setState(() {
                    list.add(ctrl.text.trim());
                    ctrl.clear();
                  });
                }
              },
            ),
          ],
        ),
        if (list.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: list
                .map((s) => Chip(
                      label: Text(s, style: const TextStyle(fontSize: 11.5)),
                      onDeleted: () => setState(() => list.remove(s)),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Future<void> _removeExistingImage(int index) async {
    final img = existingImages[index];
    final result = await context.read<AppState>().deleteTripImage(img['id'] as int);
    if (!mounted) return;
    if (result == null) {
      setState(() => existingImages.removeAt(index));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  Widget _stepImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 28, color: AppColors.textMuted),
                const SizedBox(height: 8),
                Text(t('upload_photos_hint'), style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
              ],
            ),
          ),
        ),
        if (existingImages.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < existingImages.length; i++)
                Stack(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                        image: DecorationImage(image: NetworkImage(existingImages[i]['url'] as String), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.cancel, size: 20, color: AppColors.danger),
                        onPressed: () => _removeExistingImage(i),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
        if (images.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < images.length; i++)
                Stack(
                  children: [
                    FutureBuilder<Uint8List>(
                      future: images[i].readAsBytes(),
                      builder: (ctx, snap) => Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                          image: snap.hasData ? DecorationImage(image: MemoryImage(snap.data!), fit: BoxFit.cover) : null,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.cancel, size: 20, color: AppColors.danger),
                        onPressed: () => setState(() => images.removeAt(i)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _scheduleOption(String value, IconData icon, String title, String subtitle) {
    final selected = scheduleType == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => scheduleType = value),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.surface,
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate(DateTime? initial, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2045),
    );
    if (picked != null) onPicked(picked);
  }

  Widget _specificDatesSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < specificDates.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(specificDates[i], (d) => setState(() => specificDates[i] = d)),
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: t('field_repeats_every')),
                        child: Text(specificDates[i] != null ? _fmtDate(specificDates[i]!) : '—', style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () => setState(() => specificDates.removeAt(i)),
                      style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => setState(() => specificDates.add(null)),
            icon: const Icon(Icons.add, size: 18),
            label: Text(t('action_add_date')),
          ),
        ],
      ),
    );
  }

  static const _weekdayKeys = ['weekday_sun', 'weekday_mon', 'weekday_tue', 'weekday_wed', 'weekday_thu', 'weekday_fri', 'weekday_sat'];

  Widget _recurringScheduleSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: recurrenceFrequency,
            decoration: InputDecoration(labelText: t('field_repeats_every')),
            items: [
              DropdownMenuItem(value: 'weekly', child: Text(t('unit_week'))),
              DropdownMenuItem(value: 'monthly', child: Text(t('unit_month'))),
            ],
            onChanged: (v) => setState(() => recurrenceFrequency = v ?? recurrenceFrequency),
          ),
          const SizedBox(height: 14),
          if (recurrenceFrequency == 'weekly') ...[
            Text(t('field_repeat_days_label'), style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _weekdayKeys.length; i++)
                  ChoiceChip(
                    label: Text(t(_weekdayKeys[i])),
                    selected: recurrenceDayOfWeek == i,
                    onSelected: (_) => setState(() => recurrenceDayOfWeek = i),
                  ),
              ],
            ),
          ] else
            DropdownButtonFormField<int>(
              value: recurrenceDayOfMonth,
              decoration: InputDecoration(labelText: t('field_day_of_month')),
              items: [for (var d = 1; d <= 31; d++) DropdownMenuItem(value: d, child: Text('$d'))],
              onChanged: (v) => setState(() => recurrenceDayOfMonth = v ?? recurrenceDayOfMonth),
            ),
        ],
      ),
    );
  }

  Widget _destinationOption(String value, String title, String subtitle) {
    final selected = destMode == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => destMode = value),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.surface,
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.mosque_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cityOrderOption(String value, String title) {
    final selected = destOrder == value;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => destOrder = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(title, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}
