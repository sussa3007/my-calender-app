import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:my_calender_app/component/calendar.dart';
import 'package:my_calender_app/component/schedule_bottom_sheet.dart';
import 'package:my_calender_app/component/schedule_card.dart';
import 'package:my_calender_app/component/today_banner.dart';
import 'package:my_calender_app/content/colors.dart';
import 'package:my_calender_app/database/drift_database.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/schedule_with_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List eventDays = [];
  DateTime selectedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: renderFloatingActionButton(),
      body: SafeArea(
        child: Column(
          children: [
            Calendar(
              selectedDay: selectedDay,
              focusedDay: focusedDay,
              onDaySelected: onDaySelected,
              eventLoader: eventLoader,
            ),
            const SizedBox(
              height: 10,
            ),
            TodayBanner(
              selectedDay: selectedDay,
            ),
            const SizedBox(
              height: 10,
            ),
            _ScheduleList(
              selectedDay: selectedDay,
            ),
          ],
        ),
      ),
    );
  }

  List eventLoader(DateTime dateTime) {
    setEventList();

    for (Schedule schedule in eventDays) {
      if (dateTime.day == schedule.date.day &&
          dateTime.month == schedule.date.month &&
          dateTime.year == schedule.date.year) {
        return ['event!'];
      }
    }
    return [];
  }

  setEventList() async {
    List findSchedules = await GetIt.I<LocalDatabase>()
        .getSchedules(focusedDay.year);
    eventDays = findSchedules;
  }

  FloatingActionButton renderFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          // 최대 사이즈가 화면의 50% 지만 isScrollControlled를 주면 사이즈 제한을 해제함
          isScrollControlled: true,
          context: context,
          builder: (_) {
            return ScheduleBottomSheet(
              selectedDate: selectedDay,
            );
          },
        );
      },
      backgroundColor: PRIMARY_COLOR,
      child: Icon(
        Icons.add,
        size: 35,
      ),
    );
  }

  onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = selectedDay;
    });

  }
}

class _ScheduleList extends StatelessWidget {
  final DateTime selectedDay;

  const _ScheduleList({required this.selectedDay, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: StreamBuilder<List<ScheduleWithColor>>(
            stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDay),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Center(
                  child: Text('스케줄이 없습니다!'),
                );
              }

              return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 7,
                  );
                },
                itemBuilder: (context, index) {
                  final scheduleWithColor = snapshot.data![index];
                  return Dismissible(
                    key: ObjectKey(scheduleWithColor.schedule.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (DismissDirection direction) {
                      GetIt.I<LocalDatabase>()
                          .removeSchedule(scheduleWithColor.schedule.id);
                    },
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          // 최대 사이즈가 화면의 50% 지만 isScrollControlled를 주면 사이즈 제한을 해제함
                          isScrollControlled: true,
                          context: context,
                          builder: (_) {
                            return ScheduleBottomSheet(
                              selectedDate: selectedDay,
                              scheduleId: scheduleWithColor.schedule.id,
                            );
                          },
                        );
                      },
                      child: ScheduleCard(
                        startTime: scheduleWithColor.schedule.startTime,
                        endTime: scheduleWithColor.schedule.endTime,
                        content: scheduleWithColor.schedule.content,
                        color: Color(
                          int.parse(
                              'FF${scheduleWithColor.categoryColor.hexCode}',
                              radix: 16),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
      ),
    );
  }
}
