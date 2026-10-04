import '../models/models.dart';

/// قاموس ترجمة التطبيق لكل اللغات المتاحة. مفاتيح النصوص الثابتة (عناوين،
/// أزرار، تسميات حقول...) فقط — البيانات التجريبية (أسماء الأشخاص والبرامج
/// والفنادق) تبقى كما أُدخلت، زي أي بيانات حقيقية قادمة من Backend.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<AppLanguage, String>> _dict = {
    // ===== شريط التنقل السفلي =====
    'nav_home': {
      AppLanguage.ar: 'الرئيسية', AppLanguage.en: 'Home', AppLanguage.fr: 'Accueil',
      AppLanguage.tr: 'Ana Sayfa', AppLanguage.ur: 'ہوم',
      AppLanguage.id: 'Beranda', AppLanguage.ms: 'Laman Utama',
    },
    'nav_bookings': {
      AppLanguage.ar: 'الحجوزات', AppLanguage.en: 'Bookings', AppLanguage.fr: 'Réservations',
      AppLanguage.tr: 'Rezervasyonlar', AppLanguage.ur: 'بکنگز',
      AppLanguage.id: 'Pemesanan', AppLanguage.ms: 'Tempahan',
    },
    'nav_trips': {
      AppLanguage.ar: 'البرامج', AppLanguage.en: 'Programs', AppLanguage.fr: 'Programmes',
      AppLanguage.tr: 'Programlar', AppLanguage.ur: 'پروگرامز',
      AppLanguage.id: 'Program', AppLanguage.ms: 'Program',
    },
    'nav_account': {
      AppLanguage.ar: 'حسابي', AppLanguage.en: 'Account', AppLanguage.fr: 'Mon compte',
      AppLanguage.tr: 'Hesabım', AppLanguage.ur: 'میرا اکاؤنٹ',
      AppLanguage.id: 'Akun', AppLanguage.ms: 'Akaun',
    },
    'nav_hotel_home': {
      AppLanguage.ar: 'الفندق', AppLanguage.en: 'Hotel', AppLanguage.fr: 'Hôtel',
      AppLanguage.tr: 'Otel', AppLanguage.ur: 'ہوٹل',
      AppLanguage.id: 'Hotel', AppLanguage.ms: 'Hotel',
    },
    'nav_hotel_trips': {
      AppLanguage.ar: 'برامج الفندق', AppLanguage.en: 'Hotel programs', AppLanguage.fr: "Programmes de l'hôtel",
      AppLanguage.tr: 'Otel programları', AppLanguage.ur: 'ہوٹل پروگرامز',
      AppLanguage.id: 'Program hotel', AppLanguage.ms: 'Program hotel',
    },
    'nav_bus_home': {
      AppLanguage.ar: 'الباص', AppLanguage.en: 'Bus', AppLanguage.fr: 'Bus',
      AppLanguage.tr: 'Otobüs', AppLanguage.ur: 'بس',
      AppLanguage.id: 'Bus', AppLanguage.ms: 'Bas',
    },
    'nav_bus_trips': {
      AppLanguage.ar: 'برامج الباص', AppLanguage.en: 'Bus programs', AppLanguage.fr: 'Programmes du bus',
      AppLanguage.tr: 'Otobüs programları', AppLanguage.ur: 'بس پروگرامز',
      AppLanguage.id: 'Program bus', AppLanguage.ms: 'Program bas',
    },

    // ===== تسجيل الدخول =====
    'login_subtitle': {
      AppLanguage.ar: 'سجّل دخولك للمتابعة', AppLanguage.en: 'Sign in to continue',
      AppLanguage.fr: 'Connectez-vous pour continuer', AppLanguage.tr: 'Devam etmek için giriş yapın',
      AppLanguage.ur: 'جاری رکھنے کے لیے سائن ان کریں',
      AppLanguage.id: 'Masuk untuk melanjutkan', AppLanguage.ms: 'Log masuk untuk meneruskan',
    },
    'login_phone': {
      AppLanguage.ar: 'رقم الجوال', AppLanguage.en: 'Phone number', AppLanguage.fr: 'Numéro de téléphone',
      AppLanguage.tr: 'Telefon numarası', AppLanguage.ur: 'فون نمبر',
      AppLanguage.id: 'Nomor ponsel', AppLanguage.ms: 'Nombor telefon',
    },
    'login_password': {
      AppLanguage.ar: 'كلمة المرور', AppLanguage.en: 'Password', AppLanguage.fr: 'Mot de passe',
      AppLanguage.tr: 'Şifre', AppLanguage.ur: 'پاس ورڈ',
      AppLanguage.id: 'Kata sandi', AppLanguage.ms: 'Kata laluan',
    },
    'login_as': {
      AppLanguage.ar: 'تسجيل الدخول بصفتك', AppLanguage.en: 'Sign in as', AppLanguage.fr: 'Se connecter en tant que',
      AppLanguage.tr: 'Şu şekilde giriş yap', AppLanguage.ur: 'اس حیثیت سے سائن ان کریں',
      AppLanguage.id: 'Masuk sebagai', AppLanguage.ms: 'Log masuk sebagai',
    },
    'login_as_multi_hint': {
      AppLanguage.ar: 'يمكنك اختيار أكتر من دور لو عندك أكتر من تخصص', AppLanguage.en: 'You can select more than one role if you hold multiple specialties',
      AppLanguage.fr: 'Vous pouvez sélectionner plusieurs rôles si vous avez plusieurs spécialités',
      AppLanguage.tr: 'Birden fazla uzmanlığınız varsa birden çok rol seçebilirsiniz', AppLanguage.ur: 'اگر آپ کے پاس ایک سے زیادہ مہارتیں ہیں تو آپ ایک سے زیادہ کردار منتخب کر سکتے ہیں',
      AppLanguage.id: 'Anda dapat memilih lebih dari satu peran jika memiliki beberapa spesialisasi',
      AppLanguage.ms: 'Anda boleh memilih lebih daripada satu peranan jika mempunyai beberapa kepakaran',
    },
    'login_button': {
      AppLanguage.ar: 'تسجيل الدخول', AppLanguage.en: 'Sign in', AppLanguage.fr: 'Se connecter',
      AppLanguage.tr: 'Giriş yap', AppLanguage.ur: 'سائن ان کریں',
      AppLanguage.id: 'Masuk', AppLanguage.ms: 'Log masuk',
    },
    'login_country_code': {
      AppLanguage.ar: 'المفتاح', AppLanguage.en: 'Code', AppLanguage.fr: 'Indicatif',
      AppLanguage.tr: 'Kod', AppLanguage.ur: 'کوڈ',
      AppLanguage.id: 'Kode', AppLanguage.ms: 'Kod',
    },
    'role_owner_title': {
      AppLanguage.ar: 'المدير / مالك الشركة', AppLanguage.en: 'Manager / Company owner',
      AppLanguage.fr: 'Directeur / Propriétaire de l\'entreprise', AppLanguage.tr: 'Müdür / Şirket sahibi',
      AppLanguage.ur: 'منیجر / کمپنی مالک',
      AppLanguage.id: 'Manajer / Pemilik perusahaan', AppLanguage.ms: 'Pengurus / Pemilik syarikat',
    },
    'role_owner_desc': {
      AppLanguage.ar: 'صلاحية كاملة على كل شيء', AppLanguage.en: 'Full access to everything',
      AppLanguage.fr: 'Accès complet à tout', AppLanguage.tr: 'Her şeye tam erişim',
      AppLanguage.ur: 'ہر چیز تک مکمل رسائی',
      AppLanguage.id: 'Akses penuh ke semuanya', AppLanguage.ms: 'Akses penuh kepada semua perkara',
    },
    'role_tripManager_title': {
      AppLanguage.ar: 'مدير الرحلات', AppLanguage.en: 'Trip manager', AppLanguage.fr: 'Responsable des voyages',
      AppLanguage.tr: 'Seyahat yöneticisi', AppLanguage.ur: 'ٹرپ منیجر',
      AppLanguage.id: 'Manajer perjalanan', AppLanguage.ms: 'Pengurus perjalanan',
    },
    'role_tripManager_desc': {
      AppLanguage.ar: 'يعيّن الفنادق والباصات والمشرفين', AppLanguage.en: 'Assigns hotels, buses, and supervisors',
      AppLanguage.fr: 'Attribue les hôtels, les bus et les superviseurs', AppLanguage.tr: 'Otel, otobüs ve süpervizör ataması yapar',
      AppLanguage.ur: 'ہوٹل، بسیں اور سپروائزرز تفویض کرتا ہے',
      AppLanguage.id: 'Menetapkan hotel, bus, dan supervisor', AppLanguage.ms: 'Menetapkan hotel, bas, dan penyelia',
    },
    'role_departureManager_title': {
      AppLanguage.ar: 'مدير الانطلاق', AppLanguage.en: 'Departure manager', AppLanguage.fr: 'Responsable de départ',
      AppLanguage.tr: 'Hareket yöneticisi', AppLanguage.ur: 'روانگی منیجر',
      AppLanguage.id: 'Manajer keberangkatan', AppLanguage.ms: 'Pengurus perlepasan',
    },
    'role_departureManager_desc': {
      AppLanguage.ar: 'يعيّن الباصات ويضيف معتمرين', AppLanguage.en: 'Assigns buses and adds pilgrims',
      AppLanguage.fr: 'Attribue les bus et ajoute des pèlerins', AppLanguage.tr: 'Otobüs atar ve hacı/umreci ekler',
      AppLanguage.ur: 'بسیں تفویض کرتا ہے اور زائرین شامل کرتا ہے',
      AppLanguage.id: 'Menetapkan bus dan menambahkan jemaah', AppLanguage.ms: 'Menetapkan bas dan menambah jemaah',
    },
    'role_hotelManager_title': {
      AppLanguage.ar: 'مدير / مشرف الفندق', AppLanguage.en: 'Hotel manager / supervisor',
      AppLanguage.fr: 'Directeur / Superviseur de l\'hôtel', AppLanguage.tr: 'Otel müdürü / süpervizörü',
      AppLanguage.ur: 'ہوٹل منیجر / سپروائزر',
      AppLanguage.id: 'Manajer / supervisor hotel', AppLanguage.ms: 'Pengurus / penyelia hotel',
    },
    'role_hotelManager_desc': {
      AppLanguage.ar: 'يستقبل الباصات ويسكّن المعتمرين', AppLanguage.en: 'Receives buses and houses pilgrims',
      AppLanguage.fr: 'Accueille les bus et loge les pèlerins', AppLanguage.tr: 'Otobüsleri karşılar ve hacıları/umrecileri yerleştirir',
      AppLanguage.ur: 'بسوں کا استقبال کرتا ہے اور زائرین کو کمروں میں ٹھہراتا ہے',
      AppLanguage.id: 'Menerima bus dan menempatkan jemaah', AppLanguage.ms: 'Menerima bas dan menempatkan jemaah',
    },
    'role_busSupervisor_title': {
      AppLanguage.ar: 'مشرف الباص', AppLanguage.en: 'Bus supervisor', AppLanguage.fr: 'Superviseur de bus',
      AppLanguage.tr: 'Otobüs süpervizörü', AppLanguage.ur: 'بس سپروائزر',
      AppLanguage.id: 'Supervisor bus', AppLanguage.ms: 'Penyelia bas',
    },
    'role_busSupervisor_desc': {
      AppLanguage.ar: 'يسجّل حضور وغياب المعتمرين', AppLanguage.en: 'Records pilgrim attendance',
      AppLanguage.fr: 'Enregistre la présence des pèlerins', AppLanguage.tr: 'Hacı/umreci yoklamasını kaydeder',
      AppLanguage.ur: 'زائرین کی حاضری ریکارڈ کرتا ہے',
      AppLanguage.id: 'Mencatat kehadiran jemaah', AppLanguage.ms: 'Merekod kehadiran jemaah',
    },

    // ===== حسابي =====
    'profile_travelers': {
      AppLanguage.ar: 'إدارة المعتمرين', AppLanguage.en: 'Manage pilgrims', AppLanguage.fr: 'Gérer les pèlerins',
      AppLanguage.tr: 'Hacı/umrecileri yönet', AppLanguage.ur: 'زائرین کا انتظام',
      AppLanguage.id: 'Kelola jemaah', AppLanguage.ms: 'Urus jemaah',
    },
    'profile_hotels': {
      AppLanguage.ar: 'الفنادق والإقامة', AppLanguage.en: 'Hotels & accommodation', AppLanguage.fr: 'Hôtels et hébergement',
      AppLanguage.tr: 'Oteller ve konaklama', AppLanguage.ur: 'ہوٹلز اور رہائش',
      AppLanguage.id: 'Hotel & akomodasi', AppLanguage.ms: 'Hotel & penginapan',
    },
    'profile_transport': {
      AppLanguage.ar: 'النقل والطيران', AppLanguage.en: 'Transport & flights', AppLanguage.fr: 'Transport et vols',
      AppLanguage.tr: 'Ulaşım ve uçuşlar', AppLanguage.ur: 'ٹرانسپورٹ اور پروازیں',
      AppLanguage.id: 'Transportasi & penerbangan', AppLanguage.ms: 'Pengangkutan & penerbangan',
    },
    'profile_reports': {
      AppLanguage.ar: 'التقارير والإحصائيات', AppLanguage.en: 'Reports & analytics', AppLanguage.fr: 'Rapports et statistiques',
      AppLanguage.tr: 'Raporlar ve istatistikler', AppLanguage.ur: 'رپورٹس اور اعداد و شمار',
      AppLanguage.id: 'Laporan & analitik', AppLanguage.ms: 'Laporan & analitik',
    },
    'profile_my_reports': {
      AppLanguage.ar: 'تقاريري', AppLanguage.en: 'My reports', AppLanguage.fr: 'Mes rapports',
      AppLanguage.tr: 'Raporlarım', AppLanguage.ur: 'میری رپورٹس',
      AppLanguage.id: 'Laporan saya', AppLanguage.ms: 'Laporan saya',
    },
    'profile_users': {
      AppLanguage.ar: 'المستخدمون والمشرفون', AppLanguage.en: 'Users & supervisors', AppLanguage.fr: 'Utilisateurs et superviseurs',
      AppLanguage.tr: 'Kullanıcılar ve süpervizörler', AppLanguage.ur: 'صارفین اور سپروائزرز',
      AppLanguage.id: 'Pengguna & supervisor', AppLanguage.ms: 'Pengguna & penyelia',
    },
    'profile_company': {
      AppLanguage.ar: 'بيانات الشركة', AppLanguage.en: 'Company details', AppLanguage.fr: 'Informations de l\'entreprise',
      AppLanguage.tr: 'Şirket bilgileri', AppLanguage.ur: 'کمپنی کی تفصیلات',
      AppLanguage.id: 'Detail perusahaan', AppLanguage.ms: 'Butiran syarikat',
    },
    'profile_notifications': {
      AppLanguage.ar: 'الإشعارات', AppLanguage.en: 'Notifications', AppLanguage.fr: 'Notifications',
      AppLanguage.tr: 'Bildirimler', AppLanguage.ur: 'اطلاعات',
      AppLanguage.id: 'Notifikasi', AppLanguage.ms: 'Pemberitahuan',
    },
    'profile_language': {
      AppLanguage.ar: 'اللغة', AppLanguage.en: 'Language', AppLanguage.fr: 'Langue',
      AppLanguage.tr: 'Dil', AppLanguage.ur: 'زبان',
      AppLanguage.id: 'Bahasa', AppLanguage.ms: 'Bahasa',
    },
    'profile_logout': {
      AppLanguage.ar: 'تسجيل الخروج', AppLanguage.en: 'Log out', AppLanguage.fr: 'Se déconnecter',
      AppLanguage.tr: 'Çıkış yap', AppLanguage.ur: 'لاگ آؤٹ',
      AppLanguage.id: 'Keluar', AppLanguage.ms: 'Log keluar',
    },
    'language_sheet_title': {
      AppLanguage.ar: 'اختر لغة التطبيق', AppLanguage.en: 'Choose app language', AppLanguage.fr: 'Choisissez la langue de l\'application',
      AppLanguage.tr: 'Uygulama dilini seçin', AppLanguage.ur: 'ایپ کی زبان منتخب کریں',
      AppLanguage.id: 'Pilih bahasa aplikasi', AppLanguage.ms: 'Pilih bahasa aplikasi',
    },

    // ===== عام / وحدات =====
    'unit_days': {
      AppLanguage.ar: 'أيام', AppLanguage.en: 'days', AppLanguage.fr: 'jours', AppLanguage.tr: 'gün', AppLanguage.ur: 'دن',
      AppLanguage.id: 'hari', AppLanguage.ms: 'hari',
    },
    'unit_stars': {
      AppLanguage.ar: 'نجوم', AppLanguage.en: 'stars', AppLanguage.fr: 'étoiles', AppLanguage.tr: 'yıldız', AppLanguage.ur: 'ستارے',
      AppLanguage.id: 'bintang', AppLanguage.ms: 'bintang',
    },
    'unit_seat': {
      AppLanguage.ar: 'مقعد', AppLanguage.en: 'seat', AppLanguage.fr: 'place', AppLanguage.tr: 'koltuk', AppLanguage.ur: 'نشست',
      AppLanguage.id: 'kursi', AppLanguage.ms: 'tempat duduk',
    },
    'unit_passenger': {
      AppLanguage.ar: 'راكب', AppLanguage.en: 'passenger', AppLanguage.fr: 'passager', AppLanguage.tr: 'yolcu', AppLanguage.ur: 'مسافر',
      AppLanguage.id: 'penumpang', AppLanguage.ms: 'penumpang',
    },
    'unit_week': {
      AppLanguage.ar: 'أسبوع', AppLanguage.en: 'week', AppLanguage.fr: 'semaine', AppLanguage.tr: 'hafta', AppLanguage.ur: 'ہفتہ',
      AppLanguage.id: 'minggu', AppLanguage.ms: 'minggu',
    },
    'unit_month': {
      AppLanguage.ar: 'شهر', AppLanguage.en: 'month', AppLanguage.fr: 'mois', AppLanguage.tr: 'ay', AppLanguage.ur: 'مہینہ',
      AppLanguage.id: 'bulan', AppLanguage.ms: 'bulan',
    },
    'field_repeat_days_label': {
      AppLanguage.ar: 'أيام التكرار', AppLanguage.en: 'Repeat days', AppLanguage.fr: 'Jours de répétition',
      AppLanguage.tr: 'Tekrar günleri', AppLanguage.ur: 'تکرار کے دن',
      AppLanguage.id: 'Hari pengulangan', AppLanguage.ms: 'Hari ulangan',
    },
    'field_day_of_month': {
      AppLanguage.ar: 'يوم من الشهر', AppLanguage.en: 'Day of month', AppLanguage.fr: 'Jour du mois',
      AppLanguage.tr: 'Ayın günü', AppLanguage.ur: 'مہینے کا دن',
      AppLanguage.id: 'Tanggal dalam bulan', AppLanguage.ms: 'Hari dalam bulan',
    },
    'weekday_sat': {
      AppLanguage.ar: 'السبت', AppLanguage.en: 'Sat', AppLanguage.fr: 'Sam', AppLanguage.tr: 'Cmt', AppLanguage.ur: 'ہفتہ',
      AppLanguage.id: 'Sab', AppLanguage.ms: 'Sab',
    },
    'weekday_sun': {
      AppLanguage.ar: 'الأحد', AppLanguage.en: 'Sun', AppLanguage.fr: 'Dim', AppLanguage.tr: 'Paz', AppLanguage.ur: 'اتوار',
      AppLanguage.id: 'Min', AppLanguage.ms: 'Ahd',
    },
    'weekday_mon': {
      AppLanguage.ar: 'الاثنين', AppLanguage.en: 'Mon', AppLanguage.fr: 'Lun', AppLanguage.tr: 'Pzt', AppLanguage.ur: 'پیر',
      AppLanguage.id: 'Sen', AppLanguage.ms: 'Isn',
    },
    'weekday_tue': {
      AppLanguage.ar: 'الثلاثاء', AppLanguage.en: 'Tue', AppLanguage.fr: 'Mar', AppLanguage.tr: 'Sal', AppLanguage.ur: 'منگل',
      AppLanguage.id: 'Sel', AppLanguage.ms: 'Sel',
    },
    'weekday_wed': {
      AppLanguage.ar: 'الأربعاء', AppLanguage.en: 'Wed', AppLanguage.fr: 'Mer', AppLanguage.tr: 'Çar', AppLanguage.ur: 'بدھ',
      AppLanguage.id: 'Rab', AppLanguage.ms: 'Rab',
    },
    'weekday_thu': {
      AppLanguage.ar: 'الخميس', AppLanguage.en: 'Thu', AppLanguage.fr: 'Jeu', AppLanguage.tr: 'Per', AppLanguage.ur: 'جمعرات',
      AppLanguage.id: 'Kam', AppLanguage.ms: 'Kha',
    },
    'weekday_fri': {
      AppLanguage.ar: 'الجمعة', AppLanguage.en: 'Fri', AppLanguage.fr: 'Ven', AppLanguage.tr: 'Cum', AppLanguage.ur: 'جمعہ',
      AppLanguage.id: 'Jum', AppLanguage.ms: 'Jum',
    },
    'city_order_label': {
      AppLanguage.ar: 'ترتيب المدن', AppLanguage.en: 'City order', AppLanguage.fr: 'Ordre des villes',
      AppLanguage.tr: 'Şehir sırası', AppLanguage.ur: 'شہر کی ترتیب',
      AppLanguage.id: 'Urutan kota', AppLanguage.ms: 'Susunan bandar',
    },
    'city_order_mecca_first': {
      AppLanguage.ar: 'مكة أولاً', AppLanguage.en: 'Mecca first', AppLanguage.fr: "La Mecque d'abord",
      AppLanguage.tr: 'Önce Mekke', AppLanguage.ur: 'پہلے مکہ',
      AppLanguage.id: 'Mekkah dulu', AppLanguage.ms: 'Mekah dahulu',
    },
    'city_order_medina_first': {
      AppLanguage.ar: 'المدينة أولاً', AppLanguage.en: 'Medina first', AppLanguage.fr: "Médine d'abord",
      AppLanguage.tr: 'Önce Medine', AppLanguage.ur: 'پہلے مدینہ',
      AppLanguage.id: 'Madinah dulu', AppLanguage.ms: 'Madinah dahulu',
    },
    'currency_sar': {
      AppLanguage.ar: 'ر.س', AppLanguage.en: 'SAR', AppLanguage.fr: 'SAR', AppLanguage.tr: 'SAR', AppLanguage.ur: 'SAR',
      AppLanguage.id: 'SAR', AppLanguage.ms: 'SAR',
    },
    'brand_tagline': {
      AppLanguage.ar: 'إدارة برامج العمرة', AppLanguage.en: 'Umrah program management',
      AppLanguage.fr: 'Gestion des programmes de Omra', AppLanguage.tr: 'Umre program yönetimi',
      AppLanguage.ur: 'عمرہ پروگرام مینجمنٹ',
      AppLanguage.id: 'Manajemen program umrah', AppLanguage.ms: 'Pengurusan program umrah',
    },
    'greeting_hello': {
      AppLanguage.ar: 'مرحباً', AppLanguage.en: 'Hello', AppLanguage.fr: 'Bonjour', AppLanguage.tr: 'Merhaba', AppLanguage.ur: 'خوش آمدید',
      AppLanguage.id: 'Halo', AppLanguage.ms: 'Helo',
    },
    'action_edit': {
      AppLanguage.ar: 'تعديل', AppLanguage.en: 'Edit', AppLanguage.fr: 'Modifier', AppLanguage.tr: 'Düzenle', AppLanguage.ur: 'ترمیم',
      AppLanguage.id: 'Ubah', AppLanguage.ms: 'Edit',
    },
    'label_program': {
      AppLanguage.ar: 'البرنامج', AppLanguage.en: 'Program', AppLanguage.fr: 'Programme', AppLanguage.tr: 'Program', AppLanguage.ur: 'پروگرام',
      AppLanguage.id: 'Program', AppLanguage.ms: 'Program',
    },
    'room_word': {
      AppLanguage.ar: 'غرفة', AppLanguage.en: 'Room', AppLanguage.fr: 'Chambre', AppLanguage.tr: 'Oda', AppLanguage.ur: 'کمرہ',
      AppLanguage.id: 'Kamar', AppLanguage.ms: 'Bilik',
    },
    'no_results': {
      AppLanguage.ar: 'لا نتائج', AppLanguage.en: 'No results', AppLanguage.fr: 'Aucun résultat',
      AppLanguage.tr: 'Sonuç yok', AppLanguage.ur: 'کوئی نتیجہ نہیں',
      AppLanguage.id: 'Tidak ada hasil', AppLanguage.ms: 'Tiada hasil',
    },
    'tooltip_expand': {
      AppLanguage.ar: 'تكبير', AppLanguage.en: 'Expand', AppLanguage.fr: 'Agrandir', AppLanguage.tr: 'Genişlet', AppLanguage.ur: 'بڑا کریں',
      AppLanguage.id: 'Perluas', AppLanguage.ms: 'Kembangkan',
    },
    'tooltip_collapse': {
      AppLanguage.ar: 'تصغير', AppLanguage.en: 'Collapse', AppLanguage.fr: 'Réduire', AppLanguage.tr: 'Küçült', AppLanguage.ur: 'چھوٹا کریں',
      AppLanguage.id: 'Ciutkan', AppLanguage.ms: 'Kuncupkan',
    },
    'action_done': {
      AppLanguage.ar: 'تم', AppLanguage.en: 'Done', AppLanguage.fr: 'Terminé', AppLanguage.tr: 'Tamam', AppLanguage.ur: 'مکمل',
      AppLanguage.id: 'Selesai', AppLanguage.ms: 'Selesai',
    },
    'action_save_generic': {
      AppLanguage.ar: 'حفظ', AppLanguage.en: 'Save', AppLanguage.fr: 'Enregistrer', AppLanguage.tr: 'Kaydet', AppLanguage.ur: 'محفوظ کریں',
      AppLanguage.id: 'Simpan', AppLanguage.ms: 'Simpan',
    },
    'city_mecca': {
      AppLanguage.ar: 'مكة المكرمة', AppLanguage.en: 'Mecca', AppLanguage.fr: 'La Mecque', AppLanguage.tr: 'Mekke', AppLanguage.ur: 'مکہ مکرمہ',
      AppLanguage.id: 'Mekkah', AppLanguage.ms: 'Mekah',
    },
    'city_medina': {
      AppLanguage.ar: 'المدينة المنورة', AppLanguage.en: 'Medina', AppLanguage.fr: 'Médine', AppLanguage.tr: 'Medine', AppLanguage.ur: 'مدینہ منورہ',
      AppLanguage.id: 'Madinah', AppLanguage.ms: 'Madinah',
    },

    // ===== الرئيسية (مالك/مدير رحلات) =====
    'stat_total_revenue': {
      AppLanguage.ar: 'إجمالي الإيرادات', AppLanguage.en: 'Total revenue', AppLanguage.fr: 'Revenu total',
      AppLanguage.tr: 'Toplam gelir', AppLanguage.ur: 'کل آمدنی',
      AppLanguage.id: 'Total pendapatan', AppLanguage.ms: 'Jumlah hasil',
    },
    'stat_bookings': {
      AppLanguage.ar: 'الحجوزات', AppLanguage.en: 'Bookings', AppLanguage.fr: 'Réservations',
      AppLanguage.tr: 'Rezervasyonlar', AppLanguage.ur: 'بکنگز',
      AppLanguage.id: 'Pemesanan', AppLanguage.ms: 'Tempahan',
    },
    'stat_travelers': {
      AppLanguage.ar: 'المعتمرون', AppLanguage.en: 'Pilgrims', AppLanguage.fr: 'Pèlerins',
      AppLanguage.tr: 'Hacı/Umreciler', AppLanguage.ur: 'زائرین',
      AppLanguage.id: 'Jemaah', AppLanguage.ms: 'Jemaah',
    },
    'stat_rating': {
      AppLanguage.ar: 'التقييم', AppLanguage.en: 'Rating', AppLanguage.fr: 'Note',
      AppLanguage.tr: 'Değerlendirme', AppLanguage.ur: 'درجہ بندی',
      AppLanguage.id: 'Peringkat', AppLanguage.ms: 'Penilaian',
    },
    'stat_pending_bookings': {AppLanguage.ar: 'حجوزات معلّقة', AppLanguage.en: 'Pending bookings'},
    'no_upcoming_trips': {AppLanguage.ar: 'لا توجد رحلات قادمة', AppLanguage.en: 'No upcoming trips'},
    'no_recent_activity': {AppLanguage.ar: 'لا يوجد نشاط حديث', AppLanguage.en: 'No recent activity'},
    'section_upcoming_trips': {
      AppLanguage.ar: 'الرحلات القادمة', AppLanguage.en: 'Upcoming trips', AppLanguage.fr: 'Voyages à venir',
      AppLanguage.tr: 'Yaklaşan seyahatler', AppLanguage.ur: 'آنے والے سفر',
      AppLanguage.id: 'Perjalanan mendatang', AppLanguage.ms: 'Perjalanan akan datang',
    },
    'section_current_upcoming_trips': {
      AppLanguage.ar: 'الرحلات الحالية والقادمة', AppLanguage.en: 'Current & upcoming trips',
      AppLanguage.fr: 'Voyages en cours et à venir', AppLanguage.tr: 'Devam eden ve yaklaşan seyahatler',
      AppLanguage.ur: 'جاری اور آنے والے سفر', AppLanguage.id: 'Perjalanan berjalan & mendatang',
      AppLanguage.ms: 'Perjalanan semasa & akan datang',
    },
    'trip_phase_current': {
      AppLanguage.ar: 'جارية الآن', AppLanguage.en: 'In progress', AppLanguage.fr: 'En cours',
      AppLanguage.tr: 'Devam ediyor', AppLanguage.ur: 'جاری ہے', AppLanguage.id: 'Berlangsung',
      AppLanguage.ms: 'Sedang berjalan',
    },
    'trip_starts_today': {
      AppLanguage.ar: 'تبدأ اليوم', AppLanguage.en: 'Starts today', AppLanguage.fr: "Commence aujourd'hui",
      AppLanguage.tr: 'Bugün başlıyor', AppLanguage.ur: 'آج شروع', AppLanguage.id: 'Mulai hari ini',
      AppLanguage.ms: 'Bermula hari ini',
    },
    'trip_starts_tomorrow': {
      AppLanguage.ar: 'تبدأ غدًا', AppLanguage.en: 'Starts tomorrow', AppLanguage.fr: 'Commence demain',
      AppLanguage.tr: 'Yarın başlıyor', AppLanguage.ur: 'کل شروع', AppLanguage.id: 'Mulai besok',
      AppLanguage.ms: 'Bermula esok',
    },
    'trip_in_days': {
      AppLanguage.ar: 'بعد {n} يوم', AppLanguage.en: 'In {n} days', AppLanguage.fr: 'Dans {n} jours',
      AppLanguage.tr: '{n} gün sonra', AppLanguage.ur: '{n} دن بعد', AppLanguage.id: '{n} hari lagi',
      AppLanguage.ms: '{n} hari lagi',
    },
    'trip_day_of': {
      AppLanguage.ar: 'اليوم {d} من {n}', AppLanguage.en: 'Day {d} of {n}', AppLanguage.fr: 'Jour {d} sur {n}',
      AppLanguage.tr: '{n} günün {d}. günü', AppLanguage.ur: '{n} میں سے دن {d}', AppLanguage.id: 'Hari {d} dari {n}',
      AppLanguage.ms: 'Hari {d} daripada {n}',
    },
    'trip_pilgrims': {
      AppLanguage.ar: 'المعتمرين', AppLanguage.en: 'Pilgrims', AppLanguage.fr: 'Pèlerins',
      AppLanguage.tr: 'Hacı adayları', AppLanguage.ur: 'معتمرین', AppLanguage.id: 'Jamaah',
      AppLanguage.ms: 'Jemaah',
    },
    'unit_bus': {
      AppLanguage.ar: 'باص', AppLanguage.en: 'bus(es)', AppLanguage.fr: 'bus', AppLanguage.tr: 'otobüs',
      AppLanguage.ur: 'بس', AppLanguage.id: 'bus', AppLanguage.ms: 'bas',
    },
    'program_banner_title': {
      AppLanguage.ar: 'برنامج الرحلة', AppLanguage.en: 'Trip program', AppLanguage.fr: 'Programme du voyage',
      AppLanguage.tr: 'Seyahat programı', AppLanguage.ur: 'سفر کا پروگرام', AppLanguage.id: 'Program perjalanan',
      AppLanguage.ms: 'Program perjalanan',
    },
    'program_not_defined': {
      AppLanguage.ar: 'لم يتم تحديد البرنامج بعد', AppLanguage.en: 'No program set yet',
      AppLanguage.fr: 'Aucun programme défini', AppLanguage.tr: 'Henüz program belirlenmedi',
      AppLanguage.ur: 'ابھی پروگرام طے نہیں ہوا', AppLanguage.id: 'Program belum ditentukan',
      AppLanguage.ms: 'Program belum ditetapkan',
    },
    'program_define_hint': {
      AppLanguage.ar: 'حدد أيام الرحلة وأنشطة كل يوم لتتابع سيرها يومًا بيوم',
      AppLanguage.en: 'Set the trip days and each day\'s activities to track it day by day',
      AppLanguage.fr: 'Définissez les jours et activités pour suivre le voyage jour par jour',
      AppLanguage.tr: 'Seyahati gün gün takip etmek için günleri ve etkinlikleri belirleyin',
      AppLanguage.ur: 'سفر کو دن بہ دن ٹریک کرنے کے لیے دن اور سرگرمیاں طے کریں',
      AppLanguage.id: 'Atur hari dan kegiatan untuk memantau perjalanan hari demi hari',
      AppLanguage.ms: 'Tetapkan hari dan aktiviti untuk menjejak perjalanan hari demi hari',
    },
    'program_define': {
      AppLanguage.ar: 'تحديد البرنامج', AppLanguage.en: 'Set program', AppLanguage.fr: 'Définir',
      AppLanguage.tr: 'Program belirle', AppLanguage.ur: 'پروگرام طے کریں', AppLanguage.id: 'Atur program',
      AppLanguage.ms: 'Tetapkan program',
    },
    'program_view': {
      AppLanguage.ar: 'تتبّع', AppLanguage.en: 'Track', AppLanguage.fr: 'Suivre', AppLanguage.tr: 'Takip et',
      AppLanguage.ur: 'ٹریک کریں', AppLanguage.id: 'Lacak', AppLanguage.ms: 'Jejak',
    },
    'program_day': {
      AppLanguage.ar: 'اليوم', AppLanguage.en: 'Day', AppLanguage.fr: 'Jour', AppLanguage.tr: 'Gün',
      AppLanguage.ur: 'دن', AppLanguage.id: 'Hari', AppLanguage.ms: 'Hari',
    },
    'program_today': {
      AppLanguage.ar: 'اليوم', AppLanguage.en: 'Today', AppLanguage.fr: "Aujourd'hui", AppLanguage.tr: 'Bugün',
      AppLanguage.ur: 'آج', AppLanguage.id: 'Hari ini', AppLanguage.ms: 'Hari ini',
    },
    'section_latest_notifications': {
      AppLanguage.ar: 'أحدث الإشعارات', AppLanguage.en: 'Latest notifications', AppLanguage.fr: 'Dernières notifications',
      AppLanguage.tr: 'Son bildirimler', AppLanguage.ur: 'تازہ ترین اطلاعات',
      AppLanguage.id: 'Notifikasi terbaru', AppLanguage.ms: 'Pemberitahuan terkini',
    },

    // ===== الحجوزات =====
    'bookings_title': {
      AppLanguage.ar: 'الحجوزات', AppLanguage.en: 'Bookings', AppLanguage.fr: 'Réservations',
      AppLanguage.tr: 'Rezervasyonlar', AppLanguage.ur: 'بکنگز',
      AppLanguage.id: 'Pemesanan', AppLanguage.ms: 'Tempahan',
    },
    'bookings_count_suffix': {
      AppLanguage.ar: 'حجوزات هذا الشهر', AppLanguage.en: 'bookings this month', AppLanguage.fr: 'réservations ce mois-ci',
      AppLanguage.tr: 'bu ay rezervasyon', AppLanguage.ur: 'اس مہینے بکنگز',
      AppLanguage.id: 'pemesanan bulan ini', AppLanguage.ms: 'tempahan bulan ini',
    },
    'bookings_search_hint': {
      AppLanguage.ar: 'بحث باسم العميل أو رقم الحجز', AppLanguage.en: 'Search by customer name or booking number',
      AppLanguage.fr: 'Rechercher par nom du client ou numéro de réservation',
      AppLanguage.tr: 'Müşteri adı veya rezervasyon numarasıyla ara', AppLanguage.ur: 'کسٹمر کا نام یا بکنگ نمبر تلاش کریں',
      AppLanguage.id: 'Cari berdasarkan nama pelanggan atau nomor pemesanan', AppLanguage.ms: 'Cari mengikut nama pelanggan atau nombor tempahan',
    },
    'status_paid': {
      AppLanguage.ar: 'مدفوع', AppLanguage.en: 'Paid', AppLanguage.fr: 'Payé', AppLanguage.tr: 'Ödendi', AppLanguage.ur: 'ادا شدہ',
      AppLanguage.id: 'Lunas', AppLanguage.ms: 'Dibayar',
    },
    'status_confirmed': {
      AppLanguage.ar: 'مؤكد', AppLanguage.en: 'Confirmed', AppLanguage.fr: 'Confirmé', AppLanguage.tr: 'Onaylandı', AppLanguage.ur: 'تصدیق شدہ',
      AppLanguage.id: 'Dikonfirmasi', AppLanguage.ms: 'Disahkan',
    },
    'status_cancelled': {
      AppLanguage.ar: 'ملغى', AppLanguage.en: 'Cancelled', AppLanguage.fr: 'Annulé', AppLanguage.tr: 'İptal edildi', AppLanguage.ur: 'منسوخ',
      AppLanguage.id: 'Dibatalkan', AppLanguage.ms: 'Dibatalkan',
    },
    'status_pending': {AppLanguage.ar: 'قيد الانتظار', AppLanguage.en: 'Pending'},
    'action_confirm_booking': {AppLanguage.ar: 'تأكيد الحجز', AppLanguage.en: 'Confirm booking'},
    'action_cancel_booking': {AppLanguage.ar: 'إلغاء الحجز', AppLanguage.en: 'Cancel booking'},
    'action_clear_assignment': {AppLanguage.ar: 'إلغاء التسكين', AppLanguage.en: 'Clear assignment'},

    // ===== البرامج (Trips) =====
    'trips_title': {
      AppLanguage.ar: 'برامج العمرة', AppLanguage.en: 'Umrah programs', AppLanguage.fr: 'Programmes de Omra',
      AppLanguage.tr: 'Umre programları', AppLanguage.ur: 'عمرہ پروگرامز',
      AppLanguage.id: 'Program umrah', AppLanguage.ms: 'Program umrah',
    },
    'tier_filter_title': {
      AppLanguage.ar: 'تصفية حسب الفئة', AppLanguage.en: 'Filter by tier', AppLanguage.fr: 'Filtrer par catégorie',
      AppLanguage.tr: 'Kategoriye göre filtrele', AppLanguage.ur: 'زمرے کے لحاظ سے فلٹر کریں',
      AppLanguage.id: 'Filter berdasarkan kategori', AppLanguage.ms: 'Tapis mengikut kategori',
    },
    'tier_all': {
      AppLanguage.ar: 'الكل', AppLanguage.en: 'All', AppLanguage.fr: 'Tous', AppLanguage.tr: 'Tümü', AppLanguage.ur: 'تمام',
      AppLanguage.id: 'Semua', AppLanguage.ms: 'Semua',
    },
    'tier_economy': {
      AppLanguage.ar: 'اقتصادي', AppLanguage.en: 'Economy', AppLanguage.fr: 'Économique', AppLanguage.tr: 'Ekonomik', AppLanguage.ur: 'اکانومی',
      AppLanguage.id: 'Ekonomi', AppLanguage.ms: 'Ekonomi',
    },
    'tier_premium': {
      AppLanguage.ar: 'مميز', AppLanguage.en: 'Premium', AppLanguage.fr: 'Premium', AppLanguage.tr: 'Premium', AppLanguage.ur: 'پریمیم',
      AppLanguage.id: 'Premium', AppLanguage.ms: 'Premium',
    },
    'tier_vip': {
      AppLanguage.ar: 'VIP', AppLanguage.en: 'VIP', AppLanguage.fr: 'VIP', AppLanguage.tr: 'VIP', AppLanguage.ur: 'وی آئی پی',
      AppLanguage.id: 'VIP', AppLanguage.ms: 'VIP',
    },
    'status_active': {
      AppLanguage.ar: 'نشط', AppLanguage.en: 'Active', AppLanguage.fr: 'Actif', AppLanguage.tr: 'Aktif', AppLanguage.ur: 'فعال',
      AppLanguage.id: 'Aktif', AppLanguage.ms: 'Aktif',
    },
    'status_inactive': {
      AppLanguage.ar: 'غير نشط', AppLanguage.en: 'Inactive', AppLanguage.fr: 'Inactif', AppLanguage.tr: 'Pasif', AppLanguage.ur: 'غیر فعال',
      AppLanguage.id: 'Tidak aktif', AppLanguage.ms: 'Tidak aktif',
    },
    'no_data_yet': {
      AppLanguage.ar: 'لا توجد بيانات حتى الآن', AppLanguage.en: 'No data yet', AppLanguage.fr: 'Aucune donnée pour le moment', AppLanguage.tr: 'Henüz veri yok', AppLanguage.ur: 'ابھی تک کوئی ڈیٹا نہیں',
      AppLanguage.id: 'Belum ada data', AppLanguage.ms: 'Belum ada data',
    },
    'reports_section_revenue': {
      AppLanguage.ar: 'الإيرادات', AppLanguage.en: 'Revenue', AppLanguage.fr: 'Revenus', AppLanguage.tr: 'Gelir', AppLanguage.ur: 'آمدنی',
      AppLanguage.id: 'Pendapatan', AppLanguage.ms: 'Pendapatan',
    },
    'reports_section_trips': {
      AppLanguage.ar: 'الرحلات', AppLanguage.en: 'Trips', AppLanguage.fr: 'Voyages', AppLanguage.tr: 'Geziler', AppLanguage.ur: 'سفر',
      AppLanguage.id: 'Perjalanan', AppLanguage.ms: 'Perjalanan',
    },
    'reports_section_customers': {
      AppLanguage.ar: 'العملاء', AppLanguage.en: 'Customers', AppLanguage.fr: 'Clients', AppLanguage.tr: 'Müşteriler', AppLanguage.ur: 'گاہک',
      AppLanguage.id: 'Pelanggan', AppLanguage.ms: 'Pelanggan',
    },
    'reports_section_supervisors': {
      AppLanguage.ar: 'المشرفون', AppLanguage.en: 'Supervisors', AppLanguage.fr: 'Superviseurs', AppLanguage.tr: 'Denetçiler', AppLanguage.ur: 'نگران',
      AppLanguage.id: 'Supervisor', AppLanguage.ms: 'Penyelia',
    },
    'reports_section_occupancy': {
      AppLanguage.ar: 'الإشغال', AppLanguage.en: 'Occupancy', AppLanguage.fr: 'Occupation', AppLanguage.tr: 'Doluluk', AppLanguage.ur: 'قبضہ',
      AppLanguage.id: 'Okupansi', AppLanguage.ms: 'Kadar Penghunian',
    },
    'stat_pending_revenue': {
      AppLanguage.ar: 'قيد التحصيل', AppLanguage.en: 'Pending Revenue', AppLanguage.fr: 'Revenus en attente', AppLanguage.tr: 'Bekleyen Gelir', AppLanguage.ur: 'زیر التواء آمدنی',
      AppLanguage.id: 'Pendapatan Tertunda', AppLanguage.ms: 'Pendapatan Belum Selesai',
    },
    'stat_confirmed_bookings': {
      AppLanguage.ar: 'حجوزات مؤكدة', AppLanguage.en: 'Confirmed Bookings', AppLanguage.fr: 'Réservations confirmées', AppLanguage.tr: 'Onaylanan Rezervasyonlar', AppLanguage.ur: 'تصدیق شدہ بکنگ',
      AppLanguage.id: 'Pemesanan Terkonfirmasi', AppLanguage.ms: 'Tempahan Disahkan',
    },
    'stat_avg_booking': {
      AppLanguage.ar: 'متوسط قيمة الحجز', AppLanguage.en: 'Avg. Booking Value', AppLanguage.fr: 'Valeur moy. de réservation', AppLanguage.tr: 'Ort. Rezervasyon Değeri', AppLanguage.ur: 'اوسط بکنگ ویلیو',
      AppLanguage.id: 'Rata-rata Nilai Pemesanan', AppLanguage.ms: 'Purata Nilai Tempahan',
    },
    'stat_total_trips': {
      AppLanguage.ar: 'إجمالي الرحلات', AppLanguage.en: 'Total Trips', AppLanguage.fr: 'Total des voyages', AppLanguage.tr: 'Toplam Gezi', AppLanguage.ur: 'کل سفر',
      AppLanguage.id: 'Total Perjalanan', AppLanguage.ms: 'Jumlah Perjalanan',
    },
    'stat_active_trips': {
      AppLanguage.ar: 'رحلات نشطة', AppLanguage.en: 'Active Trips', AppLanguage.fr: 'Voyages actifs', AppLanguage.tr: 'Aktif Geziler', AppLanguage.ur: 'فعال سفر',
      AppLanguage.id: 'Perjalanan Aktif', AppLanguage.ms: 'Perjalanan Aktif',
    },
    'stat_total_customers': {
      AppLanguage.ar: 'إجمالي العملاء', AppLanguage.en: 'Total Customers', AppLanguage.fr: 'Total des clients', AppLanguage.tr: 'Toplam Müşteri', AppLanguage.ur: 'کل گاہک',
      AppLanguage.id: 'Total Pelanggan', AppLanguage.ms: 'Jumlah Pelanggan',
    },
    'stat_total_spent': {
      AppLanguage.ar: 'إجمالي الإنفاق', AppLanguage.en: 'Total Spent', AppLanguage.fr: 'Total dépensé', AppLanguage.tr: 'Toplam Harcama', AppLanguage.ur: 'کل خرچ',
      AppLanguage.id: 'Total Pengeluaran', AppLanguage.ms: 'Jumlah Perbelanjaan',
    },
    'stat_returning_customers': {
      AppLanguage.ar: 'عملاء متكررون', AppLanguage.en: 'Returning Customers', AppLanguage.fr: 'Clients fidèles', AppLanguage.tr: 'Tekrar Eden Müşteriler', AppLanguage.ur: 'واپس آنے والے گاہک',
      AppLanguage.id: 'Pelanggan Berulang', AppLanguage.ms: 'Pelanggan Berulang',
    },
    'unit_trip_count': {
      AppLanguage.ar: 'رحلة', AppLanguage.en: 'trips', AppLanguage.fr: 'voyages', AppLanguage.tr: 'gezi', AppLanguage.ur: 'سفر',
      AppLanguage.id: 'perjalanan', AppLanguage.ms: 'perjalanan',
    },
    'unit_traveler': {
      AppLanguage.ar: 'مسافر', AppLanguage.en: 'travelers', AppLanguage.fr: 'voyageurs', AppLanguage.tr: 'yolcu', AppLanguage.ur: 'مسافر',
      AppLanguage.id: 'wisatawan', AppLanguage.ms: 'pelancong',
    },
    'status_draft': {
      AppLanguage.ar: 'مسودة', AppLanguage.en: 'Draft', AppLanguage.fr: 'Brouillon', AppLanguage.tr: 'Taslak', AppLanguage.ur: 'ڈرافٹ',
      AppLanguage.id: 'Draf', AppLanguage.ms: 'Draf',
    },
    'action_assign_hotel': {
      AppLanguage.ar: 'تعيين الفندق', AppLanguage.en: 'Assign hotel', AppLanguage.fr: 'Assigner un hôtel',
      AppLanguage.tr: 'Otel ata', AppLanguage.ur: 'ہوٹل مقرر کریں',
      AppLanguage.id: 'Tetapkan hotel', AppLanguage.ms: 'Tetapkan hotel',
    },
    'action_assign_buses': {
      AppLanguage.ar: 'تعيين الباصات', AppLanguage.en: 'Assign buses', AppLanguage.fr: 'Assigner des bus',
      AppLanguage.tr: 'Otobüs ata', AppLanguage.ur: 'بسیں مقرر کریں',
      AppLanguage.id: 'Tetapkan bus', AppLanguage.ms: 'Tetapkan bas',
    },
    'action_assign_supervisors': {
      AppLanguage.ar: 'تعيين المشرفين', AppLanguage.en: 'Assign supervisors', AppLanguage.fr: 'Assigner des superviseurs',
      AppLanguage.tr: 'Süpervizör ata', AppLanguage.ur: 'سپروائزرز مقرر کریں',
      AppLanguage.id: 'Tetapkan supervisor', AppLanguage.ms: 'Tetapkan penyelia',
    },
    'action_add_traveler': {
      AppLanguage.ar: 'إضافة معتمر', AppLanguage.en: 'Add pilgrim', AppLanguage.fr: 'Ajouter un pèlerin',
      AppLanguage.tr: 'Hacı/umreci ekle', AppLanguage.ur: 'زائر شامل کریں',
      AppLanguage.id: 'Tambah jemaah', AppLanguage.ms: 'Tambah jemaah',
    },

    // ===== تفاصيل البرنامج =====
    'detail_overview_subtitle': {
      AppLanguage.ar: 'نظرة عامة على البرنامج', AppLanguage.en: 'Program overview', AppLanguage.fr: 'Aperçu du programme',
      AppLanguage.tr: 'Program genel bakışı', AppLanguage.ur: 'پروگرام کا جائزہ',
      AppLanguage.id: 'Ikhtisar program', AppLanguage.ms: 'Gambaran keseluruhan program',
    },
    'fact_destination': {
      AppLanguage.ar: 'الوجهة', AppLanguage.en: 'Destination', AppLanguage.fr: 'Destination', AppLanguage.tr: 'Varış yeri', AppLanguage.ur: 'منزل',
      AppLanguage.id: 'Tujuan', AppLanguage.ms: 'Destinasi',
    },
    'fact_duration': {
      AppLanguage.ar: 'المدة', AppLanguage.en: 'Duration', AppLanguage.fr: 'Durée', AppLanguage.tr: 'Süre', AppLanguage.ur: 'دورانیہ',
      AppLanguage.id: 'Durasi', AppLanguage.ms: 'Tempoh',
    },
    'fact_price_per_person': {
      AppLanguage.ar: 'السعر للفرد', AppLanguage.en: 'Price per person', AppLanguage.fr: 'Prix par personne',
      AppLanguage.tr: 'Kişi başı fiyat', AppLanguage.ur: 'فی کس قیمت',
      AppLanguage.id: 'Harga per orang', AppLanguage.ms: 'Harga seorang',
    },
    'fact_seats': {
      AppLanguage.ar: 'المقاعد', AppLanguage.en: 'Seats', AppLanguage.fr: 'Places', AppLanguage.tr: 'Koltuklar', AppLanguage.ur: 'نشستیں',
      AppLanguage.id: 'Kursi', AppLanguage.ms: 'Tempat duduk',
    },
    'fact_hotel_mecca': {
      AppLanguage.ar: 'فندق مكة', AppLanguage.en: 'Mecca hotel', AppLanguage.fr: 'Hôtel de La Mecque',
      AppLanguage.tr: 'Mekke oteli', AppLanguage.ur: 'مکہ ہوٹل',
      AppLanguage.id: 'Hotel Mekkah', AppLanguage.ms: 'Hotel Mekah',
    },
    'fact_hotel_medina': {
      AppLanguage.ar: 'فندق المدينة', AppLanguage.en: 'Medina hotel', AppLanguage.fr: 'Hôtel de Médine',
      AppLanguage.tr: 'Medine oteli', AppLanguage.ur: 'مدینہ ہوٹل',
      AppLanguage.id: 'Hotel Madinah', AppLanguage.ms: 'Hotel Madinah',
    },
    'detail_travelers_section': {
      AppLanguage.ar: 'المعتمرون — تسكين الباص', AppLanguage.en: 'Pilgrims — bus assignment',
      AppLanguage.fr: 'Pèlerins — affectation au bus', AppLanguage.tr: 'Hacılar/Umreciler — otobüs ataması',
      AppLanguage.ur: 'زائرین — بس تفویض',
      AppLanguage.id: 'Jemaah — penetapan bus', AppLanguage.ms: 'Jemaah — penetapan bas',
    },
    'detail_travelers_note': {
      AppLanguage.ar: 'قائمة المعتمرين وربطهم بالباص تُدار الآن من شاشة "تعيين الباصات" الخاصة بكل رحلة.',
      AppLanguage.en: 'The pilgrim list and bus assignment are now managed from each trip\'s "Assign buses" screen.',
      AppLanguage.fr: 'La liste des pèlerins et leur affectation au bus sont désormais gérées depuis l\'écran « Assigner des bus » de chaque voyage.',
      AppLanguage.tr: 'Hacı/umreci listesi ve otobüs ataması artık her seyahatin "Otobüs ata" ekranından yönetiliyor.',
      AppLanguage.ur: 'زائرین کی فہرست اور بس تفویض اب ہر سفر کی "بسیں مقرر کریں" اسکرین سے منظم کی جاتی ہے۔',
      AppLanguage.id: 'Daftar jemaah dan penetapan bus kini dikelola dari layar "Tetapkan bus" masing-masing perjalanan.', AppLanguage.ms: 'Senarai jemaah dan penetapan bas kini diuruskan daripada skrin "Tetapkan bas" bagi setiap perjalanan.',
    },
    'action_stop_trip': {
      AppLanguage.ar: 'إيقاف الرحلة', AppLanguage.en: 'Stop trip', AppLanguage.fr: 'Arrêter le voyage',
      AppLanguage.tr: 'Seyahati durdur', AppLanguage.ur: 'سفر روکیں',
      AppLanguage.id: 'Hentikan perjalanan', AppLanguage.ms: 'Hentikan perjalanan',
    },
    'action_continue_trip': {
      AppLanguage.ar: 'مواصلة الرحلة', AppLanguage.en: 'Resume trip', AppLanguage.fr: 'Reprendre le voyage',
      AppLanguage.tr: 'Seyahate devam et', AppLanguage.ur: 'سفر جاری رکھیں',
      AppLanguage.id: 'Lanjutkan perjalanan', AppLanguage.ms: 'Sambung perjalanan',
    },
    'action_edit_trip': {
      AppLanguage.ar: 'تعديل الرحلة', AppLanguage.en: 'Edit trip', AppLanguage.fr: 'Modifier le voyage',
      AppLanguage.tr: 'Seyahati düzenle', AppLanguage.ur: 'سفر میں ترمیم کریں',
      AppLanguage.id: 'Ubah perjalanan', AppLanguage.ms: 'Edit perjalanan',
    },
    'action_delete_trip': {
      AppLanguage.ar: 'حذف الرحلة', AppLanguage.en: 'Delete trip', AppLanguage.fr: 'Supprimer le voyage',
      AppLanguage.tr: 'Seyahati sil', AppLanguage.ur: 'سفر حذف کریں',
      AppLanguage.id: 'Hapus perjalanan', AppLanguage.ms: 'Padam perjalanan',
    },
    'action_edit_dates': {
      AppLanguage.ar: 'تعديل التواريخ', AppLanguage.en: 'Edit dates', AppLanguage.fr: 'Modifier les dates',
      AppLanguage.tr: 'Tarihleri düzenle', AppLanguage.ur: 'تاریخیں ترمیم کریں',
      AppLanguage.id: 'Ubah tanggal', AppLanguage.ms: 'Edit tarikh',
    },
    'status_stopped': {
      AppLanguage.ar: 'متوقفة', AppLanguage.en: 'Stopped', AppLanguage.fr: 'Arrêté',
      AppLanguage.tr: 'Durduruldu', AppLanguage.ur: 'رکا ہوا',
      AppLanguage.id: 'Dihentikan', AppLanguage.ms: 'Dihentikan',
    },
    'confirm_delete_trip_title': {
      AppLanguage.ar: 'حذف الرحلة', AppLanguage.en: 'Delete trip', AppLanguage.fr: 'Supprimer le voyage',
      AppLanguage.tr: 'Seyahati sil', AppLanguage.ur: 'سفر حذف کریں',
      AppLanguage.id: 'Hapus perjalanan', AppLanguage.ms: 'Padam perjalanan',
    },
    'confirm_delete_trip_message': {
      AppLanguage.ar: 'هل أنت متأكد من حذف هذه الرحلة؟ لا يمكن التراجع عن هذا الإجراء.',
      AppLanguage.en: 'Are you sure you want to delete this trip? This action cannot be undone.',
      AppLanguage.fr: 'Voulez-vous vraiment supprimer ce voyage ? Cette action est irréversible.',
      AppLanguage.tr: 'Bu seyahati silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
      AppLanguage.ur: 'کیا آپ واقعی یہ سفر حذف کرنا چاہتے ہیں؟ یہ عمل واپس نہیں ہو سکتا۔',
      AppLanguage.id: 'Apakah Anda yakin ingin menghapus perjalanan ini? Tindakan ini tidak dapat dibatalkan.', AppLanguage.ms: 'Adakah anda pasti mahu memadam perjalanan ini? Tindakan ini tidak boleh dibatalkan.',
    },
    'action_cancel': {
      AppLanguage.ar: 'إلغاء', AppLanguage.en: 'Cancel', AppLanguage.fr: 'Annuler', AppLanguage.tr: 'İptal', AppLanguage.ur: 'منسوخ کریں',
      AppLanguage.id: 'Batal', AppLanguage.ms: 'Batal',
    },
    'tab_employees': {AppLanguage.ar: 'الموظفون', AppLanguage.en: 'Employees'},
    'tab_roles': {AppLanguage.ar: 'الأدوار والصلاحيات', AppLanguage.en: 'Roles & permissions'},
    'field_password': {AppLanguage.ar: 'كلمة المرور', AppLanguage.en: 'Password'},
    'field_role': {AppLanguage.ar: 'الدور الوظيفي', AppLanguage.en: 'Role'},
    'action_save': {AppLanguage.ar: 'حفظ', AppLanguage.en: 'Save'},
    'action_delete': {AppLanguage.ar: 'حذف', AppLanguage.en: 'Delete'},
    'add_role_title': {AppLanguage.ar: 'إضافة دور جديد', AppLanguage.en: 'Add new role'},
    'edit_role_title': {AppLanguage.ar: 'تعديل الدور', AppLanguage.en: 'Edit role'},
    'edit_employee_title': {AppLanguage.ar: 'تعديل بيانات الموظف', AppLanguage.en: 'Edit employee'},
    'field_role_name': {AppLanguage.ar: 'اسم الدور', AppLanguage.en: 'Role name'},
    'permissions_label': {AppLanguage.ar: 'الصلاحيات', AppLanguage.en: 'Permissions'},
    'confirm_delete_role_title': {AppLanguage.ar: 'حذف الدور', AppLanguage.en: 'Delete role'},
    'confirm_delete_role_message': {
      AppLanguage.ar: 'هل أنت متأكد من حذف هذا الدور؟ لا يمكن التراجع عن هذا الإجراء.',
      AppLanguage.en: 'Are you sure you want to delete this role? This action cannot be undone.',
    },
    'no_employees_yet': {AppLanguage.ar: 'لا يوجد موظفون بعد', AppLanguage.en: 'No employees yet'},
    'no_roles_yet': {AppLanguage.ar: 'لا توجد أدوار بعد', AppLanguage.en: 'No roles yet'},
    'no_buses_yet': {AppLanguage.ar: 'لا توجد باصات مضافة بعد', AppLanguage.en: 'No buses added yet'},
    'no_hotel_assigned': {AppLanguage.ar: 'لم يُسكَّن فندق بعد', AppLanguage.en: 'No hotel assigned yet'},
    'no_trips_yet': {AppLanguage.ar: 'لا توجد رحلات بعد', AppLanguage.en: 'No trips yet'},
    'no_hotels_yet': {AppLanguage.ar: 'لا توجد فنادق مضافة بعد', AppLanguage.en: 'No hotels added yet'},
    'no_customers_yet': {AppLanguage.ar: 'لا يوجد معتمرون بعد', AppLanguage.en: 'No customers yet'},
    'field_bus_company': {AppLanguage.ar: 'شركة الأتوبيسات', AppLanguage.en: 'Bus company'},
    'add_bus_company_title': {AppLanguage.ar: 'إضافة شركة أتوبيسات', AppLanguage.en: 'Add bus company'},
    'add_bus_title': {AppLanguage.ar: 'إضافة باص', AppLanguage.en: 'Add bus'},
    'field_status': {AppLanguage.ar: 'الحالة', AppLanguage.en: 'Status'},
    'login_with_phone': {AppLanguage.ar: 'رقم الجوال', AppLanguage.en: 'Phone number'},
    'login_with_email': {AppLanguage.ar: 'البريد الإلكتروني', AppLanguage.en: 'Email'},
    'action_assign_room': {AppLanguage.ar: 'تسكين الغرفة', AppLanguage.en: 'Assign room'},
    'assign_hotel_first_hint': {AppLanguage.ar: 'سكّن الفندق أولًا قبل تسكين الغرفة', AppLanguage.en: 'Assign a hotel first before assigning a room'},
    'action_add_new_hotel': {AppLanguage.ar: 'إضافة فندق جديد', AppLanguage.en: 'Add new hotel'},
    'new_bus_company_option': {AppLanguage.ar: '+ شركة نقل جديدة', AppLanguage.en: '+ New bus company'},
    'action_attendance': {AppLanguage.ar: 'تحضير', AppLanguage.en: 'Attendance'},
    'action_departure_point': {AppLanguage.ar: 'نقطة الانطلاق', AppLanguage.en: 'Departure point'},
    'departure_point_hint': {AppLanguage.ar: 'حدد نقطة تجمّع المعتمرين على الخريطة، أو اكتب العنوان نصيًا — أو الاثنين معًا.', AppLanguage.en: 'Pick the pilgrims\' meeting point on the map, or type the address — or both.'},
    'field_departure_address': {AppLanguage.ar: 'العنوان (نصيًا)', AppLanguage.en: 'Address (text)'},
    'field_room_number_optional': {AppLanguage.ar: 'رقم الغرفة (اختياري)', AppLanguage.en: 'Room number (optional)'},
    'room_pending_number': {AppLanguage.ar: 'بانتظار تحديد رقم الغرفة', AppLanguage.en: 'Room number not set yet'},
    'selected_count_prefix': {AppLanguage.ar: 'المختارون:', AppLanguage.en: 'Selected:'},
    'action_continue': {AppLanguage.ar: 'متابعة', AppLanguage.en: 'Continue'},
    'wizard_step_hotel': {AppLanguage.ar: 'الفندق والغرف', AppLanguage.en: 'Hotel & rooms'},
    'wizard_step_services': {AppLanguage.ar: 'الخدمات والزيارات', AppLanguage.en: 'Services & visits'},
    'wizard_step_images': {AppLanguage.ar: 'الصور', AppLanguage.en: 'Images'},
    'trip_category_umrah': {AppLanguage.ar: 'عمرة', AppLanguage.en: 'Umrah'},
    'trip_category_hajj': {AppLanguage.ar: 'حج', AppLanguage.en: 'Hajj'},
    'trip_category_combined': {AppLanguage.ar: 'مجمّع', AppLanguage.en: 'Combined'},
    'wizard_rooms_label': {AppLanguage.ar: 'توزيع الغرف', AppLanguage.en: 'Room distribution'},
    'wizard_room_single': {AppLanguage.ar: 'غرف مفردة', AppLanguage.en: 'Single rooms'},
    'wizard_room_double': {AppLanguage.ar: 'غرف مزدوجة', AppLanguage.en: 'Double rooms'},
    'wizard_room_triple': {AppLanguage.ar: 'غرف ثلاثية', AppLanguage.en: 'Triple rooms'},
    'wizard_room_quad': {AppLanguage.ar: 'غرف رباعية', AppLanguage.en: 'Quad rooms'},
    'wizard_has_guide': {AppLanguage.ar: 'يوجد مرشد ديني', AppLanguage.en: 'Includes religious guide'},
    'wizard_has_visits': {AppLanguage.ar: 'يوجد زيارات ومزارات', AppLanguage.en: 'Includes visits'},
    'wizard_excluded_services': {AppLanguage.ar: 'الخدمات غير المشمولة', AppLanguage.en: 'Excluded services'},
    'wizard_ziyarat': {AppLanguage.ar: 'الزيارات والمزارات', AppLanguage.en: 'Visits & landmarks'},
    'wizard_add_tag_hint': {AppLanguage.ar: 'اكتب واضغط إضافة', AppLanguage.en: 'Type and press add'},
    'wizard_departure_location': {AppLanguage.ar: 'موقع/عنوان الانطلاق التفصيلي (اختياري)', AppLanguage.en: 'Detailed departure location/address (optional)'},
    'profile_change_password': {AppLanguage.ar: 'تغيير كلمة المرور', AppLanguage.en: 'Change password'},
    'field_current_password': {AppLanguage.ar: 'كلمة المرور الحالية', AppLanguage.en: 'Current password'},
    'field_new_password': {AppLanguage.ar: 'كلمة المرور الجديدة', AppLanguage.en: 'New password'},
    'field_confirm_password': {AppLanguage.ar: 'تأكيد كلمة المرور', AppLanguage.en: 'Confirm password'},
    'password_changed_snackbar': {AppLanguage.ar: 'تم تغيير كلمة المرور بنجاح', AppLanguage.en: 'Password changed successfully'},
    'profile_bank_info': {AppLanguage.ar: 'الحساب البنكي', AppLanguage.en: 'Bank account'},
    'field_bank_name': {AppLanguage.ar: 'اسم البنك', AppLanguage.en: 'Bank name'},
    'field_bank_account_holder': {AppLanguage.ar: 'اسم صاحب الحساب', AppLanguage.en: 'Account holder name'},
    'field_bank_account_number': {AppLanguage.ar: 'رقم الحساب', AppLanguage.en: 'Account number'},
    'field_bank_iban': {AppLanguage.ar: 'رقم الآيبان (IBAN)', AppLanguage.en: 'IBAN'},
    'bank_info_saved_snackbar': {AppLanguage.ar: 'تم حفظ بيانات الحساب البنكي', AppLanguage.en: 'Bank account info saved'},

    'iban_invalid': {AppLanguage.ar: 'رقم الآيبان غير صحيح — تأكد منه (مثال: SA + 22 رقم)', AppLanguage.en: 'Invalid IBAN — please check it (e.g. SA + 22 digits)'},
    'iban_required_title': {AppLanguage.ar: 'أدخل رقم الآيبان', AppLanguage.en: 'Enter your IBAN'},
    'iban_required_body': {AppLanguage.ar: 'لا بد من إدخال رقم الآيبان (IBAN) لحساب شركتك البنكي حتى نتمكن من تحويل مستحقاتك من الحجوزات.', AppLanguage.en: 'You must add your company bank IBAN so we can transfer your booking earnings.'},
    'iban_invalid_body': {AppLanguage.ar: 'رقم الآيبان المسجل لشركتك غير صحيح. لا بد من تصحيحه حتى نتمكن من تحويل مستحقاتك.', AppLanguage.en: 'Your saved IBAN is invalid. Please correct it so we can transfer your earnings.'},
    'iban_required_action': {AppLanguage.ar: 'إدخال الآيبان', AppLanguage.en: 'Enter IBAN'},

    'profile_my_account': {AppLanguage.ar: 'بيانات حسابي', AppLanguage.en: 'My account'},
    'account_field_name': {AppLanguage.ar: 'الاسم', AppLanguage.en: 'Name'},
    'account_fill_required': {AppLanguage.ar: 'الاسم والبريد الإلكتروني مطلوبان', AppLanguage.en: 'Name and email are required'},
    'account_saved_snackbar': {AppLanguage.ar: 'تم حفظ بيانات الحساب', AppLanguage.en: 'Account details saved'},

    // ===== الرصيد والتذاكر =====
    'profile_wallet': {AppLanguage.ar: 'الرصيد', AppLanguage.en: 'Balance'},
    'wallet_balance': {AppLanguage.ar: 'الرصيد المستحق لك', AppLanguage.en: 'Balance due to you'},
    'wallet_in': {AppLanguage.ar: 'الداخل', AppLanguage.en: 'Incoming'},
    'wallet_out': {AppLanguage.ar: 'الخارج', AppLanguage.en: 'Outgoing'},
    'wallet_paid_out': {AppLanguage.ar: 'تم تحويله لك', AppLanguage.en: 'Transferred to you'},
    'wallet_refunded': {AppLanguage.ar: 'مسترد', AppLanguage.en: 'Refunded'},
    'wallet_commission': {AppLanguage.ar: 'عمولة المنصة', AppLanguage.en: 'Platform commission'},
    'wallet_sales': {AppLanguage.ar: 'إجمالي المبيعات', AppLanguage.en: 'Total sales'},
    'wallet_pending_count': {AppLanguage.ar: 'حجوزات بانتظار التحويل', AppLanguage.en: 'Bookings awaiting transfer'},
    'wallet_last_payout': {AppLanguage.ar: 'آخر تحويل', AppLanguage.en: 'Last transfer'},
    'wallet_statement': {AppLanguage.ar: 'كشف الحركات', AppLanguage.en: 'Statement'},
    'wallet_no_entries': {AppLanguage.ar: 'لا توجد حركات بعد', AppLanguage.en: 'No transactions yet'},
    'wallet_filter_all': {AppLanguage.ar: 'الكل', AppLanguage.en: 'All'},
    'wallet_balance_after': {AppLanguage.ar: 'الرصيد بعدها', AppLanguage.en: 'Balance after'},
    'wallet_overdue': {AppLanguage.ar: 'تأخر تحويل مستحقاتك أكثر من {d} أيام؟ افتح تذكرة وسنتابعها فوراً.', AppLanguage.en: 'Transfer late by more than {d} days? Open a ticket and we will follow up.'},
    'wallet_no_bank': {AppLanguage.ar: 'أضف بيانات حسابك البنكي (IBAN) حتى نتمكن من تحويل مستحقاتك.', AppLanguage.en: 'Add your bank account (IBAN) so we can transfer your earnings.'},
    'wallet_bank_to': {AppLanguage.ar: 'التحويل إلى', AppLanguage.en: 'Transfers to'},
    'wallet_status_pending': {AppLanguage.ar: 'بانتظار التحويل', AppLanguage.en: 'Awaiting transfer'},
    'wallet_status_paid_out': {AppLanguage.ar: 'محوّل', AppLanguage.en: 'Transferred'},
    'wallet_status_refunded': {AppLanguage.ar: 'مسترد', AppLanguage.en: 'Refunded'},
    'wallet_status_processing': {AppLanguage.ar: 'قيد التنفيذ', AppLanguage.en: 'Processing'},
    'wallet_load_more': {AppLanguage.ar: 'عرض المزيد', AppLanguage.en: 'Load more'},
    'tickets_title': {AppLanguage.ar: 'تذاكر الدعم', AppLanguage.en: 'Support tickets'},
    'tickets_open_new': {AppLanguage.ar: 'فتح تذكرة', AppLanguage.en: 'Open a ticket'},
    'tickets_empty': {AppLanguage.ar: 'لا توجد تذاكر', AppLanguage.en: 'No tickets'},
    'ticket_subject': {AppLanguage.ar: 'الموضوع', AppLanguage.en: 'Subject'},
    'ticket_category': {AppLanguage.ar: 'نوع المشكلة', AppLanguage.en: 'Issue type'},
    'ticket_reference': {AppLanguage.ar: 'رقم الحجز أو مرجع التحويل (اختياري)', AppLanguage.en: 'Booking no. or transfer reference (optional)'},
    'ticket_body': {AppLanguage.ar: 'اشرح المشكلة', AppLanguage.en: 'Describe the issue'},
    'ticket_send': {AppLanguage.ar: 'إرسال', AppLanguage.en: 'Send'},
    'ticket_reply_hint': {AppLanguage.ar: 'اكتب رداً...', AppLanguage.en: 'Write a reply...'},
    'ticket_close': {AppLanguage.ar: 'إغلاق التذكرة', AppLanguage.en: 'Close ticket'},
    'ticket_closed_note': {AppLanguage.ar: 'التذكرة مغلقة — أي رد جديد يعيد فتحها.', AppLanguage.en: 'Ticket closed — a new reply reopens it.'},
    'ticket_default_subject': {AppLanguage.ar: 'تأخر تحويل المستحقات', AppLanguage.en: 'Late transfer of earnings'},
    'ticket_fill_required': {AppLanguage.ar: 'اكتب الموضوع وتفاصيل المشكلة', AppLanguage.en: 'Enter a subject and details'},
    'profile_branches': {AppLanguage.ar: 'الفروع', AppLanguage.en: 'Branches'},
    'no_branches_yet': {AppLanguage.ar: 'لا توجد فروع مضافة بعد', AppLanguage.en: 'No branches added yet'},
    'add_branch_title': {AppLanguage.ar: 'إضافة فرع', AppLanguage.en: 'Add branch'},
    'field_branch_name': {AppLanguage.ar: 'اسم الفرع', AppLanguage.en: 'Branch name'},
    'field_branch_manager': {AppLanguage.ar: 'مدير الفرع', AppLanguage.en: 'Branch manager'},
    'profile_sessions': {AppLanguage.ar: 'الأجهزة المسجّلة', AppLanguage.en: 'Logged-in devices'},
    'sessions_subtitle': {AppLanguage.ar: 'كل جهاز/تطبيق سجّل دخول بحسابك', AppLanguage.en: 'Every device/app currently logged into your account'},
    'sessions_current_label': {AppLanguage.ar: 'الجهاز الحالي', AppLanguage.en: 'This device'},
    'sessions_last_used': {AppLanguage.ar: 'آخر استخدام:', AppLanguage.en: 'Last used:'},
    'sessions_created_at': {AppLanguage.ar: 'تاريخ الدخول:', AppLanguage.en: 'Signed in:'},
    'action_revoke_all_sessions': {AppLanguage.ar: 'تسجيل الخروج من كل الأجهزة الأخرى', AppLanguage.en: 'Log out of all other devices'},
    'wizard_departure_location_hint': {
      AppLanguage.ar: 'اختر مدينة الانطلاق، وممكن تضيف تفاصيل أدق زي نقطة تجمع أو عنوان محدد',
      AppLanguage.en: 'Pick the departure city, and optionally add more detail like a meeting point or specific address',
    },
    'no_bookings_yet': {AppLanguage.ar: 'لا توجد حجوزات بعد', AppLanguage.en: 'No bookings yet'},
    'no_supervisors_yet': {AppLanguage.ar: 'لا يوجد موظفون متاحون بعد', AppLanguage.en: 'No employees available yet'},
    'owner_role_badge': {AppLanguage.ar: 'المالك', AppLanguage.en: 'Owner'},
    'password_optional_hint': {AppLanguage.ar: 'اتركه فارغًا لعدم التغيير', AppLanguage.en: 'Leave blank to keep unchanged'},
    'action_add_role': {AppLanguage.ar: 'إضافة دور', AppLanguage.en: 'Add role'},
    'trip_stopped_snackbar': {
      AppLanguage.ar: 'تم إيقاف الرحلة', AppLanguage.en: 'Trip stopped', AppLanguage.fr: 'Voyage arrêté',
      AppLanguage.tr: 'Seyahat durduruldu', AppLanguage.ur: 'سفر روک دیا گیا',
      AppLanguage.id: 'Perjalanan dihentikan', AppLanguage.ms: 'Perjalanan telah dihentikan',
    },
    'trip_resumed_snackbar': {
      AppLanguage.ar: 'تمت مواصلة الرحلة', AppLanguage.en: 'Trip resumed', AppLanguage.fr: 'Voyage repris',
      AppLanguage.tr: 'Seyahate devam edildi', AppLanguage.ur: 'سفر دوبارہ شروع ہو گیا',
      AppLanguage.id: 'Perjalanan dilanjutkan', AppLanguage.ms: 'Perjalanan disambung semula',
    },
    'trip_deleted_snackbar': {
      AppLanguage.ar: 'تم حذف الرحلة', AppLanguage.en: 'Trip deleted', AppLanguage.fr: 'Voyage supprimé',
      AppLanguage.tr: 'Seyahat silindi', AppLanguage.ur: 'سفر حذف ہو گیا',
      AppLanguage.id: 'Perjalanan dihapus', AppLanguage.ms: 'Perjalanan dipadam',
    },
    'trip_date_updated_snackbar': {
      AppLanguage.ar: 'تم تعديل تاريخ الرحلة', AppLanguage.en: 'Trip date updated', AppLanguage.fr: 'Date du voyage mise à jour',
      AppLanguage.tr: 'Seyahat tarihi güncellendi', AppLanguage.ur: 'سفر کی تاریخ اپ ڈیٹ ہو گئی',
      AppLanguage.id: 'Tanggal perjalanan diperbarui', AppLanguage.ms: 'Tarikh perjalanan dikemas kini',
    },
    'fact_trip_date': {
      AppLanguage.ar: 'تاريخ الرحلة', AppLanguage.en: 'Trip date', AppLanguage.fr: 'Date du voyage',
      AppLanguage.tr: 'Seyahat tarihi', AppLanguage.ur: 'سفر کی تاریخ',
      AppLanguage.id: 'Tanggal perjalanan', AppLanguage.ms: 'Tarikh perjalanan',
    },

    // ===== تسكين الباصات =====
    'bus_assign_title': {
      AppLanguage.ar: 'تسكين الباصات', AppLanguage.en: 'Bus assignment', AppLanguage.fr: 'Affectation des bus',
      AppLanguage.tr: 'Otobüs ataması', AppLanguage.ur: 'بس تفویض',
      AppLanguage.id: 'Penetapan bus', AppLanguage.ms: 'Penetapan bas',
    },
    'bus_assign_buses_label': {
      AppLanguage.ar: 'الباصات المخصصة لهذه الرحلة', AppLanguage.en: 'Buses assigned to this trip',
      AppLanguage.fr: 'Bus affectés à ce voyage', AppLanguage.tr: 'Bu seyahate atanan otobüsler',
      AppLanguage.ur: 'اس سفر کے لیے مقرر بسیں',
      AppLanguage.id: 'Bus yang ditetapkan untuk perjalanan ini', AppLanguage.ms: 'Bas yang ditetapkan untuk perjalanan ini',
    },
    'bus_assign_travelers_label': {
      AppLanguage.ar: 'تسكين المعتمرين لكل باص', AppLanguage.en: 'Assign pilgrims to each bus',
      AppLanguage.fr: 'Affecter les pèlerins à chaque bus', AppLanguage.tr: 'Her otobüse hacı/umreci ata',
      AppLanguage.ur: 'ہر بس کے لیے زائرین تفویض کریں',
      AppLanguage.id: 'Tetapkan jemaah ke setiap bus', AppLanguage.ms: 'Tetapkan jemaah ke setiap bas',
    },
    'picker_choose_travelers_prefix': {
      AppLanguage.ar: 'اختر المعتمرين — ', AppLanguage.en: 'Choose pilgrims — ', AppLanguage.fr: 'Choisir les pèlerins — ',
      AppLanguage.tr: 'Hacı/umreci seç — ', AppLanguage.ur: 'زائرین منتخب کریں — ',
      AppLanguage.id: 'Pilih jemaah — ', AppLanguage.ms: 'Pilih jemaah — ',
    },
    'action_choose_travelers': {
      AppLanguage.ar: 'اختيار المعتمرين', AppLanguage.en: 'Choose pilgrims', AppLanguage.fr: 'Choisir les pèlerins',
      AppLanguage.tr: 'Hacı/umreci seç', AppLanguage.ur: 'زائرین منتخب کریں',
      AppLanguage.id: 'Pilih jemaah', AppLanguage.ms: 'Pilih jemaah',
    },

    // ===== تعيين الفندق =====
    'hotel_assign_title': {
      AppLanguage.ar: 'تعيين الفندق', AppLanguage.en: 'Assign hotel', AppLanguage.fr: 'Assigner un hôtel',
      AppLanguage.tr: 'Otel ata', AppLanguage.ur: 'ہوٹل مقرر کریں',
      AppLanguage.id: 'Tetapkan hotel', AppLanguage.ms: 'Tetapkan hotel',
    },
    'hotel_mecca_label': {
      AppLanguage.ar: 'فندق مكة المكرمة', AppLanguage.en: 'Mecca hotel', AppLanguage.fr: 'Hôtel de La Mecque',
      AppLanguage.tr: 'Mekke oteli', AppLanguage.ur: 'مکہ مکرمہ ہوٹل',
      AppLanguage.id: 'Hotel Mekkah', AppLanguage.ms: 'Hotel Mekah',
    },
    'hotel_medina_label': {
      AppLanguage.ar: 'فندق المدينة المنورة', AppLanguage.en: 'Medina hotel', AppLanguage.fr: 'Hôtel de Médine',
      AppLanguage.tr: 'Medine oteli', AppLanguage.ur: 'مدینہ منورہ ہوٹل',
      AppLanguage.id: 'Hotel Madinah', AppLanguage.ms: 'Hotel Madinah',
    },
    'hotel_assign_new_hint': {
      AppLanguage.ar: 'فندق جديد؟ أضفه من "الفنادق والإقامة" في حسابك.',
      AppLanguage.en: 'New hotel? Add it from "Hotels & accommodation" in your account.',
      AppLanguage.fr: 'Nouvel hôtel ? Ajoutez-le depuis « Hôtels et hébergement » dans votre compte.',
      AppLanguage.tr: 'Yeni otel mi? Hesabınızdaki "Oteller ve konaklama"dan ekleyin.',
      AppLanguage.ur: 'نیا ہوٹل؟ اسے اپنے اکاؤنٹ میں "ہوٹلز اور رہائش" سے شامل کریں۔',
      AppLanguage.id: 'Hotel baru? Tambahkan dari "Hotel & akomodasi" di akun Anda.', AppLanguage.ms: 'Hotel baharu? Tambah dari "Hotel & penginapan" dalam akaun anda.',
    },

    // ===== تعيين المشرفين =====
    'supervisor_assign_title': {
      AppLanguage.ar: 'تعيين المشرفين', AppLanguage.en: 'Assign supervisors', AppLanguage.fr: 'Assigner des superviseurs',
      AppLanguage.tr: 'Süpervizör ata', AppLanguage.ur: 'سپروائزرز مقرر کریں',
      AppLanguage.id: 'Tetapkan supervisor', AppLanguage.ms: 'Tetapkan penyelia',
    },
    'supervisor_departure': {
      AppLanguage.ar: 'مشرف الانطلاق', AppLanguage.en: 'Departure supervisor', AppLanguage.fr: 'Superviseur de départ',
      AppLanguage.tr: 'Hareket süpervizörü', AppLanguage.ur: 'روانگی سپروائزر',
      AppLanguage.id: 'Supervisor keberangkatan', AppLanguage.ms: 'Penyelia perlepasan',
    },
    'supervisor_bus': {
      AppLanguage.ar: 'مشرف الباص', AppLanguage.en: 'Bus supervisor', AppLanguage.fr: 'Superviseur de bus',
      AppLanguage.tr: 'Otobüs süpervizörü', AppLanguage.ur: 'بس سپروائزر',
      AppLanguage.id: 'Supervisor bus', AppLanguage.ms: 'Penyelia bas',
    },
    'supervisor_hotel_mecca': {
      AppLanguage.ar: 'مشرف فندق مكة المكرمة', AppLanguage.en: 'Mecca hotel supervisor',
      AppLanguage.fr: 'Superviseur de l\'hôtel de La Mecque', AppLanguage.tr: 'Mekke otel süpervizörü',
      AppLanguage.ur: 'مکہ ہوٹل سپروائزر',
      AppLanguage.id: 'Supervisor hotel Mekkah', AppLanguage.ms: 'Penyelia hotel Mekah',
    },
    'supervisor_hotel_medina': {
      AppLanguage.ar: 'مشرف فندق المدينة المنورة', AppLanguage.en: 'Medina hotel supervisor',
      AppLanguage.fr: 'Superviseur de l\'hôtel de Médine', AppLanguage.tr: 'Medine otel süpervizörü',
      AppLanguage.ur: 'مدینہ ہوٹل سپروائزر',
      AppLanguage.id: 'Supervisor hotel Madinah', AppLanguage.ms: 'Penyelia hotel Madinah',
    },
    'supervisor_none_selected': {
      AppLanguage.ar: 'بدون تحديد', AppLanguage.en: 'Unassigned', AppLanguage.fr: 'Non assigné',
      AppLanguage.tr: 'Atanmadı', AppLanguage.ur: 'غیر متعین',
      AppLanguage.id: 'Belum ditetapkan', AppLanguage.ms: 'Belum ditetapkan',
    },
    'action_save_supervisors': {
      AppLanguage.ar: 'حفظ المشرفين', AppLanguage.en: 'Save supervisors', AppLanguage.fr: 'Enregistrer les superviseurs',
      AppLanguage.tr: 'Süpervizörleri kaydet', AppLanguage.ur: 'سپروائزرز محفوظ کریں',
      AppLanguage.id: 'Simpan supervisor', AppLanguage.ms: 'Simpan penyelia',
    },

    // ===== معالج إنشاء البرنامج =====
    'wizard_title': {
      AppLanguage.ar: 'إنشاء برنامج عمرة جديد', AppLanguage.en: 'Create a new Umrah program',
      AppLanguage.fr: 'Créer un nouveau programme de Omra', AppLanguage.tr: 'Yeni Umre programı oluştur',
      AppLanguage.ur: 'نیا عمرہ پروگرام بنائیں',
      AppLanguage.id: 'Buat program umrah baru', AppLanguage.ms: 'Cipta program umrah baharu',
    },
    'wizard_step_word': {
      AppLanguage.ar: 'الخطوة', AppLanguage.en: 'Step', AppLanguage.fr: 'Étape', AppLanguage.tr: 'Adım', AppLanguage.ur: 'مرحلہ',
      AppLanguage.id: 'Langkah', AppLanguage.ms: 'Langkah',
    },
    'wizard_of_word': {
      AppLanguage.ar: 'من', AppLanguage.en: 'of', AppLanguage.fr: 'sur', AppLanguage.tr: '/', AppLanguage.ur: 'از',
      AppLanguage.id: 'dari', AppLanguage.ms: 'daripada',
    },
    'wizard_publish': {
      AppLanguage.ar: 'نشر البرنامج', AppLanguage.en: 'Publish program', AppLanguage.fr: 'Publier le programme',
      AppLanguage.tr: 'Programı yayınla', AppLanguage.ur: 'پروگرام شائع کریں',
      AppLanguage.id: 'Terbitkan program', AppLanguage.ms: 'Terbitkan program',
    },
    'wizard_next': {
      AppLanguage.ar: 'التالي', AppLanguage.en: 'Next', AppLanguage.fr: 'Suivant', AppLanguage.tr: 'İleri', AppLanguage.ur: 'اگلا',
      AppLanguage.id: 'Berikutnya', AppLanguage.ms: 'Seterusnya',
    },
    'wizard_published_snackbar': {
      AppLanguage.ar: 'تم نشر البرنامج بنجاح', AppLanguage.en: 'Program published successfully',
      AppLanguage.fr: 'Programme publié avec succès', AppLanguage.tr: 'Program başarıyla yayınlandı',
      AppLanguage.ur: 'پروگرام کامیابی سے شائع ہو گیا',
      AppLanguage.id: 'Program berhasil diterbitkan', AppLanguage.ms: 'Program berjaya diterbitkan',
    },
    'wizard_updated_snackbar': {AppLanguage.ar: 'تم حفظ التعديلات بنجاح', AppLanguage.en: 'Changes saved successfully'},
    'wizard_edit_title': {AppLanguage.ar: 'تعديل برنامج العمرة', AppLanguage.en: 'Edit Umrah program'},
    'step1_title': {
      AppLanguage.ar: 'المعلومات الأساسية', AppLanguage.en: 'Basic information', AppLanguage.fr: 'Informations de base',
      AppLanguage.tr: 'Temel bilgiler', AppLanguage.ur: 'بنیادی معلومات',
      AppLanguage.id: 'Informasi dasar', AppLanguage.ms: 'Maklumat asas',
    },
    'step2_title': {
      AppLanguage.ar: 'التسعير والعروض', AppLanguage.en: 'Pricing & offers', AppLanguage.fr: 'Tarification et offres',
      AppLanguage.tr: 'Fiyatlandırma ve teklifler', AppLanguage.ur: 'قیمتیں اور آفرز',
      AppLanguage.id: 'Harga & penawaran', AppLanguage.ms: 'Harga & tawaran',
    },
    'step3_title': {
      AppLanguage.ar: 'البرنامج اليومي', AppLanguage.en: 'Daily program', AppLanguage.fr: 'Programme quotidien',
      AppLanguage.tr: 'Günlük program', AppLanguage.ur: 'روزانہ پروگرام',
      AppLanguage.id: 'Program harian', AppLanguage.ms: 'Program harian',
    },
    'step4_title': {
      AppLanguage.ar: 'الزيارات والخدمات', AppLanguage.en: 'Visits & services', AppLanguage.fr: 'Visites et services',
      AppLanguage.tr: 'Ziyaretler ve hizmetler', AppLanguage.ur: 'زیارات اور خدمات',
      AppLanguage.id: 'Kunjungan & layanan', AppLanguage.ms: 'Lawatan & perkhidmatan',
    },
    'step5_title': {
      AppLanguage.ar: 'المميزات والصور', AppLanguage.en: 'Features & photos', AppLanguage.fr: 'Caractéristiques et photos',
      AppLanguage.tr: 'Özellikler ve fotoğraflar', AppLanguage.ur: 'خصوصیات اور تصاویر',
      AppLanguage.id: 'Fitur & foto', AppLanguage.ms: 'Ciri & foto',
    },
    'field_program_name': {
      AppLanguage.ar: 'اسم البرنامج *', AppLanguage.en: 'Program name *', AppLanguage.fr: 'Nom du programme *',
      AppLanguage.tr: 'Program adı *', AppLanguage.ur: 'پروگرام کا نام *',
      AppLanguage.id: 'Nama program *', AppLanguage.ms: 'Nama program *',
    },
    'field_trip_class': {
      AppLanguage.ar: 'درجة الرحلة *', AppLanguage.en: 'Trip class *', AppLanguage.fr: 'Classe du voyage *',
      AppLanguage.tr: 'Seyahat sınıfı *', AppLanguage.ur: 'سفر کا درجہ *',
      AppLanguage.id: 'Kelas perjalanan *', AppLanguage.ms: 'Kelas perjalanan *',
    },
    'opt_luxury_vip': {
      AppLanguage.ar: 'فاخر VIP', AppLanguage.en: 'Luxury VIP', AppLanguage.fr: 'VIP luxe',
      AppLanguage.tr: 'Lüks VIP', AppLanguage.ur: 'لگژری وی آئی پی',
      AppLanguage.id: 'VIP Mewah', AppLanguage.ms: 'VIP Mewah',
    },
    'field_departure_city': {
      AppLanguage.ar: 'مدينة الانطلاق *', AppLanguage.en: 'Departure city *', AppLanguage.fr: 'Ville de départ *',
      AppLanguage.tr: 'Kalkış şehri *', AppLanguage.ur: 'روانگی کا شہر *',
      AppLanguage.id: 'Kota keberangkatan *', AppLanguage.ms: 'Bandar berlepas *',
    },
    'city_cairo': {
      AppLanguage.ar: 'القاهرة', AppLanguage.en: 'Cairo', AppLanguage.fr: 'Le Caire', AppLanguage.tr: 'Kahire', AppLanguage.ur: 'قاہرہ',
      AppLanguage.id: 'Kairo', AppLanguage.ms: 'Kaherah',
    },
    'city_riyadh': {
      AppLanguage.ar: 'الرياض', AppLanguage.en: 'Riyadh', AppLanguage.fr: 'Riyad', AppLanguage.tr: 'Riyad', AppLanguage.ur: 'ریاض',
      AppLanguage.id: 'Riyadh', AppLanguage.ms: 'Riyadh',
    },
    'city_jeddah': {
      AppLanguage.ar: 'جدة', AppLanguage.en: 'Jeddah', AppLanguage.fr: 'Djeddah', AppLanguage.tr: 'Cidde', AppLanguage.ur: 'جدہ',
      AppLanguage.id: 'Jeddah', AppLanguage.ms: 'Jeddah',
    },
    'schedule_system_label': {
      AppLanguage.ar: 'نظام المواعيد', AppLanguage.en: 'Schedule type', AppLanguage.fr: 'Type de calendrier',
      AppLanguage.tr: 'Program türü', AppLanguage.ur: 'شیڈول کی قسم',
      AppLanguage.id: 'Jenis jadwal', AppLanguage.ms: 'Jenis jadual',
    },
    'schedule_specific_title': {
      AppLanguage.ar: 'مواعيد محددة', AppLanguage.en: 'Specific dates', AppLanguage.fr: 'Dates spécifiques',
      AppLanguage.tr: 'Belirli tarihler', AppLanguage.ur: 'مخصوص تاریخیں',
      AppLanguage.id: 'Tanggal tertentu', AppLanguage.ms: 'Tarikh tertentu',
    },
    'schedule_specific_desc': {
      AppLanguage.ar: 'تواريخ ثابتة تحددها مسبقاً', AppLanguage.en: 'Fixed dates you set in advance',
      AppLanguage.fr: 'Dates fixes que vous définissez à l\'avance', AppLanguage.tr: 'Önceden belirlediğiniz sabit tarihler',
      AppLanguage.ur: 'وہ مقررہ تاریخیں جو آپ پہلے سے طے کرتے ہیں',
      AppLanguage.id: 'Tanggal tetap yang Anda tentukan sebelumnya', AppLanguage.ms: 'Tarikh tetap yang anda tetapkan terlebih dahulu',
    },
    'schedule_daily_title': {
      AppLanguage.ar: 'تتكرر يومياً', AppLanguage.en: 'Repeats daily', AppLanguage.fr: 'Se répète quotidiennement',
      AppLanguage.tr: 'Her gün tekrarlanır', AppLanguage.ur: 'روزانہ دہرایا جاتا ہے',
      AppLanguage.id: 'Berulang setiap hari', AppLanguage.ms: 'Berulang setiap hari',
    },
    'schedule_daily_desc': {
      AppLanguage.ar: 'متاحة كل يوم بدون مواعيد ثابتة', AppLanguage.en: 'Available every day with no fixed dates',
      AppLanguage.fr: 'Disponible tous les jours sans dates fixes', AppLanguage.tr: 'Sabit tarih olmadan her gün mevcut',
      AppLanguage.ur: 'بغیر مقررہ تاریخوں کے ہر روز دستیاب',
      AppLanguage.id: 'Tersedia setiap hari tanpa tanggal tetap', AppLanguage.ms: 'Tersedia setiap hari tanpa tarikh tetap',
    },
    'schedule_recurring_title': {
      AppLanguage.ar: 'دورية', AppLanguage.en: 'Recurring', AppLanguage.fr: 'Récurrent', AppLanguage.tr: 'Periyodik', AppLanguage.ur: 'متواتر',
      AppLanguage.id: 'Berkala', AppLanguage.ms: 'Berkala',
    },
    'schedule_recurring_desc': {
      AppLanguage.ar: 'تتكرر كل أسبوع أو كل شهر', AppLanguage.en: 'Repeats every week or every month',
      AppLanguage.fr: 'Se répète chaque semaine ou chaque mois', AppLanguage.tr: 'Her hafta veya her ay tekrarlanır',
      AppLanguage.ur: 'ہر ہفتے یا ہر مہینے دہرایا جاتا ہے',
      AppLanguage.id: 'Berulang setiap minggu atau setiap bulan', AppLanguage.ms: 'Berulang setiap minggu atau setiap bulan',
    },
    'field_availability_start': {
      AppLanguage.ar: 'تاريخ بداية الإتاحة', AppLanguage.en: 'Availability start date', AppLanguage.fr: 'Date de début de disponibilité',
      AppLanguage.tr: 'Uygunluk başlangıç tarihi', AppLanguage.ur: 'دستیابی شروع ہونے کی تاریخ',
      AppLanguage.id: 'Tanggal mulai ketersediaan', AppLanguage.ms: 'Tarikh mula ketersediaan',
    },
    'field_availability_end': {
      AppLanguage.ar: 'تاريخ نهاية الإتاحة', AppLanguage.en: 'Availability end date', AppLanguage.fr: 'Date de fin de disponibilité',
      AppLanguage.tr: 'Uygunluk bitiş tarihi', AppLanguage.ur: 'دستیابی ختم ہونے کی تاریخ',
      AppLanguage.id: 'Tanggal akhir ketersediaan', AppLanguage.ms: 'Tarikh akhir ketersediaan',
    },
    'field_repeats_every': {
      AppLanguage.ar: 'يتكرر كل', AppLanguage.en: 'Repeats every', AppLanguage.fr: 'Se répète chaque',
      AppLanguage.tr: 'Şu sıklıkla tekrarlanır', AppLanguage.ur: 'ہر',
      AppLanguage.id: 'Berulang setiap', AppLanguage.ms: 'Berulang setiap',
    },
    'field_first_trip_date': {
      AppLanguage.ar: 'تاريخ أول رحلة', AppLanguage.en: 'Date of first trip', AppLanguage.fr: 'Date du premier voyage',
      AppLanguage.tr: 'İlk seyahat tarihi', AppLanguage.ur: 'پہلے سفر کی تاریخ',
      AppLanguage.id: 'Tanggal perjalanan pertama', AppLanguage.ms: 'Tarikh perjalanan pertama',
    },
    'action_add_date': {
      AppLanguage.ar: 'إضافة موعد', AppLanguage.en: 'Add date', AppLanguage.fr: 'Ajouter une date',
      AppLanguage.tr: 'Tarih ekle', AppLanguage.ur: 'تاریخ شامل کریں',
      AppLanguage.id: 'Tambah tanggal', AppLanguage.ms: 'Tambah tarikh',
    },
    'destination_label': {
      AppLanguage.ar: 'الوجهة المقصودة', AppLanguage.en: 'Intended destination', AppLanguage.fr: 'Destination prévue',
      AppLanguage.tr: 'Hedef varış yeri', AppLanguage.ur: 'مطلوبہ منزل',
      AppLanguage.id: 'Tujuan yang dimaksud', AppLanguage.ms: 'Destinasi yang dituju',
    },
    'destination_both_title': {
      AppLanguage.ar: 'مكة والمدينة المنورة', AppLanguage.en: 'Mecca & Medina', AppLanguage.fr: 'La Mecque et Médine',
      AppLanguage.tr: 'Mekke ve Medine', AppLanguage.ur: 'مکہ اور مدینہ',
      AppLanguage.id: 'Mekkah & Madinah', AppLanguage.ms: 'Mekah & Madinah',
    },
    'destination_both_desc': {
      AppLanguage.ar: 'برنامج عمرة يشمل الحرمين الشريفين', AppLanguage.en: 'An Umrah program covering both holy mosques',
      AppLanguage.fr: 'Un programme de Omra couvrant les deux mosquées saintes',
      AppLanguage.tr: 'Her iki kutsal camiyi kapsayan bir Umre programı', AppLanguage.ur: 'دونوں مقدس حرمین پر مشتمل عمرہ پروگرام',
      AppLanguage.id: 'Program umrah yang mencakup kedua masjid suci', AppLanguage.ms: 'Program umrah yang merangkumi kedua-dua masjid suci',
    },
    'destination_mecca_title': {
      AppLanguage.ar: 'مكة المكرمة فقط', AppLanguage.en: 'Mecca only', AppLanguage.fr: 'La Mecque uniquement',
      AppLanguage.tr: 'Sadece Mekke', AppLanguage.ur: 'صرف مکہ مکرمہ',
      AppLanguage.id: 'Hanya Mekkah', AppLanguage.ms: 'Mekah sahaja',
    },
    'destination_mecca_desc': {
      AppLanguage.ar: 'برنامج عمرة في مكة فقط', AppLanguage.en: 'An Umrah program in Mecca only',
      AppLanguage.fr: 'Un programme de Omra à La Mecque uniquement', AppLanguage.tr: 'Sadece Mekke\'de bir Umre programı',
      AppLanguage.ur: 'صرف مکہ میں عمرہ پروگرام',
      AppLanguage.id: 'Program umrah hanya di Mekkah', AppLanguage.ms: 'Program umrah di Mekah sahaja',
    },
    'day_distribution_label': {
      AppLanguage.ar: 'توزيع الأيام', AppLanguage.en: 'Day distribution', AppLanguage.fr: 'Répartition des jours',
      AppLanguage.tr: 'Gün dağılımı', AppLanguage.ur: 'دنوں کی تقسیم',
      AppLanguage.id: 'Distribusi hari', AppLanguage.ms: 'Pembahagian hari',
    },
    'field_days_in_mecca': {
      AppLanguage.ar: 'عدد الأيام في مكة المكرمة', AppLanguage.en: 'Days in Mecca', AppLanguage.fr: 'Nombre de jours à La Mecque',
      AppLanguage.tr: 'Mekke\'deki gün sayısı', AppLanguage.ur: 'مکہ میں دنوں کی تعداد',
      AppLanguage.id: 'Jumlah hari di Mekkah', AppLanguage.ms: 'Bilangan hari di Mekah',
    },
    'field_days_in_medina': {
      AppLanguage.ar: 'عدد الأيام في المدينة المنورة', AppLanguage.en: 'Days in Medina', AppLanguage.fr: 'Nombre de jours à Médine',
      AppLanguage.tr: 'Medine\'deki gün sayısı', AppLanguage.ur: 'مدینہ میں دنوں کی تعداد',
      AppLanguage.id: 'Jumlah hari di Madinah', AppLanguage.ms: 'Bilangan hari di Madinah',
    },
    'total_program_duration_prefix': {
      AppLanguage.ar: 'إجمالي مدة البرنامج:', AppLanguage.en: 'Total program duration:', AppLanguage.fr: 'Durée totale du programme :',
      AppLanguage.tr: 'Toplam program süresi:', AppLanguage.ur: 'پروگرام کا کل دورانیہ:',
      AppLanguage.id: 'Total durasi program:', AppLanguage.ms: 'Jumlah tempoh program:',
    },
    'field_price_per_person': {
      AppLanguage.ar: 'السعر للفرد *', AppLanguage.en: 'Price per person *', AppLanguage.fr: 'Prix par personne *',
      AppLanguage.tr: 'Kişi başı fiyat *', AppLanguage.ur: 'فی کس قیمت *',
      AppLanguage.id: 'Harga per orang *', AppLanguage.ms: 'Harga seorang *',
    },
    'family_pricing_label': {
      AppLanguage.ar: 'سعر الغرفة الخاصة (عائلي) — اختياري', AppLanguage.en: 'Private room price (family) — optional',
      AppLanguage.fr: 'Prix chambre privée (famille) — facultatif',
      AppLanguage.tr: 'Özel oda fiyatı (aile) — isteğe bağlı', AppLanguage.ur: 'نجی کمرے کی قیمت (خاندان) — اختیاری',
      AppLanguage.id: 'Harga kamar pribadi (keluarga) — opsional', AppLanguage.ms: 'Harga bilik persendirian (keluarga) — pilihan',
    },
    'family_pricing_hint': {
      AppLanguage.ar: 'يُطبق فقط لو العميل اختار غرفة خاصة لشخصين أو أكثر. بدون غرفة خاصة: السعر للفرد × عدد الأشخاص. اكتب سعر الغرفة للمجموعة كاملة.',
      AppLanguage.en: 'Applies only when the customer picks a private room for 2+ persons. Otherwise: price per person × persons. Enter the price for the whole group.',
      AppLanguage.fr: "S'applique seulement si le client choisit une chambre privée (2+ personnes). Sinon : prix par personne × personnes.",
      AppLanguage.tr: 'Yalnızca müşteri 2+ kişi için özel oda seçerse uygulanır. Aksi halde: kişi başı fiyat × kişi sayısı.',
      AppLanguage.ur: 'صرف تب لاگو جب گاہک 2 یا زیادہ افراد کے لیے نجی کمرہ چنے۔ ورنہ: فی کس قیمت × افراد۔',
      AppLanguage.id: 'Hanya berlaku jika pelanggan memilih kamar pribadi untuk 2+ orang. Jika tidak: harga per orang × jumlah orang.',
      AppLanguage.ms: 'Hanya terpakai jika pelanggan memilih bilik persendirian untuk 2+ orang. Jika tidak: harga seorang × bilangan orang.',
    },
    'family_pricing_shared_hint': {
      AppLanguage.ar: 'بدون غرفة خاصة:', AppLanguage.en: 'Shared room:', AppLanguage.fr: 'Chambre partagée :',
      AppLanguage.tr: 'Paylaşımlı oda:', AppLanguage.ur: 'مشترکہ کمرہ:', AppLanguage.id: 'Kamar bersama:', AppLanguage.ms: 'Bilik dikongsi:',
    },
    'family_pricing_cheaper_warning': {
      AppLanguage.ar: '⚠ أقل من سعر الغرفة المشتركة لنفس العدد', AppLanguage.en: '⚠ Lower than the shared-room price for the same group',
      AppLanguage.fr: '⚠ Inférieur au prix en chambre partagée', AppLanguage.tr: '⚠ Paylaşımlı oda fiyatından düşük',
      AppLanguage.ur: '⚠ مشترکہ کمرے کی قیمت سے کم', AppLanguage.id: '⚠ Lebih rendah dari harga kamar bersama',
      AppLanguage.ms: '⚠ Lebih rendah daripada harga bilik dikongsi',
    },
    'family_pricing_one_person_warning': {
      AppLanguage.ar: '⚠ الغرفة الخاصة لشخصين أو أكثر فقط', AppLanguage.en: '⚠ Private room is for 2+ persons only',
      AppLanguage.fr: '⚠ Chambre privée : 2 personnes minimum', AppLanguage.tr: '⚠ Özel oda yalnızca 2+ kişi için',
      AppLanguage.ur: '⚠ نجی کمرہ صرف 2 یا زیادہ افراد کے لیے', AppLanguage.id: '⚠ Kamar pribadi hanya untuk 2+ orang',
      AppLanguage.ms: '⚠ Bilik persendirian hanya untuk 2+ orang',
    },
    'action_add_family_pricing': {
      AppLanguage.ar: 'إضافة سعر غرفة خاصة', AppLanguage.en: 'Add private room price', AppLanguage.fr: 'Ajouter un prix chambre privée',
      AppLanguage.tr: 'Özel oda fiyatı ekle', AppLanguage.ur: 'نجی کمرے کی قیمت شامل کریں',
      AppLanguage.id: 'Tambah harga kamar pribadi', AppLanguage.ms: 'Tambah harga bilik persendirian',
    },
    'day_word_prefix': {
      AppLanguage.ar: 'اليوم', AppLanguage.en: 'Day', AppLanguage.fr: 'Jour', AppLanguage.tr: 'Gün', AppLanguage.ur: 'دن',
      AppLanguage.id: 'Hari', AppLanguage.ms: 'Hari',
    },
    'field_day_title': {
      AppLanguage.ar: 'عنوان اليوم', AppLanguage.en: 'Day title', AppLanguage.fr: 'Titre du jour',
      AppLanguage.tr: 'Gün başlığı', AppLanguage.ur: 'دن کا عنوان',
      AppLanguage.id: 'Judul hari', AppLanguage.ms: 'Tajuk hari',
    },
    'field_day_activities': {
      AppLanguage.ar: 'الأنشطة', AppLanguage.en: 'Activities', AppLanguage.fr: 'Activités',
      AppLanguage.tr: 'Etkinlikler', AppLanguage.ur: 'سرگرمیاں',
      AppLanguage.id: 'Aktivitas', AppLanguage.ms: 'Aktiviti',
    },
    'action_add_new_day': {
      AppLanguage.ar: 'إضافة يوم جديد', AppLanguage.en: 'Add a new day', AppLanguage.fr: 'Ajouter un nouveau jour',
      AppLanguage.tr: 'Yeni gün ekle', AppLanguage.ur: 'نیا دن شامل کریں',
      AppLanguage.id: 'Tambah hari baru', AppLanguage.ms: 'Tambah hari baharu',
    },
    'mecca_visits_label': {
      AppLanguage.ar: 'مزارات مكة المكرمة', AppLanguage.en: 'Mecca landmarks', AppLanguage.fr: 'Sites de La Mecque',
      AppLanguage.tr: 'Mekke ziyaret yerleri', AppLanguage.ur: 'مکہ کے مقامات',
      AppLanguage.id: 'Tempat bersejarah di Mekkah', AppLanguage.ms: 'Tempat bersejarah di Mekah',
    },
    'medina_visits_label': {
      AppLanguage.ar: 'مزارات المدينة المنورة', AppLanguage.en: 'Medina landmarks', AppLanguage.fr: 'Sites de Médine',
      AppLanguage.tr: 'Medine ziyaret yerleri', AppLanguage.ur: 'مدینہ کے مقامات',
      AppLanguage.id: 'Tempat bersejarah di Madinah', AppLanguage.ms: 'Tempat bersejarah di Madinah',
    },
    'landmark_jabal_nour': {
      AppLanguage.ar: 'جبل النور', AppLanguage.en: 'Jabal al-Nour', AppLanguage.fr: 'Jabal al-Nour',
      AppLanguage.tr: 'Cebel-i Nur', AppLanguage.ur: 'جبل نور',
      AppLanguage.id: 'Jabal Nur', AppLanguage.ms: 'Jabal Nur',
    },
    'landmark_ghar_hira': {
      AppLanguage.ar: 'غار حراء', AppLanguage.en: 'Cave of Hira', AppLanguage.fr: 'Grotte de Hira',
      AppLanguage.tr: 'Hira Mağarası', AppLanguage.ur: 'غار حرا',
      AppLanguage.id: 'Gua Hira', AppLanguage.ms: 'Gua Hira',
    },
    'landmark_masjid_khaif': {
      AppLanguage.ar: 'مسجد الخيف', AppLanguage.en: 'Masjid al-Khayf', AppLanguage.fr: 'Mosquée al-Khayf',
      AppLanguage.tr: 'Hayf Camii', AppLanguage.ur: 'مسجد خیف',
      AppLanguage.id: 'Masjid Khaif', AppLanguage.ms: 'Masjid Khaif',
    },
    'landmark_mina': {
      AppLanguage.ar: 'منى', AppLanguage.en: 'Mina', AppLanguage.fr: 'Mina', AppLanguage.tr: 'Mina', AppLanguage.ur: 'منیٰ',
      AppLanguage.id: 'Mina', AppLanguage.ms: 'Mina',
    },
    'landmark_arafat': {
      AppLanguage.ar: 'عرفات', AppLanguage.en: 'Arafat', AppLanguage.fr: 'Arafat', AppLanguage.tr: 'Arafat', AppLanguage.ur: 'عرفات',
      AppLanguage.id: 'Arafah', AppLanguage.ms: 'Arafah',
    },
    'landmark_prophet_grave': {
      AppLanguage.ar: 'زيارة قبر النبي ﷺ', AppLanguage.en: 'Visit the Prophet\'s grave ﷺ',
      AppLanguage.fr: 'Visite de la tombe du Prophète ﷺ', AppLanguage.tr: 'Peygamber\'in kabrini ziyaret ﷺ',
      AppLanguage.ur: 'نبی کریمﷺ کی قبر کی زیارت',
      AppLanguage.id: 'Ziarah makam Nabi ﷺ', AppLanguage.ms: 'Lawatan ke makam Nabi ﷺ',
    },
    'landmark_quba': {
      AppLanguage.ar: 'مسجد قباء', AppLanguage.en: 'Masjid Quba', AppLanguage.fr: 'Mosquée Quba',
      AppLanguage.tr: 'Kuba Camii', AppLanguage.ur: 'مسجد قبا',
      AppLanguage.id: 'Masjid Quba', AppLanguage.ms: 'Masjid Quba',
    },
    'landmark_baqi': {
      AppLanguage.ar: 'البقيع', AppLanguage.en: 'Al-Baqi', AppLanguage.fr: 'Al-Baqi', AppLanguage.tr: 'Baki Mezarlığı', AppLanguage.ur: 'بقیع',
      AppLanguage.id: 'Al-Baqi', AppLanguage.ms: 'Al-Baqi',
    },
    'landmark_qiblatain': {
      AppLanguage.ar: 'مسجد القبلتين', AppLanguage.en: 'Masjid al-Qiblatayn', AppLanguage.fr: 'Mosquée des Deux Qiblas',
      AppLanguage.tr: 'Kıbleteyn Camii', AppLanguage.ur: 'مسجد قبلتین',
      AppLanguage.id: 'Masjid Qiblatain', AppLanguage.ms: 'Masjid Qiblatain',
    },
    'services_label': {
      AppLanguage.ar: 'الخدمات المشمولة', AppLanguage.en: 'Included services', AppLanguage.fr: 'Services inclus',
      AppLanguage.tr: 'Dahil edilen hizmetler', AppLanguage.ur: 'شامل خدمات',
      AppLanguage.id: 'Layanan yang termasuk', AppLanguage.ms: 'Perkhidmatan yang disertakan',
    },
    'service_accommodation': {
      AppLanguage.ar: 'الإقامة بالفندق', AppLanguage.en: 'Hotel accommodation', AppLanguage.fr: 'Hébergement à l\'hôtel',
      AppLanguage.tr: 'Otel konaklaması', AppLanguage.ur: 'ہوٹل رہائش',
      AppLanguage.id: 'Akomodasi hotel', AppLanguage.ms: 'Penginapan hotel',
    },
    'service_visa': {
      AppLanguage.ar: 'تأشيرة العمرة', AppLanguage.en: 'Umrah visa', AppLanguage.fr: 'Visa de Omra',
      AppLanguage.tr: 'Umre vizesi', AppLanguage.ur: 'عمرہ ویزا',
      AppLanguage.id: 'Visa umrah', AppLanguage.ms: 'Visa umrah',
    },
    'service_insurance': {
      AppLanguage.ar: 'التأمين الطبي', AppLanguage.en: 'Medical insurance', AppLanguage.fr: 'Assurance médicale',
      AppLanguage.tr: 'Sağlık sigortası', AppLanguage.ur: 'طبی بیمہ',
      AppLanguage.id: 'Asuransi kesehatan', AppLanguage.ms: 'Insurans perubatan',
    },
    'service_all_meals': {
      AppLanguage.ar: 'جميع الوجبات', AppLanguage.en: 'All meals', AppLanguage.fr: 'Tous les repas',
      AppLanguage.tr: 'Tüm öğünler', AppLanguage.ur: 'تمام کھانے',
      AppLanguage.id: 'Semua makanan', AppLanguage.ms: 'Semua hidangan',
    },
    'field_title_generic': {
      AppLanguage.ar: 'العنوان', AppLanguage.en: 'Title', AppLanguage.fr: 'Titre', AppLanguage.tr: 'Başlık', AppLanguage.ur: 'عنوان',
      AppLanguage.id: 'Judul', AppLanguage.ms: 'Tajuk',
    },
    'field_detailed_description': {
      AppLanguage.ar: 'الوصف التفصيلي', AppLanguage.en: 'Detailed description', AppLanguage.fr: 'Description détaillée',
      AppLanguage.tr: 'Ayrıntılı açıklama', AppLanguage.ur: 'تفصیلی تفصیل',
      AppLanguage.id: 'Deskripsi lengkap', AppLanguage.ms: 'Penerangan terperinci',
    },
    'upload_photos_hint': {
      AppLanguage.ar: 'اضغط لإضافة صور البرنامج', AppLanguage.en: 'Tap to add program photos',
      AppLanguage.fr: 'Appuyez pour ajouter des photos du programme', AppLanguage.tr: 'Program fotoğrafları eklemek için dokunun',
      AppLanguage.ur: 'پروگرام کی تصاویر شامل کرنے کے لیے ٹیپ کریں',
      AppLanguage.id: 'Ketuk untuk menambahkan foto program', AppLanguage.ms: 'Ketik untuk menambah foto program',
    },

    // ===== مشرف الفندق =====
    'hm_home_subtitle': {
      AppLanguage.ar: 'نظرة عامة على عملك اليوم', AppLanguage.en: 'Overview of your work today',
      AppLanguage.fr: 'Aperçu de votre travail aujourd\'hui', AppLanguage.tr: 'Bugünkü işinizin genel görünümü',
      AppLanguage.ur: 'آج کے کام کا جائزہ',
      AppLanguage.id: 'Ikhtisar pekerjaan Anda hari ini', AppLanguage.ms: 'Gambaran keseluruhan kerja anda hari ini',
    },
    'stat_buses_arriving_today': {
      AppLanguage.ar: 'باصات وافدة اليوم', AppLanguage.en: 'Buses arriving today', AppLanguage.fr: 'Bus arrivant aujourd\'hui',
      AppLanguage.tr: 'Bugün gelen otobüsler', AppLanguage.ur: 'آج آنے والی بسیں',
      AppLanguage.id: 'Bus tiba hari ini', AppLanguage.ms: 'Bas tiba hari ini',
    },
    'stat_rooms_formed': {
      AppLanguage.ar: 'غرف مُشكّلة', AppLanguage.en: 'Rooms formed', AppLanguage.fr: 'Chambres formées',
      AppLanguage.tr: 'Oluşturulan odalar', AppLanguage.ur: 'بنائے گئے کمرے',
      AppLanguage.id: 'Kamar terbentuk', AppLanguage.ms: 'Bilik dibentuk',
    },
    'stat_waiting_housing': {
      AppLanguage.ar: 'بانتظار التسكين', AppLanguage.en: 'Waiting for housing', AppLanguage.fr: 'En attente de logement',
      AppLanguage.tr: 'Konaklama bekleniyor', AppLanguage.ur: 'رہائش کا انتظار',
      AppLanguage.id: 'Menunggu penempatan', AppLanguage.ms: 'Menunggu penempatan',
    },
    'section_closest_buses': {
      AppLanguage.ar: 'أقرب الباصات وصولاً', AppLanguage.en: 'Nearest arriving buses', AppLanguage.fr: 'Bus arrivant bientôt',
      AppLanguage.tr: 'En yakın varan otobüsler', AppLanguage.ur: 'قریب ترین آنے والی بسیں',
      AppLanguage.id: 'Bus yang akan segera tiba', AppLanguage.ms: 'Bas yang akan tiba tidak lama lagi',
    },
    'arrival_time_prefix': {
      AppLanguage.ar: 'وقت الوصول المتوقع:', AppLanguage.en: 'Expected arrival:', AppLanguage.fr: 'Heure d\'arrivée prévue :',
      AppLanguage.tr: 'Tahmini varış saati:', AppLanguage.ur: 'متوقع آمد کا وقت:',
      AppLanguage.id: 'Perkiraan waktu tiba:', AppLanguage.ms: 'Jangkaan waktu ketibaan:',
    },
    'hm_trips_subtitle': {
      AppLanguage.ar: 'الباصات الوافدة لكل رحلة', AppLanguage.en: 'Buses arriving per trip', AppLanguage.fr: 'Bus arrivant par voyage',
      AppLanguage.tr: 'Her seyahat için gelen otobüsler', AppLanguage.ur: 'ہر سفر کے لیے آنے والی بسیں',
      AppLanguage.id: 'Bus tiba per perjalanan', AppLanguage.ms: 'Bas tiba bagi setiap perjalanan',
    },
    'section_rooms_formed': {
      AppLanguage.ar: 'الغرف المُشكّلة', AppLanguage.en: 'Rooms formed', AppLanguage.fr: 'Chambres formées',
      AppLanguage.tr: 'Oluşturulan odalar', AppLanguage.ur: 'بنائے گئے کمرے',
      AppLanguage.id: 'Kamar yang terbentuk', AppLanguage.ms: 'Bilik yang dibentuk',
    },
    'no_rooms_yet': {
      AppLanguage.ar: 'لم يتم تشكيل أي غرف بعد', AppLanguage.en: 'No rooms formed yet', AppLanguage.fr: 'Aucune chambre formée pour l\'instant',
      AppLanguage.tr: 'Henüz oda oluşturulmadı', AppLanguage.ur: 'ابھی تک کوئی کمرہ نہیں بنایا گیا',
      AppLanguage.id: 'Belum ada kamar yang dibentuk', AppLanguage.ms: 'Belum ada bilik dibentuk',
    },
    'section_waiting_housing': {
      AppLanguage.ar: 'معتمرون بانتظار التسكين', AppLanguage.en: 'Pilgrims waiting for housing',
      AppLanguage.fr: 'Pèlerins en attente de logement', AppLanguage.tr: 'Konaklama bekleyen hacılar/umreciler',
      AppLanguage.ur: 'رہائش کے منتظر زائرین',
      AppLanguage.id: 'Jemaah yang menunggu penempatan', AppLanguage.ms: 'Jemaah yang menunggu penempatan',
    },
    'search_traveler_by_name': {
      AppLanguage.ar: 'بحث عن معتمر بالاسم', AppLanguage.en: 'Search a pilgrim by name', AppLanguage.fr: 'Rechercher un pèlerin par nom',
      AppLanguage.tr: 'Hacı/umreci adına göre ara', AppLanguage.ur: 'نام سے زائر تلاش کریں',
      AppLanguage.id: 'Cari jemaah berdasarkan nama', AppLanguage.ms: 'Cari jemaah mengikut nama',
    },
    'all_housed': {
      AppLanguage.ar: 'كل المعتمرين تم تسكينهم', AppLanguage.en: 'All pilgrims have been housed',
      AppLanguage.fr: 'Tous les pèlerins ont été logés', AppLanguage.tr: 'Tüm hacılar/umreciler yerleştirildi',
      AppLanguage.ur: 'تمام زائرین کو رہائش دی جا چکی',
      AppLanguage.id: 'Semua jemaah telah ditempatkan', AppLanguage.ms: 'Semua jemaah telah ditempatkan',
    },
    'action_house_selected': {
      AppLanguage.ar: 'تسكين المحددين في غرفة', AppLanguage.en: 'House selected in a room',
      AppLanguage.fr: 'Loger les sélectionnés dans une chambre', AppLanguage.tr: 'Seçilenleri bir odaya yerleştir',
      AppLanguage.ur: 'منتخب کردہ کو کمرے میں ٹھہرائیں',
      AppLanguage.id: 'Tempatkan yang dipilih di kamar', AppLanguage.ms: 'Tempatkan yang dipilih dalam bilik',
    },
    'room_details_title': {
      AppLanguage.ar: 'تفاصيل الغرفة', AppLanguage.en: 'Room details', AppLanguage.fr: 'Détails de la chambre',
      AppLanguage.tr: 'Oda detayları', AppLanguage.ur: 'کمرے کی تفصیلات',
      AppLanguage.id: 'Detail kamar', AppLanguage.ms: 'Butiran bilik',
    },
    'room_occupant_count_label': {
      AppLanguage.ar: 'عدد المعتمرين في هذه الغرفة', AppLanguage.en: 'Number of pilgrims in this room',
      AppLanguage.fr: 'Nombre de pèlerins dans cette chambre', AppLanguage.tr: 'Bu odadaki hacı/umreci sayısı',
      AppLanguage.ur: 'اس کمرے میں زائرین کی تعداد',
      AppLanguage.id: 'Jumlah jemaah di kamar ini', AppLanguage.ms: 'Bilangan jemaah dalam bilik ini',
    },
    'field_floor': {
      AppLanguage.ar: 'الدور *', AppLanguage.en: 'Floor *', AppLanguage.fr: 'Étage *', AppLanguage.tr: 'Kat *', AppLanguage.ur: 'منزل *',
      AppLanguage.id: 'Lantai *', AppLanguage.ms: 'Tingkat *',
    },
    'field_room_number': {
      AppLanguage.ar: 'رقم الغرفة *', AppLanguage.en: 'Room number *', AppLanguage.fr: 'Numéro de chambre *',
      AppLanguage.tr: 'Oda numarası *', AppLanguage.ur: 'کمرے کا نمبر *',
      AppLanguage.id: 'Nomor kamar *', AppLanguage.ms: 'Nombor bilik *',
    },
    'action_confirm_housing': {
      AppLanguage.ar: 'تأكيد التسكين', AppLanguage.en: 'Confirm housing', AppLanguage.fr: 'Confirmer le logement',
      AppLanguage.tr: 'Yerleşimi onayla', AppLanguage.ur: 'رہائش کی تصدیق کریں',
      AppLanguage.id: 'Konfirmasi penempatan', AppLanguage.ms: 'Sahkan penempatan',
    },

    // ===== مشرف الباص =====
    'bs_home_subtitle': {
      AppLanguage.ar: 'ملخص باصاتك اليوم', AppLanguage.en: 'Summary of your buses today',
      AppLanguage.fr: 'Résumé de vos bus aujourd\'hui', AppLanguage.tr: 'Bugünkü otobüslerinizin özeti',
      AppLanguage.ur: 'آج کی آپ کی بسوں کا خلاصہ',
      AppLanguage.id: 'Ringkasan bus Anda hari ini', AppLanguage.ms: 'Ringkasan bas anda hari ini',
    },
    'stat_my_buses_today': {
      AppLanguage.ar: 'باصاتي اليوم', AppLanguage.en: 'My buses today', AppLanguage.fr: 'Mes bus aujourd\'hui',
      AppLanguage.tr: 'Bugünkü otobüslerim', AppLanguage.ur: 'آج میری بسیں',
      AppLanguage.id: 'Bus saya hari ini', AppLanguage.ms: 'Bas saya hari ini',
    },
    'stat_total_present': {
      AppLanguage.ar: 'إجمالي الحاضرين', AppLanguage.en: 'Total present', AppLanguage.fr: 'Total présents',
      AppLanguage.tr: 'Toplam mevcut', AppLanguage.ur: 'کل حاضر',
      AppLanguage.id: 'Total hadir', AppLanguage.ms: 'Jumlah hadir',
    },
    'stat_total_absent': {
      AppLanguage.ar: 'إجمالي الغائبين', AppLanguage.en: 'Total absent', AppLanguage.fr: 'Total absents',
      AppLanguage.tr: 'Toplam yok', AppLanguage.ur: 'کل غیر حاضر',
      AppLanguage.id: 'Total tidak hadir', AppLanguage.ms: 'Jumlah tidak hadir',
    },
    'bs_trips_subtitle': {
      AppLanguage.ar: 'اختر الباص لتسجيل الحضور والغياب', AppLanguage.en: 'Choose a bus to record attendance',
      AppLanguage.fr: 'Choisissez un bus pour enregistrer la présence', AppLanguage.tr: 'Yoklama kaydetmek için bir otobüs seçin',
      AppLanguage.ur: 'حاضری ریکارڈ کرنے کے لیے بس منتخب کریں',
      AppLanguage.id: 'Pilih bus untuk mencatat kehadiran', AppLanguage.ms: 'Pilih bas untuk merekod kehadiran',
    },
    'attendance_present': {
      AppLanguage.ar: 'حاضر', AppLanguage.en: 'Present', AppLanguage.fr: 'Présent', AppLanguage.tr: 'Mevcut', AppLanguage.ur: 'حاضر',
      AppLanguage.id: 'Hadir', AppLanguage.ms: 'Hadir',
    },
    'attendance_absent': {
      AppLanguage.ar: 'غايب', AppLanguage.en: 'Absent', AppLanguage.fr: 'Absent', AppLanguage.tr: 'Yok', AppLanguage.ur: 'غیر حاضر',
      AppLanguage.id: 'Tidak hadir', AppLanguage.ms: 'Tidak hadir',
    },
    'attendance_total': {
      AppLanguage.ar: 'الإجمالي', AppLanguage.en: 'Total', AppLanguage.fr: 'Total', AppLanguage.tr: 'Toplam', AppLanguage.ur: 'کل',
      AppLanguage.id: 'Total', AppLanguage.ms: 'Jumlah',
    },

    // ===== المعتمرون =====
    'travelers_title': {
      AppLanguage.ar: 'المعتمرون', AppLanguage.en: 'Pilgrims', AppLanguage.fr: 'Pèlerins',
      AppLanguage.tr: 'Hacılar/Umreciler', AppLanguage.ur: 'زائرین',
      AppLanguage.id: 'Jemaah', AppLanguage.ms: 'Jemaah',
    },
    'travelers_count_suffix': {
      AppLanguage.ar: 'معتمر مسجل', AppLanguage.en: 'registered pilgrims', AppLanguage.fr: 'pèlerins enregistrés',
      AppLanguage.tr: 'kayıtlı hacı/umreci', AppLanguage.ur: 'رجسٹرڈ زائرین',
      AppLanguage.id: 'jemaah terdaftar', AppLanguage.ms: 'jemaah berdaftar',
    },
    'travelers_search_hint': {
      AppLanguage.ar: 'بحث بالاسم أو البريد الإلكتروني', AppLanguage.en: 'Search by name or email',
      AppLanguage.fr: 'Rechercher par nom ou e-mail', AppLanguage.tr: 'Ad veya e-postaya göre ara',
      AppLanguage.ur: 'نام یا ای میل سے تلاش کریں',
      AppLanguage.id: 'Cari berdasarkan nama atau email', AppLanguage.ms: 'Cari mengikut nama atau e-mel',
    },
    'travelers_trips_suffix': {
      AppLanguage.ar: 'رحلات', AppLanguage.en: 'trips', AppLanguage.fr: 'voyages', AppLanguage.tr: 'seyahat', AppLanguage.ur: 'سفر',
      AppLanguage.id: 'perjalanan', AppLanguage.ms: 'perjalanan',
    },
    'category_umrah': {
      AppLanguage.ar: 'عمرة', AppLanguage.en: 'Umrah', AppLanguage.fr: 'Omra', AppLanguage.tr: 'Umre', AppLanguage.ur: 'عمرہ',
      AppLanguage.id: 'Umrah', AppLanguage.ms: 'Umrah',
    },
    'category_hajj': {
      AppLanguage.ar: 'حج', AppLanguage.en: 'Hajj', AppLanguage.fr: 'Hajj', AppLanguage.tr: 'Hac', AppLanguage.ur: 'حج',
      AppLanguage.id: 'Haji', AppLanguage.ms: 'Haji',
    },
    'category_tourism': {
      AppLanguage.ar: 'سياحة', AppLanguage.en: 'Tourism', AppLanguage.fr: 'Tourisme', AppLanguage.tr: 'Turizm', AppLanguage.ur: 'سیاحت',
      AppLanguage.id: 'Wisata', AppLanguage.ms: 'Pelancongan',
    },
    'add_traveler_title': {
      AppLanguage.ar: 'إضافة معتمر جديد', AppLanguage.en: 'Add a new pilgrim', AppLanguage.fr: 'Ajouter un nouveau pèlerin',
      AppLanguage.tr: 'Yeni hacı/umreci ekle', AppLanguage.ur: 'نیا زائر شامل کریں',
      AppLanguage.id: 'Tambah jemaah baru', AppLanguage.ms: 'Tambah jemaah baharu',
    },
    'field_full_name': {
      AppLanguage.ar: 'الاسم الكامل *', AppLanguage.en: 'Full name *', AppLanguage.fr: 'Nom complet *',
      AppLanguage.tr: 'Tam ad *', AppLanguage.ur: 'پورا نام *',
      AppLanguage.id: 'Nama lengkap *', AppLanguage.ms: 'Nama penuh *',
    },
    'field_passport_id': {
      AppLanguage.ar: 'رقم الجواز / رقم الهوية *', AppLanguage.en: 'Passport / ID number *',
      AppLanguage.fr: 'N° de passeport / de carte d\'identité *', AppLanguage.tr: 'Pasaport / Kimlik numarası *',
      AppLanguage.ur: 'پاسپورٹ/شناختی کارڈ نمبر *',
      AppLanguage.id: 'Nomor paspor / KTP *', AppLanguage.ms: 'Nombor pasport / kad pengenalan *',
    },
    'field_phone': {
      AppLanguage.ar: 'رقم الجوال *', AppLanguage.en: 'Phone number *', AppLanguage.fr: 'Numéro de téléphone *',
      AppLanguage.tr: 'Telefon numarası *', AppLanguage.ur: 'فون نمبر *',
      AppLanguage.id: 'Nomor ponsel *', AppLanguage.ms: 'Nombor telefon *',
    },
    'field_price_paid': {
      AppLanguage.ar: 'سعر العمرة الذي دفعه المعتمر *', AppLanguage.en: 'Amount paid by the pilgrim *',
      AppLanguage.fr: 'Montant payé par le pèlerin *', AppLanguage.tr: 'Hacı/umrecinin ödediği tutar *',
      AppLanguage.ur: 'زائر کی ادا کردہ رقم *',
      AppLanguage.id: 'Jumlah yang dibayar oleh jemaah *', AppLanguage.ms: 'Jumlah yang dibayar oleh jemaah *',
    },
    'action_save_traveler': {
      AppLanguage.ar: 'حفظ المعتمر', AppLanguage.en: 'Save pilgrim', AppLanguage.fr: 'Enregistrer le pèlerin',
      AppLanguage.tr: 'Hacı/Umreciyi kaydet', AppLanguage.ur: 'زائر کو محفوظ کریں',
      AppLanguage.id: 'Simpan jemaah', AppLanguage.ms: 'Simpan jemaah',
    },

    // ===== الفنادق والإقامة =====
    'hotels_subtitle': {
      AppLanguage.ar: 'فنادقك المتعاقد معها', AppLanguage.en: 'Your contracted hotels', AppLanguage.fr: 'Vos hôtels sous contrat',
      AppLanguage.tr: 'Anlaşmalı otelleriniz', AppLanguage.ur: 'آپ کے معاہدہ شدہ ہوٹلز',
      AppLanguage.id: 'Hotel yang Anda kontrak', AppLanguage.ms: 'Hotel yang anda kontrak',
    },
    'add_hotel_title': {
      AppLanguage.ar: 'إضافة فندق جديد', AppLanguage.en: 'Add a new hotel', AppLanguage.fr: 'Ajouter un nouvel hôtel',
      AppLanguage.tr: 'Yeni otel ekle', AppLanguage.ur: 'نیا ہوٹل شامل کریں',
      AppLanguage.id: 'Tambah hotel baru', AppLanguage.ms: 'Tambah hotel baharu',
    },
    'field_hotel_name': {
      AppLanguage.ar: 'اسم الفندق *', AppLanguage.en: 'Hotel name *', AppLanguage.fr: 'Nom de l\'hôtel *',
      AppLanguage.tr: 'Otel adı *', AppLanguage.ur: 'ہوٹل کا نام *',
      AppLanguage.id: 'Nama hotel *', AppLanguage.ms: 'Nama hotel *',
    },
    'field_city': {
      AppLanguage.ar: 'المدينة', AppLanguage.en: 'City', AppLanguage.fr: 'Ville', AppLanguage.tr: 'Şehir', AppLanguage.ur: 'شہر',
      AppLanguage.id: 'Kota', AppLanguage.ms: 'Bandar',
    },
    'field_star_count': {
      AppLanguage.ar: 'عدد النجوم', AppLanguage.en: 'Star rating', AppLanguage.fr: 'Nombre d\'étoiles',
      AppLanguage.tr: 'Yıldız sayısı', AppLanguage.ur: 'ستاروں کی تعداد',
      AppLanguage.id: 'Jumlah bintang', AppLanguage.ms: 'Bilangan bintang',
    },
    'field_distance_from_haram': {
      AppLanguage.ar: 'المسافة من الحرم', AppLanguage.en: 'Distance from the Haram',
      AppLanguage.fr: 'Distance par rapport à la Mosquée sacrée', AppLanguage.tr: 'Harem\'e uzaklık',
      AppLanguage.ur: 'حرم سے فاصلہ',
      AppLanguage.id: 'Jarak dari Masjidil Haram', AppLanguage.ms: 'Jarak dari Masjidil Haram',
    },
    'action_save_hotel': {
      AppLanguage.ar: 'حفظ الفندق', AppLanguage.en: 'Save hotel', AppLanguage.fr: 'Enregistrer l\'hôtel',
      AppLanguage.tr: 'Oteli kaydet', AppLanguage.ur: 'ہوٹل محفوظ کریں',
      AppLanguage.id: 'Simpan hotel', AppLanguage.ms: 'Simpan hotel',
    },

    // ===== النقل والطيران =====
    'transport_subtitle': {
      AppLanguage.ar: 'الباصات والسائقين وشركات الطيران', AppLanguage.en: 'Buses, drivers, and airlines',
      AppLanguage.fr: 'Bus, chauffeurs et compagnies aériennes', AppLanguage.tr: 'Otobüsler, şoförler ve havayolları',
      AppLanguage.ur: 'بسیں، ڈرائیورز اور ایئرلائنز',
      AppLanguage.id: 'Bus, pengemudi, dan maskapai penerbangan', AppLanguage.ms: 'Bas, pemandu, dan syarikat penerbangan',
    },
    'transport_available': {
      AppLanguage.ar: 'متاح', AppLanguage.en: 'Available', AppLanguage.fr: 'Disponible', AppLanguage.tr: 'Müsait', AppLanguage.ur: 'دستیاب',
      AppLanguage.id: 'Tersedia', AppLanguage.ms: 'Tersedia',
    },
    'transport_partner': {
      AppLanguage.ar: 'شريك', AppLanguage.en: 'Partner', AppLanguage.fr: 'Partenaire', AppLanguage.tr: 'Ortak', AppLanguage.ur: 'پارٹنر',
      AppLanguage.id: 'Mitra', AppLanguage.ms: 'Rakan kongsi',
    },
    'transport_partner_airline': {
      AppLanguage.ar: 'شركة طيران شريكة', AppLanguage.en: 'Partner airline', AppLanguage.fr: 'Compagnie aérienne partenaire',
      AppLanguage.tr: 'Ortak havayolu', AppLanguage.ur: 'پارٹنر ایئرلائن',
      AppLanguage.id: 'Maskapai mitra', AppLanguage.ms: 'Syarikat penerbangan rakan kongsi',
    },
    'transport_no_driver': {
      AppLanguage.ar: 'بدون سائق', AppLanguage.en: 'No driver', AppLanguage.fr: 'Sans chauffeur',
      AppLanguage.tr: 'Şoförsüz', AppLanguage.ur: 'بغیر ڈرائیور',
      AppLanguage.id: 'Tanpa pengemudi', AppLanguage.ms: 'Tiada pemandu',
    },
    'add_transport_title': {
      AppLanguage.ar: 'إضافة وسيلة نقل', AppLanguage.en: 'Add a means of transport', AppLanguage.fr: 'Ajouter un moyen de transport',
      AppLanguage.tr: 'Ulaşım aracı ekle', AppLanguage.ur: 'نقل و حمل کا ذریعہ شامل کریں',
      AppLanguage.id: 'Tambah alat transportasi', AppLanguage.ms: 'Tambah kenderaan pengangkutan',
    },
    'field_type': {
      AppLanguage.ar: 'النوع *', AppLanguage.en: 'Type *', AppLanguage.fr: 'Type *', AppLanguage.tr: 'Tür *', AppLanguage.ur: 'قسم *',
      AppLanguage.id: 'Jenis *', AppLanguage.ms: 'Jenis *',
    },
    'transport_type_bus': {
      AppLanguage.ar: 'باص', AppLanguage.en: 'Bus', AppLanguage.fr: 'Bus', AppLanguage.tr: 'Otobüs', AppLanguage.ur: 'بس',
      AppLanguage.id: 'Bus', AppLanguage.ms: 'Bas',
    },
    'transport_type_flight': {
      AppLanguage.ar: 'طيران', AppLanguage.en: 'Flight', AppLanguage.fr: 'Vol', AppLanguage.tr: 'Uçuş', AppLanguage.ur: 'پرواز',
      AppLanguage.id: 'Penerbangan', AppLanguage.ms: 'Penerbangan',
    },
    'field_name_or_plate': {
      AppLanguage.ar: 'الاسم / رقم اللوحة *', AppLanguage.en: 'Name / Plate number *', AppLanguage.fr: 'Nom / N° de plaque *',
      AppLanguage.tr: 'Ad / Plaka numarası *', AppLanguage.ur: 'نام/پلیٹ نمبر *',
      AppLanguage.id: 'Nama / Nomor plat *', AppLanguage.ms: 'Nama / Nombor plat *',
    },
    'field_driver': {
      AppLanguage.ar: 'السائق', AppLanguage.en: 'Driver', AppLanguage.fr: 'Chauffeur', AppLanguage.tr: 'Şoför', AppLanguage.ur: 'ڈرائیور',
      AppLanguage.id: 'Pengemudi', AppLanguage.ms: 'Pemandu',
    },
    'field_capacity': {
      AppLanguage.ar: 'السعة', AppLanguage.en: 'Capacity', AppLanguage.fr: 'Capacité', AppLanguage.tr: 'Kapasite', AppLanguage.ur: 'گنجائش',
      AppLanguage.id: 'Kapasitas', AppLanguage.ms: 'Kapasiti',
    },

    // ===== التقارير =====
    'reports_subtitle': {
      AppLanguage.ar: 'أداء برامجك خلال آخر 6 أشهر', AppLanguage.en: 'Your programs\' performance over the last 6 months',
      AppLanguage.fr: 'Performance de vos programmes au cours des 6 derniers mois',
      AppLanguage.tr: 'Programlarınızın son 6 aydaki performansı', AppLanguage.ur: 'پچھلے 6 مہینوں میں آپ کے پروگراموں کی کارکردگی',
      AppLanguage.id: 'Performa program Anda selama 6 bulan terakhir', AppLanguage.ms: 'Prestasi program anda dalam tempoh 6 bulan lepas',
    },
    'stat_occupancy_rate': {
      AppLanguage.ar: 'معدل الإشغال', AppLanguage.en: 'Occupancy rate', AppLanguage.fr: 'Taux d\'occupation',
      AppLanguage.tr: 'Doluluk oranı', AppLanguage.ur: 'قبضے کی شرح',
      AppLanguage.id: 'Tingkat hunian', AppLanguage.ms: 'Kadar penghunian',
    },
    'stat_customer_satisfaction': {
      AppLanguage.ar: 'رضا العملاء', AppLanguage.en: 'Customer satisfaction', AppLanguage.fr: 'Satisfaction client',
      AppLanguage.tr: 'Müşteri memnuniyeti', AppLanguage.ur: 'کسٹمر اطمینان',
      AppLanguage.id: 'Kepuasan pelanggan', AppLanguage.ms: 'Kepuasan pelanggan',
    },
    'charts_coming_soon': {
      AppLanguage.ar: 'الرسوم البيانية التفصيلية ستظهر هنا قريباً', AppLanguage.en: 'Detailed charts will appear here soon',
      AppLanguage.fr: 'Des graphiques détaillés apparaîtront bientôt ici', AppLanguage.tr: 'Ayrıntılı grafikler yakında burada görünecek',
      AppLanguage.ur: 'تفصیلی چارٹس جلد یہاں ظاہر ہوں گے',
      AppLanguage.id: 'Grafik terperinci akan segera muncul di sini', AppLanguage.ms: 'Carta terperinci akan muncul di sini tidak lama lagi',
    },

    // ===== المستخدمون والمشرفون =====
    'users_subtitle': {
      AppLanguage.ar: 'إدارة فريق العمل وصلاحياته', AppLanguage.en: 'Manage your team and their permissions',
      AppLanguage.fr: 'Gérez votre équipe et ses autorisations', AppLanguage.tr: 'Ekibinizi ve izinlerini yönetin',
      AppLanguage.ur: 'اپنی ٹیم اور ان کی اجازتوں کا نظم کریں',
      AppLanguage.id: 'Kelola tim dan izin mereka', AppLanguage.ms: 'Urus pasukan anda dan kebenaran mereka',
    },
    'search_by_name': {
      AppLanguage.ar: 'بحث بالاسم', AppLanguage.en: 'Search by name', AppLanguage.fr: 'Rechercher par nom',
      AppLanguage.tr: 'Ada göre ara', AppLanguage.ur: 'نام سے تلاش کریں',
      AppLanguage.id: 'Cari berdasarkan nama', AppLanguage.ms: 'Cari mengikut nama',
    },
    'add_user_title': {
      AppLanguage.ar: 'إضافة مستخدم / مشرف', AppLanguage.en: 'Add a user / supervisor',
      AppLanguage.fr: 'Ajouter un utilisateur / superviseur', AppLanguage.tr: 'Kullanıcı / süpervizör ekle',
      AppLanguage.ur: 'صارف/سپروائزر شامل کریں',
      AppLanguage.id: 'Tambah pengguna / supervisor', AppLanguage.ms: 'Tambah pengguna / penyelia',
    },
    'field_email': {
      AppLanguage.ar: 'البريد الإلكتروني', AppLanguage.en: 'Email', AppLanguage.fr: 'E-mail', AppLanguage.tr: 'E-posta', AppLanguage.ur: 'ای میل',
      AppLanguage.id: 'Email', AppLanguage.ms: 'E-mel',
    },
    'roles_multi_label': {
      AppLanguage.ar: 'الأدوار (يمكن اختيار أكثر من دور)', AppLanguage.en: 'Roles (you can select more than one)',
      AppLanguage.fr: 'Rôles (vous pouvez en sélectionner plusieurs)', AppLanguage.tr: 'Roller (birden fazla seçebilirsiniz)',
      AppLanguage.ur: 'کردار (آپ ایک سے زیادہ منتخب کر سکتے ہیں)',
      AppLanguage.id: 'Peran (Anda dapat memilih lebih dari satu)', AppLanguage.ms: 'Peranan (anda boleh memilih lebih daripada satu)',
    },
    'action_save_user': {
      AppLanguage.ar: 'حفظ المستخدم', AppLanguage.en: 'Save user', AppLanguage.fr: 'Enregistrer l\'utilisateur',
      AppLanguage.tr: 'Kullanıcıyı kaydet', AppLanguage.ur: 'صارف کو محفوظ کریں',
      AppLanguage.id: 'Simpan pengguna', AppLanguage.ms: 'Simpan pengguna',
    },
    'tag_manager': {
      AppLanguage.ar: 'مدير', AppLanguage.en: 'Manager', AppLanguage.fr: 'Directeur', AppLanguage.tr: 'Müdür', AppLanguage.ur: 'منیجر',
      AppLanguage.id: 'Manajer', AppLanguage.ms: 'Pengurus',
    },
    'tag_hotel_supervisor_mecca': {
      AppLanguage.ar: 'مشرف فندق مكة', AppLanguage.en: 'Mecca hotel supervisor', AppLanguage.fr: 'Superviseur de l\'hôtel de La Mecque',
      AppLanguage.tr: 'Mekke otel süpervizörü', AppLanguage.ur: 'مکہ ہوٹل سپروائزر',
      AppLanguage.id: 'Supervisor hotel Mekkah', AppLanguage.ms: 'Penyelia hotel Mekah',
    },
    'tag_hotel_supervisor_medina': {
      AppLanguage.ar: 'مشرف فندق المدينة', AppLanguage.en: 'Medina hotel supervisor', AppLanguage.fr: 'Superviseur de l\'hôtel de Médine',
      AppLanguage.tr: 'Medine otel süpervizörü', AppLanguage.ur: 'مدینہ ہوٹل سپروائزر',
      AppLanguage.id: 'Supervisor hotel Madinah', AppLanguage.ms: 'Penyelia hotel Madinah',
    },

    // ===== بيانات الشركة =====
    'company_subtitle': {
      AppLanguage.ar: 'اضغط على الشعار لتغييره، وعدّل اسم الشركة وبيانات التواصل ثم احفظ',
      AppLanguage.en: 'Tap the logo to change it, edit the company name and contact details, then save',
    },
    'field_company_name': {
      AppLanguage.ar: 'اسم الشركة', AppLanguage.en: 'Company name', AppLanguage.fr: 'Nom de l\'entreprise',
      AppLanguage.tr: 'Şirket adı', AppLanguage.ur: 'کمپنی کا نام',
      AppLanguage.id: 'Nama perusahaan', AppLanguage.ms: 'Nama syarikat',
    },
    'field_license_number': {
      AppLanguage.ar: 'رقم الترخيص', AppLanguage.en: 'License number', AppLanguage.fr: 'Numéro de licence',
      AppLanguage.tr: 'Lisans numarası', AppLanguage.ur: 'لائسنس نمبر',
      AppLanguage.id: 'Nomor lisensi', AppLanguage.ms: 'Nombor lesen',
    },
    'field_contact_number': {
      AppLanguage.ar: 'رقم التواصل', AppLanguage.en: 'Contact number', AppLanguage.fr: 'Numéro de contact',
      AppLanguage.tr: 'İletişim numarası', AppLanguage.ur: 'رابطہ نمبر',
      AppLanguage.id: 'Nomor kontak', AppLanguage.ms: 'Nombor hubungan',
    },
    'action_save_changes': {
      AppLanguage.ar: 'حفظ التعديلات', AppLanguage.en: 'Save changes', AppLanguage.fr: 'Enregistrer les modifications',
      AppLanguage.tr: 'Değişiklikleri kaydet', AppLanguage.ur: 'تبدیلیاں محفوظ کریں',
      AppLanguage.id: 'Simpan perubahan', AppLanguage.ms: 'Simpan perubahan',
    },
    'company_saved_snackbar': {
      AppLanguage.ar: 'تم حفظ بيانات الشركة', AppLanguage.en: 'Company details saved', AppLanguage.fr: 'Informations de l\'entreprise enregistrées',
      AppLanguage.tr: 'Şirket bilgileri kaydedildi', AppLanguage.ur: 'کمپنی کی تفصیلات محفوظ ہو گئیں',
      AppLanguage.id: 'Detail perusahaan disimpan', AppLanguage.ms: 'Butiran syarikat disimpan',
    },

    // ===== الإشعارات =====
    'notifications_subtitle': {
      AppLanguage.ar: 'كل تنبيهاتك في مكان واحد', AppLanguage.en: 'All your alerts in one place',
      AppLanguage.fr: 'Toutes vos alertes au même endroit', AppLanguage.tr: 'Tüm uyarılarınız tek yerde',
      AppLanguage.ur: 'آپ کی تمام اطلاعات ایک جگہ',
      AppLanguage.id: 'Semua notifikasi Anda di satu tempat', AppLanguage.ms: 'Semua makluman anda di satu tempat',
    },
    'action_mark_all_read': {
      AppLanguage.ar: 'تحديد الكل كمقروء', AppLanguage.en: 'Mark all as read',
      AppLanguage.fr: 'Tout marquer comme lu', AppLanguage.tr: 'Tümünü okundu işaretle',
      AppLanguage.ur: 'سب کو پڑھا ہوا نشان زد کریں',
      AppLanguage.id: 'Tandai semua sudah dibaca', AppLanguage.ms: 'Tanda semua sebagai dibaca',
    },
    'no_notifications_yet': {
      AppLanguage.ar: 'لا توجد إشعارات حتى الآن', AppLanguage.en: 'No notifications yet',
      AppLanguage.fr: 'Aucune notification pour le moment', AppLanguage.tr: 'Henüz bildirim yok',
      AppLanguage.ur: 'ابھی تک کوئی اطلاع نہیں',
      AppLanguage.id: 'Belum ada notifikasi', AppLanguage.ms: 'Belum ada makluman',
    },
    'time_ago_5_min': {
      AppLanguage.ar: 'منذ 5 دقائق', AppLanguage.en: '5 minutes ago', AppLanguage.fr: 'Il y a 5 minutes',
      AppLanguage.tr: '5 dakika önce', AppLanguage.ur: '5 منٹ پہلے',
      AppLanguage.id: '5 menit yang lalu', AppLanguage.ms: '5 minit yang lalu',
    },
    'time_ago_20_min': {
      AppLanguage.ar: 'منذ 20 دقيقة', AppLanguage.en: '20 minutes ago', AppLanguage.fr: 'Il y a 20 minutes',
      AppLanguage.tr: '20 dakika önce', AppLanguage.ur: '20 منٹ پہلے',
      AppLanguage.id: '20 menit yang lalu', AppLanguage.ms: '20 minit yang lalu',
    },
    'time_ago_3_hours': {
      AppLanguage.ar: 'منذ 3 ساعات', AppLanguage.en: '3 hours ago', AppLanguage.fr: 'Il y a 3 heures',
      AppLanguage.tr: '3 saat önce', AppLanguage.ur: '3 گھنٹے پہلے',
      AppLanguage.id: '3 jam yang lalu', AppLanguage.ms: '3 jam yang lalu',
    },
    'time_ago_1_day': {
      AppLanguage.ar: 'منذ يوم واحد', AppLanguage.en: '1 day ago', AppLanguage.fr: 'Il y a 1 jour',
      AppLanguage.tr: '1 gün önce', AppLanguage.ur: '1 دن پہلے',
      AppLanguage.id: '1 hari yang lalu', AppLanguage.ms: '1 hari yang lalu',
    },

    // ===== "عرض الكل" وأخطاء التحقق من النماذج (كانت نصوص عربية ثابتة) =====
    'see_all': {
      AppLanguage.ar: 'عرض الكل', AppLanguage.en: 'See all', AppLanguage.fr: 'Voir tout',
      AppLanguage.tr: 'Tümünü gör', AppLanguage.ur: 'سب دیکھیں',
      AppLanguage.id: 'Lihat semua', AppLanguage.ms: 'Lihat semua',
    },
    'err_login_required': {
      AppLanguage.ar: 'الرجاء إدخال البيانات المطلوبة وكلمة المرور',
      AppLanguage.en: 'Please enter the required data and password',
      AppLanguage.fr: 'Veuillez saisir les informations requises et le mot de passe',
      AppLanguage.tr: 'Lütfen gerekli bilgileri ve şifreyi girin',
      AppLanguage.ur: 'براہ کرم مطلوبہ معلومات اور پاس ورڈ درج کریں',
      AppLanguage.id: 'Silakan masukkan data yang diperlukan dan kata sandi',
      AppLanguage.ms: 'Sila masukkan data yang diperlukan dan kata laluan',
    },
    'err_hotel_fields_required': {
      AppLanguage.ar: 'الرجاء إدخال اسم الفندق والمدينة والمسافة من الحرم',
      AppLanguage.en: 'Please enter the hotel name, city, and distance from Haram',
      AppLanguage.fr: "Veuillez saisir le nom de l'hôtel, la ville et la distance du Haram",
      AppLanguage.tr: "Lütfen otel adını, şehri ve Harem'e olan mesafeyi girin",
      AppLanguage.ur: 'براہ کرم ہوٹل کا نام، شہر اور حرم سے فاصلہ درج کریں',
      AppLanguage.id: 'Silakan masukkan nama hotel, kota, dan jarak dari Haram',
      AppLanguage.ms: 'Sila masukkan nama hotel, bandar, dan jarak dari Haram',
    },
    'err_trip_load_failed': {
      AppLanguage.ar: 'تعذّر تحميل بيانات البرنامج', AppLanguage.en: 'Failed to load program data',
      AppLanguage.fr: 'Impossible de charger les données du programme',
      AppLanguage.tr: 'Program verileri yüklenemedi',
      AppLanguage.ur: 'پروگرام کا ڈیٹا لوڈ نہیں ہو سکا',
      AppLanguage.id: 'Gagal memuat data program', AppLanguage.ms: 'Gagal memuatkan data program',
    },
    'err_trip_basic_required': {
      AppLanguage.ar: 'الرجاء إدخال اسم البرنامج، مدينة الانطلاق، وعدد الأيام',
      AppLanguage.en: 'Please enter the program name, departure city, and number of days',
      AppLanguage.fr: 'Veuillez saisir le nom du programme, la ville de départ et le nombre de jours',
      AppLanguage.tr: 'Lütfen program adını, kalkış şehrini ve gün sayısını girin',
      AppLanguage.ur: 'براہ کرم پروگرام کا نام، روانگی کا شہر اور دنوں کی تعداد درج کریں',
      AppLanguage.id: 'Silakan masukkan nama program, kota keberangkatan, dan jumlah hari',
      AppLanguage.ms: 'Sila masukkan nama program, bandar berlepas, dan bilangan hari',
    },
    'err_trip_price_required': {
      AppLanguage.ar: 'الرجاء إدخال سعر البرنامج', AppLanguage.en: 'Please enter the program price',
      AppLanguage.fr: 'Veuillez saisir le prix du programme',
      AppLanguage.tr: 'Lütfen program fiyatını girin',
      AppLanguage.ur: 'براہ کرم پروگرام کی قیمت درج کریں',
      AppLanguage.id: 'Silakan masukkan harga program', AppLanguage.ms: 'Sila masukkan harga program',
    },
    'err_select_hotel': {
      AppLanguage.ar: 'الرجاء اختيار الفندق', AppLanguage.en: 'Please select the hotel',
      AppLanguage.fr: "Veuillez sélectionner l'hôtel", AppLanguage.tr: 'Lütfen oteli seçin',
      AppLanguage.ur: 'براہ کرم ہوٹل منتخب کریں',
      AppLanguage.id: 'Silakan pilih hotel', AppLanguage.ms: 'Sila pilih hotel',
    },
    'err_room_number_required': {
      AppLanguage.ar: 'الرجاء إدخال رقم الغرفة', AppLanguage.en: 'Please enter the room number',
      AppLanguage.fr: 'Veuillez saisir le numéro de la chambre',
      AppLanguage.tr: 'Lütfen oda numarasını girin',
      AppLanguage.ur: 'براہ کرم کمرے کا نمبر درج کریں',
      AppLanguage.id: 'Silakan masukkan nomor kamar', AppLanguage.ms: 'Sila masukkan nombor bilik',
    },
    'err_room_number_capacity_required': {
      AppLanguage.ar: 'الرجاء إدخال رقم الغرفة والسعة',
      AppLanguage.en: 'Please enter the room number and capacity',
      AppLanguage.fr: 'Veuillez saisir le numéro et la capacité de la chambre',
      AppLanguage.tr: 'Lütfen oda numarasını ve kapasitesini girin',
      AppLanguage.ur: 'براہ کرم کمرے کا نمبر اور گنجائش درج کریں',
      AppLanguage.id: 'Silakan masukkan nomor dan kapasitas kamar',
      AppLanguage.ms: 'Sila masukkan nombor dan kapasiti bilik',
    },
    'err_bus_number_required': {
      AppLanguage.ar: 'الرجاء إدخال رقم الباص', AppLanguage.en: 'Please enter the bus number',
      AppLanguage.fr: 'Veuillez saisir le numéro du bus',
      AppLanguage.tr: 'Lütfen otobüs numarasını girin',
      AppLanguage.ur: 'براہ کرم بس کا نمبر درج کریں',
      AppLanguage.id: 'Silakan masukkan nomor bus', AppLanguage.ms: 'Sila masukkan nombor bas',
    },
    'err_branch_name_required': {
      AppLanguage.ar: 'الرجاء إدخال اسم الفرع', AppLanguage.en: 'Please enter the branch name',
      AppLanguage.fr: 'Veuillez saisir le nom de la succursale',
      AppLanguage.tr: 'Lütfen şube adını girin',
      AppLanguage.ur: 'براہ کرم برانچ کا نام درج کریں',
      AppLanguage.id: 'Silakan masukkan nama cabang', AppLanguage.ms: 'Sila masukkan nama cawangan',
    },
    'err_name_phone_required': {
      AppLanguage.ar: 'الرجاء إدخال الاسم ورقم الجوال', AppLanguage.en: 'Please enter the name and phone number',
      AppLanguage.fr: 'Veuillez saisir le nom et le numéro de téléphone',
      AppLanguage.tr: 'Lütfen adı ve telefon numarasını girin',
      AppLanguage.ur: 'براہ کرم نام اور فون نمبر درج کریں',
      AppLanguage.id: 'Silakan masukkan nama dan nomor telepon',
      AppLanguage.ms: 'Sila masukkan nama dan nombor telefon',
    },
    'err_password_fields_required': {
      AppLanguage.ar: 'الرجاء إدخال كلمة المرور الحالية والجديدة',
      AppLanguage.en: 'Please enter the current and new password',
      AppLanguage.fr: 'Veuillez saisir le mot de passe actuel et le nouveau',
      AppLanguage.tr: 'Lütfen mevcut ve yeni şifreyi girin',
      AppLanguage.ur: 'براہ کرم موجودہ اور نیا پاس ورڈ درج کریں',
      AppLanguage.id: 'Silakan masukkan kata sandi saat ini dan yang baru',
      AppLanguage.ms: 'Sila masukkan kata laluan semasa dan baharu',
    },
    'err_new_password_min_length': {
      AppLanguage.ar: 'كلمة المرور الجديدة يجب أن تكون 8 أحرف على الأقل',
      AppLanguage.en: 'The new password must be at least 8 characters',
      AppLanguage.fr: 'Le nouveau mot de passe doit comporter au moins 8 caractères',
      AppLanguage.tr: 'Yeni şifre en az 8 karakter olmalıdır',
      AppLanguage.ur: 'نیا پاس ورڈ کم از کم 8 حروف کا ہونا چاہیے',
      AppLanguage.id: 'Kata sandi baru harus minimal 8 karakter',
      AppLanguage.ms: 'Kata laluan baharu mestilah sekurang-kurangnya 8 aksara',
    },
    'err_password_mismatch': {
      AppLanguage.ar: 'تأكيد كلمة المرور غير متطابق', AppLanguage.en: "Password confirmation doesn't match",
      AppLanguage.fr: 'La confirmation du mot de passe ne correspond pas',
      AppLanguage.tr: 'Şifre onayı eşleşmiyor',
      AppLanguage.ur: 'پاس ورڈ کی تصدیق مماثل نہیں ہے',
      AppLanguage.id: 'Konfirmasi kata sandi tidak cocok', AppLanguage.ms: 'Pengesahan kata laluan tidak sepadan',
    },
    'err_user_fields_required': {
      AppLanguage.ar: 'الرجاء إدخال الاسم والبريد الإلكتروني واختيار الدور',
      AppLanguage.en: 'Please enter the name, email, and select a role',
      AppLanguage.fr: "Veuillez saisir le nom, l'e-mail et sélectionner un rôle",
      AppLanguage.tr: 'Lütfen adı, e-postayı girin ve bir rol seçin',
      AppLanguage.ur: 'براہ کرم نام، ای میل درج کریں اور کردار منتخب کریں',
      AppLanguage.id: 'Silakan masukkan nama, email, dan pilih peran',
      AppLanguage.ms: 'Sila masukkan nama, e-mel, dan pilih peranan',
    },
    'err_password_min_length': {
      AppLanguage.ar: 'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
      AppLanguage.en: 'Password must be at least 8 characters',
      AppLanguage.fr: 'Le mot de passe doit comporter au moins 8 caractères',
      AppLanguage.tr: 'Şifre en az 8 karakter olmalıdır',
      AppLanguage.ur: 'پاس ورڈ کم از کم 8 حروف کا ہونا چاہیے',
      AppLanguage.id: 'Kata sandi harus minimal 8 karakter',
      AppLanguage.ms: 'Kata laluan mestilah sekurang-kurangnya 8 aksara',
    },
    'err_role_name_required': {
      AppLanguage.ar: 'اسم الدور مطلوب', AppLanguage.en: 'Role name is required',
      AppLanguage.fr: 'Le nom du rôle est requis', AppLanguage.tr: 'Rol adı gereklidir',
      AppLanguage.ur: 'کردار کا نام درکار ہے',
      AppLanguage.id: 'Nama peran diperlukan', AppLanguage.ms: 'Nama peranan diperlukan',
    },
  };

  static String t(String key, AppLanguage lang) {
    final entry = _dict[key];
    if (entry == null) return key;
    return entry[lang] ?? entry[AppLanguage.ar] ?? key;
  }
}
