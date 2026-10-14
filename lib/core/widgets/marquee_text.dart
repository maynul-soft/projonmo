import 'package:flutter/material.dart';

/// A smooth, zero-dependency horizontal marquee widget for announcements and notices.
/// Automatically scrolls text from right to left in a continuous loop.
class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double velocity; // Pixels per second
  final double blankSpace; // Space between repetitions
  final Duration pauseAfterRound;

  const MarqueeText({
    super.key,
    required this.text,
    this.style,
    this.velocity = 35.0,
    this.blankSpace = 48.0,
    this.pauseAfterRound = const Duration(milliseconds: 1000),
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  @override
  void didUpdateWidget(covariant MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
      _startScrolling();
    }
  }

  Future<void> _startScrolling() async {
    if (!mounted || _isScrolling) return;
    _isScrolling = true;

    while (mounted) {
      if (!_scrollController.hasClients) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll <= 0) {
        // Text fits completely in available width; re-check after brief delay
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }

      // Calculate duration based on velocity
      final durationMs = ((maxScroll - _scrollController.offset) / widget.velocity * 1000).toInt();
      if (durationMs <= 0) {
        _scrollController.jumpTo(0.0);
        continue;
      }

      try {
        await _scrollController.animateTo(
          maxScroll,
          duration: Duration(milliseconds: durationMs),
          curve: Curves.linear,
        );

        if (!mounted) break;
        await Future.delayed(widget.pauseAfterRound);

        if (!mounted) break;
        _scrollController.jumpTo(0.0);
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (_) {
        break;
      }
    }
    _isScrolling = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: widget.style,
                maxLines: 1,
              ),
              SizedBox(width: widget.blankSpace),
              Text(
                widget.text,
                style: widget.style,
                maxLines: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
