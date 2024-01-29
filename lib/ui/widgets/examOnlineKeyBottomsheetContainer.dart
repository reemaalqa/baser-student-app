import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:eschool/cubits/appConfigurationCubit.dart';

import 'package:eschool/data/models/examsOnline.dart';

import 'package:eschool/ui/screens/exam/onlineExam/cubits/examOnlineCubit.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';

import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';

class ExamOnlineKeyBottomsheetContainer extends StatefulWidget {
  final ExamsOnline exam;
  final Function navigateToExamScreen;
  const ExamOnlineKeyBottomsheetContainer({
    Key? key,
    required this.exam,
    required this.navigateToExamScreen,
  }) : super(key: key);

  @override
  ExamOnlineKeyBottomsheetContainerState createState() =>
      ExamOnlineKeyBottomsheetContainerState();
}

class ExamOnlineKeyBottomsheetContainerState
    extends State<ExamOnlineKeyBottomsheetContainer> {
  late TextEditingController textEditingController = TextEditingController();

  late String errorMessage = "";

  late bool rulesAccepted = false;

  final double horizontalPaddingPercentage = 0.125;

  Widget _buildAcceptRulesContainer() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal:
            MediaQuery.of(context).size.width * horizontalPaddingPercentage,
        vertical: 10.0,
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          2.sizedBoxWidth,
          InkWell(
            onTap: () {
              setState(() {
                rulesAccepted = !rulesAccepted;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rulesAccepted
                    ? UiUtils.getColorScheme(context).primary
                    : Colors.transparent,
                border: Border.all(
                  width: 1.5,
                  color: rulesAccepted
                      ? UiUtils.getColorScheme(context).primary
                      : UiUtils.getColorScheme(context).secondary,
                ),
              ),
              child: rulesAccepted
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.background,
                      size: 15.0,
                    )
                  : const SizedBox(),
            ),
          ),
          10.sizedBoxWidth,
          Text(
            UiUtils.getTranslatedLabel(context, iAgreeWithExamRulesKey),
            style: TextStyle(
              color: UiUtils.getColorScheme(context).secondary,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * (0.127),
      ),
      child: Divider(
        color: UiUtils.getColorScheme(context).secondary,
      ),
    );
  }

  Widget _buildExamRules() {
    return Flexible(
      flex: 3,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (0.1),
        ),
        child: Html(
          data: context.read<AppConfigurationCubit>().fetchExamRules(),
          shrinkWrap: true,
        ),
      ),
    );
  }

  Widget _buildExamKeyTextFieldContainer() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(
        horizontal:
            MediaQuery.of(context).size.width * horizontalPaddingPercentage,
      ),
      padding: const EdgeInsetsDirectional.only(start: 20.0),
      height: 55.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: UiUtils.getColorScheme(context).background,
        ),
        borderRadius: BorderRadius.circular(10.0),
        color: UiUtils.getColorScheme(context).background,
      ),
      child: TextField(
        controller: textEditingController,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: UiUtils.getColorScheme(context).onSecondary,
        ),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: UiUtils.getTranslatedLabel(context, enterExamKey),
          hintStyle: TextStyle(color: Theme.of(context).hintColor),
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSelectedExamDetails() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 20),
      margin: EdgeInsets.symmetric(
        horizontal:
            MediaQuery.of(context).size.width * horizontalPaddingPercentage,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.exam.subject.showType
                ? widget.exam.subject.subjectNameWithType
                : widget.exam.subject.name,
            style: TextStyle(
              color: UiUtils.getColorScheme(context).secondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            widget.exam.title,
            style: TextStyle(
              color: UiUtils.getColorScheme(context).onSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (context.read<ExamOnlineCubit>().state
            is ExamOnlineFetchInProgress) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: BlocListener<ExamOnlineCubit, ExamOnlineState>(
        bloc: context.read<ExamOnlineCubit>(),
        listener: (context, state) {
          if (state is ExamOnlineFetchFailure) {
            setState(() {
              errorMessage = UiUtils.getErrorMessageFromErrorCode(
                context,
                state.errorMessage,
              );
            });
          } else if (state is ExamOnlineFetchSuccess) {
            widget.navigateToExamScreen();
          }
        },
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * (0.95),
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10.0),
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () {
                                if (context.read<ExamOnlineCubit>().state
                                    is! ExamOnlineFetchInProgress) {
                                  Navigator.of(context).pop();
                                }
                              },
                              icon: Icon(
                                Icons.close,
                                size: 28.0,
                                color:
                                    UiUtils.getColorScheme(context).secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildSelectedExamDetails(),
                    ],
                  ),
                  _buildDivider(),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * (0.127),
                      ),
                      child: Text(
                        UiUtils.getTranslatedLabel(context, examRulesKey),
                        style: TextStyle(
                          color: UiUtils.getColorScheme(context).secondary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildExamRules(),
                  _buildDivider(),
                  _buildAcceptRulesContainer(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * (0.0125),
                  ),
                  _buildExamKeyTextFieldContainer(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * (0.0125),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: errorMessage.isEmpty
                        ? 20.sizedBoxHeight
                        : SizedBox(
                            height: 20.0,
                            child: Text(
                              errorMessage,
                              style: TextStyle(
                                color: UiUtils.getColorScheme(context).error,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height *
                        (errorMessage.isEmpty ? 0 : 0.02),
                  ),
                  //show submit button
                  BlocBuilder<ExamOnlineCubit, ExamOnlineState>(
                    bloc: context.read<ExamOnlineCubit>(),
                    builder: (context, state) {
                      return CustomRoundedButton(
                        onTap: state is ExamOnlineFetchInProgress
                            ? () {}
                            : () {
                                FocusScope.of(context).unfocus();
                                if (!rulesAccepted) {
                                  setState(() {
                                    errorMessage = UiUtils.getTranslatedLabel(
                                      context,
                                      pleaseAcceptExamRulesKey,
                                    );
                                  });
                                } else if (textEditingController.text.trim() ==
                                    widget.exam.examKey.toString()) {
                                  errorMessage = "";
                                  //start exam
                                  context
                                      .read<ExamOnlineCubit>()
                                      .startExam(exam: widget.exam);
                                } else {
                                  setState(() {
                                    errorMessage = UiUtils.getTranslatedLabel(
                                      context,
                                      enterValidExamKey,
                                    );
                                  });
                                }
                              },
                        textSize: 18.0,
                        widthPercentage: 0.75,
                        titleColor: Theme.of(context).scaffoldBackgroundColor,
                        backgroundColor:
                            UiUtils.getColorScheme(context).primary,
                        buttonTitle: UiUtils.getTranslatedLabel(
                          context,
                          state is ExamOnlineFetchInProgress
                              ? submittingKey
                              : submitKey,
                        ),
                        showBorder: false,
                      );
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * (0.02),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
