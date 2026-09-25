import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../date_planner_controller.dart';
import 'date_planner_loading.dart';

/// Screen displayed while the backend designs the itinerary.
///
/// Loops the EverUs loading animation until the real API call returns (the parent
/// swaps this widget out as soon as [DatePlannerController.isGenerating] flips), and
/// falls back to the [DatePlannerLoading] spinner if the video cannot play.
class DatePlannerGenerating extends StatefulWidget {
  static const String videoAsset = 'assets/videos/animation.mp4';

  /// The state controller driving the generation.
  final DatePlannerController controller;

  /// Const constructor for [DatePlannerGenerating].
  const DatePlannerGenerating({super.key, required this.controller});

  @override
  State<DatePlannerGenerating> createState() => _DatePlannerGeneratingState();
}

class _DatePlannerGeneratingState extends State<DatePlannerGenerating> {
  VideoPlayerController? _video;
  bool _videoFailed = false;

  @override
  void initState() {
    super.initState();
    _startVideo();
  }

  Future<void> _startVideo() async {
    try {
      final video = VideoPlayerController.asset(
        DatePlannerGenerating.videoAsset,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _video = video;
      await video.initialize();
      await video.setLooping(true);
      await video.setVolume(0);
      await video.play();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Loading animation unavailable, using spinner: $e");
      if (mounted) setState(() => _videoFailed = true);
    }
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = _video;
    if (_videoFailed || video == null) {
      return const DatePlannerLoading();
    }
    if (!video.value.isInitialized) {
      return const SizedBox.expand();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: AspectRatio(
                  aspectRatio: video.value.aspectRatio,
                  child: VideoPlayer(video),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'EverUs đang lên lộ trình...',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5A384C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
