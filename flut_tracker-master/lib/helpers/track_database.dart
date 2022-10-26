import 'package:flut_tracker/domain/days.dart';
import 'package:flut_tracker/domain/trakmodel.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TrackDatabase {
  static final TrackDatabase instance = TrackDatabase._init();

  static Database _database;

  TrackDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDB('track.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $trackNotesDB (
  ${TrackModelFields.id} $idType, 
  ${TrackModelFields.activityType} $textType,
  ${TrackModelFields.timestamp} $integerType,
  ${TrackModelFields.confidence} $textType
  )
''');
  }

  Future<void> create(TrackModel trackModel) async {
    final db = await instance.database;

    var logger = Logger();
    final id = await db.insert(trackNotesDB, trackModel.toJson());
    logger.d(id);
  }

  Future<List<TrackModel>> readAllTracks() async {
    final db = await instance.database;

    const orderBy = '${TrackModelFields.id} ASC';

    final result = await db.query(trackNotesDB, orderBy: orderBy);
    print(result.length);
    return result.map((json) => TrackModel.fromJson(json)).toList();
  }

  Future<List<TrackModel>> readTodayTracks() async {
    final db = await instance.database;
    DateTime now = DateTime.now();
    int initToday = DateTime(now.year, now.month, now.day)
        // .add(const Duration(hours: 1))
        .millisecondsSinceEpoch;

    const orderBy = '${TrackModelFields.timestamp} ASC';

    final result = await db.query(trackNotesDB,
        orderBy: orderBy,
        where: '${TrackModelFields.timestamp} > ?',
        whereArgs: [initToday]);
    print(result.length);

    return result.map((json) => TrackModel.fromJson(json)).toList();
  }

  Future<void> deleteAll() async {
    final db = await instance.database;

    return await db.delete(trackNotesDB);
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
