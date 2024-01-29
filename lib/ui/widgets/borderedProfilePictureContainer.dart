import 'package:eschool/ui/widgets/customUserProfileImageWidget.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';

class BorderedProfilePictureContainer extends StatelessWidget {
  final BoxConstraints boxConstraints;
  final String imageUrl;
  final Function? onTap;
  final double? heightAndWidthPercentage;
  const BorderedProfilePictureContainer({
    Key? key,
    required this.boxConstraints,
    required this.imageUrl,
    this.heightAndWidthPercentage,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        boxConstraints.maxWidth *
            (heightAndWidthPercentage == null
                ? UiUtils.defaultProfilePictureHeightAndWidthPercentage * (0.5)
                : heightAndWidthPercentage! * (0.5)),
      ),
      onTap: () {
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        width: boxConstraints.maxWidth *
            (heightAndWidthPercentage ??
                UiUtils.defaultProfilePictureHeightAndWidthPercentage),
        height: boxConstraints.maxWidth *
            (heightAndWidthPercentage ??
                UiUtils.defaultProfilePictureHeightAndWidthPercentage),
        child: CustomUserProfileImageWidget(profileUrl: imageUrl),
      ),
    );
  }
}
