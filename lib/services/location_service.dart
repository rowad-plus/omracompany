import 'dart:convert';
import 'package:http/http.dart' as http;

/// IP-based country detection — no runtime permission needed, fast enough
/// for a pre-login screen. Mirrors rihlaty_mobile's own LocationService.
class LocationService {
  static Future<String?> detectCountryCode() async {
    try {
      final res = await http
          .get(Uri.parse('https://ipwho.is/'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (json['success'] != true) return null;
      return json['country_code'] as String?;
    } catch (_) {
      // Any failure (timeout, DNS, offline, malformed JSON) just keeps
      // whatever default was already showing — never guess.
      return null;
    }
  }
}
