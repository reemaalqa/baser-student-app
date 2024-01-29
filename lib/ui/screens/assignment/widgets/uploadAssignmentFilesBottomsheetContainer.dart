import 'package:dotted_border/dotted_border.dart';
import 'package:eschool/cubits/uploadAssignmentCubit.dart';
import 'package:eschool/data/models/assignment.dart';
import 'package:eschool/ui/widgets/bottomsheetTopTitleAndCloseButton.dart';

import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadAssignmentFilesBottomsheetContainer extends StatefulWidget {
  final Assignment assignment;
  final bool isEditingOnSubmittedAssignment;

  const UploadAssignmentFilesBottomsheetContainer({
    Key? key,
    required this.assignment,
    this.isEditingOnSubmittedAssignment = false,
  }) : super(key: key);

  @override
  State<UploadAssignmentFilesBottomsheetContainer> createState() =>
      _UploadAssignmentFilesBottomsheetContainerState();
}

class _UploadAssignmentFilesBottomsheetContainerState
    extends State<UploadAssignmentFilesBottomsheetContainer> {
  List<PlatformFile> uploadedFiles = [];

  Future<void> _pickFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      uploadedFiles.addAll(result.files);
      setState(() {});
    }
  }

  Future<void> _addFiles() async {
    //upload files
    final permission = await Permission.storage.request();
    if (permission.isGranted) {
      await _pickFiles();
    } else {
      try {
        await _pickFiles();
      } on Exception {
        if (context.mounted) {
          UiUtils.showCustomSnackBar(
              context: context,
              errorMessage: UiUtils.getTranslatedLabel(
                  context, allowStoragePermissionToContinueKey),
              backgroundColor: Theme.of(context).colorScheme.error);
          await Future.delayed(const Duration(seconds: 2));
          openAppSettings();
        }
      }
    }
  }

  Widget _buildUploadedFileContainer(int fileIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.background,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10.0),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Row(
            children: [
              SizedBox(
                width: boxConstraints.maxWidth * (0.75),
                child: Text(
                  uploadedFiles[fileIndex].name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  if (context.read<UploadAssignmentCubit>().state
                      is UploadAssignmentInProgress) {
                    return;
                  }
                  uploadedFiles.removeAt(fileIndex);
                  setState(() {});
                },
                icon: const Icon(Icons.close),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (context.read<UploadAssignmentCubit>().state
            is UploadAssignmentInProgress) {
          context.read<UploadAssignmentCubit>().cancelUploadAssignmentProcess();
        }
        return Future.value(true);
      },
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * (0.075),
            vertical: MediaQuery.of(context).size.height * (0.04),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BottomsheetTopTitleAndCloseButton(
                onTapCloseButton: () {
                  if (context.read<UploadAssignmentCubit>().state
                      is UploadAssignmentInProgress) {
                    context
                        .read<UploadAssignmentCubit>()
                        .cancelUploadAssignmentProcess();
                  }
                  Navigator.of(context).pop();
                },
                titleKey: widget.isEditingOnSubmittedAssignment
                    ? changeFilesKey
                    : uploadFilesKey,
              ),
              uploadedFiles.isNotEmpty
                  ? Text(
                      UiUtils.getTranslatedLabel(
                        context,
                        assignmentSubmissionDisclaimerKey,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                height: uploadedFiles.isNotEmpty
                    ? MediaQuery.of(context).size.height * (0.025)
                    : 0,
              ),
              InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () async {
                  _addFiles();
                },
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  dashPattern: const [10, 10],
                  radius: const Radius.circular(15.0),
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.3),
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * (0.8),
                    height: MediaQuery.of(context).size.height * (0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 15,
                                offset: const Offset(0, 1.5),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.3),
                              )
                            ],
                          ),
                          width: 25,
                          height: 25,
                          child: Icon(
                            Icons.add,
                            size: 15,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * (0.05),
                        ),
                        Text(
                          UiUtils.getTranslatedLabel(context, addFilesKey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.025),
              ),
              ...List.generate(uploadedFiles.length, (index) => index)
                  .map((fileIndex) => _buildUploadedFileContainer(fileIndex))
                  .toList(),
              uploadedFiles.isEmpty
                  ? const SizedBox()
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * (0.025),
                    ),
              uploadedFiles.isNotEmpty
                  ? BlocConsumer<UploadAssignmentCubit, UploadAssignmentState>(
                      listener: (context, state) {
                        if (state is UploadAssignmentFetchSuccess) {
                          Navigator.of(context).pop({
                            "error": false,
                            "assignmentSubmission": state.assignmentSubmission
                          });
                        } else if (state is UploadAssignmentFailure) {
                          Navigator.of(context).pop(
                            {"error": true, "message": state.errorMessage},
                          );
                        }
                      },
                      builder: (context, state) {
                        return CustomRoundedButton(
                          onTap: () {
                            if (state is UploadAssignmentInProgress) {
                              return;
                            }
                            context
                                .read<UploadAssignmentCubit>()
                                .uploadAssignment(
                                  assignmentSubmissionId:
                                      widget.assignment.assignmentSubmission.id,
                                  assignmentId: widget.assignment.id,
                                  filePaths: uploadedFiles
                                      .map((file) => file.path!)
                                      .toList(),
                                  isEditingOnSubmittedAssignment:
                                      widget.isEditingOnSubmittedAssignment,
                                );
                          },
                          height: 40,
                          widthPercentage:
                              state is UploadAssignmentInProgress ? 0.65 : 0.35,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          buttonTitle: state is UploadAssignmentInProgress
                              ? "${UiUtils.getTranslatedLabel(context, submittingKey)} (${state.uploadedProgress.toStringAsFixed(2)})%"
                              : UiUtils.getTranslatedLabel(
                                  context,
                                  submitKey,
                                ),
                          showBorder: false,
                        );
                      },
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
