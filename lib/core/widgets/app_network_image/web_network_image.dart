// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final Set<String> _registeredImageViews = <String>{};

class AppNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Widget? placeholder;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.placeholder,
  });

  @override
  State<AppNetworkImage> createState() => _WebNetworkImageState();
}

class _WebNetworkImageState extends State<AppNetworkImage> {
  String _viewId = '';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _registerView();
  }

  @override
  void didUpdateWidget(covariant AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl || oldWidget.fit != widget.fit) {
      _registerView();
    }
  }

  void _registerView() {
    final cleanUrl = widget.imageUrl.trim();
    if (cleanUrl.isEmpty) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    _hasError = false;
    final objectFit = widget.fit == BoxFit.contain
        ? 'contain'
        : widget.fit == BoxFit.fill
            ? 'fill'
            : widget.fit == BoxFit.fitWidth
                ? 'scale-down'
                : 'cover';

    final id = 'web-img-${cleanUrl.hashCode.abs()}-$objectFit';
    _viewId = id;

    if (!_registeredImageViews.contains(id)) {
      _registeredImageViews.add(id);
      ui_web.platformViewRegistry.registerViewFactory(
        id,
        (int viewId) {
          final img = html.ImageElement()
            ..src = cleanUrl
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = objectFit
            ..style.border = 'none'
            ..style.pointerEvents = 'none';
          return img;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _viewId.isEmpty) {
      return widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
          );
    }

    Widget content = SizedBox(
      width: widget.width,
      height: widget.height,
      child: HtmlElementView(viewType: _viewId),
    );

    if (widget.borderRadius != null) {
      content = ClipRRect(borderRadius: widget.borderRadius!, child: content);
    }

    return content;
  }
}
