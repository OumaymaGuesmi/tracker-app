import 'package:flut_tracker/widgets/common_widgets.dart';
import 'package:flut_tracker/widgets/ui_cnst.dart';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';

class RequestPermissionPage extends StatefulWidget {
  const RequestPermissionPage({Key key}) : super(key: key);

  @override
  State<RequestPermissionPage> createState() => _RequestPermissionPageState();
}

class _RequestPermissionPageState extends State<RequestPermissionPage> {
  final activityRecognition = FlutterActivityRecognition.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.run_circle_rounded,
              color: NewUICnst.uclaBlue,
              size: 120,
            ),
            const Text(
              "Physical activity permission",
              style: TextStyle(fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ElevatedButtonWidget(
                  onPressed: () async {
                    PermissionRequestResult reqResult;
                    reqResult = await activityRecognition.requestPermission();
                    if (reqResult == PermissionRequestResult.GRANTED) {
                      Navigator.of(context).pushReplacementNamed('home');
                    }
                  },
                  buttonText: "Request Permission"),
            )
          ],
        )),
      ),
    );
  }
}
