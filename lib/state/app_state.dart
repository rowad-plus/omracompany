import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../models/models.dart';
import '../services/api_client.dart';

/// حالة التطبيق العامة: الدور الحالي، بيانات البرامج التجريبية،
/// تعيينات الباصات، الغرف، والحضور والغياب.
/// (بديل الـ localStorage/متغيرات JS اللي كنا مستخدمينها في نسخة الويب)
class AppState extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  static const _tokenPrefsKey = 'provider_api_token';

  Set<UserRole> currentRoles = {UserRole.owner};

  /// الدور الأساسي لعرض الهوية (الاسم التجريبي، الأفاتار...) لما يكون عند
  /// المستخدم أكتر من دور — بيرجع أعلى دور حسب ترتيب تعريف الـ enum.
  UserRole get primaryRole => UserRole.values.firstWhere(currentRoles.contains, orElse: () => UserRole.owner);

  void setRoles(Set<UserRole> roles) {
    if (roles.isEmpty) return;
    currentRoles = roles;
    notifyListeners();
  }

  // ------- الجلسة/تسجيل الدخول (Backend حقيقي) -------
  bool sessionLoading = true;
  bool isLoggedIn = false;

  String accountName = '';
  String accountEmail = '';
  String? companyName;
  String? companyLogo;
  Set<String> permissions = {};

  /// بيحوّل صلاحيات الحساب الفعلية (من الـ API) لمجموعة أدوار العرض القديمة،
  /// عشان نفس منطق التنقل (RootShell) يشتغل من غير أي تغيير. لو الحساب عنده
  /// صلاحيات الفندق والباص مع بعض (زي "مسؤول عام")، بياخد التبويبين مع بعض.
  Set<UserRole> _rolesFromPermissions(String legacyRole, Set<String> perms) {
    if (legacyRole == 'owner') return {UserRole.owner};

    final roles = <UserRole>{};
    if (perms.contains('umrah.manage') || perms.contains('bookings.manage')) {
      roles.add(UserRole.tripManager);
    }
    if (perms.contains('bookings.assign-hotel')) roles.add(UserRole.hotelManager);
    if (perms.contains('bookings.assign-bus') || perms.contains('bookings.attendance')) {
      roles.add(UserRole.busSupervisor);
    }
    if (roles.isEmpty) roles.add(UserRole.departureManager);
    return roles;
  }

  void _applyAccountPayload(Map<String, dynamic> account) {
    accountName = account['name'] as String? ?? '';
    accountEmail = account['email'] as String? ?? '';
    final company = account['company'] as Map<String, dynamic>?;
    companyName = company?['name'] as String?;
    companyLogo = company?['logo'] as String?;
    permissions = (account['permissions'] as List<dynamic>? ?? []).cast<String>().toSet();
    currentRoles = _rolesFromPermissions(account['role'] as String? ?? '', permissions);
  }

  /// بيتشيك لو فيه توكن محفوظ من جلسة سابقة ويحاول يسترجع بيانات الحساب.
  /// بيتنادى مرة واحدة عند فتح التطبيق (AuthGate).
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenPrefsKey);
    if (token == null) {
      sessionLoading = false;
      notifyListeners();
      return;
    }

    _api.setToken(token);
    try {
      final account = await _api.get('/me') as Map<String, dynamic>;
      _applyAccountPayload(account);
      isLoggedIn = true;
    } catch (_) {
      await prefs.remove(_tokenPrefsKey);
      _api.setToken(null);
    }
    sessionLoading = false;
    notifyListeners();
  }

  /// بيسجّل الدخول بالبريد أو برقم الجوال (واحد منهم بس) وكلمة المرور.
  /// بيرجع null لو نجح، أو رسالة الخطأ.
  Future<String?> login({String? email, String? phone, required String password}) async {
    try {
      final res = await _api.post('/login', {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'password': password,
      }) as Map<String, dynamic>;
      final token = res['token'] as String;
      final account = res['account'] as Map<String, dynamic>;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenPrefsKey, token);

      _api.setToken(token);
      _applyAccountPayload(account);
      isLoggedIn = true;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر الاتصال بالخادم، تحقق من الإنترنت وحاول مجددًا';
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } catch (_) {
      // نتجاهل فشل تسجيل الخروج من السيرفر — بنمسح الجلسة محليًا على أي حال.
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenPrefsKey);
    _api.setToken(null);

    isLoggedIn = false;
    accountName = '';
    accountEmail = '';
    companyName = null;
    companyLogo = null;
    permissions = {};
    employees = [];
    companyRoles = [];
    currentRoles = {UserRole.owner};
    notifyListeners();
  }

  // ------- لوحة التحكم (Backend حقيقي) -------
  Map<String, dynamic>? dashboardData;
  bool dashboardLoading = false;

  Future<void> fetchDashboard() async {
    dashboardLoading = true;
    notifyListeners();
    try {
      dashboardData = await _api.get('/dashboard') as Map<String, dynamic>;
    } finally {
      dashboardLoading = false;
      notifyListeners();
    }
    fetchUnreadNotificationsCount();
  }

  Map<String, dynamic>? reportsData;
  bool reportsLoading = false;

  Future<void> fetchReports() async {
    reportsLoading = true;
    notifyListeners();
    try {
      reportsData = await _api.get('/reports') as Map<String, dynamic>;
    } finally {
      reportsLoading = false;
      notifyListeners();
    }
  }

  // ------- برامج العمرة الفعلية (Backend حقيقي) -------
  List<ApiTrip> apiTrips = [];
  List<AssignableHotel> apiHotels = [];
  List<AssignableBus> apiBuses = [];
  List<AssignableEmployee> apiEmployeesForAssign = [];
  bool apiTripsLoading = false;

  Future<void> fetchApiTrips() async {
    apiTripsLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/umrah-trips') as Map<String, dynamic>;
      apiTrips = (res['trips'] as List<dynamic>).map((e) => ApiTrip.fromJson(e as Map<String, dynamic>)).toList();
      apiHotels = (res['hotels'] as List<dynamic>).map((e) => AssignableHotel.fromJson(e as Map<String, dynamic>)).toList();
      apiBuses = (res['buses'] as List<dynamic>).map((e) => AssignableBus.fromJson(e as Map<String, dynamic>)).toList();
      apiEmployeesForAssign =
          (res['employees'] as List<dynamic>).map((e) => AssignableEmployee.fromJson(e as Map<String, dynamic>)).toList();
    } finally {
      apiTripsLoading = false;
      notifyListeners();
    }
  }

  Future<String?> toggleApiTrip(int id) async {
    try {
      await _api.patch('/umrah-trips/$id/toggle');
      await fetchApiTrips();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تغيير حالة البرنامج';
    }
  }

  Future<String?> deleteApiTrip(int id) async {
    try {
      await _api.delete('/umrah-trips/$id');
      apiTrips.removeWhere((t) => t.id == id);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر حذف البرنامج';
    }
  }

  Future<String?> assignTripHotel(int id, Map<String, dynamic> data) async {
    try {
      await _api.post('/umrah-trips/$id/assign-hotel', data);
      await fetchApiTrips();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تسكين الفندق';
    }
  }

  Future<String?> assignTripBuses(int id, List<int> busIds) async {
    try {
      await _api.post('/umrah-trips/$id/assign-buses', {'bus_ids': busIds});
      await fetchApiTrips();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تسكين الباصات';
    }
  }

  Future<String?> assignTripDeparturePoint(int id, {String? location, double? lat, double? lng}) async {
    try {
      await _api.post('/umrah-trips/$id/assign-departure', {
        'departure_location': location,
        'departure_latitude': lat,
        'departure_longitude': lng,
      });
      await fetchApiTrips();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تحديد نقطة الانطلاق';
    }
  }

  Future<String?> assignTripSupervisors(int id, List<int> supervisorIds) async {
    try {
      await _api.post('/umrah-trips/$id/assign-supervisors', {'supervisor_ids': supervisorIds});
      await fetchApiTrips();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تسكين المشرفين';
    }
  }

  // ------- الحجوزات، الحضور والغياب، تسكين الغرف (Backend حقيقي) -------
  Map<String, dynamic>? bookingsData;
  bool bookingsLoading = false;

  List<Map<String, dynamic>> get bookingsList =>
      ((bookingsData?['bookings'] as Map<String, dynamic>?)?['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

  List<AssignableHotel> get bookingHotels =>
      (bookingsData?['hotelsList'] as List<dynamic>? ?? []).map((e) => AssignableHotel.fromJson(e as Map<String, dynamic>)).toList();

  /// الباص بقى بس رقم — مش لازم يتبع شركة نقل عشان تقدر تسكنه لحجز.
  List<AssignableBus> get bookingBuses =>
      (bookingsData?['busesList'] as List<dynamic>? ?? []).map((b) => AssignableBus.fromJson(b as Map<String, dynamic>)).toList();

  /// إضافة فندق سريعة من نفس شاشة تسكين الحجز — بترجع الـ id الجديد عشان
  /// يتحدد تلقائيًا، وبتحدّث بيانات الحجوزات عشان الفندق يظهر في القايمة.
  Future<(int?, String?)> quickAddHotelForBooking({
    required String name,
    required int cityId,
    required int stars,
    required String distanceHaram,
    String? contact,
  }) async {
    try {
      final res = await _api.post('/hotels', {
        'name': name,
        'type': 'umrah',
        'city_id': cityId,
        'stars': stars,
        'distance_haram': distanceHaram,
        'contact': contact,
      }) as Map<String, dynamic>;
      final newId = (res['hotel'] as Map<String, dynamic>)['id'] as int;
      await fetchBookings();
      return (newId, null);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (_) {
      return (null, 'تعذّر إضافة الفندق');
    }
  }

  /// إضافة باص سريعة — بس رقم الباص، مش لازم شركة نقل.
  Future<(int?, String?)> quickAddBusForBooking({
    required String busNumber,
    int? capacity,
  }) async {
    try {
      final res = await _api.post('/buses', {
        'bus_number': busNumber,
        'capacity': capacity,
      }) as Map<String, dynamic>;
      final newId = (res['bus'] as Map<String, dynamic>)['id'] as int;
      await fetchBookings();
      return (newId, null);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (_) {
      return (null, 'تعذّر إضافة الباص');
    }
  }

  Future<void> fetchBookings() async {
    bookingsLoading = true;
    notifyListeners();
    try {
      bookingsData = await _api.get('/bookings') as Map<String, dynamic>;
    } finally {
      bookingsLoading = false;
      notifyListeners();
    }
  }

  Future<String?> confirmBooking(int id) async {
    try {
      await _api.patch('/bookings/$id/confirm');
      await fetchBookings();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تأكيد الحجز';
    }
  }

  Future<String?> cancelBooking(int id) async {
    try {
      await _api.patch('/bookings/$id/cancel');
      await fetchBookings();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إلغاء الحجز';
    }
  }

  Future<List<Map<String, dynamic>>> fetchTripCompanions(int bookingId) async {
    final res = await _api.get('/bookings/$bookingId/trip-companions') as Map<String, dynamic>;
    return (res['companions'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// تسكين الفندق وتسكين الغرفة إجراءان منفصلان في الواجهة، لكن نفس الـ API:
  /// لو [roomNumber]/[roomCapacity] اتبعتوش، الباك إند بيحافظ على أي تسكين
  /// غرفة موجود قبل كده (ومنطقيًا العكس صحيح لو الفندق كان متسكن بالفعل).
  Future<String?> assignBookingHotel({
    required int bookingId,
    required int hotelId,
    String? roomNumber,
    int? roomCapacity,
    List<int> companionIds = const [],
  }) async {
    try {
      await _api.patch('/bookings/$bookingId/assign-hotel', {
        'hotel_id': hotelId,
        if (roomNumber != null) 'room_number': roomNumber,
        if (roomCapacity != null) 'room_capacity': roomCapacity,
        'companion_ids': companionIds,
      });
      await fetchBookings();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تسكين الحجز في الفندق';
    }
  }

  Future<String?> clearBookingHotel(int bookingId) async {
    try {
      await _api.delete('/bookings/$bookingId/assign-hotel');
      await fetchBookings();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إلغاء تسكين الفندق';
    }
  }

  Future<String?> assignBookingBus(int bookingId, int busId) async {
    try {
      await _api.patch('/bookings/$bookingId/assign-bus', {'bus_id': busId});
      await fetchBookings();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تسكين الحجز في الباص';
    }
  }

  Future<String?> clearBookingBus(int bookingId) async {
    try {
      await _api.delete('/bookings/$bookingId/assign-bus');
      await fetchBookings();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إلغاء تسكين الباص';
    }
  }

  Future<String?> markAttendance(int bookingId, String status) async {
    try {
      await _api.patch('/bookings/$bookingId/attendance', {'attendance_status': status});
      await fetchBookings();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تسجيل الحضور';
    }
  }

  // ------- الموظفون (Backend حقيقي) -------
  List<Employee> employees = [];
  bool employeesLoading = false;

  Future<void> fetchEmployees() async {
    employeesLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/employees') as Map<String, dynamic>;
      employees = (res['employees'] as List<dynamic>).map((e) => Employee.fromJson(e as Map<String, dynamic>)).toList();
    } finally {
      employeesLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createEmployee({
    required String name,
    required String email,
    String? phone,
    required int roleId,
    required String password,
  }) async {
    try {
      final res = await _api.post('/employees', {
        'name': name,
        'email': email,
        'phone': phone,
        'role_id': roleId,
        'password': password,
      }) as Map<String, dynamic>;
      employees.add(Employee.fromJson(res['employee'] as Map<String, dynamic>));
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إضافة الموظف، حاول مجددًا';
    }
  }

  Future<String?> updateEmployee({
    required int id,
    required String name,
    required String email,
    String? phone,
    required int roleId,
    String? password,
  }) async {
    try {
      final res = await _api.put('/employees/$id', {
        'name': name,
        'email': email,
        'phone': phone,
        'role_id': roleId,
        if (password != null && password.isNotEmpty) 'password': password,
      }) as Map<String, dynamic>;
      final updated = Employee.fromJson(res['employee'] as Map<String, dynamic>);
      final idx = employees.indexWhere((e) => e.id == id);
      if (idx != -1) employees[idx] = updated;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تعديل بيانات الموظف، حاول مجددًا';
    }
  }

  Future<void> toggleEmployee(int id) async {
    final res = await _api.patch('/employees/$id/toggle') as Map<String, dynamic>;
    final idx = employees.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final e = employees[idx];
      employees[idx] = Employee(
        id: e.id,
        name: e.name,
        email: e.email,
        phone: e.phone,
        roleId: e.roleId,
        roleName: e.roleName,
        isActive: res['is_active'] as bool,
        joined: e.joined,
      );
      notifyListeners();
    }
  }

  // ------- الأدوار والصلاحيات (Backend حقيقي) -------
  List<CompanyRole> companyRoles = [];
  Map<String, PermissionGroup> permissionGroups = {};
  bool rolesLoading = false;

  Future<void> fetchRoles() async {
    rolesLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/roles') as Map<String, dynamic>;
      companyRoles = (res['roles'] as List<dynamic>).map((r) => CompanyRole.fromJson(r as Map<String, dynamic>)).toList();
      final groups = res['permissionGroups'] as Map<String, dynamic>? ?? {};
      permissionGroups = groups.map((k, v) => MapEntry(k, PermissionGroup.fromJson(k, v as Map<String, dynamic>)));
    } finally {
      rolesLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createRole({required String name, required List<String> permissionNames}) async {
    try {
      final res = await _api.post('/roles', {'name': name, 'permissions': permissionNames}) as Map<String, dynamic>;
      companyRoles.add(CompanyRole.fromJson(res['role'] as Map<String, dynamic>));
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إنشاء الدور، حاول مجددًا';
    }
  }

  Future<String?> updateRole({required int id, required String name, required List<String> permissionNames}) async {
    try {
      final res = await _api.put('/roles/$id', {'name': name, 'permissions': permissionNames}) as Map<String, dynamic>;
      final updated = CompanyRole.fromJson(res['role'] as Map<String, dynamic>);
      final idx = companyRoles.indexWhere((r) => r.id == id);
      if (idx != -1) companyRoles[idx] = updated;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تعديل الدور، حاول مجددًا';
    }
  }

  Future<String?> deleteRole(int id) async {
    try {
      await _api.delete('/roles/$id');
      companyRoles.removeWhere((r) => r.id == id);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر حذف الدور، حاول مجددًا';
    }
  }

  AppLanguage language = AppLanguage.ar;

  void setLanguage(AppLanguage lang) {
    language = lang;
    notifyListeners();
  }

  String t(String key) => AppStrings.t(key, language);

  // ------- الإشعارات (Backend حقيقي) -------
  List<AppNotification> notifications = [];
  bool notificationsLoading = false;
  int unreadNotificationsCount = 0;

  Future<void> fetchNotifications() async {
    notificationsLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/notifications') as Map<String, dynamic>;
      notifications = (res['data'] as List<dynamic>).map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
      unreadNotificationsCount = res['unread_count'] as int? ?? 0;
    } finally {
      notificationsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadNotificationsCount() async {
    try {
      final res = await _api.get('/notifications/unread-count') as Map<String, dynamic>;
      unreadNotificationsCount = res['unread_count'] as int? ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markNotificationRead(int id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1 || notifications[index].isRead) return;
    try {
      await _api.post('/notifications/$id/read');
      final n = notifications[index];
      notifications[index] = AppNotification(
        id: n.id,
        type: n.type,
        title: n.title,
        body: n.body,
        timeAgo: n.timeAgo,
        isRead: true,
        kind: n.kind,
      );
      if (unreadNotificationsCount > 0) unreadNotificationsCount--;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _api.post('/notifications/read-all');
      notifications = notifications
          .map((n) => AppNotification(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                timeAgo: n.timeAgo,
                isRead: true,
                kind: n.kind,
              ))
          .toList();
      unreadNotificationsCount = 0;
      notifyListeners();
    } catch (_) {}
  }

  // ------- الفنادق والإقامة (Backend حقيقي) -------
  List<CompanyHotel> companyHotels = [];
  List<SaudiCity> saudiCities = [];
  bool companyHotelsLoading = false;

  Future<void> fetchCompanyHotels() async {
    companyHotelsLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/hotels') as Map<String, dynamic>;
      companyHotels = (res['hotels'] as List<dynamic>).map((e) => CompanyHotel.fromJson(e as Map<String, dynamic>)).toList();
      saudiCities = (res['saudiCities'] as List<dynamic>).map((e) => SaudiCity.fromJson(e as Map<String, dynamic>)).toList();
    } finally {
      companyHotelsLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createCompanyHotel({
    required String name,
    required int cityId,
    required int stars,
    required String distanceHaram,
    String? contact,
  }) async {
    try {
      final res = await _api.post('/hotels', {
        'name': name,
        'type': 'umrah',
        'city_id': cityId,
        'stars': stars,
        'distance_haram': distanceHaram,
        'contact': contact,
      }) as Map<String, dynamic>;
      companyHotels.add(CompanyHotel.fromJson(res['hotel'] as Map<String, dynamic>));
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إضافة الفندق';
    }
  }

  Future<String?> updateCompanyHotel({
    required int id,
    required String name,
    required int cityId,
    required int stars,
    required String distanceHaram,
    String? contact,
  }) async {
    try {
      final res = await _api.put('/hotels/$id', {
        'name': name,
        'type': 'umrah',
        'city_id': cityId,
        'stars': stars,
        'distance_haram': distanceHaram,
        'contact': contact,
      }) as Map<String, dynamic>;
      final updated = CompanyHotel.fromJson(res['hotel'] as Map<String, dynamic>);
      final idx = companyHotels.indexWhere((h) => h.id == id);
      if (idx != -1) companyHotels[idx] = updated;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تعديل الفندق';
    }
  }

  Future<String?> deleteCompanyHotel(int id) async {
    try {
      await _api.delete('/hotels/$id');
      companyHotels.removeWhere((h) => h.id == id);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر حذف الفندق';
    }
  }

  // ------- النقل والطيران (Backend حقيقي) -------
  List<CompanyBusCompany> busCompanies = [];
  bool busCompaniesLoading = false;

  List<CompanyBus> unassignedBuses = [];

  Future<void> fetchBusCompanies() async {
    busCompaniesLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/bus-companies') as Map<String, dynamic>;
      busCompanies =
          (res['busCompanies'] as List<dynamic>).map((e) => CompanyBusCompany.fromJson(e as Map<String, dynamic>)).toList();
      unassignedBuses =
          (res['unassignedBuses'] as List<dynamic>? ?? []).map((e) => CompanyBus.fromJson(e as Map<String, dynamic>)).toList();
    } finally {
      busCompaniesLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createBusCompany({required String name, String? contact}) async {
    try {
      await _api.post('/bus-companies', {'name': name, 'contact': contact});
      await fetchBusCompanies();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إضافة شركة الأتوبيسات';
    }
  }

  Future<String?> updateBusCompany({required int id, required String name, String? contact}) async {
    try {
      await _api.put('/bus-companies/$id', {'name': name, 'contact': contact});
      await fetchBusCompanies();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تعديل شركة الأتوبيسات';
    }
  }

  Future<String?> createBus({
    int? busCompanyId,
    required String busNumber,
    int? capacity,
    String? driverName,
    String? driverPhone,
  }) async {
    try {
      await _api.post('/buses', {
        if (busCompanyId != null) 'bus_company_id': busCompanyId,
        'bus_number': busNumber,
        'capacity': capacity,
        'driver_name': driverName,
        'driver_phone': driverPhone,
      });
      await fetchBusCompanies();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إضافة الباص';
    }
  }

  Future<String?> updateBus({
    required int id,
    int? busCompanyId,
    required String busNumber,
    int? capacity,
    String? driverName,
    String? driverPhone,
  }) async {
    try {
      await _api.put('/buses/$id', {
        'bus_company_id': busCompanyId,
        'bus_number': busNumber,
        'capacity': capacity,
        'driver_name': driverName,
        'driver_phone': driverPhone,
      });
      await fetchBusCompanies();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تعديل الباص';
    }
  }

  // ------- المعتمرون/العملاء (Backend حقيقي) -------
  List<Customer> customers = [];
  bool customersLoading = false;

  Future<void> fetchCustomers({String? search}) async {
    customersLoading = true;
    notifyListeners();
    try {
      final query = search != null && search.isNotEmpty ? '?search=${Uri.encodeQueryComponent(search)}' : '';
      final res = await _api.get('/customers$query') as Map<String, dynamic>;
      customers = (res['customers'] as List<dynamic>).map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
    } finally {
      customersLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createCustomer({required String name, required String phone, String? email}) async {
    try {
      final res = await _api.post('/customers', {'name': name, 'phone': phone, 'email': email}) as Map<String, dynamic>;
      customers.insert(0, Customer.fromJson(res['customer'] as Map<String, dynamic>));
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إضافة المسافر';
    }
  }

  /// رد التعديل من الباك إند بيرجّع الاسم/الجوال/الإيميل بس (من غير إحصائيات
  /// الحجوزات)، فبنحدّث نفس عنصر القايمة بدل ما نستبدله بالكامل عشان محافظش
  /// نفقد bookings_count/total_spent المعروضين بالفعل.
  Future<String?> updateCustomer({required int id, required String name, required String phone, String? email}) async {
    try {
      await _api.put('/customers/$id', {'name': name, 'phone': phone, 'email': email});
      final idx = customers.indexWhere((c) => c.id == id);
      if (idx != -1) {
        final old = customers[idx];
        customers[idx] = Customer(
          id: old.id,
          name: name,
          phone: phone,
          email: email,
          bookingsCount: old.bookingsCount,
          totalSpent: old.totalSpent,
          tripTypes: old.tripTypes,
        );
      }
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تعديل بيانات المسافر';
    }
  }

  // ------- بيانات الشركة (Backend حقيقي) -------
  CompanyInfo? companyInfo;
  bool companyInfoLoading = false;

  Future<void> fetchCompanyInfo() async {
    companyInfoLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/company') as Map<String, dynamic>;
      companyInfo = CompanyInfo.fromJson(res['company'] as Map<String, dynamic>);
    } finally {
      companyInfoLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateCompanyInfo({
    required String name,
    String? commercialRegister,
    String? email,
    String? phone,
  }) async {
    try {
      final res = await _api.put('/company', {
        'name': name,
        'type': 'umrah',
        'commercial_register': commercialRegister,
        'email': email,
        'phone': phone,
      }) as Map<String, dynamic>;
      companyInfo = CompanyInfo.fromJson(res['company'] as Map<String, dynamic>);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تحديث بيانات الشركة';
    }
  }

  // ------- بيانات الحساب البنكي (Backend حقيقي) -------
  BankInfo? bankInfo;
  bool bankInfoLoading = false;

  Future<void> fetchBankInfo() async {
    bankInfoLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/company/bank-info') as Map<String, dynamic>;
      bankInfo = BankInfo.fromJson(res);
    } finally {
      bankInfoLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateBankInfo({
    required String bankName,
    required String bankAccountHolder,
    required String bankAccountNumber,
    required String bankIban,
  }) async {
    try {
      await _api.put('/company/bank-info', {
        'bank_name': bankName,
        'bank_account_holder': bankAccountHolder,
        'bank_account_number': bankAccountNumber,
        'bank_iban': bankIban,
      });
      bankInfo = BankInfo(
        bankName: bankName,
        bankAccountHolder: bankAccountHolder,
        bankAccountNumber: bankAccountNumber,
        bankIban: bankIban,
      );
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر حفظ بيانات الحساب البنكي';
    }
  }

  // ------- فروع الشركة (Backend حقيقي) -------
  List<CompanyBranchInfo> branches = [];
  bool branchesLoading = false;

  Future<void> fetchBranches() async {
    branchesLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/branches') as Map<String, dynamic>;
      branches = (res['branches'] as List<dynamic>).map((e) => CompanyBranchInfo.fromJson(e as Map<String, dynamic>)).toList();
    } finally {
      branchesLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createBranch({required String name, String? city, String? phone, String? manager}) async {
    try {
      final res = await _api.post('/branches', {'name': name, 'city': city, 'phone': phone, 'manager': manager}) as Map<String, dynamic>;
      branches.add(CompanyBranchInfo.fromJson(res['branch'] as Map<String, dynamic>));
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إضافة الفرع';
    }
  }

  Future<String?> updateBranch({required int id, required String name, String? city, String? phone, String? manager}) async {
    try {
      final res = await _api.put('/branches/$id', {'name': name, 'city': city, 'phone': phone, 'manager': manager}) as Map<String, dynamic>;
      final updated = CompanyBranchInfo.fromJson(res['branch'] as Map<String, dynamic>);
      final idx = branches.indexWhere((b) => b.id == id);
      if (idx != -1) branches[idx] = updated;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تعديل الفرع';
    }
  }

  Future<String?> deleteBranch(int id) async {
    try {
      await _api.delete('/branches/$id');
      branches.removeWhere((b) => b.id == id);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر حذف الفرع';
    }
  }

  // ------- الجلسات النشطة (Backend حقيقي) -------
  List<AccountSession> accountSessions = [];
  bool sessionsLoading = false;

  Future<void> fetchAccountSessions() async {
    sessionsLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/sessions') as Map<String, dynamic>;
      accountSessions = (res['sessions'] as List<dynamic>).map((e) => AccountSession.fromJson(e as Map<String, dynamic>)).toList();
    } finally {
      sessionsLoading = false;
      notifyListeners();
    }
  }

  Future<String?> revokeSession(int id) async {
    try {
      await _api.delete('/sessions/$id');
      accountSessions.removeWhere((s) => s.id == id);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إنهاء الجلسة';
    }
  }

  Future<String?> revokeOtherSessions() async {
    try {
      await _api.delete('/sessions');
      accountSessions.removeWhere((s) => !s.isCurrent);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إنهاء الجلسات الأخرى';
    }
  }

  Future<String?> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await _api.put('/profile/password', {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      });
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تغيير كلمة المرور';
    }
  }

  Future<String?> uploadCompanyLogo(List<int> bytes) async {
    try {
      final res = await _api.postMultipart('/company/logo', {}, files: [MapEntry('logo', bytes)]) as Map<String, dynamic>;
      final url = res['url'] as String?;
      if (url != null && companyInfo != null) {
        companyInfo = CompanyInfo(
          id: companyInfo!.id,
          name: companyInfo!.name,
          fullName: companyInfo!.fullName,
          type: companyInfo!.type,
          commercialRegister: companyInfo!.commercialRegister,
          foundedYear: companyInfo!.foundedYear,
          about: companyInfo!.about,
          phone: companyInfo!.phone,
          whatsapp: companyInfo!.whatsapp,
          email: companyInfo!.email,
          website: companyInfo!.website,
          addressText: companyInfo!.addressText,
          slogan: companyInfo!.slogan,
          logo: url,
        );
      }
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر رفع شعار الشركة';
    }
  }

  // ------- خيارات نموذج إنشاء البرنامج (Backend حقيقي) -------
  List<SaudiCity> tripFormCities = [];
  List<AssignableHotel> tripFormHotels = [];
  List<AssignableBus> tripFormBuses = [];
  bool tripFormOptionsLoading = false;

  Future<void> fetchTripFormOptions() async {
    tripFormOptionsLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/umrah-trips-form-options') as Map<String, dynamic>;
      tripFormCities = (res['cities'] as List<dynamic>).map((e) => SaudiCity.fromJson(e as Map<String, dynamic>)).toList();
      tripFormHotels = (res['hotels'] as List<dynamic>).map((e) => AssignableHotel.fromJson(e as Map<String, dynamic>)).toList();
      tripFormBuses = (res['buses'] as List<dynamic>).map((e) => AssignableBus.fromJson(e as Map<String, dynamic>)).toList();
    } finally {
      tripFormOptionsLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createTrip(Map<String, dynamic> data, {List<List<int>> images = const []}) async {
    try {
      await _api.postMultipart(
        '/umrah-trips',
        data,
        files: [for (final bytes in images) MapEntry('images[]', bytes)],
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إنشاء البرنامج';
    }
  }

  Future<Map<String, dynamic>?> fetchTripEditData(int tripId) async {
    try {
      return await _api.get('/umrah-trips/$tripId/edit-data') as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<String?> deleteTripImage(int imageId) async {
    try {
      await _api.delete('/umrah-trip-images/$imageId');
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر حذف الصورة';
    }
  }

  /// تعديل برنامج موجود — لو [images] اتبعتت بتتضاف على الصور الموجودة
  /// (الباك إند بيحافظ عليها لو keep_images=true).
  Future<String?> updateTrip(int tripId, Map<String, dynamic> data, {List<List<int>> images = const []}) async {
    try {
      await _api.postMultipart(
        '/umrah-trips/$tripId',
        {...data, 'keep_images': true},
        files: [for (final bytes in images) MapEntry('images[]', bytes)],
        method: 'PUT',
      );
      await fetchApiTrips();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر تعديل البرنامج';
    }
  }
}
