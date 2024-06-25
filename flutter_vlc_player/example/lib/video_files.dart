class VideoFiles {
  final String name;
  final String path;
  final VideoType type;
  final String videoDate;
  final String camName;

  const VideoFiles({
    required this.name, required this.path, required this.type, this.camName = "",
    this.videoDate = "",
  }
  );
}

enum VideoType {
  asset,
  file,
  network,
  recorded,
}