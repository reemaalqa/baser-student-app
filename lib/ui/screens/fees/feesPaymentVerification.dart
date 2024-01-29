import 'package:eschool/cubits/postFeesPaymentCubit.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class FeesPaymentVerification extends StatefulWidget {
  final Student studentDetails;
  final int transactionId;
  final int? status;
  final String? paymentId;
  final String? orderId; //Razorpay
  final String? paymentSignature;
  final String? paymentIntentId; //stripe

  const FeesPaymentVerification({
    Key? key,
    required this.studentDetails,
    required this.transactionId,
    this.paymentId,
    this.paymentSignature,
    this.orderId,
    this.paymentIntentId,
    required this.status,
  }) : super(key: key);

  @override
  FeesPaymentVerificationState createState() => FeesPaymentVerificationState();
  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => FeesPaymentVerification(
        studentDetails: arguments['studentDetails'],
        transactionId: arguments['transactionId'],
        paymentId: arguments['paymentId'],
        paymentSignature: arguments['paymentSignature'],
        orderId: arguments['orderId'],
        paymentIntentId: arguments['paymentIntentId'],
        status: arguments['status'],
      ),
    );
  }
}

class FeesPaymentVerificationState extends State<FeesPaymentVerification> {
  @override
  void initState() {
    super.initState();
    storeFees();
  }

  void storeFees() {
    Future.delayed(Duration.zero, () {
      //Updating payment status

      context.read<PostFeesPaymentCubit>().storeFees(
            status: widget.status,
            transactionId: widget.transactionId.toString(),
            childId: widget.studentDetails.id,
            verifyStripePaymentIntent: widget.paymentIntentId != null,
            paymentId: widget.paymentId,
            paymentIntentId: widget.paymentIntentId,
            paymentSignature: widget.paymentSignature,
          );
    });
  }

  Widget buildVerificationLottieAnimation({required String jsonFileName}) {
    return Align(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * (0.4),
        child: Lottie.asset(
          "assets/animations/$jsonFileName.json",
          animate: true,
        ),
      ),
    );
  }

  Color setTitleColor({required String statusTitle}) {
    switch (statusTitle) {
      case paymentSuccessTitleKey:
        return UiUtils.getColorScheme(context).onPrimary;

      case paymentFailureTitleKey:
        return UiUtils.getColorScheme(context).error;

      case paymentPendingTitleKey:
        return UiUtils.getColorScheme(context).primary;
      default:
        return UiUtils.getColorScheme(context).primary;
    }
  }

  Widget setTitleAndMessage({
    required String titleText,
    required String msgText,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * (0.065),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            UiUtils.getTranslatedLabel(context, titleText),
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: setTitleColor(statusTitle: titleText),
            ),
          ),
          Text(
            UiUtils.getTranslatedLabel(context, msgText),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              color: UiUtils.getColorScheme(context).secondary,
            ),
          )
        ],
      ),
    );
  }

  Widget onResponse({
    required String jsonFileName,
    required String titleText,
    required String msgText,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Spacer(
          flex: 2,
        ),
        buildVerificationLottieAnimation(jsonFileName: jsonFileName),
        setTitleAndMessage(titleText: titleText, msgText: msgText),
        const Spacer(),
        CustomRoundedButton(
          height: 60,
          widthPercentage: 0.3,
          backgroundColor: Theme.of(context).colorScheme.primary,
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          titleColor: Theme.of(context).scaffoldBackgroundColor,
          buttonTitle: UiUtils.getTranslatedLabel(context, homeKey),
          showBorder: true,
        ),
        const Spacer(
          flex: 2,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        body: widget.status == 0
            ? onResponse(
                jsonFileName: "payment_cancel",
                titleText: paymentFailureTitleKey,
                msgText: paymentFailureMsgKey,
              ) //for Razorpay
            : BlocBuilder<PostFeesPaymentCubit, PostFeesPaymentState>(
                builder: (context, state) {
                  if (state is PostFeesPaymentSuccess) {
                    return onResponse(
                      jsonFileName: "payment_successful",
                      titleText: paymentSuccessTitleKey,
                      msgText: paymentSuccessMsgKey,
                    );
                  }
                  if (state is PostFeesPaymentFailure) {
                    return onResponse(
                      jsonFileName: "payment_cancel",
                      titleText: paymentFailureTitleKey,
                      msgText: paymentFailureMsgKey,
                    );
                  }
                  return onResponse(
                    jsonFileName: "payment_process",
                    titleText: paymentPendingTitleKey,
                    msgText: paymentPendingMsgKey,
                  );
                },
              ),
      ),
    );
  }
}
