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

  List<AssignableBus> get bookingBuses {
    final companies = bookingsData?['busCompaniesList'] as List<dynamic>? ?? [];
    return companies.expand((c) {
      final company = c as Map<String, dynamic>;
      final buses = company['buses'] as List<dynamic>? ?? [];
      return buses.map((b) => AssignableBus.fromJson({...b as Map<String, dynamic>, 'company': company['name']}));
    }).toList();
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

  Future<String?> assignBookingHotel({
    required int bookingId,
    required int hotelId,
    required String roomNumber,
    required int roomCapacity,
    List<int> companionIds = const [],
  }) async {
    try {
      await _api.post('/bookings/$bookingId/assign-hotel', {
        'hotel_id': hotelId,
        'room_number': roomNumber,
        'room_capacity': roomCapacity,
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

  // ------- بيانات تجريبية للبرامج -------
  final List<Trip> trips = [
    const Trip(
      id: 'ramadan',
      name: 'عمرة رمضان المميزة',
      destination: 'مكة والمدينة المنورة',
      days: 10,
      stars: 5,
      tier: TripTier.premium,
      status: TripStatus.active,
      price: 14400,
      seatsFilled: 28,
      seatsTotal: 40,
      hotelMecca: 'برج الساعة فيرمونت',
      hotelMedina: 'فندق الحرم انترناشيونال',
    ),
    const Trip(
      id: 'istanbul',
      name: 'رحلة إسطنبول السياحية',
      destination: 'إسطنبول',
      days: 7,
      stars: 4,
      tier: TripTier.economy,
      status: TripStatus.active,
      price: 17000,
      seatsFilled: 18,
      seatsTotal: 25,
    ),
    const Trip(
      id: 'hajj2028',
      name: 'برنامج حج 2028',
      destination: 'مكة والمدينة المنورة',
      days: 30,
      stars: 5,
      tier: TripTier.vip,
      status: TripStatus.draft,
      price: 44000,
      seatsFilled: 45,
      seatsTotal: 60,
      hotelMecca: 'برج الساعة فيرمونت',
      hotelMedina: 'فندق الحرم انترناشيونال',
    ),
  ];

  // ------- الباصات -------
  final List<BusInfo> buses = [
    BusInfo(id: 'bus1', name: 'باص 1 — أ ب ج 1234', capacity: 45, assignedToTrip: true, arrivalTime: '3:00 م'),
    BusInfo(id: 'bus2', name: 'باص 2 — د هـ و 5678', capacity: 30, assignedToTrip: true, arrivalTime: '4:15 م'),
    BusInfo(id: 'bus3', name: 'باص 3 — ز ح ط 9012', capacity: 40, assignedToTrip: false, arrivalTime: '6:30 م'),
  ];

  void toggleBusAssignedToTrip(BusInfo bus, bool value) {
    bus.assignedToTrip = value;
    notifyListeners();
  }

  // ------- المعتمرون التجريبيون -------
  final List<String> demoTravelers = [
    'علي إبراهيم حسن',
    'فريد عبد النور',
    'ريهام سعيد',
    'يوسف حسن رضا',
    'هند عبد الرحمن',
  ];

  // busId -> assigned traveler names
  final Map<String, List<String>> busAssignments = {};

  List<String> travelersForBus(String busId) {
    final assigned = busAssignments[busId];
    return (assigned != null && assigned.isNotEmpty) ? assigned : demoTravelers;
  }

  void assignTravelerToBus(String busId, String name) {
    final list = busAssignments.putIfAbsent(busId, () => []);
    if (!list.contains(name)) list.add(name);
    notifyListeners();
  }

  void removeTravelerFromBus(String busId, String name) {
    busAssignments[busId]?.remove(name);
    notifyListeners();
  }

  // ------- تسكين الغرف: busId -> rooms -------
  final Map<String, List<RoomAssignment>> hotelRooms = {};

  void addRoom(String busId, RoomAssignment room) {
    hotelRooms.putIfAbsent(busId, () => []).add(room);
    notifyListeners();
  }

  List<String> unhousedTravelers(String busId) {
    final pool = travelersForBus(busId);
    final housed = (hotelRooms[busId] ?? [])
        .expand((r) => r.occupantNames)
        .toSet();
    return pool.where((n) => !housed.contains(n)).toList();
  }

  // ------- الحضور والغياب: "tripId|busId" -> {name: status} -------
  final Map<String, Map<String, AttendanceStatus>> attendance = {};

  AttendanceStatus attendanceFor(String tripId, String busId, String name) {
    final key = '$tripId|$busId';
    return attendance[key]?[name] ?? AttendanceStatus.none;
  }

  void setAttendance(String tripId, String busId, String name, AttendanceStatus status) {
    final key = '$tripId|$busId';
    final map = attendance.putIfAbsent(key, () => {});
    final current = map[name] ?? AttendanceStatus.none;
    map[name] = current == status ? AttendanceStatus.none : status;
    notifyListeners();
  }

  (int present, int absent) attendanceCounts(String tripId, String busId) {
    final key = '$tripId|$busId';
    final map = attendance[key] ?? {};
    final present = map.values.where((s) => s == AttendanceStatus.present).length;
    final absent = map.values.where((s) => s == AttendanceStatus.absent).length;
    return (present, absent);
  }

  (int present, int absent) allAttendanceTotals() {
    int present = 0, absent = 0;
    for (final map in attendance.values) {
      present += map.values.where((s) => s == AttendanceStatus.present).length;
      absent += map.values.where((s) => s == AttendanceStatus.absent).length;
    }
    return (present, absent);
  }

  // ------- المعتمرون (شاشة إدارة المعتمرين) -------
  final List<Traveler> travelerRecords = [
    const Traveler(id: 't1', name: 'علي إبراهيم حسن', passportOrId: '—', phone: '—', amountPaid: 39200, tripsCount: 3, category: 'عمرة'),
    const Traveler(id: 't2', name: 'فريد عبد النور', passportOrId: '—', phone: '—', amountPaid: 48000, tripsCount: 1, category: 'حج'),
    const Traveler(id: 't3', name: 'ريهام سعيد', passportOrId: '—', phone: '—', amountPaid: 29500, tripsCount: 2, category: 'سياحة'),
  ];

  void addTravelerRecord(Traveler traveler) {
    travelerRecords.add(traveler);
    notifyListeners();
  }

  // ------- الفنادق والإقامة -------
  final List<Hotel> hotels = [
    const Hotel(name: 'برج الساعة فيرمونت', city: 'مكة المكرمة', stars: 5, distance: '50 متر من الحرم'),
    const Hotel(name: 'سويسأوتيل المقام', city: 'مكة المكرمة', stars: 5, distance: '150 متر من الحرم'),
    const Hotel(name: 'فندق الحرم انترناشيونال', city: 'المدينة المنورة', stars: 4, distance: '100 متر من المسجد النبوي'),
  ];

  void addHotel(Hotel hotel) {
    hotels.add(hotel);
    notifyListeners();
  }

  // ------- النقل والطيران -------
  final List<TransportItem> transportItems = [
    const TransportItem(type: TransportType.bus, name: 'أ ب ج 1234', driver: 'محمد عطية', capacity: 45),
    const TransportItem(type: TransportType.bus, name: 'د هـ و 5678', driver: 'خالد سالم', capacity: 30),
    const TransportItem(type: TransportType.flight, name: 'مصر للطيران'),
  ];

  void addTransportItem(TransportItem item) {
    transportItems.add(item);
    notifyListeners();
  }

  // ------- المستخدمون والمشرفون -------
  final List<TeamUser> teamUsers = [
    const TeamUser(name: 'أحمد السيد', contact: 'ahmed@rowadplus.com', roles: {UserRole.owner, UserRole.tripManager}),
    const TeamUser(name: 'محمد عطية', contact: '+966 5X XXX XXXX', roles: {UserRole.departureManager, UserRole.busSupervisor}),
    const TeamUser(name: 'خالد سالم', contact: '+966 5X XXX XXXX', roles: {UserRole.busSupervisor}),
    const TeamUser(name: 'أحمد فوزي', contact: '+966 5X XXX XXXX', roles: {UserRole.hotelManager}),
  ];

  void addTeamUser(TeamUser user) {
    teamUsers.add(user);
    notifyListeners();
  }

  // ------- الإشعارات -------
  final List<AppNotification> notifications = [
    const AppNotification(title: 'حجز جديد — علي إبراهيم حسن', timeAgo: 'time_ago_5_min', kind: NotificationKind.info),
    const AppNotification(title: 'دفعة مستلمة من سارة أحمد', timeAgo: 'time_ago_20_min', kind: NotificationKind.warning),
    const AppNotification(title: 'إلغاء حجز — رحلة إسطنبول', timeAgo: 'time_ago_3_hours', kind: NotificationKind.danger),
    const AppNotification(title: 'تقييم جديد 5 نجوم على برنامج الحج', timeAgo: 'time_ago_1_day', kind: NotificationKind.success),
  ];

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

  Future<void> fetchBusCompanies() async {
    busCompaniesLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/bus-companies') as Map<String, dynamic>;
      busCompanies =
          (res['busCompanies'] as List<dynamic>).map((e) => CompanyBusCompany.fromJson(e as Map<String, dynamic>)).toList();
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

  Future<String?> createBus({
    required int busCompanyId,
    required String busNumber,
    int? capacity,
    String? driverName,
    String? driverPhone,
  }) async {
    try {
      await _api.post('/buses', {
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
      return 'تعذّر إضافة الباص';
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

  Future<String?> createTrip(Map<String, dynamic> data) async {
    try {
      await _api.post('/umrah-trips', data);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذّر إنشاء البرنامج';
    }
  }
}
