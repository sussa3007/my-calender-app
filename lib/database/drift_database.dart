// private 값은 불러올수 없음
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:my_calender_app/model/category_color.dart';
import 'package:my_calender_app/model/schedule.dart';
import 'package:my_calender_app/model/schedule_with_color.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// private 값도 불러올수 있음
part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    Schedules,
    CategoryColors,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  Future<int> createSchedule(SchedulesCompanion data) =>
      into(schedules).insert(data);

  Future<int> createCategoryColor(CategoryColorsCompanion data) =>
      into(categoryColors).insert(data);

  Future<List<CategoryColor>> getCategoryColors() =>
      select(categoryColors).get();

  Stream<List<ScheduleWithColor>> watchSchedules(DateTime dateTime) {
    final query = select(schedules).join([
      innerJoin(categoryColors, categoryColors.id.equalsExp(schedules.colorId))
    ]);
    query.where(schedules.date.equals(dateTime));
    query.orderBy([
      OrderingTerm.asc(schedules.startTime)
    ]);
    return query.watch().map(
          (rows) => rows.map(
            (row) => ScheduleWithColor(
              categoryColor: row.readTable(categoryColors),
              schedule: row.readTable(schedules),
            ),
          ).toList(),
        );
    // val..method 형태는 메소드가 적용된 val값을 리턴한다.
    // return (select(schedules)..where((tbl) => tbl.date.equals(dateTime))).watch();
  }

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
