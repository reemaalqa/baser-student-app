import 'dart:io';
import 'package:eschool/cubits/chat/chatUsersCubit.dart';
import 'package:eschool/cubits/resultsOnlineCubit.dart';
import 'package:eschool/data/repositories/chatRepository.dart';
import 'package:eschool/data/repositories/resultRepository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:eschool/app/appLocalization.dart';
import 'package:eschool/app/routes.dart';

import 'package:eschool/cubits/appConfigurationCubit.dart';
import 'package:eschool/cubits/appLocalizationCubit.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/examDetailsCubit.dart';
import 'package:eschool/cubits/examsOnlineCubit.dart';
import 'package:eschool/cubits/feesPaymentCubit.dart';
import 'package:eschool/cubits/feesReceiptCubit.dart';
import 'package:eschool/cubits/noticeBoardCubit.dart';
import 'package:eschool/cubits/postFeesPaymentCubit.dart';
import 'package:eschool/cubits/reportTabSelectionCubit.dart';
import 'package:eschool/cubits/resultTabSelectionCubit.dart';
import 'package:eschool/cubits/studentFeesCubit.dart';
import 'package:eschool/cubits/studentSubjectAndSlidersCubit.dart';
import 'package:eschool/cubits/examTabSelectionCubit.dart';

import 'package:eschool/data/repositories/announcementRepository.dart';
import 'package:eschool/data/repositories/authRepository.dart';
import 'package:eschool/data/repositories/examRepository.dart';
import 'package:eschool/data/repositories/settingsRepository.dart';
import 'package:eschool/data/repositories/studentRepository.dart';
import 'package:eschool/data/repositories/systemInfoRepository.dart';

import 'package:eschool/ui/screens/exam/onlineExam/cubits/examOnlineCubit.dart';
import 'package:eschool/ui/screens/reports/cubits/onlineExamReportCubit.dart';
import 'package:eschool/ui/screens/reports/cubits/assignmentReportCubit.dart';
import 'package:eschool/ui/screens/reports/repositories/reportRepository.dart';
import 'package:eschool/ui/styles/colors.dart';

import 'package:eschool/utils/appLanguages.dart';
import 'package:eschool/utils/hiveBoxKeys.dart';
import 'package:eschool/utils/notificationUtils/generalNotificationUtility.dart';
import 'package:eschool/utils/uiUtils.dart';

//to avoide handshake error on some devices
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  //Register the licence of font
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp();

  await NotificationUtility.initializeAwesomeNotification();

  await Hive.initFlutter();
  await Hive.openBox(showCaseBoxKey);
  await Hive.openBox(authBoxKey);

  await Hive.openBox(settingsBoxKey);
  await Hive.openBox(studentSubjectsBoxKey);

  runApp(const MyApp());
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    //preloading some of the imaegs
    precacheImage(
      AssetImage(UiUtils.getImagePath("upper_pattern.png")),
      context,
    );

    precacheImage(
      AssetImage(UiUtils.getImagePath("lower_pattern.png")),
      context,
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppLocalizationCubit>(
          create: (_) => AppLocalizationCubit(SettingsRepository()),
        ),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider<StudentSubjectsAndSlidersCubit>(
          create: (_) => StudentSubjectsAndSlidersCubit(
            studentRepository: StudentRepository(),
            systemRepository: SystemRepository(),
          ),
        ),
        BlocProvider<NoticeBoardCubit>(
          create: (context) => NoticeBoardCubit(AnnouncementRepository()),
        ),
        BlocProvider<AppConfigurationCubit>(
          create: (context) => AppConfigurationCubit(SystemRepository()),
        ),
        BlocProvider<ExamDetailsCubit>(
          create: (context) => ExamDetailsCubit(StudentRepository()),
        ),

        //
        BlocProvider<StudentFeesCubit>(
          create: (context) => StudentFeesCubit(StudentRepository()),
        ),
        BlocProvider<FeesPaymentCubit>(
          create: (context) => FeesPaymentCubit(StudentRepository()),
        ),
        BlocProvider<PostFeesPaymentCubit>(
          create: (context) => PostFeesPaymentCubit(StudentRepository()),
        ),
        BlocProvider<FeesReceiptCubit>(
          create: (context) => FeesReceiptCubit(StudentRepository()),
        ),

        BlocProvider<ResultTabSelectionCubit>(
          create: (_) => ResultTabSelectionCubit(),
        ),
        BlocProvider<ReportTabSelectionCubit>(
          create: (_) => ReportTabSelectionCubit(),
        ),

        BlocProvider<OnlineExamReportCubit>(
          create: (_) => OnlineExamReportCubit(ReportRepository()),
        ),
        BlocProvider<AssignmentReportCubit>(
          create: (_) => AssignmentReportCubit(ReportRepository()),
        ),

        BlocProvider<ExamTabSelectionCubit>(
          create: (_) => ExamTabSelectionCubit(),
        ),
        BlocProvider<ExamOnlineCubit>(
          create: (_) => ExamOnlineCubit(ExamOnlineRepository()),
        ),
        BlocProvider<ExamsOnlineCubit>(
          create: (_) => ExamsOnlineCubit(ExamOnlineRepository()),
        ),

        BlocProvider<ResultsOnlineCubit>(
          create: (_) => ResultsOnlineCubit(ResultOnlineRepository()),
        ),

        BlocProvider<ChatUsersCubit>(
          create: (context) => ChatUsersCubit(ChatRepository()),
        ),
      ],
      child: Builder(
        builder: (context) {
          final currentLanguage =
              context.watch<AppLocalizationCubit>().state.language;

          return MaterialApp(
            navigatorKey: UiUtils.rootNavigatorKey,
            theme: Theme.of(context).copyWith(
              textTheme:
              GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
              scaffoldBackgroundColor: pageBackgroundColor,
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: primaryColor,
                onPrimary: onPrimaryColor,
                secondary: secondaryColor,
                background: backgroundColor,
                error: errorColor,
                onSecondary: onSecondaryColor,
                onBackground: onBackgroundColor,
              ),
            ),
            builder: (context, widget) {
              return ScrollConfiguration(
                behavior: GlobalScrollBehavior(),
                child: widget!,
              );
            },
            locale: currentLanguage,
            localizationsDelegates: const [
              AppLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: appLanguages.map((appLanguage) {
              return UiUtils.getLocaleFromLanguageCode(
                appLanguage.languageCode,
              );
            }).toList(),
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.splash,
            onGenerateRoute: Routes.onGenerateRouted,
          );
        },
      ),
    );
  }
}
