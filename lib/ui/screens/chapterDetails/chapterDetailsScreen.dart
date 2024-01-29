import 'package:eschool/data/models/lesson.dart';
import 'package:eschool/data/models/studyMaterial.dart';
import 'package:eschool/ui/widgets/filesContainer.dart';
import 'package:eschool/ui/screens/chapterDetails/widgets/topicsContainer.dart';
import 'package:eschool/ui/widgets/videosContainer.dart';
import 'package:eschool/ui/widgets/customAppbar.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChapterDetailsScreen extends StatefulWidget {
  final Lesson lesson;

  final int? childId;
  const ChapterDetailsScreen({Key? key, required this.lesson, this.childId})
      : super(key: key);

  @override
  State<ChapterDetailsScreen> createState() => _ChapterDetailsScreenState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) => ChapterDetailsScreen(
        lesson: arguments['lesson'],
        childId: arguments['childId'],
      ),
    );
  }
}

class _ChapterDetailsScreenState extends State<ChapterDetailsScreen> {
  late String _selectedTabTitleKey = topicsKey;
  late List<String> chapterContentTitles = [topicsKey, filesKey, videosKey];

  Widget _buildAppBar() {
    return CustomAppBar(title: widget.lesson.name);
  }

  Widget _buildChapterContentTitles() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * (0.1),
      ),
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: chapterContentTitles
            .map(
              (title) => GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabTitleKey = title;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _selectedTabTitleKey == title
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.center,
                  child: Text(
                    UiUtils.getTranslatedLabel(context, title),
                    style: TextStyle(
                      color: _selectedTabTitleKey == title
                          ? Theme.of(context).scaffoldBackgroundColor
                          : Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: UiUtils.getScrollViewTopPadding(
                  context: context,
                  appBarHeightPercentage: UiUtils.appBarSmallerHeightPercentage,
                ),
              ),
              child: Column(
                children: [
                  _buildChapterContentTitles(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * (0.025),
                  ),
                  _selectedTabTitleKey == topicsKey
                      ? TopicsContainer(
                          topics: widget.lesson.topics,
                          childId: widget.childId,
                        )
                      : _selectedTabTitleKey == filesKey
                          ? FilesContainer(
                              files: widget.lesson.studyMaterials
                                  .where(
                                    (element) =>
                                        element.studyMaterialType ==
                                        StudyMaterialType.file,
                                  )
                                  .toList(),
                            )
                          : VideosContainer(
                              studyMaterials: widget.lesson.studyMaterials
                                  .where(
                                    (element) =>
                                        element.studyMaterialType ==
                                            StudyMaterialType.youtubeVideo ||
                                        element.studyMaterialType ==
                                            StudyMaterialType.uploadedVideoUrl,
                                  )
                                  .toList(),
                            )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(),
          ),
        ],
      ),
    );
  }
}
