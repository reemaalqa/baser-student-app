import 'package:eschool/cubits/pdfFileCubit.dart';
import 'package:eschool/data/models/studyMaterial.dart';
import 'package:eschool/data/repositories/subjectRepository.dart';
import 'package:eschool/ui/styles/colors.dart';
import 'package:eschool/ui/widgets/customAppbar.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/svg.dart';

class PdfFileScreen extends StatefulWidget {
  final StudyMaterial pdfFileMaterial;
  final bool isFile;
  const PdfFileScreen(
      {super.key, required this.pdfFileMaterial, this.isFile = false});

  static Route route(RouteSettings routeSettings) {
    final StudyMaterial studyMaterial =
        (routeSettings.arguments as Map?)?["studyMaterial"] ??
            StudyMaterial.fromJson({});
    final bool isItFile = (routeSettings.arguments as Map?)?["isFile"] ?? false;
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
          create: (context) => PdfFileSaveCubit(SubjectRepository()),
          child: PdfFileScreen(
            pdfFileMaterial: studyMaterial,
            isFile: isItFile,
          )),
    );
  }

  @override
  State<PdfFileScreen> createState() => _PdfFileScreenState();
}

class _PdfFileScreenState extends State<PdfFileScreen> {
  bool isFullScreen = false;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context.read<PdfFileSaveCubit>().savePdfFile(
          studyMaterial: widget.pdfFileMaterial,
          storeInExternalStorage: false,
          isFile: widget.isFile);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BlocBuilder<PdfFileSaveCubit, PdfFileSaveState>(
        builder: (context, state) {
          if (state is PdfFileSaveSuccess) {
            return FloatingActionButton(
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
            );
          }
          return const SizedBox.shrink();
        },
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
            child: BlocBuilder<PdfFileSaveCubit, PdfFileSaveState>(
              builder: (context, state) {
                if (state is PdfFileSaveInProgress) {
                  return Padding(
                    padding:
                        EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          UiUtils.getTranslatedLabel(
                              context, pdfFileLoadingKey),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${state.uploadedPercentage.toStringAsFixed(2)} %",
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
                                    width: boxConstraints.maxWidth,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.5),
                                  ),
                                  UiUtils.buildProgressContainer(
                                    width: boxConstraints.maxWidth *
                                        state.uploadedPercentage *
                                        0.01,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is PdfFileSaveSuccess) {
                  return PDFView(
                    filePath: state.pdfFilePath,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: true,
                    pageFling: false,
                  );
                } else {
                  return Center(
                    child: ErrorContainer(
                      errorMessageText: UiUtils.getTranslatedLabel(
                          context, pdfFileOpenErrorKey),
                    ),
                  );
                }
              },
            ),
          ),
          if (!isFullScreen)
            CustomAppBar(
              title: widget.pdfFileMaterial.fileName
                  .replaceFirst(".${widget.pdfFileMaterial.fileExtension}", ""),
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
                          studyMaterial: widget.pdfFileMaterial,
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
