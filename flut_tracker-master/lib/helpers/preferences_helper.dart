import 'dart:developer';

import 'package:flut_tracker/domain/days.dart';
import 'package:flut_tracker/widgets/ui_cnst.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesService {
  Future<List<Days>> getAvailableDays();
  Future<void> changeDayAvailability(int dayID);
  // Future<void> changeHoursAvailability()
}

class PreferencesServiceImpl implements PreferencesService {
  Logger logger;
  static PreferencesServiceImpl instance = PreferencesServiceImpl._internal();

  PreferencesServiceImpl._internal() {
    logger = Logger();
  }

  factory PreferencesServiceImpl() => instance;

  @override
  Future<void> changeDayAvailability(int dayID) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      List<Days> vara = [];
      List<String> storedDays = preferences.getStringList(KeysCnst.savedDays);
      if (storedDays == null) {
        vara = daysListCnst;
      } else {
        vara = List<Days>.from(storedDays.map((e) => daysFromJson(e)));
      }

      vara[dayID].selected = !vara[dayID].selected;

      preferences.setStringList(KeysCnst.savedDays,
          List<String>.from(vara.map((e) => daysToJson(e))));
    } on Exception catch (e) {
      logger.e(e);
      // TODO
    }
  }

  @override
  Future<List<Days>> getAvailableDays() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      List<String> storedDays = preferences.getStringList(KeysCnst.savedDays);
      if (storedDays == null) {
        return daysListCnst;
      } else {
        return List<Days>.from(storedDays.map((e) => daysFromJson(e)));
      }
    } on Exception catch (e) {
      logger.e(e);
      throw UnimplementedError();
    }
  }

  Future<String> getStringValue(String key) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      return preferences.getString(key);
    } on Exception catch (e) {
      logger.e(e);
      throw UnimplementedError();
    }
  }

  Future<bool> getBoolValue(String key) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      return preferences.getBool(key);
    } on Exception catch (e) {
      logger.e(e);
      throw UnimplementedError();
    }
  }

  Future<void> saveStringValue(String key, String value) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString(key, value);
      log("saved value" + value);
    } on Exception catch (e) {
      logger.e(e);
      throw UnimplementedError();
    }
  }

  Future<void> saveBoolValue(String key, bool value) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool(key, value);
      log("saved value " + value.toString());
    } on Exception catch (e) {
      logger.e(e);
      throw UnimplementedError();
    }
  }

  Future<void> clean() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.clear();
    } on Exception catch (e) {
      logger.e(e);
      throw UnimplementedError();
    }
  }
}
