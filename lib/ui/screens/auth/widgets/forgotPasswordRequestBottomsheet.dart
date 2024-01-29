import 'package:eschool/cubits/forgotPasswordRequestCubit.dart';
import 'package:eschool/ui/widgets/bottomsheetTopTitleAndCloseButton.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordRequestBottomsheet extends StatefulWidget {
  const ForgotPasswordRequestBottomsheet({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordRequestBottomsheet> createState() =>
      _ForgotPasswordRequestBottomsheetState();
}

class _ForgotPasswordRequestBottomsheetState
    extends State<ForgotPasswordRequestBottomsheet> {
  final TextEditingController _emailTextEditingController =
      TextEditingController();

  @override
  void dispose() {
    _emailTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (context.read<ForgotPasswordRequestCubit>().state
            is ForgotPasswordRequestInProgress) {
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
                  if (context.read<ForgotPasswordRequestCubit>().state
                      is ForgotPasswordRequestInProgress) {
                    return;
                  }
                  Navigator.of(context).pop();
                },
                titleKey: forgotPasswordKey,
              ),
              CustomTextFieldContainer(
                hideText: false,
                hintTextKey: emailKey,
                textEditingController: _emailTextEditingController,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.025),
              ),
              BlocConsumer<ForgotPasswordRequestCubit,
                  ForgotPasswordRequestState>(
                listener: (context, state) {
                  if (state is ForgotPasswordRequestFailure) {
                    UiUtils.showCustomSnackBar(
                      context: context,
                      errorMessage: UiUtils.getErrorMessageFromErrorCode(
                        context,
                        state.errorMessage,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    );
                  } else if (state is ForgotPasswordRequestSuccess) {
                    Navigator.of(context).pop({
                      "error": false,
                      "email": _emailTextEditingController.text.trim()
                    });
                  }
                },
                builder: (context, state) {
                  return CustomRoundedButton(
                    onTap: () {
                      if (state is ForgotPasswordRequestInProgress) {
                        return;
                      }
                      FocusScope.of(context).unfocus();
                      if (_emailTextEditingController.text.trim().isEmpty) {
                        UiUtils.showCustomSnackBar(
                          context: context,
                          errorMessage: UiUtils.getTranslatedLabel(
                            context,
                            pleaseEnterEmailKey,
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        );
                        return;
                      }

                      context
                          .read<ForgotPasswordRequestCubit>()
                          .requestforgotPassword(
                            email: _emailTextEditingController.text.trim(),
                          );
                    },
                    height: 40,
                    textSize: 16.0,
                    widthPercentage: 0.45,
                    titleColor: Theme.of(context).scaffoldBackgroundColor,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: UiUtils.getTranslatedLabel(
                      context,
                      state is ForgotPasswordRequestInProgress
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
