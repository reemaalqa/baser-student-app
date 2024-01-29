import 'package:eschool/cubits/resetPasswordRequestCubit.dart';
import 'package:eschool/ui/widgets/bottomsheetTopTitleAndCloseButton.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestResetPasswordBottomsheet extends StatefulWidget {
  const RequestResetPasswordBottomsheet({Key? key}) : super(key: key);

  @override
  State<RequestResetPasswordBottomsheet> createState() =>
      _RequestResetPasswordBottomsheetState();
}

class _RequestResetPasswordBottomsheetState
    extends State<RequestResetPasswordBottomsheet> {
  final TextEditingController _grNumberTextEditingController =
      TextEditingController();

  DateTime? dateOfBirth;

  @override
  void dispose() {
    _grNumberTextEditingController.dispose();
    super.dispose();
  }

  String _formatDateOfBirth() {
    return UiUtils.formatDate(dateOfBirth!);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (context.read<RequestResetPasswordCubit>().state
            is RequestResetPasswordInProgress) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Container(
        margin: MediaQuery.of(context).viewInsets,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (0.075),
          vertical: MediaQuery.of(context).size.height * (0.04),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(UiUtils.bottomSheetTopRadius),
            topRight: Radius.circular(UiUtils.bottomSheetTopRadius),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BottomsheetTopTitleAndCloseButton(
                onTapCloseButton: () {
                  if (context.read<RequestResetPasswordCubit>().state
                      is RequestResetPasswordInProgress) {
                    return;
                  }
                  Navigator.of(context).pop();
                },
                titleKey: resetPasswordKey,
              ),
              CustomTextFieldContainer(
                hideText: false,
                hintTextKey: grNumberKey,
                textEditingController: _grNumberTextEditingController,
              ),
              GestureDetector(
                onTap: () {
                  showDatePicker(
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                                onPrimary:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                        ),
                        child: child!,
                      );
                    },
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(
                      DateTime.now().year - 50,
                    ),
                    lastDate: DateTime.now(),
                  ).then((value) {
                    dateOfBirth = value;
                    setState(() {});
                  });
                },
                child: Container(
                  alignment: AlignmentDirectional.centerStart,
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 10.0),
                  padding: const EdgeInsetsDirectional.only(
                    start: 20.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: UiUtils.getColorScheme(context).secondary,
                    ),
                  ),
                  child: Text(
                    dateOfBirth == null
                        ? UiUtils.getTranslatedLabel(context, dateOfBirthKey)
                        : _formatDateOfBirth(),
                    style: TextStyle(
                      color: UiUtils.getColorScheme(context).secondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.025),
              ),
              BlocConsumer<RequestResetPasswordCubit,
                  RequestResetPasswordState>(
                listener: (context, state) {
                  if (state is RequestResetPasswordFailure) {
                    UiUtils.showCustomSnackBar(
                      context: context,
                      errorMessage: UiUtils.getErrorMessageFromErrorCode(
                        context,
                        state.errorMessage,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    );
                  } else if (state is RequestResetPasswordSuccess) {
                    Navigator.of(context).pop({
                      "error": false,
                    });
                  }
                },
                builder: (context, state) {
                  return CustomRoundedButton(
                    onTap: () {
                      if (state is RequestResetPasswordInProgress) {
                        return;
                      }
                      FocusScope.of(context).unfocus();
                      if (_grNumberTextEditingController.text.trim().isEmpty) {
                        UiUtils.showCustomSnackBar(
                          context: context,
                          errorMessage: UiUtils.getTranslatedLabel(
                            context,
                            enterGrNumberKey,
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        );
                        return;
                      }
                      if (dateOfBirth == null) {
                        UiUtils.showCustomSnackBar(
                          context: context,
                          errorMessage: UiUtils.getTranslatedLabel(
                            context,
                            selectDateOfBirthKey,
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        );
                        return;
                      }
                      context
                          .read<RequestResetPasswordCubit>()
                          .requestResetPassword(
                            grNumber:
                                _grNumberTextEditingController.text.trim(),
                            dob: dateOfBirth!,
                          );
                    },
                    height: 40,
                    textSize: 16.0,
                    widthPercentage: 0.45,
                    titleColor: Theme.of(context).scaffoldBackgroundColor,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: UiUtils.getTranslatedLabel(
                      context,
                      state is RequestResetPasswordInProgress
                          ? submittingKey
                          : submitKey,
                    ),
                    showBorder: false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
