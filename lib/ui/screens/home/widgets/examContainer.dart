import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/examTabSelectionCubit.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/ui/widgets/customTabBarContainer.dart';
import 'package:eschool/ui/widgets/examOfflineListContainer.dart';
import 'package:eschool/ui/widgets/examOnlineListContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/tabBarBackgroundContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/customBackButton.dart';

class ExamContainer extends StatelessWidget {
  final int? childId;
  final List<Subject>? subjects;
  const ExamContainer({Key? key, this.childId, this.subjects})
      : super(key: key);

  Widget _buildAppBar(
      BuildContext context, ExamTabSelectionState currentState,) {
    return ScreenTopBackgroundContainer(
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            context.read<AuthCubit>().isParent()
                ? const CustomBackButton()
                : const SizedBox(),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                UiUtils.getTranslatedLabel(context, examsKey),
                style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: UiUtils.screenTitleFontSize,),
              ),
            ),
            AnimatedAlign(
              curve: UiUtils.tabBackgroundContainerAnimationCurve,
              duration: UiUtils.tabBackgroundContainerAnimationDuration,
              alignment: currentState.examFilterTabTitle == offlineKey
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd,
              child: TabBarBackgroundContainer(boxConstraints: boxConstraints),
            ),
            CustomTabBarContainer(
              boxConstraints: boxConstraints,
              alignment: AlignmentDirectional.centerStart,
              isSelected: currentState.examFilterTabTitle == offlineKey,
              onTap: () {
                context
                    .read<ExamTabSelectionCubit>()
                    .changeExamFilterTabTitle(offlineKey);
              },
              titleKey: offlineKey,
            ),
            CustomTabBarContainer(
              boxConstraints: boxConstraints,
              alignment: AlignmentDirectional.centerEnd,
              isSelected: currentState.examFilterTabTitle == onlineKey,
              onTap: () {
                context
                    .read<ExamTabSelectionCubit>()
                    .changeExamFilterTabTitle(onlineKey);
              },
              titleKey: onlineKey,
            ),
          ],
        );
      },),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExamTabSelectionCubit, ExamTabSelectionState>(
      builder: (context, state) {
        return Stack(
          children: [
            (context.read<ExamTabSelectionCubit>().isExamOnline())
                ? ExamOnlineListContainer(childId: childId, subjects: subjects)
                : ExamOfflineListContainer(
                    childId: childId,
                  ),
            Align(
              alignment: Alignment.topCenter,
              child: _buildAppBar(context, state),
            ),
          ],
        );
      },
    );
  }
}
