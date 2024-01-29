import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/studentSubjectAndSlidersCubit.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/notificationUtils/generalNotificationUtility.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({Key? key}) : super(key: key);

  void showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(UiUtils.getTranslatedLabel(context, sureToLogoutKey)),
        actions: [
          CupertinoButton(
            child: Text(UiUtils.getTranslatedLabel(context, yesKey)),
            onPressed: () {
              //clear the student subjects list at the time of logout
              context.read<StudentSubjectsAndSlidersCubit>().clearSubjects();

              if (context.read<AuthCubit>().isParent()) {
                //If parent is logging out then pop the dialog
                Navigator.of(context).pop();
              }
              NotificationUtility
                  .removeListener(); //remove old notification listeners
              context.read<AuthCubit>().signOut();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(Routes.auth);
            },
          ),
          CupertinoButton(
            child: Text(UiUtils.getTranslatedLabel(context, noKey)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: InkWell(
        onTap: () {
          showLogOutDialog(context);
        },
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width * (0.4),
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 16,
                  width: 16,
                  child: SvgPicture.asset(
                    UiUtils.getImagePath("logout_icon.svg"),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text(
                  UiUtils.getTranslatedLabel(context, logoutKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
