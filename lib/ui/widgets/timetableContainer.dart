import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/timeTableCubit.dart';
import 'package:eschool/data/models/timeTableSlot.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/subjectImageContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimeTableContainer extends StatefulWidget {
  final int? childId;
  const TimeTableContainer({Key? key, this.childId}) : super(key: key);

  @override
  State<TimeTableContainer> createState() => _TimeTableContainerState();
}

class _TimeTableContainerState extends State<TimeTableContainer>
    with SingleTickerProviderStateMixin {
  late int _currentSelectedDayIndex = DateTime.now().weekday - 1;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<TimeTableCubit>().fetchStudentTimeTable(
            useParentApi: context.read<AuthCubit>().isParent(),
            childId: widget.childId,
          );
    });
  }

  Widget _buildTimeTableShimmerLoadingContainer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        horizontal: UiUtils.screenContentHorizontalPaddingInPercentage *
            MediaQuery.of(context).size.width,
      ),
      child: ShimmerLoadingContainer(
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Row(
              children: [
                CustomShimmerContainer(
                  height: 60,
                  width: boxConstraints.maxWidth * (0.25),
                ),
                SizedBox(
                  width: boxConstraints.maxWidth * (0.05),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomShimmerContainer(
                      height: 9,
                      width: boxConstraints.maxWidth * (0.6),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomShimmerContainer(
                      height: 8,
                      width: boxConstraints.maxWidth * (0.5),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimeTableLoading() {
    return ShimmerLoadingContainer(
      child: Column(
        children: List.generate(5, (index) => index)
            .map((e) => _buildTimeTableShimmerLoadingContainer())
            .toList(),
      ),
    );
  }

  Widget _buildAppBar() {
    String getStudentClassDetails = "";
    if (context.read<AuthCubit>().isParent()) {
      final studentDetails = context
          .read<AuthCubit>()
          .getParentDetails()
          .children
          .where((element) => element.id == widget.childId)
          .first;

      getStudentClassDetails = studentDetails.classSectionName;
    } else {
      getStudentClassDetails =
          context.read<AuthCubit>().getStudentDetails().classSectionName;
    }
    return ScreenTopBackgroundContainer(
      heightPercentage: UiUtils.appBarMediumtHeightPercentage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.childId == null ? const SizedBox() : const CustomBackButton(),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              UiUtils.getTranslatedLabel(context, timeTableKey),
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: UiUtils.screenTitleFontSize,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: MediaQuery.of(context).size.width * (0.075),
            child: Container(
              alignment: Alignment.center,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.075),
                    offset: const Offset(2.5, 2.5),
                    blurRadius: 5,
                  )
                ],
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              width: MediaQuery.of(context).size.width * (0.85),
              child: Text(
                "${UiUtils.getTranslatedLabel(context, classKey)} - $getStudentClassDetails",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayContainer(int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentSelectedDayIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(5.0),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: index == _currentSelectedDayIndex
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
        ),
        padding: const EdgeInsets.all(7.5),
        child: Text(
          UiUtils.weekDays[index],
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: index == _currentSelectedDayIndex
                ? Theme.of(context).scaffoldBackgroundColor
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDays() {
    final List<Widget> children = [];

    for (var i = 0; i < UiUtils.weekDays.length; i++) {
      children.add(_buildDayContainer(i));
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * (0.85),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }

  Widget _buildTimeTableSlotDetailsContainer({
    required TimeTableSlot timeTableSlot,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.075),
            offset: const Offset(4, 4),
            blurRadius: 10,
          )
        ],
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      width: MediaQuery.of(context).size.width * (0.85),
      padding: const EdgeInsets.symmetric(horizontal: 12.5, vertical: 10.0),
      child: Row(
        children: [
          SubjectImageContainer(
            showShadow: false,
            height: 60,
            width: MediaQuery.of(context).size.width * (0.175),
            radius: 7.5,
            subject: timeTableSlot.subject,
          ),
          const SizedBox(
            width: 20,
          ),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${UiUtils.formatTime(timeTableSlot.startTime)} - ${UiUtils.formatTime(timeTableSlot.endTime)}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0,
                  ),
                ),
                Text(
                  timeTableSlot.subject.showType
                      ? timeTableSlot.subject.subjectNameWithType
                      : timeTableSlot.subject.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0,
                  ),
                ),
                Text(
                  "${timeTableSlot.teacherFirstName} ${timeTableSlot.teacherLastName}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<TimeTableSlot> _buildTimeTableSlots(List<TimeTableSlot> timeTableSlot) {
    final dayWiseTimeTableSlots = timeTableSlot
        .where((element) => element.day == _currentSelectedDayIndex + 1)
        .toList();
    return dayWiseTimeTableSlots;
  }

  Widget _buildTimeTable() {
    return BlocBuilder<TimeTableCubit, TimeTableState>(
      builder: (context, state) {
        if (state is TimeTableFetchSuccess) {
          final timetableSlots = _buildTimeTableSlots(state.timeTable);
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: timetableSlots.isEmpty
                ? NoDataContainer(
                    key: isApplicationItemAnimationOn ? UniqueKey() : null,
                    titleKey: noLecturesKey,
                  )
                : Column(
                    children: List.generate(
                      timetableSlots.length,
                      (index) => Animate(
                        key: isApplicationItemAnimationOn ? UniqueKey() : null,
                        effects: listItemAppearanceEffects(
                          itemIndex: index,
                          totalLoadedItems: timetableSlots.length,
                        ),
                        child: _buildTimeTableSlotDetailsContainer(
                          timeTableSlot: timetableSlots[index],
                        ),
                      ),
                    ),
                  ),
          );
        }
        if (state is TimeTableFetchFailure) {
          return ErrorContainer(
            key: isApplicationItemAnimationOn ? UniqueKey() : null,
            errorMessageCode: state.errorMessage,
            onTapRetry: () {
              context.read<TimeTableCubit>().fetchStudentTimeTable(
                    useParentApi: context.read<AuthCubit>().isParent(),
                    childId: widget.childId,
                  );
            },
          );
        }

        return _buildTimeTableLoading();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: UiUtils.getScrollViewBottomPadding(context),
              top: UiUtils.getScrollViewTopPadding(
                context: context,
                appBarHeightPercentage: UiUtils.appBarMediumtHeightPercentage,
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.025),
                ),
                _buildDays(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.025),
                ),
                _buildTimeTable(),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: _buildAppBar(),
        ),
      ],
    );
  }
}
