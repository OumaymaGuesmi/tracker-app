import 'package:flut_tracker/domain/trakmodel.dart';
import 'package:flut_tracker/helpers/track_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class ActivityHistory extends StatefulWidget {
  const ActivityHistory({Key key}) : super(key: key);

  @override
  State<ActivityHistory> createState() => _ActivityHistoryState();
}

class _ActivityHistoryState extends State<ActivityHistory> {
  TrackDatabase trackDatabase = TrackDatabase.instance;
  var logger = Logger();
  List<TrackModel> allTracks = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getSaved();
  }

  Future getSaved() async {
    setState(() {
      isLoading = true;
    });
    allTracks = await trackDatabase.readAllTracks();
    allTracks = List.from(allTracks.reversed);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity history"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        titleTextStyle: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.w500, fontSize: 24),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : allTracks.isEmpty
                ? const Center(
                    child: Text(
                      "Nothing to show",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
                    ),
                  )
                : ListView.builder(
                    itemCount: allTracks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(allTracks[index].activityType),
                        subtitle: Text(DateFormat.yMd()
                            .add_Hm()
                            .format(DateTime.fromMicrosecondsSinceEpoch(
                                allTracks[index].timestamp * 1000))
                            .toString()),
                        trailing: statusIcon(allTracks[index].activityType),
                      );
                    },
                  ),
      ),
    );
  }

  Icon statusIcon(String activityType) {
    ActivityType type = ActivityType.values.byName(activityType);
    switch (type) {
      case ActivityType.RUNNING:
      case ActivityType.WALKING:
        return const Icon(
          Icons.directions_run,
          color: Colors.green,
        );
        break;
      case ActivityType.STILL:
        return const Icon(
          Icons.stop_circle,
          color: Colors.red,
        );
        break;
      case ActivityType.IN_VEHICLE:
      case ActivityType.ON_BICYCLE:
      case ActivityType.UNKNOWN:
        return null;
        break;
      default:
        return null;
    }
  }
}
