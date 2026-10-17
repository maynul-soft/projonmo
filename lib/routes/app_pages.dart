import 'package:get/get.dart';
import '../core/network/network.dart';
import '../features/splash/controllers/splash_controller.dart';
import '../features/splash/views/splash_view.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/views/login_view.dart';
import '../features/auth/views/register_view.dart';
import '../features/calculator/controllers/calculator_controller.dart';
import '../features/calculator/views/calculator_view.dart';
import '../features/check_in/controllers/check_in_controller.dart';
import '../features/check_in/views/check_in_view.dart';
import '../features/home/controllers/home_controller.dart';
import '../features/home/views/annual_salary_view.dart';
import '../features/home/views/download_app_view.dart';
import '../features/home/views/faq_view.dart';
import '../features/home/views/invitation_view.dart';
import '../features/home/views/monthly_salary_view.dart';
import '../features/home/views/notification_view.dart';
import '../features/home/views/rule_view.dart';
import '../features/home/views/weekly_salary_view.dart';
import '../features/main_nav/controllers/main_nav_controller.dart';
import '../features/main_nav/views/main_nav_view.dart';
import '../features/my_products/controllers/my_products_controller.dart';
import '../features/my_products/views/my_products_view.dart';
import '../features/my_teams/controllers/daily_commission_controller.dart';
import '../features/my_teams/controllers/team_controller.dart';
import '../features/my_teams/views/daily_commission_view.dart';
import '../features/my_teams/views/my_teams_view.dart';
import '../features/post/controllers/post_controller.dart';
import '../features/post/views/post_detail_view.dart';
import '../features/product/controllers/product_controller.dart';
import '../features/product/views/product_detail_view.dart';
import '../features/profile/controllers/profile_controller.dart';
import '../features/profile/views/change_password_view.dart';
import '../features/wallet/controllers/wallet_controller.dart';
import '../features/wallet/views/bank_account_view.dart';
import '../features/wallet/views/funding_details_view.dart';
import '../features/wallet/views/recharge_view.dart';
import '../features/wallet/views/withdraw_view.dart';
import '../features/wallet/views/withdraw_otp_view.dart';
import '../features/profile/views/points_convert_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final initialBinding = BindingsBuilder(() {
    Get.put<ApiClient>(ApiClient.instance, permanent: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
  });

  static final routes = [
    GetPage(
      name: AppRoutes.initial,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put<SplashController>(SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put<SplashController>(SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      }),
    ),
    GetPage(
      name: '${AppRoutes.register}/:id',
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainNavView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        Get.lazyPut<MainNavController>(() => MainNavController(), fenix: true);
        Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
        Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
        Get.lazyPut<PostController>(() => PostController(), fenix: true);
        Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
        Get.lazyPut<MyProductsController>(() => MyProductsController(), fenix: true);
        Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.myProducts,
      page: () => const MyProductsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
        Get.lazyPut<MyProductsController>(() => MyProductsController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.checkIn,
      page: () => const CheckInView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CheckInController>(() => CheckInController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.calculator,
      page: () => const CalculatorView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CalculatorController>(() => CalculatorController(), fenix: true);
        Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.myTeams,
      page: () => const MyTeamsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TeamController>(() => TeamController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.dailyCommission,
      page: () => const DailyCommissionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DailyCommissionController>(() => DailyCommissionController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.postDetail,
      page: () => const PostDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PostController>(() => PostController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.recharge,
      page: () => const RechargeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
        Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.withdraw,
      page: () => const WithdrawView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
        Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.withdrawOtp,
      page: () => const WithdrawOtpView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.pointsConvert,
      page: () => const PointsConvertView(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationView(),
    ),
    GetPage(
      name: AppRoutes.fundingDetails,
      page: () => const FundingDetailsView(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.bankAccount,
      page: () => const BankAccountView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.weeklySalary,
      page: () => const WeeklySalaryView(),
    ),
    GetPage(
      name: AppRoutes.monthlySalary,
      page: () => const MonthlySalaryView(),
    ),
    GetPage(
      name: AppRoutes.annualSalary,
      page: () => const AnnualSalaryView(),
    ),
    GetPage(
      name: AppRoutes.faq,
      page: () => const FaqView(),
    ),
    GetPage(
      name: AppRoutes.rule,
      page: () => const RuleView(),
    ),
    GetPage(
      name: AppRoutes.downloadApp,
      page: () => const DownloadAppView(),
    ),
    GetPage(
      name: AppRoutes.invitation,
      page: () => const InvitationView(),
    ),
  ];
}
