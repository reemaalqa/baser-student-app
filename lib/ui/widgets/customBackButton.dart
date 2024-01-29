import 'package:eschool/ui/widgets/svgButton.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final Function? onTap;
  final double? topPadding;
  final AlignmentDirectional? alignmentDirectional;
  const CustomBackButton(
      {Key? key, this.onTap, this.topPadding, this.alignmentDirectional,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignmentDirectional ?? AlignmentDirectional.topStart,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          top: topPadding ?? 0,
          start: UiUtils.screenContentHorizontalPadding,
        ),
        child: SvgButton(
            onTap: () {
              if (onTap != null) {
                onTap?.call();
              } else {
                Navigator.of(context).pop();
              }
            },
            svgIconUrl: UiUtils.getBackButtonPath(context),),
      ),
    );
  }
}
