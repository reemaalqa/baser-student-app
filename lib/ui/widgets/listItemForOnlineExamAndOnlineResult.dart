import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';

class ListItemForOnlineExamAndOnlineResult extends StatelessWidget {
  final String examStartingDate;
  final String? examEndingDate;
  final String examName;
  final String subjectName;
  final String totalMarks;
  final String marks;
  final VoidCallback onItemTap;
  final bool isSubjectSelected;

  const ListItemForOnlineExamAndOnlineResult({
    Key? key,
    required this.examStartingDate,
    this.examEndingDate,
    required this.examName,
    required this.totalMarks,
    required this.marks,
    required this.onItemTap,
    required this.subjectName,
    this.isSubjectSelected = false,
  }) : super(key: key);

  Widget _buildDetailsBackgroundContainer({
    required Widget child,
    required BuildContext context,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        width: MediaQuery.of(context).size.width * (0.90),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: UiUtils.getColorScheme(context).background,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: child,
      ),
    );
  }

  TextStyle _getLabelsTextStyle({required BuildContext context}) {
    return TextStyle(
      color: UiUtils.getColorScheme(context).onBackground,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );
  }

  Widget _buildSubjectNameAndDateContainer({
    required BuildContext context,
    required String subjName,
    required bool isSubjectSelected,
    String? examDate,
    String? examEndDate,
  }) {
    return isSubjectSelected
        ? Row(
            children: [
              (marks == '') //for exams only,and not results
                  ? Icon(
                      Icons.access_time_rounded,
                      color: UiUtils.getColorScheme(context).onBackground,
                      size: 15,
                    )
                  : const SizedBox.shrink(),
              2.sizedBoxWidth,
              Text(
                examEndDate == ''
                    ? '--'
                    : (marks != '')
                        ? UiUtils.dateConverter(
                            DateTime.parse(examEndDate!),
                            context,
                            true,
                          )
                        : UiUtils.dateConverter(
                            DateTime.parse(examEndDate!),
                            context,
                            false,
                          ),
                style: _getLabelsTextStyle(context: context),
              ),
            ],
          )
        : Row(
            children: [
              Text(
                subjName,
                style: _getLabelsTextStyle(context: context),
                maxLines: 2,
              ),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  children: [
                    (marks == '') //for exams only,and not results
                        ? Icon(
                            Icons.access_time_rounded,
                            color: UiUtils.getColorScheme(context).onBackground,
                            size: 15,
                          )
                        : const SizedBox.shrink(),
                    2.sizedBoxWidth,
                    Text(
                      examEndDate == ''
                          ? '--'
                          : (marks != '')
                              ? UiUtils.dateConverter(
                                  DateTime.parse(examEndDate!),
                                  context,
                                  true,
                                )
                              : UiUtils.dateConverter(
                                  DateTime.parse(examEndDate!),
                                  context,
                                  false,
                                ),
                      style: _getLabelsTextStyle(context: context),
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  TextStyle _getExamNameAndMarksTextStyle({required BuildContext context}) {
    return TextStyle(
      color: UiUtils.getColorScheme(context).secondary,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildExamNameAndMarksContainer({
    required BuildContext context,
    required String examName,
    required String totalMarks,
    required String marks,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            examName,
            style: _getExamNameAndMarksTextStyle(context: context),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        (marks != '')
            ? Text(
                "${UiUtils.getTranslatedLabel(context, marksKey)} : $marks / $totalMarks",
                style: _getExamNameAndMarksTextStyle(context: context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            : Text(
                "${UiUtils.getTranslatedLabel(context, totalMarksKey)} : $totalMarks",
                style: _getExamNameAndMarksTextStyle(context: context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onItemTap,
      child: _buildDetailsBackgroundContainer(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSubjectNameAndDateContainer(
              context: context,
              subjName: subjectName,
              isSubjectSelected: isSubjectSelected,
              examDate: examStartingDate,
              examEndDate: examEndingDate,
            ),
            const SizedBox(
              height: 5.0,
            ),
            _buildExamNameAndMarksContainer(
              context: context,
              examName: examName,
              marks: marks,
              totalMarks: totalMarks,
            ),
          ],
        ),
      ),
    );
  }
}
