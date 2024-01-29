import 'package:flutter/material.dart';

class ChangeCalendarMonthButton extends StatelessWidget {
  final Function onTap;
  final bool isDisable;
  final bool isNextButton;
  const ChangeCalendarMonthButton(
      {Key? key,
      required this.onTap,
      required this.isDisable,
      required this.isNextButton,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap.call();
      },
      borderRadius: BorderRadius.circular(7.5),
      child: Container(
        margin: EdgeInsetsDirectional.only(
            end: isNextButton ? 15.0 : 0, start: isNextButton ? 0 : 15.0,),
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(isDisable ? 0.75 : 1.0),
            borderRadius: BorderRadius.circular(7.5),),
        child: Icon(
          isNextButton ? Icons.chevron_right : Icons.chevron_left,
          size: 26,
          color: Theme.of(context)
              .scaffoldBackgroundColor
              .withOpacity(isDisable ? 0.75 : 1.0),
        ),
      ),
    );
  }
}
