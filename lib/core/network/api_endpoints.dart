import 'package:flutter/foundation.dart';

/// All API URLs and Base URL definitions based on CUSTOMER_API.md and API_GUIDE.md
class ApiEndpoints {
  ApiEndpoints._();

  // ===========================================================================
  // BASE URLS & TIMEOUTS
  // ===========================================================================
  /// Local backend base URL as documented in CUSTOMER_API.md & API_GUIDE.md
  static const String localBaseUrl = 'http://localhost:8001/api/v1';

  /// Android Emulator local backend base URL
  // static const String androidEmulatorBaseUrl = 'http://10.0.2.2:8001/api/v1';
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:8001/api/v1';

  /// Production backend base URL
  static const String productionBaseUrl = 'https://api.projonmo.tech/api/v1';

  /// Active default base URL
  /// Automatically uses Production (`https://api.tecqora.com/api/v1`) in Release builds (`flutter build apk`).
  /// Uses Local / Emulator URL in Debug Mode (`flutter run`).
  /// Supports optional command line override: `--dart-define=BASE_URL=https://your-domain.com/api/v1`
  static String get defaultBaseUrl {
    const envBaseUrl = String.fromEnvironment('BASE_URL');
    if (envBaseUrl.isNotEmpty) return envBaseUrl;

    if (kIsWeb && kDebugMode) return localBaseUrl;
    if (kDebugMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return androidEmulatorBaseUrl;
      }
      return localBaseUrl;
    }
    return productionBaseUrl;
  }

  /// Default Request Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ===========================================================================
  // 1. SYSTEM & HEALTH
  // ===========================================================================
  static const String root = '/';
  static const String health = '/health';

  // ===========================================================================
  // 2. PUBLIC API (No Auth - Maintenance-aware 503)
  // ===========================================================================
  static const String publicHome = '/public/home';
  static const String publicBanners = '/public/banners';
  static const String publicFaqs = '/public/faqs';
  static const String publicRules = '/public/rules';
  static const String publicVideos = '/public/videos';
  static const String publicPosts = '/public/posts';
  static const String publicLuckyGifts = '/public/lucky-gifts';
  static const String publicAnnouncementPopup = '/public/announcement-popup';
  static const String publicAppDownload = '/public/app-download';
  static const String publicTelegram = '/public/telegram';
  static const String publicCategories = '/public/categories';
  static const String publicProducts = '/public/products';
  static String publicProductDetail(String id) => '/public/products/$id';
  static const String publicCalculatorSettings = '/public/calculator-settings';

  // ===========================================================================
  // 3. CUSTOMER AUTH API (No Bearer token - Maintenance-aware 503)
  // ===========================================================================
  static const String customerSendOtp = '/customer/auth/send-otp';
  static const String customerVerifyOtp = '/customer/auth/verify-otp';
  static const String customerRegister = '/customer/auth/register';
  static const String customerLogin = '/customer/auth/login';
  static const String customerRefreshToken = '/customer/auth/refresh';

  // ===========================================================================
  // 4. CUSTOMER PROTECTED API (Requires Header: Authorization: Bearer <accessToken>)
  // ===========================================================================
  // Profile & Security
  static const String customerMe = '/customer/me';
  static const String customerChangePassword = '/customer/me/password';
  static const String customerSignOut = '/customer/auth/sign-out';
  static const String customerDashboard = '/customer/dashboard';

  // Products & Contracts
  static const String customerMyProducts = '/customer/products/mine';
  static const String customerPurchaseProduct = '/customer/products/purchase';
  static String customerPurchaseProductById(String id) => '/customer/products/$id/purchase';

  // Deposits & Payment Methods
  static const String customerPaymentMethods = '/customer/payment-methods';
  static const String customerDeposits = '/customer/deposits';
  static const String customerTransactions = '/customer/transactions';

  // Withdrawals & Bank Accounts
  static const String customerWithdrawalMethods = '/customer/withdrawal-methods';
  static String customerDeleteWithdrawalMethod(String id) => '/customer/withdrawal-methods/$id';
  static const String customerWithdrawals = '/customer/withdrawals';
  static const String customerWithdrawalSendOtp = '/customer/withdrawals/send-otp';
  static const String customerWithdrawalPreview = '/customer/withdrawals/preview';

  // Team & Income
  static const String customerTeam = '/customer/team';
  static const String customerIncome = '/customer/income';

  // Salary & VIP Levels
  static const String customerSalaryWeekly = '/customer/salary/weekly';
  static const String customerSalaryMonthly = '/customer/salary/monthly';
  static const String customerSalaryAnnual = '/customer/salary/annual';
  static const String customerSalaryClaim = '/customer/salary/claim';
  static const String customerVipLevels = '/customer/vip/levels';

  // Points & Rewards
  static const String customerPoints = '/customer/points';
  static const String customerPointsConvert = '/customer/points/convert';
  static const String customerPointsRedeem = '/customer/points/redeem';

  // Uploads
  static const String customerUploads = '/customer/uploads';

  // ===========================================================================
  // 5. ADMIN AUTH & COMMON (Bearer admin)
  // ===========================================================================
  static const String adminLogin = '/auth/login';
  static const String adminUploads = '/uploads';
  static const String adminMe = '/admin/me';
  static const String adminChangePassword = '/admin/me/password';

  // ===========================================================================
  // 6. ADMIN PANEL APIS (Bearer admin)
  // ===========================================================================
  // Dashboard
  static const String adminDashboard = '/admin/dashboard';
  static const String adminPendingDeposits = '/admin/dashboard/pending-deposits';
  static const String adminPendingWithdrawals = '/admin/dashboard/pending-withdrawals';

  // Users
  static const String adminUsers = '/admin/users';
  static String adminUserDetail(String id) => '/admin/users/$id';
  static String adminUserStatus(String id) => '/admin/users/$id/status';

  // Categories
  static const String adminCategories = '/admin/categories';
  static String adminCategory(String id) => '/admin/categories/$id';

  // Products
  static const String adminProducts = '/admin/products';
  static String adminProduct(String id) => '/admin/products/$id';

  // Deposits & Withdrawals Review
  static const String adminDeposits = '/admin/deposits';
  static String adminReviewDeposit(String id) => '/admin/deposits/$id';
  static const String adminWithdrawals = '/admin/withdrawals';
  static String adminReviewWithdrawal(String id) => '/admin/withdrawals/$id';

  // Settings & Content
  static const String adminPaymentMethods = '/admin/payment-methods';
  static String adminPaymentMethod(String id) => '/admin/payment-methods/$id';
  static const String adminBanners = '/admin/banners';
  static String adminBanner(String id) => '/admin/banners/$id';
  static const String adminVideos = '/admin/videos';
  static String adminVideo(String id) => '/admin/videos/$id';
  static const String adminFaqs = '/admin/faqs';
  static String adminFaq(String id) => '/admin/faqs/$id';
  static const String adminRules = '/admin/rules';
  static String adminRule(String id) => '/admin/rules/$id';
  static const String adminPosts = '/admin/posts';
  static String adminPost(String id) => '/admin/posts/$id';
  static const String adminLuckyGifts = '/admin/lucky-gifts';
  static String adminLuckyGift(String id) => '/admin/lucky-gifts/$id';
  static const String adminSettings = '/admin/settings';
  static String adminSetting(String key) => '/admin/settings/$key';
}
