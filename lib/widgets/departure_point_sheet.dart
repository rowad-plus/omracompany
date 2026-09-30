import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// تحديد نقطة الانطلاق (تجمّع المعتمرين) — إما بالنقر على خريطة مجانية
/// (OpenStreetMap، من غير أي مفتاح API) أو كتابة العنوان نصيًا والبحث
/// عنه (عبر Nominatim، بحث مجاني تابع لـ OpenStreetMap)، أو الاثنين معًا.
class DeparturePointSheet extends StatefulWidget {
  final ApiTrip trip;
  const DeparturePointSheet({super.key, required this.trip});

  @override
  State<DeparturePointSheet> createState() => _DeparturePointSheetState();
}

class _DeparturePointSheetState extends State<DeparturePointSheet> {
  static const _defaultCenter = LatLng(21.4225, 39.8262); // مكة المكرمة

  late final TextEditingController locationCtrl;
  final mapController = MapController();
  late LatLng markerPosition;
  bool hasMarker = false;
  bool saving = false;
  bool searching = false;
  String? error;
  String? searchError;
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
    super.dispose();
  }

  /// بحث عن مكان بالاسم/العنوان عبر Nominatim — خدمة بحث مجانية تابعة
  /// لـ OpenStreetMap، من غير أي مفتاح API.
  Future<void> _search() async {
    final query = locationCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() {
      searching = true;
      searchResults = [];
      searchError = null;
    });
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'format': 'json',
        'limit': '5',
        'accept-language': 'ar',
        'q': query,
      });
      final res = await http.get(uri, headers: {'User-Agent': 'RowadPlusProviderApp/1.0'}).timeout(const Duration(seconds: 12));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final results = (jsonDecode(res.body) as List<dynamic>).cast<Map<String, dynamic>>();
        setState(() {
          searchResults = results;
          if (results.isEmpty) searchError = 'لا توجد نتائج مطابقة';
        });
      } else {
        setState(() => searchError = 'تعذّر البحث (${res.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => searchError = 'تعذّر البحث — تأكد من الاتصال بالإنترنت');
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  void _selectResult(Map<String, dynamic> result) {
    final lat = double.tryParse('${result['lat']}');
    final lng = double.tryParse('${result['lon']}');
    if (lat == null || lng == null) return;
    setState(() {
      markerPosition = LatLng(lat, lng);
      hasMarker = true;
      searchResults = [];
    });
    mapController.move(markerPosition, 16);
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
              Text(t('action_departure_point'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(t('departure_point_hint'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ],
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: locationCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(labelText: t('field_departure_address')),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: searching ? null : _search,
                    style: IconButton.styleFrom(backgroundColor: AppColors.primaryLight),
                    icon: searching
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.search, color: AppColors.primary),
                  ),
                ],
              ),
              if (searchError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(searchError!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ),
              if (searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: searchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) => InkWell(
                      onTap: () => _selectResult(searchResults[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Text('${searchResults[i]['display_name']}', style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 240,
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: markerPosition,
                      initialZoom: hasMarker ? 15 : 6,
                      onTap: (tapPosition, point) => setState(() {
                        markerPosition = point;
                        hasMarker = true;
                        searchResults = [];
                      }),
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
                            child: const Icon(Icons.location_pin, color: AppColors.danger, size: 40),
                          ),
                        ]),
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
