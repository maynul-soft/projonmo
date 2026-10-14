import 'package:flutter/material.dart';

class PlatformVideoPlayer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 48),
          SizedBox(height: 8),
          Text(
            'Playing Video...',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
