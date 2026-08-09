/// Laravel بيرجّع الحقول المُلقّمة بـ decimal:2 كـ String في الـ JSON
/// (مثلًا "3100.00")، فمينفعش نعمل cast مباشر لـ num.
double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}

/// لغات الواجهة المتاحة.
enum AppLanguage { ar, en, fr, tr, ur, id, ms }

extension AppLanguageX on AppLanguage {
  String get nativeName {
    switch (this) {
      case AppLanguage.ar:
        return 'العربية';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.fr:
        return 'Français';
      case AppLanguage.tr:
        return 'Türkçe';
      case AppLanguage.ur:
        return 'اردو';
      case AppLanguage.id:
        return 'Bahasa Indonesia';
      case AppLanguage.ms:
        return 'Bahasa Melayu';
    }
  }

  String get flag {
    switch (this) {
      case AppLanguage.ar:
        return '🇸🇦';
      case AppLanguage.en:
        return '🇬🇧';
      case AppLanguage.fr:
        return '🇫🇷';
      case AppLanguage.tr:
        return '🇹🇷';
      case AppLanguage.ur:
        return '🇵🇰';
      case AppLanguage.id:
        return '🇮🇩';
      case AppLanguage.ms:
        return '🇲🇾';
    }
  }

  bool get isRtl => this == AppLanguage.ar || this == AppLanguage.ur;

  String get localeCode {
    switch (this) {
      case AppLanguage.ar:
        return 'ar';
      case AppLanguage.en:
        return 'en';
      case AppLanguage.fr:
        return 'fr';
      case AppLanguage.tr:
        return 'tr';
      case AppLanguage.ur:
        return 'ur';
      case AppLanguage.id:
        return 'id';
      case AppLanguage.ms:
        return 'ms';
    }
  }
}

/// أدوار المستخدمين في التطبيق — نفس منطق نسخة الويب.
enum UserRole { owner, tripManager, departureManager, hotelManager, busSupervisor }

extension UserRoleX on UserRole {
  String get demoName {
    switch (this) {
      case UserRole.owner:
        return 'أحمد السيد';
      case UserRole.tripManager:
        return 'سارة منصور';
      case UserRole.departureManager:
        return 'خالد سالم';
      case UserRole.hotelManager:
        return 'أحمد فوزي';
      case UserRole.busSupervisor:
        return 'محمد عطية';
    }
  }

  String get initials {
    // أول حرفين من الاسم التجريبي، لعرضه في الأفاتار.
    final parts = demoName.split(' ');
    if (parts.length >= 2) return parts[0][0] + parts[1][0];
    return demoName.substring(0, 2);
  }
}

enum TripTier { economy, premium, vip }

extension TripTierX on TripTier {
  String get label {
    switch (this) {
      case TripTier.economy:
        return 'اقتصادي';
      case TripTier.premium:
        return 'مميز';
      case TripTier.vip:
        return 'VIP';
    }
  }
}

enum TripStatus { active, draft }

class Trip {
  final String id;
  final String name;
  final String destination;
  final int days;
  final int stars;
  final TripTier tier;
  final TripStatus status;
  final double price;
  final int seatsFilled;
  final int seatsTotal;
  final String? hotelMecca;
  final String? hotelMedina;

  const Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.days,
    required this.stars,
    required this.tier,
    required this.status,
    required this.price,
    required this.seatsFilled,
    required this.seatsTotal,
    this.hotelMecca,
    this.hotelMedina,
  });
}

class BusInfo {
  final String id;
  final String name;
  final int capacity;
  bool assignedToTrip;
  final String? arrivalTime;

  BusInfo({
    required this.id,
    required this.name,
    required this.capacity,
    this.assignedToTrip = false,
    this.arrivalTime,
  });
}

class Traveler {
  final String id;
  final String name;
  final String passportOrId;
  final String phone;
  final double? amountPaid;
  final int tripsCount;
  final String category;

  const Traveler({
    required this.id,
    required this.name,
    required this.passportOrId,
    required this.phone,
    this.amountPaid,
    this.tripsCount = 1,
    this.category = 'عمرة',
  });
}

/// فندق متعاقد معه — يُعرض في "الفنادق والإقامة" ويُستخدم عند تعيين الفندق لبرنامج.
class Hotel {
  final String name;
  final String city;
  final int stars;
  final String distance;
  final String phone;

  const Hotel({
    required this.name,
    required this.city,
    required this.stars,
    required this.distance,
    this.phone = '+966 5X XXX XXXX',
  });
}

enum TransportType { bus, flight }

extension TransportTypeX on TransportType {
  String get label => this == TransportType.bus ? 'باص' : 'طيران';
}

/// وسيلة نقل (باص أو شركة طيران شريكة) — تُعرض في "النقل والطيران".
class TransportItem {
  final TransportType type;
  final String name;
  final String? driver;
  final int? capacity;

  const TransportItem({
    required this.type,
    required this.name,
    this.driver,
    this.capacity,
  });
}

/// عضو فريق عمل (مستخدم/مشرف) بأدوار متعددة محتملة.
class TeamUser {
  final String name;
  final String contact;
  final Set<UserRole> roles;

  const TeamUser({
    required this.name,
    required this.contact,
    required this.roles,
  });
}

enum NotificationKind { info, warning, danger, success }

class AppNotification {
  final String title;
  final String timeAgo;
  final NotificationKind kind;

  const AppNotification({
    required this.title,
    required this.timeAgo,
    required this.kind,
  });
}

class RoomAssignment {
  final String floor;
  final String roomNumber;
  final List<String> occupantNames;

  const RoomAssignment({
    required this.floor,
    required this.roomNumber,
    required this.occupantNames,
  });

  int get capacity => occupantNames.length;
}

/// مدينة سعودية (Backend) — تُستخدم في اختيار مدينة الفندق أو مدينة الانطلاق.
class SaudiCity {
  final int id;
  final String name;
  const SaudiCity({required this.id, required this.name});

  factory SaudiCity.fromJson(Map<String, dynamic> j) =>
      SaudiCity(id: j['id'] as int, name: j['name'] as String? ?? '');
}

/// فندق متعاقد معه فعليًا في شاشة "الفنادق والإقامة" (Backend حقيقي).
class CompanyHotel {
  final int id;
  final int cityId;
  final String cityName;
  final String name;
  final int stars;
  final String distanceHaram;
  final String contact;
  final String notes;

  const CompanyHotel({
    required this.id,
    required this.cityId,
    required this.cityName,
    required this.name,
    required this.stars,
    required this.distanceHaram,
    this.contact = '',
    this.notes = '',
  });

  factory CompanyHotel.fromJson(Map<String, dynamic> j) => CompanyHotel(
        id: j['id'] as int,
        cityId: j['city_id'] as int? ?? 0,
        cityName: j['city_name'] as String? ?? '',
        name: j['name'] as String? ?? '',
        stars: j['stars'] as int? ?? 0,
        distanceHaram: j['distance_haram']?.toString() ?? '',
        contact: j['contact'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
      );
}

/// باص تابع لشركة أتوبيسات متعاقد معها (Backend حقيقي).
class CompanyBus {
  final int id;
  final int busCompanyId;
  final String busNumber;
  final int? capacity;
  final String driverName;
  final String driverPhone;
  final String notes;

  const CompanyBus({
    required this.id,
    required this.busCompanyId,
    required this.busNumber,
    this.capacity,
    this.driverName = '',
    this.driverPhone = '',
    this.notes = '',
  });

  factory CompanyBus.fromJson(Map<String, dynamic> j) => CompanyBus(
        id: j['id'] as int,
        busCompanyId: j['bus_company_id'] as int,
        busNumber: j['bus_number'] as String? ?? '',
        capacity: j['capacity'] as int?,
        driverName: j['driver_name'] as String? ?? '',
        driverPhone: j['driver_phone'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
      );
}

/// شركة أتوبيسات متعاقد معها، مع باصاتها (Backend حقيقي).
class CompanyBusCompany {
  final int id;
  final String name;
  final String contact;
  final String notes;
  final List<CompanyBus> buses;

  const CompanyBusCompany({
    required this.id,
    required this.name,
    this.contact = '',
    this.notes = '',
    this.buses = const [],
  });

  factory CompanyBusCompany.fromJson(Map<String, dynamic> j) => CompanyBusCompany(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        contact: j['contact'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
        buses: (j['buses'] as List<dynamic>? ?? []).map((b) => CompanyBus.fromJson(b as Map<String, dynamic>)).toList(),
      );
}

/// عميل/معتمر فعلي (Backend حقيقي) — شاشة إدارة المعتمرين.
class Customer {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final int bookingsCount;
  final double totalSpent;
  final List<String> tripTypes;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.bookingsCount = 0,
    this.totalSpent = 0,
    this.tripTypes = const [],
  });

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        email: j['email'] as String?,
        bookingsCount: j['bookings_count'] as int? ?? 0,
        totalSpent: _toDouble(j['total_spent']),
        tripTypes: (j['trip_types'] as List<dynamic>? ?? []).cast<String>(),
      );
}

/// بيانات الشركة (Backend حقيقي) — شاشة إعدادات الشركة.
class CompanyInfo {
  final int id;
  final String name;
  final String? fullName;
  final String type;
  final String? commercialRegister;
  final int? foundedYear;
  final String? about;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? website;
  final String? addressText;
  final String? slogan;
  final String? logo;

  const CompanyInfo({
    required this.id,
    required this.name,
    this.fullName,
    this.type = 'umrah',
    this.commercialRegister,
    this.foundedYear,
    this.about,
    this.phone,
    this.whatsapp,
    this.email,
    this.website,
    this.addressText,
    this.slogan,
    this.logo,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> j) => CompanyInfo(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        fullName: j['full_name'] as String?,
        type: j['type'] as String? ?? 'umrah',
        commercialRegister: j['commercial_register'] as String?,
        foundedYear: j['founded_year'] as int?,
        about: j['about'] as String?,
        phone: j['phone'] as String?,
        whatsapp: j['whatsapp'] as String?,
        email: j['email'] as String?,
        website: j['website'] as String?,
        addressText: j['address_text'] as String?,
        slogan: j['slogan'] as String?,
        logo: j['logo'] as String?,
      );
}

enum AttendanceStatus { none, present, absent }

/// موظف فعلي في الشركة (Backend) — مختلف عن TeamUser التجريبي القديم.
class Employee {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final int roleId;
  final String roleName;
  final bool isActive;
  final String joined;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.roleId,
    required this.roleName,
    required this.isActive,
    required this.joined,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        roleId: json['role_id'] as int,
        roleName: json['role_name'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
        joined: json['joined'] as String? ?? '',
      );
}

/// دور وظيفي فعلي في الشركة (Backend) بصلاحيات ديناميكية.
class CompanyRole {
  final int id;
  final String name;
  final bool isOwner;
  final int usersCount;
  final List<String> permissions;

  const CompanyRole({
    required this.id,
    required this.name,
    required this.isOwner,
    required this.usersCount,
    required this.permissions,
  });

  factory CompanyRole.fromJson(Map<String, dynamic> json) => CompanyRole(
        id: json['id'] as int,
        name: json['name'] as String,
        isOwner: json['is_owner'] as bool? ?? false,
        usersCount: json['users_count'] as int? ?? 0,
        permissions: (json['permissions'] as List<dynamic>? ?? []).cast<String>(),
      );
}

/// برنامج عمرة فعلي (Backend) — مختلف عن Trip التجريبي القديم.
class ApiTrip {
  final int id;
  final String title;
  final String type; // economy/premium/vip
  final String status; // active/inactive
  final int durationDays;
  final double price;
  final String currency;
  final int totalSeats;
  final int bookingsCount;
  final String? hotelName;
  final int hotelStars;
  final String? hotelNameMadinah;
  final int hotelStarsMadinah;
  final String? airline;
  final String? flightNoGo;
  final String? flightNoReturn;
  final String? departureTime;
  final String? nextDate;
  final List<Map<String, dynamic>> buses;
  final List<Map<String, dynamic>> supervisors;

  const ApiTrip({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.durationDays,
    required this.price,
    required this.currency,
    required this.totalSeats,
    required this.bookingsCount,
    this.hotelName,
    this.hotelStars = 0,
    this.hotelNameMadinah,
    this.hotelStarsMadinah = 0,
    this.airline,
    this.flightNoGo,
    this.flightNoReturn,
    this.departureTime,
    this.nextDate,
    this.buses = const [],
    this.supervisors = const [],
  });

  factory ApiTrip.fromJson(Map<String, dynamic> j) => ApiTrip(
        id: j['id'] as int,
        title: j['title'] as String? ?? '',
        type: j['type'] as String? ?? 'economy',
        status: j['status'] as String? ?? 'active',
        durationDays: j['duration_days'] as int? ?? 0,
        price: _toDouble(j['price']),
        currency: j['currency'] as String? ?? '',
        totalSeats: j['total_seats'] as int? ?? 0,
        bookingsCount: j['bookings_count'] as int? ?? 0,
        hotelName: j['hotel_name'] as String?,
        hotelStars: j['hotel_stars'] as int? ?? 0,
        hotelNameMadinah: j['hotel_name_madinah'] as String?,
        hotelStarsMadinah: j['hotel_stars_madinah'] as int? ?? 0,
        airline: j['airline'] as String?,
        flightNoGo: j['flight_no_go'] as String?,
        flightNoReturn: j['flight_no_return'] as String?,
        departureTime: j['departure_time'] as String?,
        nextDate: j['next_date'] as String?,
        buses: (j['buses'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>(),
        supervisors: (j['supervisors'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>(),
      );
}

/// فندق متعاقد معه فعليًا (Backend) — يُستخدم عند تسكين الحجوزات.
class AssignableHotel {
  final int id;
  final String name;
  final int stars;
  final String? distanceHaram;
  final String city;

  const AssignableHotel({required this.id, required this.name, required this.stars, this.distanceHaram, this.city = ''});

  factory AssignableHotel.fromJson(Map<String, dynamic> j) => AssignableHotel(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        stars: j['stars'] as int? ?? 0,
        distanceHaram: j['distance_haram']?.toString(),
        city: j['city'] as String? ?? '',
      );
}

/// باص فعلي (Backend) — يُستخدم عند تسكين الرحلات والحجوزات.
class AssignableBus {
  final int id;
  final String number;
  final int capacity;
  final String company;

  const AssignableBus({required this.id, required this.number, required this.capacity, this.company = ''});

  factory AssignableBus.fromJson(Map<String, dynamic> j) => AssignableBus(
        id: j['id'] as int,
        number: j['number'] as String? ?? (j['bus_number'] as String? ?? ''),
        capacity: j['capacity'] as int? ?? 0,
        company: j['company'] as String? ?? '',
      );
}

/// موظف فعلي مؤهل ليكون مشرف رحلة (Backend).
class AssignableEmployee {
  final int id;
  final String name;
  final String role;

  const AssignableEmployee({required this.id, required this.name, this.role = ''});

  factory AssignableEmployee.fromJson(Map<String, dynamic> j) => AssignableEmployee(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        role: j['role'] as String? ?? '',
      );
}

/// مجموعة صلاحيات (قسم) — تُستخدم في شاشة إنشاء/تعديل الدور.
class PermissionGroup {
  final String key;
  final String label;
  final Map<String, String> permissions; // permission key -> label

  const PermissionGroup({required this.key, required this.label, required this.permissions});

  factory PermissionGroup.fromJson(String key, Map<String, dynamic> json) => PermissionGroup(
        key: key,
        label: json['label'] as String? ?? key,
        permissions: (json['permissions'] as Map<String, dynamic>? ?? {}).map((k, v) => MapEntry(k, v as String)),
      );
}
