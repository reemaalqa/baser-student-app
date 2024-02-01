import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/timeTableCubit.dart';
import 'package:eschool/cubits/timer/timer_cubit.dart';
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

class StudyingContainer extends StatefulWidget {
  final int? childId;
  const StudyingContainer({Key? key, this.childId}) : super(key: key);

  @override
  State<StudyingContainer> createState() => _StudyingContainerState();
}

class _StudyingContainerState extends State<StudyingContainer>
    with SingleTickerProviderStateMixin {
  late TimerCubit timerCubit;

  @override
  void initState() {
    super.initState();
    timerCubit =context.read<TimerCubit>();
    timerCubit.disposeTimer();
    Future.delayed(Duration.zero, () {
      timerCubit.startTimer(20);
      //context.read<TimerCubit>().startTimer(20);
    });
  }
@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timerCubit.disposeTimer();
  }
  Widget _buildAppBar() {
    String getStudentClassDetails = "";
      getStudentClassDetails =
          context.read<AuthCubit>().getStudentDetails().classSectionName;

    return ScreenTopBackgroundContainer(
      heightPercentage: UiUtils.appBarMediumtHeightPercentage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.childId == null ? const SizedBox() : const CustomBackButton(),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              UiUtils.getTranslatedLabel(context, studyingKey),
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

  @override
  Widget build(BuildContext context) {
    final timerCubit = context.watch<TimerCubit>();
    //timerCubit.startTimer(20);
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
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
                Center(
                  child: BlocBuilder<TimerCubit, TimerState>(
                    builder: (context, state) {
                     if (state is TimerRunning) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                            !timerCubit.isFirstTimer
                              // _isStudying(state)
                                  ?
                               UiUtils.getTranslatedLabel(context, studyingtimekey)
                              :UiUtils.getTranslatedLabel(context, breaktimeKey)
                                ,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildTimerDisplay(state.secondsRemaining),
                          ],
                        );
                      }  else {
                        return Container();
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.025),
                ),
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

  // bool _isStudying(TimerRunning state) {
  //   return state. > 10; // For example, if more than 10 seconds, it's studying time
  // }

  Widget _buildTimerDisplay(int secondsRemaining) {
    final minutes = (secondsRemaining / 60).floor();
    final seconds = secondsRemaining % 60;

    return Text(
      '${_formatTime(minutes)}:${_formatTime(seconds)}',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatTime(int time) {
    return time < 10 ? '0$time' : '$time';
  }
}
