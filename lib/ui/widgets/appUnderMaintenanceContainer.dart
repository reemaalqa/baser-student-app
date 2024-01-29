import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppUnderMaintenanceContainer extends StatelessWidget {
  const AppUnderMaintenanceContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            UiUtils.getImagePath("maintenance.svg"),
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.0125),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              UiUtils.getTranslatedLabel(context, appUnderMaintenanceKey),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          )
        ],
      ),
    );
  }
}
