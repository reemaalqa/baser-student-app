import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:eschool/cubits/resultOnlineCubit.dart';

import 'package:eschool/data/models/resultOnlineDetails.dart';
import 'package:eschool/data/repositories/resultRepository.dart';

import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';

import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';

class ResultOnlineScreen extends StatefulWidget {
  final int examId;
  final String examName, subjectName;
  final int? childId;
  const ResultOnlineScreen({
    Key? key,
    required this.examId,
    required this.examName,
    required this.subjectName,
    this.childId,
  }) : super(key: key);

  @override
  ResultOnlineScreenState createState() => ResultOnlineScreenState();
  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (context) => ResultOnlineCubit(ResultOnlineRepository()),
        child: ResultOnlineScreen(
          examId: arguments['examId'],
          examName: arguments['examName'],
          subjectName: arguments['subjectName'],
          childId: arguments['childId'] ?? 0,
        ),
      ),
    );
  }
}

class ResultOnlineScreenState extends State<ResultOnlineScreen> {
  void fetchResultDetails() {
    // ignore: avoid_single_cascade_in_expression_statements
    context
      ..read<ResultOnlineCubit>().fetchResultOnlineDetails(
        examId: widget.examId,
        useParentApi: context.read<AuthCubit>().isParent(),
        childId: widget.childId ?? 0,
      );
  }

  @override
  void initState() {
    fetchResultDetails();
    super.initState();
  }

  Widget buildResultAppBar(ResultOnlineDetails result) {
    return ScreenTopBackgroundContainer(
      heightPercentage: UiUtils.appBarBiggerHeightPercentage + (0.03),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Column(
            children: [
              Stack(
                children: [
                  const CustomBackButton(),
                  Align(
                    child: Text(
                      UiUtils.getTranslatedLabel(context, examResultKey),
                      style: setTextStyle(
                        txtColor: Theme.of(context).scaffoldBackgroundColor,
                        txtSize: UiUtils.screenTitleFontSize,
                      ),
                    ),
                  ),
                ],
              ),
              20.sizedBoxHeight,
              Column(
                children: [
                  Text(
                    widget.subjectName,
                    style: setTextStyle(
                      txtColor: Theme.of(context).scaffoldBackgroundColor,
                      txtSize: UiUtils.screenSubTitleFontSize,
                    ),
                  ),
                  Text(
                    widget.examName,
                    style: setTextStyle(
                      txtColor: Theme.of(context).scaffoldBackgroundColor,
                      txtSize: UiUtils.screenTitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  10.sizedBoxHeight,
                  CustomRoundedButton(
                    widthPercentage: 0.8,
                    radius: 25,
                    height: 40,
                    backgroundColor: Colors.transparent,
                    buttonTitle:
                        "${UiUtils.getTranslatedLabel(context, obtainedMarksKey)} :  ${result.totalObtainedMarks} / ${result.totalMarks}",
                    textSize: 14,
                    showBorder: true,
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget setTitleAndTotalQuestions({
    required String titleTxt,
    required int totalQuestions,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$titleTxt ${UiUtils.getTranslatedLabel(context, marksKey)} ${UiUtils.getTranslatedLabel(context, questionsKey)}",
          style: setTextStyle(
            txtColor: UiUtils.getColorScheme(context).onBackground,
            txtSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "[ $totalQuestions ]",
          style: setTextStyle(
            txtColor: UiUtils.getColorScheme(context).onBackground,
            txtSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget setMarksQuestionsContainer({
    required String titleTxt,
    required int totalQuestions,
    required String correctAnswerCount,
    required String incorrectAnswerCount,
  }) {
    return Column(
      children: [
        setTitleAndTotalQuestions(
          titleTxt: titleTxt,
          totalQuestions: totalQuestions,
        ),
        buildQuestionsAnalysisContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    correctAnswerCount,
                    style: setTextStyle(
                      txtColor: UiUtils.getColorScheme(context).onBackground,
                      txtSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  3.sizedBoxHeight,
                  Text(
                    UiUtils.getTranslatedLabel(context, correctAnswersKey),
                    style: setTextStyle(
                      txtColor: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.7),
                      txtSize: 12,
                    ),
                  ),
                  5.sizedBoxHeight,
                  setCurvedBottomContainer(
                    bgColor: UiUtils.getColorScheme(context).onSecondary,
                  )
                ],
              ),
              SizedBox(
                height: 45,
                child: VerticalDivider(
                  thickness: 1,
                  indent: 0,
                  endIndent: 10,
                  width: 20,
                  color: UiUtils.getColorScheme(context)
                      .onBackground
                      .withOpacity(0.4),
                ),
              ),
              Column(
                children: [
                  Text(
                    incorrectAnswerCount,
                    style: setTextStyle(
                      txtColor: UiUtils.getColorScheme(context).onBackground,
                      txtSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  3.sizedBoxHeight,
                  Text(
                    UiUtils.getTranslatedLabel(context, incorrectAnswersKey),
                    style: setTextStyle(
                      txtColor: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.7),
                      txtSize: 12,
                    ),
                  ),
                  5.sizedBoxHeight,
                  setCurvedBottomContainer(
                    bgColor: UiUtils.getColorScheme(context).error,
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget setCurvedBottomContainer({required Color bgColor}) {
    return Container(
      width: MediaQuery.of(context).size.width * (0.295),
      height: MediaQuery.of(context).size.height * (0.010),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }

  Widget buildQuestionsAnalysisContainer({required Widget child}) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        width: MediaQuery.of(context).size.width * (0.9),
        padding: const EdgeInsets.only(top: 15, left: 23, right: 23),
        decoration: BoxDecoration(
          color: UiUtils.getColorScheme(context).background,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: child,
      ),
    );
  }

  Widget buildQuestionCountContainer({
    required Color bgColor,
    required String questionsCount,
    required String questionTypeTxt,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        width: MediaQuery.of(context).size.width * (0.42),
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              questionsCount,
              style: setTextStyle(
                txtColor: Theme.of(context).scaffoldBackgroundColor,
                txtSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              questionTypeTxt,
              style: setTextStyle(
                txtColor: Theme.of(context).scaffoldBackgroundColor,
                txtSize: 12,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildResultSummary(ResultOnlineDetails result) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      padding: EdgeInsets.only(
        top: UiUtils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
        ),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  setTitleAndTotalQuestions(
                    titleTxt: UiUtils.getTranslatedLabel(context, totalKey),
                    totalQuestions: result.totalQuestions!,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: buildQuestionCountContainer(
                          questionsCount:
                              result.correctAnswers!.totalQuestions.toString(),
                          questionTypeTxt: UiUtils.getTranslatedLabel(
                            context,
                            correctAnswersKey,
                          ),
                          bgColor: UiUtils.getColorScheme(context).onPrimary,
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: buildQuestionCountContainer(
                          questionsCount: result
                              .inCorrectAnswers!.totalQuestions
                              .toString(),
                          questionTypeTxt: UiUtils.getTranslatedLabel(
                            context,
                            incorrectAnswersKey,
                          ),
                          bgColor: UiUtils.getColorScheme(context).error,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Column(
              children: context
                  .read<ResultOnlineCubit>()
                  .getUniqueCorrectAnswerMark()
                  .map((questionMark) {
                return setMarksQuestionsContainer(
                  titleTxt: questionMark.toString(),
                  totalQuestions: context
                      .read<ResultOnlineCubit>()
                      .getTotalQuestionsOfMark(questionMark!),
                  correctAnswerCount: context
                      .read<ResultOnlineCubit>()
                      .getCorectAnswersByMark(questionMark)
                      .length
                      .toString(),
                  incorrectAnswerCount: context
                      .read<ResultOnlineCubit>()
                      .getIncorectAnswersByMark(questionMark)
                      .length
                      .toString(),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget shimmerRowContainer(BoxConstraints boxConstraints) {
    return Row(
      children: [
        CustomShimmerContainer(
          borderRadius: 20,
          height: boxConstraints.maxWidth * (0.305),
          width: boxConstraints.maxWidth * (0.47),
        ),
        SizedBox(
          width: boxConstraints.maxWidth * (0.055),
        ),
        CustomShimmerContainer(
          borderRadius: 20,
          height: boxConstraints.maxWidth * (0.305),
          width: boxConstraints.maxWidth * (0.47),
        )
      ],
    );
  }

  Widget shimmerColumnContainer(BoxConstraints boxConstraints) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              CustomShimmerContainer(width: boxConstraints.maxWidth * (0.4)),
              const Spacer(),
              CustomShimmerContainer(width: boxConstraints.maxWidth * (0.15)),
            ],
          ),
        ),
        10.sizedBoxHeight,
        CustomShimmerContainer(
          borderRadius: 20,
          height: boxConstraints.maxWidth * (0.295),
          width: boxConstraints.maxWidth * (0.97),
        )
      ],
    );
  }

  Container buildShimmerLoadingResultDetailsContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      padding: EdgeInsets.only(
        bottom: 15,
        top: MediaQuery.of(context).size.height * 0.285,
      ),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return ShimmerLoadingContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      CustomShimmerContainer(
                        width: boxConstraints.maxWidth * (0.6),
                      ),
                      const Spacer(),
                      CustomShimmerContainer(
                        width: boxConstraints.maxWidth * (0.15),
                      ),
                    ],
                  ),
                ),
                10.sizedBoxHeight,
                shimmerRowContainer(boxConstraints),
                25.sizedBoxHeight,
                shimmerColumnContainer(boxConstraints),
                15.sizedBoxHeight,
                shimmerColumnContainer(boxConstraints),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ResultOnlineCubit, ResultOnlineState>(
        builder: (context, state) {
          if (state is ResultOnlineFetchSuccess) {
            return Stack(
              children: [
                buildResultSummary(state.result),
                Align(
                  alignment: Alignment.topCenter,
                  child: buildResultAppBar(state.result),
                ),
              ],
            );
          }
          if (state is ResultOnlineFetchFailure) {
            return ErrorContainer(
              errorMessageCode: state.errorMessage,
              onTapRetry: fetchResultDetails,
            );
          }
          return buildShimmerLoadingResultDetailsContainer();
        },
      ),
    );
  }

  TextStyle setTextStyle({
    required Color txtColor,
    required double txtSize,
    FontWeight? fontWeight = FontWeight.normal,
  }) {
    return TextStyle(
      color: txtColor,
      fontSize: txtSize,
      fontWeight: fontWeight,
    );
  }
}
