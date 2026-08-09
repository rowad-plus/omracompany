import 'dart:convert';
import 'package:http/http.dart' as http;

/// استثناء موحّد لأخطاء الـ API — بيحتوي على رسالة عربية جاهزة للعرض
/// (من حقل "message" في رد Laravel) وكود الحالة HTTP.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  ApiException(this.statusCode, this.message, {this.errors});

  @override
  String toString() => message;
}

/// عميل HTTP بسيط لباقي الـ Provider API — بيحقن توكن Sanctum تلقائيًا
/// ويحوّل ردود الأخطاء لـ ApiException برسالة قابلة للعرض مباشرة.
class ApiClient {
  static const String baseUrl = 'https://omraway.com/api/v1/provider';

  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  dynamic _decode(http.Response res) {
    Map<String, dynamic>? body;
    if (res.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) body = decoded;
      } catch (_) {
        // رد مش JSON (صفحة خطأ HTML مثلًا) — هنسيب body فاضي ونستخدم رسالة عامة.
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body ?? {};
    }

    final message = body?['message'] as String? ??
        (res.statusCode == 401
            ? 'انتهت صلاحية الجلسة، الرجاء تسجيل الدخول من جديد'
            : res.statusCode == 403
                ? 'ليس لديك صلاحية للقيام بهذا الإجراء'
                : 'حدث خطأ غير متوقع، الرجاء المحاولة لاحقًا');
    final errors = body?['errors'] as Map<String, dynamic>?;
    throw ApiException(res.statusCode, message, errors: errors);
  }

  Future<dynamic> get(String path) async {
    final res = await http.get(_uri(path), headers: _headers);
    return _decode(res);
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? data]) async {
    final res = await http.post(_uri(path), headers: _headers, body: jsonEncode(data ?? {}));
    return _decode(res);
  }

  Future<dynamic> put(String path, [Map<String, dynamic>? data]) async {
    final res = await http.put(_uri(path), headers: _headers, body: jsonEncode(data ?? {}));
    return _decode(res);
  }

  Future<dynamic> patch(String path, [Map<String, dynamic>? data]) async {
    final res = await http.patch(_uri(path), headers: _headers, body: jsonEncode(data ?? {}));
    return _decode(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await http.delete(_uri(path), headers: _headers);
    return _decode(res);
  }
}
