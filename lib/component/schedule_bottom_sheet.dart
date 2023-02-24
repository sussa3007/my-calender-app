import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:my_calender_app/component/custom_text_field.dart';
import 'package:my_calender_app/content/colors.dart';
import 'package:my_calender_app/database/drift_database.dart';
import 'package:my_calender_app/model/category_color.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final int? scheduleId;

  const ScheduleBottomSheet(
      {this.scheduleId, required this.selectedDate, Key? key})
      : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  int? startTime;
  int? endTime;
  String? content;
  int? selectedColorId;

  @override
  Widget build(BuildContext context) {
    // 키보드(시스템 view) 사이즈
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: FutureBuilder<Schedule>(
          future: widget.scheduleId == null
              ? null
              : GetIt.I<LocalDatabase>().getScheduleById(widget.scheduleId!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('스케줄을 불러올 수 없습니다.'),
              );
            }
            // 빌더가 실행되고 로딩 중 일때
            if (snapshot.connectionState != ConnectionState.none &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            // 실행 되고 값이 한번도 셋팅 되지 않았을때
            if (snapshot.hasData && startTime == null) {
              print(snapshot.data);
              startTime = snapshot.data!.startTime;
              endTime = snapshot.data!.endTime;
              content = snapshot.data!.content;
              // startTime == null 조건이 없다면 계속 데이터 베이스 값으로 설정을 해주기 때문에 바뀌지 않음
              selectedColorId = snapshot.data!.colorId;
            }
            return SafeArea(
              child: Container(
                color: Colors.white,
                // 키보드 사이즈까지 더해줘서 높이를 준다
                height: MediaQuery.of(context).size.height / 2 + bottomInset,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 15),
                    child: Form(
                      key: formKey,
                      // 자동으로 벨리데이션 가능
                      // autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Time(
                            onStartSaved: (String? val) {
                              startTime = int.parse(val!);
                            },
                            onEndSaved: (String? val) {
                              endTime = int.parse(val!);
                            },
                            startInitialValue: startTime?.toString() ?? '',
                            endInitialValue: endTime?.toString() ?? '',
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          _Content(
                            onContentSaved: (String? val) {
                              content = val!;
                            },
                            contentInitialValue: content ?? '',
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          FutureBuilder<List<CategoryColor>>(
                              future:
                                  GetIt.I<LocalDatabase>().getCategoryColors(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    selectedColorId == null &&
                                    snapshot.data!.isNotEmpty) {
                                  selectedColorId = snapshot.data![0].id;
                                }
                                return _ColorPicker(
                                  selectedColorId: selectedColorId,
                                  colorIdSetter: (int id) {
                                    setState(() {
                                      selectedColorId = id;
                                    });
                                  },
                                  colors:
                                      snapshot.hasData ? snapshot.data! : [],
                                );
                              }),
                          const SizedBox(
                            height: 10,
                          ),
                          _SaveButton(
                            onPressed: onSavePressed,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  void onSavePressed() async {
    // 키는 생성 되었는데 form 위젯과 결합 되지 않았을때
    if (formKey.currentState == null) {
      return;
    }
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (widget.scheduleId == null) {
        final saveId = await GetIt.I<LocalDatabase>().createSchedule(
          SchedulesCompanion(
            date: Value(widget.selectedDate),
            startTime: Value(startTime!),
            endTime: Value(endTime!),
            content: Value(content!),
            colorId: Value(selectedColorId!),
          ),
        );
      } else {
        await GetIt.I<LocalDatabase>().updateScheduleById(
          widget.scheduleId!,
          SchedulesCompanion(
            date: Value(widget.selectedDate),
            startTime: Value(startTime!),
            endTime: Value(endTime!),
            content: Value(content!),
            colorId: Value(selectedColorId!),
          ),
        );
      }

      Navigator.of(context).pop();
    } else {
      print('에러가 있습니다!');
    }
  }
}

// 함수를 할당 할 수 있음
typedef ColorIdSetter = void Function(int id);

class _ColorPicker extends StatelessWidget {
  final List<CategoryColor> colors;
  final int? selectedColorId;
  final ColorIdSetter colorIdSetter;

  const _ColorPicker(
      {required this.selectedColorId,
      required this.colorIdSetter,
      required this.colors,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 컴포넌트 줄바꿈
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: colors
          .map((e) => GestureDetector(
                onTap: () {
                  colorIdSetter(e.id);
                },
                child: renderColor(
                  e,
                  e.id == selectedColorId,
                ),
              ))
          .toList(),
    );
  }

  Widget renderColor(CategoryColor color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(
          int.parse('FF${color.hexCode}', radix: 16),
        ),
        border: isSelected
            ? Border.all(
                color: Colors.black54,
                width: 4,
              )
            : null,
      ),
      width: 32,
      height: 32,
    );
  }
}

class _Time extends StatelessWidget {
  final FormFieldSetter<String> onStartSaved;
  final FormFieldSetter<String> onEndSaved;
  final String startInitialValue;
  final String endInitialValue;

  const _Time({
    required this.startInitialValue,
    required this.endInitialValue,
    required this.onStartSaved,
    required this.onEndSaved,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: CustomTextField(
          label: '시작 시간',
          isTime: true,
          onSaved: onStartSaved,
          initialValue: startInitialValue,
        )),
        const SizedBox(
          width: 16,
        ),
        Expanded(
            child: CustomTextField(
          label: '종료 시간',
          isTime: true,
          onSaved: onEndSaved,
          initialValue: endInitialValue,
        ))
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final String contentInitialValue;
  final FormFieldSetter<String> onContentSaved;

  const _Content(
      {required this.onContentSaved,
      required this.contentInitialValue,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        label: '내용',
        isTime: false,
        onSaved: onContentSaved,
        initialValue: contentInitialValue,
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY_COLOR,
            ),
            child: const Text('저장'),
          ),
        ),
      ],
    );
  }
}
