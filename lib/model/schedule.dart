import 'package:drift/drift.dart';

class Schedules extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement() ();

  TextColumn get content => text() ();

  DateTimeColumn get date => dateTime() ();

  IntColumn get startTime => integer() ();

  IntColumn get endTime => integer() ();

  // color table id
  IntColumn get colorId => integer() ();

  DateTimeColumn get createdAt => dateTime().clientDefault (() => DateTime.now()) ();


}