import 'package:flutter_vlc_player_example/cam_data_by_date.dart';

class Cams{
  final String comapany_name;
  final String cams;
  final List<CamDataByDate> dateList;

  const Cams(
    this.comapany_name,
    this.cams,
    this.dateList,
  );
  
}