import 'package:eschool/data/models/studyMaterial.dart';
import 'package:eschool/ui/styles/colors.dart';
import 'package:eschool/ui/widgets/commonImageWidget.dart';
import 'package:eschool/ui/widgets/customAppbar.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ImageFileScreen extends StatefulWidget {
  final StudyMaterial imageFileMaterial;
  final List<StudyMaterial> listOfImages;
  final bool isFile;
  final int? initialPage;
  const ImageFileScreen(
      {super.key,
      required this.imageFileMaterial,
      required this.listOfImages,
      required this.isFile,
      this.initialPage});

  static Route route(RouteSettings routeSettings) {
    final StudyMaterial studyMaterial =
        (routeSettings.arguments as Map?)?["studyMaterial"] ??
            StudyMaterial.fromJson({});
    final List<StudyMaterial> multipleFiles =
        (routeSettings.arguments as Map?)?["multiStudyMaterial"] ?? [];
    final bool isItFile = (routeSettings.arguments as Map?)?["isFile"] ?? false;
    final int? initialPageNumber =
        (routeSettings.arguments as Map?)?["initialPage"];

    return CupertinoPageRoute(
      builder: (_) => ImageFileScreen(
        imageFileMaterial: studyMaterial,
        listOfImages: multipleFiles,
        isFile: isItFile,
        initialPage: initialPageNumber,
      ),
    );
  }

  @override
  State<ImageFileScreen> createState() => _ImageFileScreenState();
}

class _ImageFileScreenState extends State<ImageFileScreen> {
  late final ValueNotifier<int> _currentImageIndex;
  late final PageController _pageController;
  bool isFullScreen = false;

  @override
  void initState() {
    //goto initial page if specified
    final initialPage = widget.initialPage ?? 0;
    _currentImageIndex = ValueNotifier(initialPage);
    _pageController = PageController(initialPage: initialPage);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentImageIndex.dispose();
    super.dispose();
  }

  _fileCountContainer({required int currentValue, required int totalValues}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black38,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        "$currentValue / $totalValues",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          setState(() {
            isFullScreen = !isFullScreen;
          });
        },
        child: Icon(
          isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: !isFullScreen
                  ? UiUtils.getScrollViewTopPadding(
                      context: context,
                      appBarHeightPercentage:
                          UiUtils.appBarSmallerHeightPercentage,
                      keepExtraSpace: false,
                    )
                  : 0,
            ),
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: (value) {
                    _currentImageIndex.value = value;
                  },
                  children: (widget.listOfImages.isEmpty
                          ? [widget.imageFileMaterial]
                          : widget.listOfImages)
                      .map((e) => InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4,
                            child: Container(
                              alignment: Alignment.center,
                              child: CommonImageWidget(
                                imagePath: e.fileUrl,
                                isFile: widget.isFile,
                                boxFit: BoxFit.contain,
                                errorWidget: (context, url, error) => Center(
                                  child: ErrorContainer(
                                    errorMessageText:
                                        UiUtils.getTranslatedLabel(
                                            context, imageFileOpenErrorKey),
                                  ),
                                ),
                                progressIndicatorBuilder:
                                    (context, url, progress) => Padding(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * 0.1),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        UiUtils.getTranslatedLabel(
                                            context, imageFileLoadingKey),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "${((progress.downloaded / (progress.totalSize ?? 100)) * 100).toStringAsFixed(2)} %",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: 6,
                                        child: LayoutBuilder(
                                          builder: (context, boxConstraints) {
                                            return Stack(
                                              children: [
                                                UiUtils.buildProgressContainer(
                                                  width:
                                                      boxConstraints.maxWidth,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onBackground
                                                      .withOpacity(0.5),
                                                ),
                                                UiUtils.buildProgressContainer(
                                                  width: boxConstraints
                                                          .maxWidth *
                                                      (progress.downloaded /
                                                          (progress.totalSize ??
                                                              100)) *
                                                      100 *
                                                      0.01,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                Positioned(
                  top: 30,
                  right: 15,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentImageIndex,
                    builder: (context, value, child) =>
                        widget.listOfImages.isEmpty
                            ? const SizedBox.shrink()
                            : _fileCountContainer(
                                currentValue: value + 1,
                                totalValues: widget.listOfImages.length),
                  ),
                ),
              ],
            ),
          ),
          if (!isFullScreen)
            ValueListenableBuilder<int>(
                valueListenable: _currentImageIndex,
                builder: (context, value, child) {
                  final StudyMaterial current = widget.listOfImages.isEmpty
                      ? widget.imageFileMaterial
                      : widget.listOfImages[value];
                  return CustomAppBar(
                    title: current.fileName.substring(
                      0,
                      current.fileName.lastIndexOf('.') == -1
                          ? current.fileName.length
                          : current.fileName.lastIndexOf('.'),
                    ),
                    actionButton: widget.isFile
                        ? null
                        : IconButton(
                            icon: SvgPicture.asset(
                              UiUtils.getImagePath("download_icon.svg"),
                              width: 20,
                              height: 20,
                            ),
                            onPressed: () {
                              UiUtils.openDownloadBottomsheet(
                                context: context,
                                studyMaterial: current,
                              );
                            },
                          ),
                  );
                }),
        ],
      ),
    );
  }
}
