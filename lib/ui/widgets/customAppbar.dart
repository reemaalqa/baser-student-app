import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/svgButton.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final Function? onPressBackButton;
  final String? subTitle;
  final bool? showBackButton;
  final Widget? actionButton;
  const CustomAppBar({
    Key? key,
    this.onPressBackButton,
    required this.title,
    this.subTitle,
    this.showBackButton,
    this.actionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenTopBackgroundContainer(
      padding: EdgeInsets.zero,
      heightPercentage: UiUtils.appBarSmallerHeightPercentage,
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              (showBackButton ?? true)
                  ? Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: UiUtils.screenContentHorizontalPadding,
                        ),
                        child: SvgButton(
                          onTap: () {
                            if (onPressBackButton != null) {
                              onPressBackButton!.call();
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          svgIconUrl: UiUtils.getBackButtonPath(context),
                        ),
                      ),
                    )
                  : const SizedBox(),
              Align(
                child: Container(
                  alignment: Alignment.center,
                  width: boxConstraints.maxWidth * (0.6),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: UiUtils.screenTitleFontSize,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
              ),
              Align(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: boxConstraints.maxHeight * (0.28) +
                        UiUtils.screenTitleFontSize,
                  ),
                  child: Text(
                    subTitle ?? "",
                    style: TextStyle(
                      fontSize: UiUtils.screenSubTitleFontSize,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
              ),
              if (actionButton != null)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: 10,
                    ),
                    child: actionButton,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
