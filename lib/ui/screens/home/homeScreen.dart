import 'package:eschool/cubits/appConfigurationCubit.dart';
import 'package:eschool/cubits/assignmentsCubit.dart';
import 'package:eschool/cubits/attendanceCubit.dart';
import 'package:eschool/cubits/chat/chatUsersCubit.dart';
import 'package:eschool/cubits/holidaysCubit.dart';
import 'package:eschool/cubits/resultsCubit.dart';
import 'package:eschool/cubits/studentParentDetailsCubit.dart';
import 'package:eschool/cubits/timeTableCubit.dart';
import 'package:eschool/data/repositories/assignmentRepository.dart';
import 'package:eschool/data/repositories/settingsRepository.dart';
import 'package:eschool/data/repositories/studentRepository.dart';
import 'package:eschool/data/repositories/systemInfoRepository.dart';
import 'package:eschool/ui/screens/chat/chatUsersScreen.dart';
import 'package:eschool/ui/screens/home/cubits/assignmentsTabSelectionCubit.dart';
import 'package:eschool/ui/screens/home/widgets/examContainer.dart';
import 'package:eschool/ui/screens/reports/reportSubjectsContainer.dart';
import 'package:eschool/ui/widgets/appUnderMaintenanceContainer.dart';
import 'package:eschool/ui/widgets/assignmentsContainer.dart';
import 'package:eschool/ui/widgets/attendanceContainer.dart';
import 'package:eschool/ui/screens/home/widgets/bottomNavigationItemContainer.dart';
import 'package:eschool/ui/screens/home/widgets/homeContainer.dart';
import 'package:eschool/ui/screens/home/widgets/moreMenuBottomsheetContainer.dart';
import 'package:eschool/ui/widgets/forceUpdateDialogContainer.dart';
import 'package:eschool/ui/widgets/noticeBoardContainer.dart';
import 'package:eschool/ui/screens/home/widgets/parentProfileContainer.dart';
import 'package:eschool/ui/widgets/settingsContainer.dart';
import 'package:eschool/ui/widgets/timetableContainer.dart';
import 'package:eschool/ui/widgets/holidaysContainer.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/homeBottomsheetMenu.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/notificationUtils/chatNotificationsUtils.dart';
import 'package:eschool/utils/notificationUtils/generalNotificationUtility.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../cubits/timer/timer_cubit.dart';
import '../../widgets/resultsContainer.dart';
import '../../widgets/studyingContainer.dart';

//value notifier to show notification icon active/deavtive
ValueNotifier<int> notificationCountValueNotifier = ValueNotifier(0);

class HomeScreen extends StatefulWidget {
  static GlobalKey<HomeScreenState> homeScreenKey =
  GlobalKey<HomeScreenState>();
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<TimeTableCubit>(
            create: (_) => TimeTableCubit(StudentRepository()),
          ),
          BlocProvider<StudentParentDetailsCubit>(
            create: (_) => StudentParentDetailsCubit(StudentRepository()),
          ),
          BlocProvider<AssignmentsCubit>(
            create: (_) => AssignmentsCubit(AssignmentRepository()),
          ),
          BlocProvider<TimerCubit>(
            create: (context) => TimerCubit(),
          ),
          BlocProvider<AttendanceCubit>(
            create: (context) => AttendanceCubit(StudentRepository()),
          ),
          BlocProvider<HolidaysCubit>(
            create: (context) => HolidaysCubit(SystemRepository()),
          ),
          BlocProvider<AssignmentsTabSelectionCubit>(
            create: (_) => AssignmentsTabSelectionCubit(),
          ),
          BlocProvider<ResultsCubit>(
            create: (_) => ResultsCubit(StudentRepository()),
          ),
        ],
        child: ShowCaseWidget(
          onFinish: () {},
          builder: Builder(
            builder: (context) => HomeScreen(
              key: homeScreenKey,
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final Animation<double> _bottomNavAndTopProfileAnimation =
  Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),
  );

  late final List<AnimationController> _bottomNavItemTitlesAnimationController =
  [];

  late final AnimationController _moreMenuBottomsheetAnimationController =
  AnimationController(
    vsync: this,
    duration: homeMenuBottomSheetAnimationDuration,
  );

  late final Animation<Offset> _moreMenuBottomsheetAnimation =
  Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
    CurvedAnimation(
      parent: _moreMenuBottomsheetAnimationController,
      curve: Curves.easeInOut,
    ),
  );

  late final Animation<double> _moreMenuBackgroundContainerColorAnimation =
  Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _moreMenuBottomsheetAnimationController,
      curve: Curves.easeInOut,
    ),
  );

  late int _currentSelectedBottomNavIndex = 0;
  late int _previousSelectedBottmNavIndex = -1;

  //index of opened homeBottomsheet menu
  late int _currentlyOpenMenuIndex = -1;

  late bool _isMoreMenuOpen = false;

  final List<BottomNavItem> _bottomNavItems = [
    BottomNavItem(
      activeImageUrl: UiUtils.getImagePath("home_active_icon.svg"),
      disableImageUrl: UiUtils.getImagePath("home_icon.svg"),
      title: homeKey,
    ),
    BottomNavItem(
      activeImageUrl: UiUtils.getImagePath("chat_active_icon.svg"),
      disableImageUrl: UiUtils.getImagePath("chat_icon.svg"),
      title: chatKey,
    ),
    BottomNavItem(
      activeImageUrl: UiUtils.getImagePath("assignment_active_icon.svg"),
      disableImageUrl: UiUtils.getImagePath("assignment_icon.svg"),
      title: assignmentsKey,
    ),
    BottomNavItem(
      activeImageUrl: UiUtils.getImagePath("menu_active_icon.svg"),
      disableImageUrl: UiUtils.getImagePath("menu_icon.svg"),
      title: menuKey,
    ),
  ];

  late List<GlobalKey> _bottomNavItemShowCaseKey = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    //Refereshing the shared preferences to get the latest notification count, it there were any notifications in the background
    if (state == AppLifecycleState.resumed) {
      notificationCountValueNotifier.value =
      await SettingsRepository().getNotificationCount();
      final backgroundChatMessages =
      await SettingsRepository().getBackgroundChatNotificationData();
      if (backgroundChatMessages.isNotEmpty) {
        //empty any old data and stream new once
        SettingsRepository().setBackgroundChatNotificationData(data: []);
        for (int i = 0; i < backgroundChatMessages.length; i++) {
          ChatNotificationsUtils.addChatStreamValue(
              chatData: backgroundChatMessages[i]);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initAnimations();
    initShowCaseKeys();
    WidgetsBinding.instance.addObserver(this);

    _animationController.forward();
    Future.delayed(Duration.zero, () {
      //setup notification callback here
      NotificationUtility.setUpNotificationService(context);
    });
  }

  void navigateToAssignmentContainer() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    changeBottomNavItem(1);
  }

  void initAnimations() {
    for (var i = 0; i < _bottomNavItems.length; i++) {
      _bottomNavItemTitlesAnimationController.add(
        AnimationController(
          value: i == _currentSelectedBottomNavIndex ? 0.0 : 1.0,
          vsync: this,
          duration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  void initShowCaseKeys() {
    for (var i = 0; i < _bottomNavItems.length; i++) {
      _bottomNavItemShowCaseKey.add(GlobalKey());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    for (var animationController in _bottomNavItemTitlesAnimationController) {
      animationController.dispose();
    }
    _moreMenuBottomsheetAnimationController.dispose();
    super.dispose();
  }

  Future<void> changeBottomNavItem(int index) async {
    if (_moreMenuBottomsheetAnimationController.isAnimating) {
      return;
    }
    _bottomNavItemTitlesAnimationController[_currentSelectedBottomNavIndex]
        .forward();

    //need to assign previous selected bottom index only if menu is close
    if (!_isMoreMenuOpen && _currentlyOpenMenuIndex == -1) {
      _previousSelectedBottmNavIndex = _currentSelectedBottomNavIndex;
    }

    //change current selected bottom index
    setState(() {
      _currentSelectedBottomNavIndex = index;

      //if user taps on non-last bottom nav item then change _currentlyOpenMenuIndex
      if (_currentSelectedBottomNavIndex != _bottomNavItems.length - 1) {
        _currentlyOpenMenuIndex = -1;
      }
    });

    _bottomNavItemTitlesAnimationController[_currentSelectedBottomNavIndex]
        .reverse();

    //if bottom index is last means open/close the bottom sheet
    if (index == _bottomNavItems.length - 1) {
      if (_moreMenuBottomsheetAnimationController.isCompleted) {
        //close the menu
        await _moreMenuBottomsheetAnimationController.reverse();

        setState(() {
          _isMoreMenuOpen = !_isMoreMenuOpen;
        });

        //change bottom nav to previous selected index
        //only if there is not any opened menu item container
        if (_currentlyOpenMenuIndex == -1) {
          changeBottomNavItem(_previousSelectedBottmNavIndex);
        }
      } else {
        //open menu
        await _moreMenuBottomsheetAnimationController.forward();
        setState(() {
          _isMoreMenuOpen = !_isMoreMenuOpen;
        });
      }
    } else {
      //if current selected index is not last index(bottom nav item)
      //and menu is open then close the menu
      if (_moreMenuBottomsheetAnimationController.isCompleted) {
        await _moreMenuBottomsheetAnimationController.reverse();
        setState(() {
          _isMoreMenuOpen = !_isMoreMenuOpen;
        });
      }
    }
  }

  Future<void> _closeBottomMenu() async {
    if (_currentlyOpenMenuIndex == -1) {
      //close the menu and change bottom sheet
      changeBottomNavItem(_previousSelectedBottmNavIndex);
    } else {
      await _moreMenuBottomsheetAnimationController.reverse();
      setState(() {
        _isMoreMenuOpen = !_isMoreMenuOpen;
      });
    }
  }

  Future<void> _onTapMoreMenuItemContainer(int index) async {
    await _moreMenuBottomsheetAnimationController.reverse();
    _currentlyOpenMenuIndex = index;
    _isMoreMenuOpen = !_isMoreMenuOpen;
    setState(() {});
  }

  Widget _buildBottomNavigationContainer() {
    return FadeTransition(
      opacity: _bottomNavAndTopProfileAnimation,
      child: SlideTransition(
        position: _bottomNavAndTopProfileAnimation.drive(
          Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero),
        ),
        child: Container(
          alignment: Alignment.center,
          // padding: EdgeInsets.only(
          //   bottom: MediaQuery.of(context).size.height * (0.075) * (0.075),
          // ),
          margin: EdgeInsets.only(
            bottom: UiUtils.bottomNavigationBottomMargin,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color:
                UiUtils.getColorScheme(context).secondary.withOpacity(0.15),
                offset: const Offset(2.5, 2.5),
                blurRadius: 20,
              )
            ],
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          width: MediaQuery.of(context).size.width * (0.85),
          height: MediaQuery.of(context).size.height *
              UiUtils.bottomNavigationHeightPercentage,
          child: BlocBuilder<ChatUsersCubit, ChatUsersState>(
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, boxConstraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _bottomNavItems.map((bottomNavItem) {
                      final int index = _bottomNavItems
                          .indexWhere((e) => e.title == bottomNavItem.title);
                      return BottomNavItemContainer(
                        showCaseKey: _bottomNavItemShowCaseKey[index],
                        showCaseDescription: bottomNavItem.title,
                        onTap: changeBottomNavItem,
                        boxConstraints: boxConstraints,
                        currentIndex: _currentSelectedBottomNavIndex,
                        bottomNavItem: _bottomNavItems[index],
                        animationController:
                        _bottomNavItemTitlesAnimationController[index],
                        index: index,
                        notificationCount:
                        (index == 1 && state is ChatUsersFetchSuccess)
                            ? state.totalUnreadUsers
                            : null,
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMoreMenuBackgroundContainer() {
    return GestureDetector(
      onTap: () async {
        _closeBottomMenu();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.75),
      ),
    );
  }

  //To load the selected menu item
  //it _currentlyOpenMenuIndex is 0 then load the container based on homeBottomSheetMenu[_currentlyOpenMenuIndex]
  Widget _buildMenuItemContainer() {
    if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title == attendanceKey) {
      return const AttendanceContainer();
    } else if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title ==
        studyingKey) {
      return const StudyingContainer();
    }
    else if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title ==
        timeTableKey) {
      return const TimeTableContainer();
    } else if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title ==
        settingsKey) {
      return const SettingsContainer();
    } else if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title ==
        noticeBoardKey) {
      return const NoticeBoardContainer(
        showBackButton: false,
      );
    } else if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title ==
        parentProfileKey) {
      return const ParentProfileContainer();
    } else if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title ==
        holidaysKey) {
      return const HolidaysContainer();
    } else if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title == examsKey) {
      return const ExamContainer();
    } else if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title ==
        resultKey) {
      return const ResultsContainer();
    } else if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title ==
        reportsKey) {
      return const ReportSubjectsContainer();
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_isMoreMenuOpen) {
          _closeBottomMenu();
          return Future.value(false);
        }
        if (_currentSelectedBottomNavIndex != 0) {
          changeBottomNavItem(0);
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        body: context.read<AppConfigurationCubit>().appUnderMaintenance()
            ? const AppUnderMaintenanceContainer()
            : Stack(
          children: [
            IndexedStack(
              index: _currentSelectedBottomNavIndex,
              children: [
                const HomeContainer(
                  isForBottomMenuBackground: false,
                ),
                const ChatUsersScreen(
                  isForBottomMenuBackground: false,
                ),
                const AssignmentsContainer(
                  isForBottomMenuBackground: false,
                ),
                //Based on previous selected index show backgorund content
                _currentlyOpenMenuIndex != -1
                    ? _buildMenuItemContainer()
                    : _previousSelectedBottmNavIndex == 0
                    ? const HomeContainer(
                  isForBottomMenuBackground: true,
                )
                    : _previousSelectedBottmNavIndex == 1
                    ? const ChatUsersScreen(
                  isForBottomMenuBackground: true,
                )
                    : _previousSelectedBottmNavIndex == 2
                    ? const AssignmentsContainer(
                  isForBottomMenuBackground: true,
                )
                    : const SizedBox(),
              ],
            ),
            IgnorePointer(
              ignoring: !_isMoreMenuOpen,
              child: FadeTransition(
                opacity: _moreMenuBackgroundContainerColorAnimation,
                child: _buildMoreMenuBackgroundContainer(),
              ),
            ),

            //More menu bottom sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _moreMenuBottomsheetAnimation,
                child: MoreMenuBottomsheetContainer(
                  closeBottomMenu: _closeBottomMenu,
                  onTapMoreMenuItemContainer: _onTapMoreMenuItemContainer,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomNavigationContainer(),
            ),
            context.read<AppConfigurationCubit>().forceUpdate()
                ? FutureBuilder<bool>(
              future: UiUtils.forceUpdate(
                context
                    .read<AppConfigurationCubit>()
                    .getAppVersion(),
              ),
              builder: (context, snaphsot) {
                if (snaphsot.hasData) {
                  return (snaphsot.data ?? false)
                      ? const ForceUpdateDialogContainer()
                      : const SizedBox();
                }

                return const SizedBox();
              },
            )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
