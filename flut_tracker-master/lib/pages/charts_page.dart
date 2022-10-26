import 'package:flut_tracker/domain/chart_data_model.dart';
import 'package:flut_tracker/domain/trakmodel.dart';
import 'package:flut_tracker/helpers/preferences_helper.dart';
import 'package:flut_tracker/helpers/track_database.dart';
import 'package:flut_tracker/widgets/ui_cnst.dart';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({Key key}) : super(key: key);

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  bool isLoading = false;

  List<TrackModel> todayTracks = [];
  List<ChartData> chartData = <ChartData>[];
  bool remoteWork = false;
  PreferencesServiceImpl preferencesService = PreferencesServiceImpl.instance;
  TrackDatabase trackDatabase = TrackDatabase.instance;

  var logger = Logger();

  Future getSaved() async {
    setState(() {
      isLoading = true;
    });
    todayTracks = await TrackDatabase.instance.readTodayTracks();
    remoteWork =
        await preferencesService.getBoolValue(KeysCnst.remoteWork) ?? false;
    chartData = [
      ChartData(
          x: "MOVING",
          y: todayTracks
              .where((element) =>
                  (element.activityType == ActivityType.RUNNING.name) ||
                  (element.activityType == ActivityType.WALKING.name))
              .length),
      ChartData(
          x: ActivityType.STILL.name,
          y: todayTracks
              .where(
                  (element) => element.activityType == ActivityType.STILL.name)
              .length),
    ];
    chartData = List.from(chartData.where((element) => element.y != 0));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SwitchListTile(
                  title: const Text("Remote work"),
                  value: remoteWork,
                  onChanged: (bool newValue) {
                    preferencesService.saveBoolValue(
                        KeysCnst.remoteWork, newValue);
                    setState(() {
                      remoteWork = newValue;
                    });
                  },
                ),
                ListTile(
                  title: const Text("Delete all records"),
                  onTap: () async {
                    await preferencesService.clean();
                    await trackDatabase.deleteAll();
                    setState(() {});
                  },
                  trailing: const Icon(Icons.delete),
                ),
                Expanded(
                    child: todayTracks.isEmpty
                        ? const Center(
                            child: Text(
                              "Nothing to show",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 24),
                            ),
                          )
                        : SfCircularChart(
                            legend: Legend(isVisible: true),
                            title: ChartTitle(
                              text: "Today\'s stats",
                            ),
                            series: <CircularSeries<ChartData, String>>[
                                PieSeries<ChartData, String>(
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                    radius: '70%',
                                    dataLabelSettings: const DataLabelSettings(
                                        isVisible: true,
                                        labelPosition:
                                            ChartDataLabelPosition.outside,
                                        useSeriesColor: true))
                              ])),
              ],
            ),
    ));
  }

  @override
  void initState() {
    super.initState();
    getSaved();
  }
}
