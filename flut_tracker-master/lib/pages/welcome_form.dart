import 'dart:async';

import 'package:flut_tracker/domain/days.dart';
import 'package:flut_tracker/domain/trakmodel.dart';
import 'package:flut_tracker/helpers/notification_service.dart';
import 'package:flut_tracker/helpers/preferences_helper.dart';
import 'package:flut_tracker/helpers/track_database.dart';
import 'package:flut_tracker/widgets/common_widgets.dart';
import 'package:flut_tracker/widgets/ui_cnst.dart';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:timezone/data/latest.dart' as tz;

class WelcomeForm extends StatefulWidget {
  const WelcomeForm({Key key}) : super(key: key);

  @override
  State<WelcomeForm> createState() => _WelcomeFormState();
}

class _WelcomeFormState extends State<WelcomeForm> {
  TextEditingController workStartController = TextEditingController();
  TextEditingController workEndController = TextEditingController();
  TextEditingController breakStartController = TextEditingController();
  TextEditingController breakEndController = TextEditingController();

  PreferencesServiceImpl preferencesService = PreferencesServiceImpl.instance;
  TrackDatabase trackDatabase = TrackDatabase.instance;
  List<Days> daysRetrieved = [];
  bool isLoading = false;
  List<TrackModel> allTracks = [];

  bool remoteWork = false;

  var logger = Logger();

  final _activityStreamController = StreamController<Activity>();
  StreamSubscription<Activity> _activityStreamSubscription;

  void _onActivityReceive(Activity activity) {
    logger.i('Activity Detected >> ${activity.toJson()}');
    _activityStreamController.sink.add(activity);
    final newActivity = TrackModel(
        activityType: activity.type.name,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        confidence: activity.confidence.name);
    trackDatabase.create(newActivity);
  }

  void _handleError(dynamic error) {
    logger.e('Catch Error >> $error');
  }

  @override
  void initState() {
    super.initState();
    getSaved();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      final activityRecognition = FlutterActivityRecognition.instance;
      _activityStreamSubscription = activityRecognition.activityStream
          .handleError(_handleError)
          .listen(_onActivityReceive);
    });
  }

  @override
  void dispose() {
    _activityStreamController.close();
    _activityStreamSubscription?.cancel();
    super.dispose();
  }

  Future getSaved() async {
    setState(() {
      isLoading = true;
    });
    tz.initializeTimeZones();

    daysRetrieved = await preferencesService.getAvailableDays();
    allTracks = await TrackDatabase.instance.readAllTracks();
    workStartController.text =
        await preferencesService.getStringValue(KeysCnst.workStartTime);
    workEndController.text =
        await preferencesService.getStringValue(KeysCnst.workEndTime);
    breakStartController.text =
        await preferencesService.getStringValue(KeysCnst.breakStartTime);
    breakEndController.text =
        await preferencesService.getStringValue(KeysCnst.breakEndTime);
    remoteWork =
        await preferencesService.getBoolValue(KeysCnst.remoteWork) ?? false;
    setState(() {
      isLoading = false;
    });

    if (breakStartController.text.isNotEmpty) {
      final difference = differenceTime(breakStartController.text).inMinutes;
      logger.i(difference);
      if (difference > 0 && difference < 20) {
        logger.i("sending notification");
        NotificationService().showNotification(
          id: 1,
          title: "Break Time",
          body: "You have a break in $difference minutes",
          // duration: Duration(minutes: difference)
        );
      }
    }
    if (breakEndController.text.isNotEmpty) {
      final difference = differenceTime(breakEndController.text).inSeconds;
      if (difference > 0) {
        NotificationService().showNotification(
            id: 1,
            title: "Break Time",
            body: "Time to back to work",
            duration: Duration(seconds: difference));
      }
    }

    if (allTracks.isNotEmpty) {
      final difference = differenceDate(
          DateTime.fromMicrosecondsSinceEpoch(allTracks.last.timestamp * 1000));
      print(allTracks.last.toJson());
      print(
          DateTime.fromMicrosecondsSinceEpoch(allTracks.last.timestamp * 1000));
      print(
          "difference between now and last record => ${difference.inMinutes}");
      if (remoteWork) {
        if (allTracks.last.activityType == ActivityType.STILL.name &&
            difference.inMinutes < -30) {
          NotificationService().showNotification(
              id: 2,
              title: "Let\'s move",
              body: "You have been still for too long, do some workout");
        }
      } else {
        if (allTracks.last.activityType == ActivityType.STILL.name &&
            difference.inMinutes > -45) {
          NotificationService().showNotification(
              id: 2,
              title: "Let\'s move",
              body: "You have been still for too long, do some workout");
        }
      }
    }
  }

  Duration differenceTime(String input) {
    DateTime inputTime = DateFormat.Hm().parse(input);
    DateTime nowTime =
        DateFormat.Hm().parse(DateFormat.Hm().format(DateTime.now()));
    return inputTime.difference(nowTime);
  }

  Duration differenceDate(DateTime inputTime) {
    // DateTime nowTime =
    //     DateFormat.Hm().parse(DateFormat.Hm().format(DateTime.now()));
    return inputTime.difference(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0.0,
        ),
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView(
                    children: [
                      const Text(
                        "Working days",
                        style: NewUICnst.titleStyle,
                      ),
                      Wrap(
                        children: List<Widget>.generate(
                          daysRetrieved.length,
                          (int idx) {
                            return Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: ChoiceChip(
                                  label: Text(daysRetrieved[idx].label),
                                  selected: daysRetrieved[idx].selected,
                                  onSelected: (bool selected) {
                                    preferencesService
                                        .changeDayAvailability(idx);
                                    setState(() {
                                      daysRetrieved[idx].selected = selected;
                                    });
                                  }),
                            );
                          },
                        ).toList(),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Working hours",
                          style: NewUICnst.titleStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Flexible(
                              child: TimePickerField(
                                textController: workStartController,
                                preferencesKey: KeysCnst.workStartTime,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Flexible(
                              child: TimePickerField(
                                textController: workEndController,
                                preferencesKey: KeysCnst.workEndTime,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Break time",
                          style: NewUICnst.titleStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Flexible(
                              child: TimePickerField(
                                textController: breakStartController,
                                preferencesKey: KeysCnst.breakStartTime,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Flexible(
                              child: TimePickerField(
                                textController: breakEndController,
                                preferencesKey: KeysCnst.breakEndTime,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: ElevatedButtonWidget(
                      //     buttonText: "all",
                      //     onPressed: () async {
                      //       List<TrackModel> result =
                      //           await TrackDatabase.instance.readAllTracks();
                      //       result.forEach((element) {
                      //         logger.w(element.id.toString() +
                      //             " " +
                      //             element.timestamp.toString() +
                      //             " " +
                      //             element.confidence +
                      //             " " +
                      //             element.activityType);
                      //       });
                      //     },
                      //   ),
                      // ),
                      // Row(
                      //   children: [
                      //     Flexible(
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: ElevatedButtonWidget(
                      //           buttonText: "Walking",
                      //           onPressed: () async {
                      //             TrackModel toInsert = TrackModel(
                      //                 timestamp:
                      //                     DateTime.now().millisecondsSinceEpoch,
                      //                 activityType: ActivityType.WALKING.name,
                      //                 confidence: ActivityConfidence.HIGH.name);
                      //             trackDatabase.create(toInsert);
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //     Flexible(
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: ElevatedButtonWidget(
                      //           buttonText: "Running",
                      //           onPressed: () async {
                      //             TrackModel toInsert = TrackModel(
                      //                 timestamp:
                      //                     DateTime.now().millisecondsSinceEpoch,
                      //                 activityType: ActivityType.RUNNING.name,
                      //                 confidence: ActivityConfidence.HIGH.name);
                      //             trackDatabase.create(toInsert);
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //     Flexible(
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: ElevatedButtonWidget(
                      //           buttonText: "Still",
                      //           onPressed: () async {
                      //             TrackModel toInsert = TrackModel(
                      //                 timestamp: DateTime.now()
                      //                     // .subtract(const Duration(minutes: 35))
                      //                     .millisecondsSinceEpoch,
                      //                 activityType: ActivityType.STILL.name,
                      //                 confidence: ActivityConfidence.HIGH.name);
                      //             print(toInsert.toJson());
                      //             trackDatabase.create(toInsert);
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
        ));
  }
}
