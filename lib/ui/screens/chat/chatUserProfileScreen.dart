import 'package:eschool/data/models/chatUser.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customUserProfileImageWidget.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChatUserProfileScreen extends StatefulWidget {
  final ChatUser chatUser;
  const ChatUserProfileScreen({super.key, required this.chatUser});

  static route(RouteSettings routeSettings) {
    final ChatUser user =
        (routeSettings.arguments as Map<String, dynamic>?)?["chatUser"] ??
            ChatUser.fromJsonAPI({});
    return CupertinoPageRoute(
      builder: (_) => ChatUserProfileScreen(chatUser: user),
    );
  }

  @override
  State<ChatUserProfileScreen> createState() => _ChatUserProfileScreenState();
}

class _ChatUserProfileScreenState extends State<ChatUserProfileScreen> {
  Widget _buildProfileDetailsTile({
    required String label,
    required String value,
    required String iconUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12.5),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1a212121),
                  offset: Offset(0, 10),
                  blurRadius: 16,
                )
              ],
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: SvgPicture.asset(iconUrl),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * (0.05),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.0,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: UiUtils.getScrollViewBottomPadding(context),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.3),
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  ScreenTopBackgroundContainer(
                    child: Stack(
                      children: [
                        const CustomBackButton(),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            UiUtils.getTranslatedLabel(context, profileKey),
                            style: TextStyle(
                              fontSize: UiUtils.screenTitleFontSize,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      width: MediaQuery.of(context).size.width * (0.3),
                      height: MediaQuery.of(context).size.width * (0.3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: CustomUserProfileImageWidget(
                            profileUrl: widget.chatUser.profileUrl),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.chatUser.userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              widget.chatUser.qualification,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                fontSize: 14.0,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (0.075),
              ),
              child: Divider(
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.75),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (0.075),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      UiUtils.getTranslatedLabel(context, personalDetailsKey),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _buildProfileDetailsTile(
                    label: UiUtils.getTranslatedLabel(context, emailKey),
                    value: UiUtils.formatEmptyValue(widget.chatUser.email),
                    iconUrl: UiUtils.getImagePath("user_pro_icon.svg"),
                  ),
                  if (widget.chatUser.classTeacher?.isNotEmpty ?? false)
                    _buildProfileDetailsTile(
                      label:
                          UiUtils.getTranslatedLabel(context, classTeacherKey),
                      value: UiUtils.formatEmptyValue(
                        widget.chatUser.classTeacherString,
                      ),
                      iconUrl: UiUtils.getImagePath("user_pro_class_icon.svg"),
                    ),
                  if (widget.chatUser.subjectNames.isNotEmpty)
                    _buildProfileDetailsTile(
                      label: UiUtils.getTranslatedLabel(
                          context, subjectTeacherKey),
                      value: UiUtils.formatEmptyValue(
                        widget.chatUser.subjects,
                      ),
                      iconUrl: UiUtils.getImagePath("user_pro_class_icon.svg"),
                    ),
                  _buildProfileDetailsTile(
                    label: UiUtils.getTranslatedLabel(context, phoneNumberKey),
                    value:
                        UiUtils.formatEmptyValue(widget.chatUser.mobileNumber),
                    iconUrl: UiUtils.getImagePath("phone-call.svg"),
                  ),
                  if (widget.chatUser.studentNames?.isNotEmpty ?? false)
                    _buildProfileDetailsTile(
                      label: UiUtils.getTranslatedLabel(context, teacherOfKey),
                      value: UiUtils.formatEmptyValue(
                          widget.chatUser.studentNamesString),
                      iconUrl: UiUtils.getImagePath("user_pro_info.svg"),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
