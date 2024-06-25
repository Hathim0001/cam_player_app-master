import 'package:flutter_vlc_player_example/video_files.dart';

class CamDataByDate {
  final String date;
  final List<VideoFiles> videoFiles;

  const CamDataByDate(
    this.date,
    this.videoFiles,
  );
}