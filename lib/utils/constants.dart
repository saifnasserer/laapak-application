/// App Constants
///
/// Centralized constants for the Laapak mobile app.
/// Includes API endpoints, error messages, and configuration values.
class AppConstants {
  AppConstants._();

  // ==================== API Configuration ====================

  /// Base URL for API Key endpoints
  static const String apiKeyBaseUrl =
      'https://reports.laapak.com/api/v2/external';

  /// Base URL for JWT endpoints
  static const String jwtBaseUrl = 'https://reports.laapak.com/api';

  /// Development base URL
  static const String devBaseUrl = 'http://localhost:3000/api';

  /// WooCommerce/WordPress base URL
  static const String wooCommerceBaseUrl = 'https://laapak.com';

  // ==================== WooCommerce API Credentials ====================
  // Note: These credentials are used for WooCommerce API integration.
  // They are read-only credentials for accessing product data and do not expose sensitive operations.
  static const String wooCommerceConsumerKey =
      'ck_a00837182f934a0f93d63877b3e33e127cefc11b';
  static const String wooCommerceConsumerSecret =
      'cs_2186f8d150aa716f9c6b3d1c66e9c96f5e6b209d';

  // ==================== API Endpoints ====================

  /// Health check endpoint
  static const String endpointHealth = '/health';

  /// Admin login endpoint
  static const String endpointAdminLogin = '/auth/login';

  /// Client login endpoint
  static const String endpointClientLogin = '/clients/auth';

  /// Verify client endpoint
  static const String endpointVerifyClient = '/auth/verify-client';

  /// Client profile endpoint
  static String endpointClientProfile(int clientId) => '/clients/$clientId/profile';

  /// All clients endpoint
  static const String endpointAllClients = '/clients';

  /// Single client endpoint
  static String endpointClient(int clientId) => '/clients/$clientId';

  /// Client reports endpoint
  static String endpointClientReports(int clientId) => '/clients/$clientId/reports';

  /// My reports endpoint (authenticated client)
  static const String endpointMyReports = '/reports/me';

  /// All reports endpoint
  static const String endpointAllReports = '/reports';

  /// Single report endpoint
  static String endpointReport(String reportId) => '/reports/$reportId';

  /// Search reports endpoint
  static const String endpointSearchReports = '/reports/search';

  /// Client invoices endpoint
  static String endpointClientInvoices(int clientId) => '/clients/$clientId/invoices';

  /// Single invoice endpoint
  static String endpointInvoice(String invoiceId) => '/invoices/$invoiceId';

  /// Invoice print endpoint
  static String endpointInvoicePrint(String invoiceId) => '/invoices/$invoiceId/print';

  /// All invoices endpoint
  static const String endpointAllInvoices = '/invoices';

  /// Bulk invoice endpoint
  static const String endpointBulkInvoice = '/invoices/bulk';

  /// Bulk client lookup endpoint
  static const String endpointBulkLookupClients = '/clients/bulk-lookup';

  /// Client data export endpoint
  static String endpointClientDataExport(int clientId) => '/clients/$clientId/data-export';

  // ==================== Storage Keys ====================

  /// Auth token storage key
  static const String storageKeyToken = 'auth_token';

  /// Client data storage key
  static const String storageKeyClient = 'client_data';

  // ==================== Error Messages (Arabic) ====================

  /// Generic error messages
  static const String errorGeneric = 'حدث خطأ غير متوقع';
  static const String errorNetwork = 'مشكلة في الاتصال بالإنترنت';
  static const String errorTimeout = 'انتهت مهلة الاتصال. حاول مرة أخرى';
  static const String errorServer = 'خطأ في الخادم. حاول مرة أخرى لاحقاً';
  static const String errorUnauthorized = 'غير مصرح لك بالوصول';
  static const String errorNotFound = 'لم يتم العثور على المورد المطلوب';
  static const String errorInvalidResponse = 'استجابة غير صحيحة من الخادم';

  /// Authentication errors
  static const String errorLoginFailed = 'فشل تسجيل الدخول';
  static const String errorInvalidCredentials = 'بيانات الدخول غير صحيحة';
  static const String errorSessionExpired = 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى';
  static const String errorTokenExpired = 'انتهت صلاحية الجلسة';

  /// Validation errors
  static const String errorPhoneRequired = 'لو سمحت أدخل رقم التليفون';
  static const String errorPhoneInvalid = 'رقم التليفون مش صحيح';
  static const String errorOrderCodeRequired = 'لو سمحت أدخل كود الطلب';
  static const String errorOrderCodeInvalid = 'كود الطلب غير صحيح';

  /// Report errors
  static const String errorReportNotFound = 'التقرير غير موجود';
  static const String errorReportLoadFailed = 'فشل تحميل التقرير';
  static const String errorReportsLoadFailed = 'فشل تحميل التقارير';

  /// Invoice errors
  static const String errorInvoiceNotFound = 'الفاتورة غير موجودة';
  static const String errorInvoiceLoadFailed = 'فشل تحميل الفاتورة';
  static const String errorInvoiceNotAvailable = 'لا توجد فاتورة متاحة لهذا التقرير';

  /// Video errors
  static const String errorVideoLoadFailed = 'فشل تحميل الفيديو';
  static const String errorVideoTimeout = 'انتهت مهلة التحميل. تحقق من الاتصال بالإنترنت';
  static const String errorVideoFormat = 'تنسيق الفيديو غير مدعوم';

  /// Image errors
  static const String errorImageLoadFailed = 'فشل تحميل الصورة';

  /// Device errors
  static const String errorDeviceInfoLoadFailed = 'فشل تحميل بيانات الجهاز';

  // ==================== Success Messages (Arabic) ====================

  static const String successLogin = 'تم تسجيل الدخول بنجاح';
  static const String successLogout = 'تم تسجيل الخروج بنجاح';
  static const String successNotificationSent = 'تم إرسال الإشعار التجريبي';

  // ==================== Validation Patterns ====================

  /// Egyptian phone number pattern (10-11 digits, may start with 0 or country code)
  static final RegExp phonePattern = RegExp(r'^(?:\+20|0)?1[0-9]{9}$');

  /// Order code pattern (alphanumeric, 4-20 characters)
  static final RegExp orderCodePattern = RegExp(r'^[A-Za-z0-9]{4,20}$');

  // ==================== Timeouts ====================

  /// Default API request timeout
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Video loading timeout
  static const Duration videoTimeout = Duration(seconds: 30);

  /// Image loading timeout
  static const Duration imageTimeout = Duration(seconds: 15);

  // ==================== Retry Configuration ====================

  /// Maximum number of retry attempts
  static const int maxRetries = 3;

  /// Initial retry delay
  static const Duration initialRetryDelay = Duration(seconds: 1);

  /// Maximum retry delay
  static const Duration maxRetryDelay = Duration(seconds: 10);

  // ==================== Pagination ====================

  /// Default page limit
  static const int defaultPageLimit = 50;

  /// Maximum page limit
  static const int maxPageLimit = 100;

  // ==================== Cache Configuration ====================

  /// Image cache max age
  static const Duration imageCacheMaxAge = Duration(days: 7);

  /// Video cache max age
  static const Duration videoCacheMaxAge = Duration(days: 3);

  /// API response cache max age
  static const Duration apiCacheMaxAge = Duration(minutes: 5);

  // ==================== UI Constants ====================

  /// Snackbar duration
  static const Duration snackbarDuration = Duration(seconds: 3);

  /// Long snackbar duration
  static const Duration snackbarDurationLong = Duration(seconds: 5);

  /// Animation duration
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Debounce delay for search
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);

  // ==================== Deep Link Paths ====================

  /// Deep link path for reports
  static const String deepLinkReports = '/reports';

  /// Deep link path for warranty
  static const String deepLinkWarranty = '/warranty';

  /// Deep link path for invoices
  static const String deepLinkInvoices = '/invoices';

  // ==================== Share Configuration ====================

  /// App name for sharing
  static const String appName = 'Laapak';

  /// App website URL
  static const String appWebsite = 'https://laapak.com';

  // ==================== Notification IDs ====================

  /// Test notification ID
  static const int notificationIdTest = 0;

  /// Report update notification ID base
  static const int notificationIdReportBase = 1000;

  /// Invoice notification ID base
  static const int notificationIdInvoiceBase = 2000;

  // ==================== Contact Information ====================

  /// WhatsApp support phone number (Egyptian format)
  static const String whatsappPhoneNumber = '+201013148007';

  /// Support email address
  static const String supportEmail = 'support@laapak.com';
}


