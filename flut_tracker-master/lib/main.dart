import 'package:flut_tracker/pages/request_permission.dart';
import 'package:flut_tracker/widgets/ui_cnst.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';

import 'helpers/notification_service.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final activityRecognition = FlutterActivityRecognition.instance;

  PermissionRequestResult reqResult;
  reqResult = await activityRecognition.checkPermission();
  NotificationService().initNotification();

  runApp(MyApp(
    granted: (reqResult == PermissionRequestResult.GRANTED),
  ));
}

class MyApp extends StatelessWidget {
  final bool granted;
  const MyApp({Key key, @required this.granted}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Flutter Tracker',
      theme: ThemeData(
          fontFamily: NewUICnst.fontFamily,
          primarySwatch:Colors.red,
          backgroundColor: NewUICnst.ghostWhite,
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NewUICnst.borderRadius),
                borderSide: const BorderSide(
                  width: 1,
                )),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NewUICnst.borderRadius),
                borderSide: BorderSide(color: Colors.grey[700])),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NewUICnst.borderRadius),
                borderSide: const BorderSide(
                    color: NewUICnst.focuseBorderColor, width: 1)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NewUICnst.borderRadius),
                borderSide: const BorderSide(
                    color: NewUICnst.errorBorderColor, width: 1)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NewUICnst.borderRadius),
                borderSide: const BorderSide(
                    color: NewUICnst.errorBorderColor, width: 1)),
            filled: true,
            isDense: true,
            // labelStyle:NewUICnst.fieldLabelStyle
            hintStyle: NewUICnst.fieldHintStyle,
          )),
      debugShowCheckedModeBanner: false,
      initialRoute: granted ? 'home' : 'permission',
      routes: {
        'home': (context) => const HomeApp(),
        'permission': (context) => const RequestPermissionPage()
      },
    );
  }
}
