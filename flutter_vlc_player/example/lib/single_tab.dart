import 'dart:convert';
// ignore: unused_import
import 'dart:developer';
import 'dart:io';

import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter_vlc_player_example/cam_data_by_date.dart';
import 'package:flutter_vlc_player_example/cams.dart';
import 'package:flutter_vlc_player_example/video_files.dart';
import 'package:flutter_vlc_player_example/vlc_player_with_controls.dart';
import "package:http/http.dart" as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class 


SingleTab extends StatefulWidget {
  @override
  _SingleTabState createState() => _SingleTabState();
}

class _SingleTabState extends State<SingleTab> {
  static const _networkCachingMs = 2000;
  static const _subtitlesFontSize = 30;
  static const _height = 400.0;
  static final DateTime _rangeDate =
      DateTime.now().subtract(const Duration(days: 30));
  static String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final DatePickerController itemScrollController = DatePickerController();
  static bool dateAlreadyScrolled = false;
  Set<DateTime> activeDateSet = {};
  late Future<List<VideoFiles>> futureVideoFiles;

  final _key = GlobalKey<VlcPlayerWithControlsState>();

  // ignore: avoid-late-keyword
  late final VlcPlayerController _controller;

  //

  int selectedVideoIndex = 0;

  Future<File> _loadVideoToFs() async {
    final videoData = await rootBundle.load('assets/cctv_footage.dav');
    final videoBytes = Uint8List.view(videoData.buffer);
    final dir = (await getTemporaryDirectory()).path;
    final temp = File('$dir/temp.file');
    temp.writeAsBytesSync(videoBytes);

    return temp;
  }

  List<Cams> cams = [];
  List<VideoFiles> videoFiles = [];
  List<CamDataByDate> camsByDate = [];

  Future<List<VideoFiles>> pullJsonFromFile() async {
    final dir = (await getTemporaryDirectory()).path;
    final temp = File('$dir/temp.json');
    final json = temp.readAsStringSync();

    final List<VideoFiles> files = filterDate(jsonDecode(json));
    setState(() {
      
    });
    return files;
  }

  Future<List<VideoFiles>> pullJsonData() async {
    activeDateSet =  {};
    cams = [];
    videoFiles = [];
    camsByDate = [];
    try {
      final result =
      await http.get(Uri.parse("http://zeko.greenorange.in/share.json"));

       
      
     final jsonResult = jsonDecode(result.body);
     final dir = (await getTemporaryDirectory()).path;
    final temp = File('$dir/temp.json');
    temp.writeAsStringSync(result.body);
      
      return filterDate(jsonResult);
     
    } catch (exe) {
      return null!;
    }finally{
      setState(() {
      
    });
    }
  }

  List<VideoFiles> filterDate(jsonResult){
    final int camCount = int.parse(jsonResult["cams"].length.toString());

      for (int i = 0; i < camCount; i++) {
        jsonResult["cams"][i].keys.forEach((key) {
          //Cams cam = new Cams(key.toString(),);

          final int fileCount = int.parse(
              jsonResult["cams"][i][key.toString()].length.toString(),);

          for (int j = 0; j < fileCount; j++) {
            jsonResult["cams"][i][key.toString()][j].keys.forEach((videokey) {
              final int videoCount = int.parse(jsonResult["cams"][i][key.toString()]
                      [j][videokey.toString()]
                  .length
                  .toString(),);
              for (int k = 0; k < videoCount; k++) {
                final videoData = jsonResult["cams"][i][key.toString()][j]
                    [videokey.toString()][k];

                final VideoFiles newFile = VideoFiles(
                    camName: key.toString(),
                    videoDate: videokey.toString(),
                    name: videoData["name"].toString(),
                    path: videoData["path"].toString(),
                    type: VideoType.network,);
                videoFiles.add(newFile);
              }
              final CamDataByDate camDataByDate =
                  CamDataByDate(videokey.toString(), videoFiles);
              activeDateSet
                  .add(DateFormat('yyyy-MM-dd').parse(videokey.toString()));
              camsByDate.add(camDataByDate);
            });
          }
          final Cams cam = Cams(jsonResult["comapany_name"].toString(),
              key.toString(), camsByDate,);
          cams.add(cam);
        });
      }
      videoFiles =
          videoFiles.where((i) => i.videoDate == _selectedDate).toList();
    return videoFiles;
  }

  void filterSelectedDate(){
    setState(() {
      futureVideoFiles = pullJsonFromFile();
    });
    
  }

  @override
  void initState() {
    super.initState();
    futureVideoFiles = pullJsonData();
    
    final List<VideoFiles> initVideFile = [];

    const VideoFiles newVideo = VideoFiles(
        name: "init",
        path: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
        type: VideoType.network,);
    initVideFile.add(newVideo);

    final initVideo = initVideFile[selectedVideoIndex];
    switch (initVideo.type) {
      case VideoType.network:
        _controller = VlcPlayerController.network(
          initVideo.path,
          hwAcc: HwAcc.full,
          options: VlcPlayerOptions(
            advanced: VlcAdvancedOptions([
              VlcAdvancedOptions.networkCaching(_networkCachingMs),
            ]),
            subtitle: VlcSubtitleOptions([
              VlcSubtitleOptions.boldStyle(true),
              VlcSubtitleOptions.fontSize(_subtitlesFontSize),
              VlcSubtitleOptions.outlineColor(VlcSubtitleColor.yellow),
              VlcSubtitleOptions.outlineThickness(VlcSubtitleThickness.normal),
              // works only on externally added subtitles
              VlcSubtitleOptions.color(VlcSubtitleColor.navy),
            ]),
            http: VlcHttpOptions([
              VlcHttpOptions.httpReconnect(true),
            ]),
            rtp: VlcRtpOptions([
              VlcRtpOptions.rtpOverRtsp(true),
            ]),
          ),
        );
        break;
      case VideoType.file:
        final file = File(initVideo.path);
        _controller = VlcPlayerController.file(
          file,
        );
        break;
      case VideoType.asset:
        _controller = VlcPlayerController.asset(
          initVideo.path,
          options: VlcPlayerOptions(),
        );
        break;
      case VideoType.recorded:
        break;
    }
    _controller.addOnInitListener(() async {
      await _controller.startRendererScanning();
    });
    _controller.addOnRendererEventListener((type, id, name) {
      debugPrint('OnRendererEventListener $type $id $name');
    });
  }

  void jumpToSelectedDate() {
    if (!dateAlreadyScrolled) itemScrollController.jumpToSelection();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: _height,
          child: VlcPlayerWithControls(
            key: _key,
            controller: _controller,
            onStopRecording: (recordPath) {
              setState(() {
                videoFiles.add(
                  VideoFiles(
                    name: 'Recorded Video',
                    path: recordPath,
                    type: VideoType.recorded,
                  ),
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'The recorded video file has been added to the end of list.',
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 90,
          child: DatePicker(
            _rangeDate,
            initialSelectedDate: DateTime.now(),
            selectionColor: Colors.blue,
            activeDates: activeDateSet.toList(),
            deactivatedColor: Colors.red.shade100,
            
            controller: itemScrollController,
            onDateChange: (date) {
              // New date selected
              setState(() {
                final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
                _selectedDate = formattedDate;
                filterSelectedDate();
              });
            },
          ),
        ),
        FutureBuilder(
          future: futureVideoFiles,
          builder: (context, AsyncSnapshot<List<VideoFiles>> snapshot) {
            jumpToSelectedDate();
            dateAlreadyScrolled = true;
            if (snapshot.hasError) {
              return const SizedBox();
            } else if (snapshot.hasData) {
              final List<VideoFiles> currentVideoFiles = snapshot.data!;
              
              return RefreshIndicator(
                  color: Colors.blue,
                  onRefresh: () async {
                    setState(() {
                      futureVideoFiles = pullJsonData();
                    }); 
                  },
                  child:
                  Stack( children: [ SizedBox(
                height: 300.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currentVideoFiles.length,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final video = currentVideoFiles[index];
                    IconData iconData;
                    switch (video.type) {
                      case VideoType.network:
                        iconData = Icons.camera_alt_rounded;
                        break;
                      case VideoType.file:
                        iconData = Icons.insert_drive_file;
                        break;
                      case VideoType.asset:
                        iconData = Icons.all_inbox;
                        break;
                      case VideoType.recorded:
                        iconData = Icons.videocam;
                        break;
                    }

                    return ListTile(
                      dense: true,
                      selected: selectedVideoIndex == index,
                      selectedTileColor: Colors.black54,
                      leading: Icon(
                        iconData,
                        color: selectedVideoIndex == index
                            ? Colors.blue
                            : Colors.black,
                      ),
                      title: Text(
                        video.camName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selectedVideoIndex == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      subtitle: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: <TextSpan>[
                          TextSpan(text: video.videoDate ),
                          const TextSpan(text: " "),
                          TextSpan(text: video.name, style: const TextStyle(decoration: TextDecoration.underline)),
                          ],
                       
                        style: TextStyle(
                          color: selectedVideoIndex == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      ),
                      onTap: () async {
                        await _controller.stopRecording();
                        switch (video.type) {
                          case VideoType.network:
                            await _controller.setMediaFromNetwork(
                              video.path,
                              hwAcc: HwAcc.full,
                            );
                            break;
                          case VideoType.file:
                            if (!mounted) break;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Copying file to temporary storage...',),
                              ),
                            );
                            await Future<void>.delayed(
                                const Duration(seconds: 1),);
                            final tempVideo = await _loadVideoToFs();
                            await Future<void>.delayed(
                                const Duration(seconds: 1),);
                            if (!mounted) break;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Now trying to play...'),
                              ),
                            );
                            await Future<void>.delayed(
                                const Duration(seconds: 1),);
                            if (await tempVideo.exists()) {
                              await _controller.setMediaFromFile(tempVideo);
                            } else {
                              if (!mounted) break;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('File load error.'),
                                ),
                              );
                            }
                            break;
                          case VideoType.asset:
                            await _controller.setMediaFromAsset(video.path);
                            break;
                          case VideoType.recorded:
                            final recordedFile = File(video.path);
                            await _controller.setMediaFromFile(recordedFile);
                            break;
                        }
                        setState(() {
                          selectedVideoIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),],),
              );
              
            } else {
              return const SizedBox();
            }
          },
        ),
      ],
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _controller.stopRecording();
    await _controller.stopRendererScanning();
    await _controller.dispose();
  }
}
