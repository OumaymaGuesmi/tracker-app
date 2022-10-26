import 'package:flut_tracker/helpers/preferences_helper.dart';
import 'package:flut_tracker/widgets/ui_cnst.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ElevatedButtonWidget extends StatelessWidget {
  final Color buttonColor;
  final Color fontColor;
  final String buttonText;
  final Function onPressed;
  const ElevatedButtonWidget(
      {Key key,
      this.buttonColor,
      this.fontColor,
      this.buttonText,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        textStyle: NewUICnst.buttonTextStyle,
        primary: buttonColor,
        onPrimary: fontColor,
        elevation: 0.0,
        onSurface: Colors.black,
        minimumSize: const Size(double.infinity, NewUICnst.rowHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NewUICnst.borderRadius),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class TimePickerField extends StatefulWidget {
  final TextEditingController textController;
  final String preferencesKey;
  const TimePickerField(
      {Key key, @required this.textController, @required this.preferencesKey})
      : super(key: key);

  @override
  State<TimePickerField> createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.textController,
      decoration: const InputDecoration(
          hintText: '00:00'
      ),
      readOnly: true,
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          builder: (context, childWidget) {
            return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(alwaysUse24HourFormat: true),
                child: childWidget);
          },
          initialTime: (widget.textController.text.isEmpty)
              ? TimeOfDay.now()
              : TimeOfDay(
                  hour: int.parse(widget.textController.text.split(":")[0]),
                  minute: int.parse(widget.textController.text.split(":")[1])),
          initialEntryMode: TimePickerEntryMode.dial,
          context: context,
        );
        if (pickedTime != null) {
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          String formattedTime = DateFormat('HH:mm').format(parsedTime);
          await PreferencesServiceImpl.instance
              .saveStringValue(widget.preferencesKey, formattedTime);

          setState(() {
            widget.textController.text = formattedTime;
          });
        }
      },
    );
  }
}
