export 'mobile_video_player.dart'
    if (dart.library.html) 'web_video_player.dart'
    if (dart.library.js_interop) 'web_video_player.dart';
