import 'http_override_mobile.dart'
    if (dart.library.html) 'http_override_web.dart'
    if (dart.library.js_interop) 'http_override_web.dart';

void initHttpOverrides() {
  setupHttpOverrides();
}
