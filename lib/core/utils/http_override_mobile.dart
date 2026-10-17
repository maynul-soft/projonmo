import 'dart:io';

class AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..userAgent =
          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36'
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void setupHttpOverrides() {
  HttpOverrides.global = AppHttpOverrides();
}
