import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:my_calender_app/content/colors.dart';
import 'package:my_calender_app/database/drift_database.dart';
import 'package:my_calender_app/model/schedule_with_color.dart';

class TodayBanner extends StatelessWidget {
  final DateTime selectedDay;

  const TodayBanner(
      {required this.selectedDay, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle =
        TextStyle(color: Colors.white, fontWeight: FontWeight.w700);
    return Container(
      color: PRIMARY_COLOR,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedDay.year}년 ${selectedDay.month}월 ${selectedDay.day}일',
              style: textStyle,
            ),
            StreamBuilder<List<ScheduleWithColor>>(
              stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDay),
              builder: (context, snapshot) {
                int count = 0;
                if(snapshot.hasData) {
                  count = snapshot.data!.length;
                }
                return Text(
                  '$count 개',
                  style: textStyle,
                );
              }
            )
          ],
        ),
      ),
    );
  }
}
