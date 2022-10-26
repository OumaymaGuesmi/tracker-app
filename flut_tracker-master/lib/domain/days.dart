// To parse this JSON data, do
//
//     final days = daysFromJson(jsonString);

import 'dart:convert';

Days daysFromJson(String str) => Days.fromJson(json.decode(str));

String daysToJson(Days data) => json.encode(data.toJson());

const String trackNotesDB = 'trackNotesDB';

class Days {
  Days({
    this.label,
    this.selected,
  });

  String label;
  bool selected;

  factory Days.fromJson(Map<String, dynamic> json) => Days(
        label: json["label"],
        selected: json["selected"],
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "selected": selected,
      };
}

List<Days> daysListCnst = [
  Days(label: "Monday", selected: false),
  Days(label: "Tuesday", selected: false),
  Days(label: "Wednesday", selected: false),
  Days(label: "Thursday", selected: false),
  Days(label: "Friday", selected: false),
  Days(label: "Saturday", selected: false),
  Days(label: "Sunday", selected: false),
];
