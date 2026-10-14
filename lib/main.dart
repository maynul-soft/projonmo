import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_assets.dart';
import 'core/constants/app_strings.dart';
import 'core/network/network.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await TokenStorage.instance.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DelMonteApp());
}

class DelMonteApp extends StatelessWidget {
  const DelMonteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      initialBinding: AppPages.initialBinding,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Global background image for entire application
            Image.asset(
              AppAssets.scaffoldBackground,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            ?child,
          ],
        );
      },
    );
  }
}
