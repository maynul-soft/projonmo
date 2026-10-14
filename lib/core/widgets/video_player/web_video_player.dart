// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class PlatformVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool loop;
  final bool showControls;

  const PlatformVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = true,
    this.loop = true,
    this.showControls = true,
  });

  @override
  State<PlatformVideoPlayer> createState() => _PlatformVideoPlayerState();
}

class _PlatformVideoPlayerState extends State<PlatformVideoPlayer> {
  late final String _viewId;
  html.Element? _element;

  String _getYouTubeEmbedUrl(String url) {
    // If it's already an embed URL
    if (url.contains('youtube.com/embed/')) {
      final glue = url.contains('?') ? '&' : '?';
      return '$url${glue}autoplay=${widget.autoPlay ? 1 : 0}&enablejsapi=1&rel=0';
    }

    // Match youtube.com/watch?v=ID or youtu.be/ID
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.group(1) != null) {
      final videoId = match.group(1)!;
      return 'https://www.youtube.com/embed/$videoId?autoplay=${widget.autoPlay ? 1 : 0}&rel=0';
    }

    return url;
  }

  bool _isYouTube(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  @override
  void initState() {
    super.initState();
    _viewId = 'video-element-${DateTime.now().microsecondsSinceEpoch}';

    if (_isYouTube(widget.videoUrl)) {
      final embedUrl = _getYouTubeEmbedUrl(widget.videoUrl);
      _element = html.IFrameElement()
        ..src = embedUrl
        ..style.border = 'none'
        ..style.height = '100%'
        ..style.width = '100%'
        ..setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture')
        ..setAttribute('allowfullscreen', 'true');
    } else {
      final videoElem = html.VideoElement()
        ..src = widget.videoUrl
        ..autoplay = widget.autoPlay
        ..controls = widget.showControls
        ..loop = widget.loop
        ..setAttribute('playsinline', 'true')
        ..style.border = 'none'
        ..style.height = '100%'
        ..style.width = '100%'
        ..style.objectFit = 'cover'
        ..style.backgroundColor = '#000000';

      if (widget.autoPlay) {
        videoElem.play().catchError((_) {
          videoElem.muted = true;
          videoElem.play().catchError((_) {});
        });
      }
      _element = videoElem;
    }

    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int id) => _element!,
    );
  }

  @override
  void dispose() {
    if (_element is html.VideoElement) {
      final v = _element as html.VideoElement;
      v.pause();
      v.src = '';
    } else if (_element is html.IFrameElement) {
      final iframe = _element as html.IFrameElement;
      iframe.src = '';
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
