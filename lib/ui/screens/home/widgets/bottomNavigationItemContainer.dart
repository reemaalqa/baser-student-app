import 'package:eschool/ui/styles/colors.dart';
import 'package:eschool/ui/widgets/customShowCaseWidget.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BottomNavItem {
  final String title;
  final String activeImageUrl;
  final String disableImageUrl;

  BottomNavItem({
    required this.activeImageUrl,
    required this.disableImageUrl,
    required this.title,
  });
}

class BottomNavItemContainer extends StatefulWidget {
  final BoxConstraints boxConstraints;
  final int index;
  final int currentIndex;
  final AnimationController animationController;
  final BottomNavItem bottomNavItem;
  final Function onTap;
  final GlobalKey showCaseKey;
  final String showCaseDescription;
  final int? notificationCount; //null won't show anything
  const BottomNavItemContainer({
    Key? key,
    required this.boxConstraints,
    required this.currentIndex,
    required this.showCaseDescription,
    required this.showCaseKey,
    required this.bottomNavItem,
    required this.animationController,
    required this.onTap,
    required this.index,
    this.notificationCount,
  }) : super(key: key);

  @override
  State<BottomNavItemContainer> createState() => _BottomNavItemContainerState();
}

class _BottomNavItemContainerState extends State<BottomNavItemContainer> {
  @override
  Widget build(BuildContext context) {
    return CustomShowCaseWidget(
      globalKey: widget.showCaseKey,
      description: widget.showCaseDescription,
      child: InkWell(
        onTap: () async {
          widget.onTap(widget.index);
        },
        child: SizedBox(
          width: widget.boxConstraints.maxWidth * (0.25),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: const Offset(0.0, 0.35),
                    ).animate(
                      CurvedAnimation(
                        parent: widget.animationController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: SvgPicture.asset(
                      widget.index == widget.currentIndex
                          ? widget.bottomNavItem.activeImageUrl
                          : widget.bottomNavItem.disableImageUrl,
                    ),
                  ),
                  SizedBox(
                    height: widget.boxConstraints.maxHeight * (0.051),
                  ),
                  FadeTransition(
                    opacity: Tween<double>(begin: 1.0, end: 0.0)
                        .animate(widget.animationController),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        // ignore: use_named_constants
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(0.0, 0.5),
                      ).animate(
                        CurvedAnimation(
                          parent: widget.animationController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Text(
                        UiUtils.getTranslatedLabel(
                          context,
                          widget.bottomNavItem.title,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //notification count showing on top of the icon, having same animation as icon
              if (widget.index != widget.currentIndex &&
                  widget.notificationCount != null &&
                  widget.notificationCount != 0)
                PositionedDirectional(
                  top: -7,
                  end: widget.boxConstraints.maxWidth * (0.07),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: const Offset(0.0, 0.35),
                    ).animate(
                      CurvedAnimation(
                        parent: widget.animationController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: redColor,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        widget.notificationCount! > 9
                            ? "9+"
                            : widget.notificationCount.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
