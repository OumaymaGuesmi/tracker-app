// To parse this JSON data, do
//
//     final trackModel = trackModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

TrackModel trackModelFromJson(String str) =>
    TrackModel.fromJson(json.decode(str));

String trackModelToJson(TrackModel data) => json.encode(data.toJson());

class TrackModelFields {
  static final List<String> init = [id, activityType, timestamp, confidence];

  static const String id = '_id';
  static const String activityType = 'activityType';
  static const String timestamp = 'timestamp';
  static const String confidence = 'confidence';
}

class TrackModel {
  TrackModel({
    this.id,
    @required this.activityType,
    @required this.timestamp,
    @required this.confidence,
  });

  int id;
  String activityType;
  int timestamp;
  String confidence;

  factory TrackModel.fromJson(Map<String, dynamic> json) => TrackModel(
        id: json[TrackModelFields.id] ?? null,
        activityType:
            json[TrackModelFields.activityType] ?? null,
        timestamp: json[TrackModelFields.timestamp] ?? null,
        confidence: json[TrackModelFields.confidence] ?? null,
      );

  Map<String, dynamic> toJson() => {
        TrackModelFields.id: id,
        TrackModelFields.activityType: activityType,
        TrackModelFields.timestamp: timestamp,
        TrackModelFields.confidence: confidence,
      };
}
