import 'package:eschool/cubits/changePasswordCubit.dart';
import 'package:eschool/ui/widgets/bottomsheetTopTitleAndCloseButton.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool/ui/widgets/passwordHideShowButton.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordBottomsheet extends StatefulWidget {
  const ChangePasswordBottomsheet({Key? key}) : super(key: key);

  @override
  State<ChangePasswordBottomsheet> createState() =>
      _ChangePasswordBottomsheetState();
}

class _ChangePasswordBottomsheetState extends State<ChangePasswordBottomsheet> {
  final TextEditingController _currentPasswordTextEditingController =
      TextEditingController();
  final TextEditingController _newPasswordTextEditingController =
      TextEditingController();
  final TextEditingController _confirmNewPasswordTextEditingController =
      TextEditingController();

  bool _hideCurrentPassword = true;

  bool _hideNewPassword = true;

  bool _hideConfirmNewPassword = true;

  @override
  void dispose() {
    _currentPasswordTextEditingController.dispose();
    _newPasswordTextEditingController.dispose();
    _confirmNewPasswordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (context.read<ChangePasswordCubit>().state
            is ChangePasswordInProgress) {
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
                  if (context.read<ChangePasswordCubit>().state
                      is ChangePasswordInProgress) {
                    return;
                  }
                  Navigator.of(context).pop();
                },
                titleKey: changePasswordKey,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.025),
              ),
              CustomTextFieldContainer(
                suffixWidget: PasswordHideShowButton(
                  hidePassword: _hideCurrentPassword,
                  onTap: () {
                    setState(() {
                      _hideCurrentPassword = !_hideCurrentPassword;
                    });
                  },
                ),
                hideText: _hideCurrentPassword,
                hintTextKey: currentPasswordKey,
                textEditingController: _currentPasswordTextEditingController,
              ),
              CustomTextFieldContainer(
                suffixWidget: PasswordHideShowButton(
                  hidePassword: _hideNewPassword,
                  onTap: () {
                    setState(() {
                      _hideNewPassword = !_hideNewPassword;
                    });
                  },
                ),
                hideText: _hideNewPassword,
                hintTextKey: newPasswordKey,
                textEditingController: _newPasswordTextEditingController,
              ),
              CustomTextFieldContainer(
                suffixWidget: PasswordHideShowButton(
                  hidePassword: _hideConfirmNewPassword,
                  onTap: () {
                    setState(() {
                      _hideConfirmNewPassword = !_hideConfirmNewPassword;
                    });
                  },
                ),
                hideText: _hideConfirmNewPassword,
                hintTextKey: confirmNewPasswordKey,
                textEditingController: _confirmNewPasswordTextEditingController,
              ),
              BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
                listener: (context, state) {
                  if (state is ChangePasswordFailure) {
                    UiUtils.showCustomSnackBar(
                      context: context,
                      errorMessage: UiUtils.getErrorMessageFromErrorCode(
                        context,
                        state.errorMessage,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    );
                  } else if (state is ChangePasswordSuccess) {
                    Navigator.of(context).pop({
                      "error": false,
                    });
                  }
                },
                builder: (context, state) {
                  return CustomRoundedButton(
                    onTap: () {
                      if (state is ChangePasswordInProgress) {
                        return;
                      }
                      FocusScope.of(context).unfocus();
                      if (_currentPasswordTextEditingController.text
                              .trim()
                              .isEmpty ||
                          _newPasswordTextEditingController.text
                              .trim()
                              .isEmpty ||
                          _confirmNewPasswordTextEditingController.text
                              .trim()
                              .isEmpty) {
                        UiUtils.showCustomSnackBar(
                          context: context,
                          errorMessage: UiUtils.getTranslatedLabel(
                            context,
                            pleaseEnterAllFieldKey,
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        );
                        return;
                      }

                      //new password and confirm password must be same
                      if (_newPasswordTextEditingController.text.trim() !=
                          _confirmNewPasswordTextEditingController.text
                              .trim()) {
                        UiUtils.showCustomSnackBar(
                          context: context,
                          errorMessage: UiUtils.getTranslatedLabel(
                            context,
                            newPasswordAndConfirmSameKey,
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        );
                        return;
                      }

                      context.read<ChangePasswordCubit>().changePassword(
                            currentPassword:
                                _currentPasswordTextEditingController.text
                                    .trim(),
                            newPassword:
                                _newPasswordTextEditingController.text.trim(),
                            newConfirmedPassword:
                                _confirmNewPasswordTextEditingController.text
                                    .trim(),
                          );
                    },
                    height: 40,
                    textSize: 16.0,
                    widthPercentage: 0.45,
                    titleColor: Theme.of(context).scaffoldBackgroundColor,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: UiUtils.getTranslatedLabel(
                      context,
                      state is ChangePasswordInProgress
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
