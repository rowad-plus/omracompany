import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// تحديد نقطة الانطلاق (تجمّع المعتمرين) على خريطة مجانية (OpenStreetMap،
/// من غير أي مفتاح API): الخريطة بتتحرك وتتكبّر، والنقطة بتتحدد بالضغط
/// عليها أو من زر "موقعي الحالي" أو من البحث الصغير داخل الخريطة (Nominatim،
/// بحث مجاني تابع لـ OpenStreetMap). العنوان النصي اختياري ويتملا تلقائيًا
/// لو كان فاضي.
class DeparturePointSheet extends StatefulWidget {
  final ApiTrip trip;
  const DeparturePointSheet({super.key, required this.trip});

  @override
  State<DeparturePointSheet> createState() => _DeparturePointSheetState();
}

class _DeparturePointSheetState extends State<DeparturePointSheet> {
  static const _defaultCenter = LatLng(21.4225, 39.8262); // مكة المكرمة
  static const _nominatimHeaders = {'User-Agent': 'RowadPlusProviderApp/1.0'};

  late final TextEditingController locationCtrl;
  final searchCtrl = TextEditingController();
  final searchFocus = FocusNode();
  final mapController = MapController();
  late LatLng markerPosition;
  bool hasMarker = false;
  bool saving = false;
  bool searching = false;
  bool locating = false;
  String? error;
  String? mapNote;
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    locationCtrl = TextEditingController(text: widget.trip.departureLocation ?? '');
    hasMarker = widget.trip.departureLatitude != null && widget.trip.departureLongitude != null;
    markerPosition = hasMarker
        ? LatLng(widget.trip.departureLatitude!, widget.trip.departureLongitude!)
        : _defaultCenter;
  }

  @override
  void dispose() {
    locationCtrl.dispose();
    searchCtrl.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  String _t(String key) => context.read<AppState>().t(key);

  /// Places the marker at [point]; fills the text address from the map when
  /// the supervisor hasn't typed one.
  void _setPoint(LatLng point, {double? zoom, String? label}) {
    setState(() {
      markerPosition = point;
      hasMarker = true;
      searchResults = [];
      mapNote = null;
    });
    if (zoom != null) mapController.move(point, zoom);
    if (locationCtrl.text.trim().isEmpty) {
      if (label != null) {
        locationCtrl.text = label;
      } else {
        _fillAddress(point);
      }
    }
  }

  Future<void> _fillAddress(LatLng point) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'json',
        'zoom': '18',
        'accept-language': 'ar',
        'lat': '${point.latitude}',
        'lon': '${point.longitude}',
      });
      final res = await http.get(uri, headers: _nominatimHeaders).timeout(const Duration(seconds: 10));
      if (!mounted || res.statusCode != 200) return;
      final name = (jsonDecode(res.body) as Map<String, dynamic>)['display_name'] as String?;
      // Only if still empty and the point hasn't moved meanwhile.
      if (name != null && locationCtrl.text.trim().isEmpty && point == markerPosition) {
        locationCtrl.text = name;
      }
    } catch (_) {
      // Address is optional — the point itself is what matters.
    }
  }

  Future<void> _search() async {
    final query = searchCtrl.text.trim();
    if (query.isEmpty) return;
    searchFocus.unfocus();
    setState(() {
      searching = true;
      searchResults = [];
      mapNote = null;
    });
    try {
      final center = mapController.camera.center;
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'format': 'json',
        'limit': '5',
        'accept-language': 'ar',
        'q': query,
        // Prefer places near what's on screen.
        'viewbox': '${center.longitude - 1},${center.latitude + 1},${center.longitude + 1},${center.latitude - 1}',
      });
      final res = await http.get(uri, headers: _nominatimHeaders).timeout(const Duration(seconds: 12));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final results = (jsonDecode(res.body) as List<dynamic>).cast<Map<String, dynamic>>();
        setState(() {
          searchResults = results;
          if (results.isEmpty) mapNote = _t('map_no_results');
        });
      } else {
        setState(() => mapNote = _t('map_search_failed'));
      }
    } catch (_) {
      if (mounted) setState(() => mapNote = _t('map_search_failed'));
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  void _selectResult(Map<String, dynamic> result) {
    final lat = double.tryParse('${result['lat']}');
    final lng = double.tryParse('${result['lon']}');
    if (lat == null || lng == null) return;
    _setPoint(LatLng(lat, lng), zoom: 16, label: result['display_name'] as String?);
  }

  Future<void> _myLocation() async {
    if (locating) return;
    setState(() {
      locating = true;
      mapNote = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) setState(() => mapNote = _t('map_location_off'));
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => mapNote = _t('map_location_denied'));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      if (!mounted) return;
      _setPoint(LatLng(pos.latitude, pos.longitude), zoom: 17);
    } catch (_) {
      if (mounted) setState(() => mapNote = _t('map_location_failed'));
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      saving = true;
      error = null;
    });
    final text = locationCtrl.text.trim();
    final result = await context.read<AppState>().assignTripDeparturePoint(
          widget.trip.id,
          location: text.isEmpty ? null : text,
          lat: hasMarker ? markerPosition.latitude : null,
          lng: hasMarker ? markerPosition.longitude : null,
        );
    if (!mounted) return;
    setState(() => saving = false);
    if (result == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => error = result);
    }
  }

  BoxDecoration get _floating => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2))],
      );

  Widget _mapSearch(String Function(String) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 40,
          decoration: _floating,
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: searchCtrl,
                  focusNode: searchFocus,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: t('map_search_hint'),
                    hintStyle: const TextStyle(fontSize: 13),
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (searching)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.search, size: 20, color: AppColors.primary),
                  onPressed: _search,
                ),
            ],
          ),
        ),
        if (searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 170),
            decoration: _floating,
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: searchResults.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) => InkWell(
                onTap: () => _selectResult(searchResults[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: Text('${searchResults[i]['display_name']}',
                      maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().t;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(t('action_departure_point'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                  // The sheet no longer closes by dragging (the map needs it).
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Text(t('departure_point_hint'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ],
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 320,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: markerPosition,
                          initialZoom: hasMarker ? 15 : 6,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                          ),
                          onTap: (tapPosition, point) {
                            searchFocus.unfocus();
                            _setPoint(point);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.rowadplus.omra_admin',
                          ),
                          if (hasMarker)
                            MarkerLayer(markers: [
                              Marker(
                                point: markerPosition,
                                width: 40,
                                height: 40,
                                alignment: Alignment.topCenter,
                                child: const Icon(Icons.location_pin, color: AppColors.danger, size: 40),
                              ),
                            ]),
                        ],
                      ),
                      Positioned(top: 8, left: 8, right: 8, child: _mapSearch(t)),
                      PositionedDirectional(
                        bottom: 10,
                        end: 10,
                        child: Material(
                          color: AppColors.surface,
                          shape: const CircleBorder(),
                          elevation: 3,
                          child: IconButton(
                            tooltip: t('map_my_location'),
                            onPressed: _myLocation,
                            icon: locating
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.my_location, color: AppColors.primary),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        bottom: 14,
                        start: 10,
                        end: 64,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: mapNote != null ? AppColors.danger : const Color(0xB3000000),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(mapNote ?? t('map_tap_hint'),
                                style: const TextStyle(fontSize: 11, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasMarker) ...[
                const SizedBox(height: 6),
                Text(
                  '${markerPosition.latitude.toStringAsFixed(6)}, ${markerPosition.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: locationCtrl,
                maxLines: 2,
                decoration: InputDecoration(labelText: t('field_departure_address')),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(t('action_save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
