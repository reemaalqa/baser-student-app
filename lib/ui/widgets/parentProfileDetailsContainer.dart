import 'package:eschool/data/models/parent.dart';
import 'package:eschool/ui/widgets/customUserProfileImageWidget.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';

class ParentProfileDetailsContainer extends StatelessWidget {
  final String nameKey; //motherName,fatherName,guardianName and name
  final Parent parent;
  const ParentProfileDetailsContainer({
    Key? key,
    required this.nameKey,
    required this.parent,
  }) : super(key: key);

  Widget _buildParentDetailsTitleAndValue({
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.75),
              fontSize: 13.0,
            ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * (0.8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Theme.of(context).colorScheme.background,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            top: -40,
            start: MediaQuery.of(context).size.width * (0.4) - 42.5,
            child: Container(
              width: 85.0,
              height: 85.0,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: CustomUserProfileImageWidget(profileUrl: parent.image),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 60,
              ),
              Divider(
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.75),
                height: 1.25,
              ),
              const SizedBox(
                height: 20,
              ),
              _buildParentDetailsTitleAndValue(
                title: UiUtils.getTranslatedLabel(context, nameKey),
                context: context,
                value: UiUtils.formatEmptyValue(
                  "${parent.firstName} ${parent.lastName}",
                ),
              ),
              _buildParentDetailsTitleAndValue(
                context: context,
                title: UiUtils.getTranslatedLabel(context, dateOfBirthKey),
                value: UiUtils.formatEmptyValue(
                    DateTime.tryParse(parent.dob) == null
                        ? parent.dob
                        : UiUtils.formatDate(DateTime.tryParse(parent.dob)!)),
              ),
              _buildParentDetailsTitleAndValue(
                context: context,
                title: UiUtils.getTranslatedLabel(context, emailKey),
                value: UiUtils.formatEmptyValue(parent.email),
              ),
              _buildParentDetailsTitleAndValue(
                context: context,
                title: UiUtils.getTranslatedLabel(context, occupationKey),
                value: UiUtils.formatEmptyValue(parent.occupation),
              ),
              _buildParentDetailsTitleAndValue(
                context: context,
                title: UiUtils.getTranslatedLabel(context, phoneNumberKey),
                value: UiUtils.formatEmptyValue(parent.mobile),
              ),
              //address hidden as not added from backend at the moment
              // _buildParentDetailsTitleAndValue(
              //   context: context,
              //   title: UiUtils.getTranslatedLabel(context, addressKey),
              //   value: UiUtils.formatEmptyValue(parent.currentAddress),
              // ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
