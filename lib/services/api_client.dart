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

  /// من غيرها أي طلب على شبكة ضعيفة كان بيفضل معلّق للأبد (spinner ما
  /// بيخلصش) لحد ما المستخدم يسيب الشاشة ويرجعلها تاني. دلوقتي بيفشل
  /// برسالة واضحة بعد مهلة معقولة بدل ما يعلّق.
  static const Duration _timeout = Duration(seconds: 20);

  /// عميل HTTP واحد مشترك بدل `http.get` المباشر — كل نداء مباشر كان بيفتح
  /// اتصال TCP + مصافحة TLS جديدة للسيرفر (في ألمانيا)، وده على شبكة جوال
  /// في السعودية بياخد ثواني قبل ما الطلب نفسه يبدأ. العميل المشترك بيسيب
  /// الاتصال مفتوح (keep-alive) فكل الطلبات بعد أول واحد بتمشي على طول.
  final http.Client _http = http.Client();

  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Never _throwTimeout() =>
      throw ApiException(0, 'انتهت مهلة الاتصال بالخادم، تحقق من الإنترنت وحاول مجددًا');

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
    final res = await _http.get(_uri(path), headers: _headers).timeout(_timeout, onTimeout: _throwTimeout);
    return _decode(res);
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? data]) async {
    final res = await _http
        .post(_uri(path), headers: _headers, body: jsonEncode(data ?? {}))
        .timeout(_timeout, onTimeout: _throwTimeout);
    return _decode(res);
  }

  Future<dynamic> put(String path, [Map<String, dynamic>? data]) async {
    final res = await _http
        .put(_uri(path), headers: _headers, body: jsonEncode(data ?? {}))
        .timeout(_timeout, onTimeout: _throwTimeout);
    return _decode(res);
  }

  Future<dynamic> patch(String path, [Map<String, dynamic>? data]) async {
    final res = await _http
        .patch(_uri(path), headers: _headers, body: jsonEncode(data ?? {}))
        .timeout(_timeout, onTimeout: _throwTimeout);
    return _decode(res);
  }

  Future<dynamic> delete(String path, [Map<String, dynamic>? data]) async {
    final res = await _http
        .delete(_uri(path), headers: _headers, body: data == null ? null : jsonEncode(data))
        .timeout(_timeout, onTimeout: _throwTimeout);
    return _decode(res);
  }

  /// بيسطّح أي Map/List متداخل لصيغة الأقواس اللي Laravel بيفهمها في
  /// multipart/form-data، مثلًا: family_prices[0][price], programs[0][steps][1].
  void _flatten(String key, dynamic value, Map<String, String> out) {
    if (value == null) return;
    if (value is Map) {
      value.forEach((k, v) => _flatten('$key[$k]', v, out));
    } else if (value is List) {
      for (var i = 0; i < value.length; i++) {
        _flatten('$key[$i]', value[i], out);
      }
    } else if (value is bool) {
      out[key] = value ? '1' : '0';
    } else {
      out[key] = value.toString();
    }
  }

  /// طلب multipart لإنشاء/تعديل برنامج فيه صور — Laravel بيستخدم _method
  /// لمحاكاة PUT جوه POST عادي، لأن رفع الملفات مع PUT مباشر مش مضمون.
  Future<dynamic> postMultipart(
    String path,
    Map<String, dynamic> fields, {
    List<MapEntry<String, List<int>>> files = const [],
    String? method,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.headers['Accept'] = 'application/json';
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
    if (method != null) request.fields['_method'] = method;

    final flat = <String, String>{};
    fields.forEach((k, v) => _flatten(k, v, flat));
    request.fields.addAll(flat);

    for (var i = 0; i < files.length; i++) {
      request.files.add(http.MultipartFile.fromBytes(files[i].key, files[i].value, filename: 'image_$i.jpg'));
    }

    final streamed = await _http.send(request).timeout(const Duration(seconds: 60), onTimeout: _throwTimeout);
    final res = await http.Response.fromStream(streamed);
    return _decode(res);
  }
}
