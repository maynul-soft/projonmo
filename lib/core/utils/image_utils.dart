import 'package:flutter/foundation.dart';

/// Converts an image URL to a CORS-safe URL when running on Flutter Web.
///
/// On Web (CanvasKit / Skwasm renderer), Flutter fetches image bytes via XMLHttpRequest/fetch
/// which strictly enforces Cross-Origin Resource Sharing (CORS). Many third-party image hosts
/// do not provide 'Access-Control-Allow-Origin: *' headers, causing images to fail loading.
///
/// This helper routes external image URLs through a secure, high-speed CDN image proxy (wsrv.nl)
/// only on Flutter Web. On native platforms (Android, iOS, macOS, Windows, Linux), it returns the
/// original URL unchanged.
String getWebSafeImageUrl(String? url) {
  if (url == null) return '';
  final trimmed = url.trim();
  if (trimmed.isEmpty) return '';

  // Only proxy on Flutter Web platform
  if (!kIsWeb) return trimmed;

  // Do not proxy data URIs, blob URIs, localhost / local IP addresses, or already-proxied URLs
  if (trimmed.startsWith('data:') ||
      trimmed.startsWith('blob:') ||
      trimmed.contains('localhost') ||
      trimmed.contains('127.0.0.1') ||
      trimmed.contains('wsrv.nl')) {
    return trimmed;
  }

  // Proxy external HTTP/HTTPS image URLs
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return 'https://wsrv.nl/?url=${Uri.encodeComponent(trimmed)}';
  }

  return trimmed;
}
