import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_calender_app/content/colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;

  // 시간과 내용 구분
  final bool isTime;
  final FormFieldSetter<String> onSaved;

  const CustomTextField({
    required this.onSaved,
    required this.label, required this.isTime, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: PRIMARY_COLOR, fontWeight: FontWeight.w700),
        ),
        if(isTime) renderTextField(),
        if(!isTime) Expanded(child: renderTextField()),
      ],
    );
  }

  Widget renderTextField() {
    return TextFormField(
      //입력과 동시에 val 을 받아옴
      // onChanged: (String? val) {
      //
      // },
      // null이 반환되면 에러가 없음 에러가 있으면 에러를 String 값으로 반환해준다.
      validator: (String? val) {
        if(val == null || val.isEmpty){
          return '값을 입력해주세요!';
        }
        if(isTime) {
          int time = int.parse(val);
          if(time < 0) {
            return '0 이상의 숫자를 입력해주세요!';
          }
          if(time > 24) {
            return '24 이하의 숫자를 입력해주세요!';
          }
        } else {
          if(val.length > 100) {
            return '100자 이하로 입력해주세요!';
          }
        }
        return null;
      },
      onSaved: onSaved,
      cursorColor: Colors.grey,
      maxLines: isTime ? 1 : null,
      // 세로 길이 늘리기
      expands: !isTime,
      keyboardType: isTime ? TextInputType.number : TextInputType.multiline,
      maxLength: isTime ? null : 100,
      inputFormatters: isTime
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ]
          : [
            LengthLimitingTextInputFormatter(100)
      ],
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 0, style: BorderStyle.none)),
        // 배경 컬러를 넣어주기위해 true
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
