import 'dart:io';

import 'package:eschool/ui/styles/colors.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/errorMessageKeysAndCodes.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

enum AttachmentFileSelectionType {
  camara,
  gallery,
  document,
}

class AttachmentDialogWidget extends StatefulWidget {
  final Function(List<String> selectedFilePaths, bool isImage) onItemSelected;
  final Function() onCancel;
  const AttachmentDialogWidget(
      {super.key, required this.onItemSelected, required this.onCancel});

  @override
  State<AttachmentDialogWidget> createState() => _AttachmentDialogWidgetState();
}

class _AttachmentDialogWidgetState extends State<AttachmentDialogWidget> {
  AttachmentFileSelectionType selectionType =
      AttachmentFileSelectionType.camara;
  List<String> selectedFilePaths = [];
  bool loading = false;

  onFilesPicked() async {
    setState(() {
      loading = true;
    });
    try {
      List<String> tempPaths = [];
      if (selectionType == AttachmentFileSelectionType.document) {
        //document picking logic
        FilePickerResult? result =
            await FilePicker.platform.pickFiles(allowMultiple: true);
        if (result != null) {
          tempPaths = result.files.map((e) => e.path ?? "").toList();
        }
      } else if (selectionType == AttachmentFileSelectionType.gallery) {
        //gallery picking logic
        final ImagePicker picker = ImagePicker();
        final result = await picker.pickMultiImage();
        if (result.isNotEmpty) {
          tempPaths = result.map<String>((e) => e.path).toList();
        }
      } else {
        //camara picking logic
        final ImagePicker picker = ImagePicker();
        final result = await picker.pickImage(source: ImageSource.camera);
        if (result != null) {
          tempPaths = [result.path];
        }
      }
      int totalNumberOfFilesRemovedBecauseOfMaxNumberLimit = 0;
      int totalNumberOfFilesRemovedBecauseOfMaxSizeLimit = 0;
      for (int i = 0; i < tempPaths.length; i++) {
        if (!selectedFilePaths.contains(tempPaths[i])) {
          //add if already not added the same file with size and total count validations
          if (selectedFilePaths.length >= maxFilesOrImagesInOneMessage) {
            totalNumberOfFilesRemovedBecauseOfMaxNumberLimit++;
          } else if ((await File(tempPaths[i]).length()) >=
              maxFileSizeInBytesCanBeSent) {
            totalNumberOfFilesRemovedBecauseOfMaxSizeLimit++;
          } else {
            selectedFilePaths.add(tempPaths[i]);
          }
        }
      }
      if (totalNumberOfFilesRemovedBecauseOfMaxNumberLimit != 0 ||
          totalNumberOfFilesRemovedBecauseOfMaxSizeLimit != 0) {
        if (context.mounted) {
          UiUtils.showCustomSnackBar(
            context: context,
            errorMessage:
                "${totalNumberOfFilesRemovedBecauseOfMaxNumberLimit != 0 ? "${UiUtils.getTranslatedLabel(context, maxAllowedFilesAreKey)} $maxFilesOrImagesInOneMessage, ${UiUtils.getTranslatedLabel(context, removedKey)} $totalNumberOfFilesRemovedBecauseOfMaxNumberLimit ${UiUtils.getTranslatedLabel(context, extraKey)}." : ""} ${totalNumberOfFilesRemovedBecauseOfMaxSizeLimit != 0 ? "${UiUtils.getTranslatedLabel(context, removedKey)} $totalNumberOfFilesRemovedBecauseOfMaxSizeLimit ${UiUtils.getTranslatedLabel(context, filesAsTheyExceededTheLimitOfKey)} ${UiUtils.getFileSizeString(
                    bytes: maxFileSizeInBytesCanBeSent,
                  )}." : ""}",
            backgroundColor: Theme.of(context).colorScheme.error,
          );
        }
      }
    } on PlatformException catch (_) {
      if (context.mounted) {
        UiUtils.showCustomSnackBar(
            context: context,
            errorMessage: UiUtils.getTranslatedLabel(
                context,
                ErrorMessageKeysAndCode.getErrorMessageKeyFromCode(
                    ErrorMessageKeysAndCode.permissionNotGivenCode)),
            backgroundColor: errorColor);
      }
    } catch (_) {
      if (context.mounted) {
        UiUtils.showCustomSnackBar(
            context: context,
            errorMessage: UiUtils.getTranslatedLabel(
                context,
                ErrorMessageKeysAndCode.getErrorMessageKeyFromCode(
                    ErrorMessageKeysAndCode.defaultErrorMessageCode)),
            backgroundColor: errorColor);
      }
    }
    loading = false;
    setState(() {});
  }

  onClickSend() {
    widget.onItemSelected(selectedFilePaths,
        selectionType == AttachmentFileSelectionType.document ? false : true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: secondaryColor.withOpacity(0.05),
      ),
      padding: const EdgeInsets.all(10),
      child: loading
          ? Container(
              height: 100,
              alignment: Alignment.center,
              child: const SizedBox(
                height: 30,
                width: 30,
                child: CustomCircularProgressIndicator(
                  indicatorColor: primaryColor,
                ),
              ),
            )
          : selectedFilePaths.isEmpty
              ? SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      {
                        "image": UiUtils.getImagePath("document_attach.svg"),
                        "text":
                            UiUtils.getTranslatedLabel(context, documentKey),
                        "onTap": () {
                          selectionType = AttachmentFileSelectionType.document;
                          onFilesPicked();
                        }
                      },
                      {
                        "image":
                            UiUtils.getImagePath("camara_image_attach.svg"),
                        "text": UiUtils.getTranslatedLabel(context, cameraKey),
                        "onTap": () {
                          selectionType = AttachmentFileSelectionType.camara;
                          onFilesPicked();
                        }
                      },
                      {
                        "image":
                            UiUtils.getImagePath("gallery_image_attach.svg"),
                        "text": UiUtils.getTranslatedLabel(context, galleryKey),
                        "onTap": () {
                          selectionType = AttachmentFileSelectionType.gallery;
                          onFilesPicked();
                        }
                      },
                    ].map<Widget>((e) {
                      return Expanded(
                        child: InkWell(
                          onTap: e["onTap"] as Function(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(15),
                                    child: SvgPicture.asset(
                                      e["image"] as String,
                                      fit: BoxFit.cover,
                                      colorFilter: const ColorFilter.mode(
                                          Colors.white, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                e["text"] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: secondaryColor.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              "${UiUtils.getTranslatedLabel(context, selectionType == AttachmentFileSelectionType.camara ? camaraImagesKey : selectionType == AttachmentFileSelectionType.document ? selectedFilesKey : pickedImages)} (${selectedFilePaths.length})",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            onTap: () {
                              onFilesPicked();
                            },
                            child: const Icon(
                              Icons.add,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: selectionType ==
                                AttachmentFileSelectionType.document
                            ? List.generate(selectedFilePaths.length, (index) {
                                //normal selected file UI
                                return SizedBox(
                                  height: 100,
                                  width: 150,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: primaryColor,
                                          ),
                                          padding: const EdgeInsets.all(5),
                                          height: 100,
                                          width: 150,
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                UiUtils.getImagePath(
                                                    "document_attach.svg"),
                                                width: 25,
                                                height: 25,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                        Colors.white,
                                                        BlendMode.srcIn),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                selectedFilePaths[index]
                                                    .split("/")
                                                    .last
                                                    .toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional.topEnd,
                                          child: Container(
                                            margin: const EdgeInsets.all(5),
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white24),
                                            child: InkWell(
                                              onTap: () {
                                                selectedFilePaths
                                                    .removeAt(index);
                                                setState(() {});
                                              },
                                              child: const Icon(
                                                Icons.close_rounded,
                                                color: redColor,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              })
                            : List.generate(selectedFilePaths.length, (index) {
                                //image files selected UI
                                return SizedBox(
                                  height: 100,
                                  width: 130,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: primaryColor,
                                          ),
                                          height: 100,
                                          width: 130,
                                          clipBehavior: Clip.antiAlias,
                                          child: Image.file(
                                            File(selectedFilePaths[index]),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional.topEnd,
                                          child: Container(
                                            margin: const EdgeInsets.all(5),
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white24),
                                            child: InkWell(
                                              onTap: () {
                                                selectedFilePaths
                                                    .removeAt(index);
                                                setState(() {});
                                              },
                                              child: const Icon(
                                                Icons.close_rounded,
                                                color: redColor,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: CustomRoundedButton(
                              onTap: () {
                                widget.onCancel();
                              },
                              widthPercentage: 0.3,
                              height: 40,
                              textAlign: TextAlign.center,
                              backgroundColor: Colors.transparent,
                              buttonTitle: UiUtils.getTranslatedLabel(
                                  context, cancelKey),
                              titleColor:
                                  UiUtils.getColorScheme(context).primary,
                              showBorder: true,
                              borderColor:
                                  UiUtils.getColorScheme(context).primary,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: CustomRoundedButton(
                              onTap: () {
                                onClickSend();
                              },
                              widthPercentage: 0.3,
                              height: 40,
                              textAlign: TextAlign.center,
                              backgroundColor:
                                  UiUtils.getColorScheme(context).primary,
                              buttonTitle:
                                  UiUtils.getTranslatedLabel(context, sendKey),
                              titleColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              showBorder: false,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
