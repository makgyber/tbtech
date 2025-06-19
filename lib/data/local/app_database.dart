import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:tbtech/data/local/dao/job_order_dao.dart';
import 'package:tbtech/models/job_order.dart';

part 'app_database.g.dart'; // Generated code will be in this file

@Database(version: 1, entities: [JobOrder])
abstract class AppDatabase extends FloorDatabase {
  JobOrderDao get jobOrderDao;

// You can add migrations here if your database version increases
// static final Migration _migration1to2 = Migration(1, 2, (database) async {
//   await database.execute('ALTER TABLE Post ADD COLUMN newField TEXT');
// });
}