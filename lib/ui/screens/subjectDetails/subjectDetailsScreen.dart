import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/subjectAnnouncementsCubit.dart';
import 'package:eschool/cubits/subjectLessonsCubit.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/data/repositories/announcementRepository.dart';
import 'package:eschool/data/repositories/subjectRepository.dart';
import 'package:eschool/ui/screens/subjectDetails/widgets/announcementContainer.dart';
import 'package:eschool/ui/screens/subjectDetails/widgets/chaptersContainer.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/customTabBarContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/tabBarBackgroundContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubjectDetailsScreen extends StatefulWidget {
  final Subject subject;
  final int? childId;
  const SubjectDetailsScreen({Key? key, required this.subject, this.childId})
      : super(key: key);

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<SubjectLessonsCubit>(
            create: (_) => SubjectLessonsCubit(SubjectRepository()),
          ),
          BlocProvider<SubjectAnnouncementCubit>(
            create: (_) => SubjectAnnouncementCubit(AnnouncementRepository()),
          ),
        ],
        child: SubjectDetailsScreen(
          childId: arguments['childId'],
          subject: arguments['subject'],
        ),
      ),
    );
  }
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  late String _selectedTabTitle = chaptersKey;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(_subjectAnnouncementScrollListener);

  void _subjectAnnouncementScrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (_selectedTabTitle == announcementKey) {
        if (context.read<SubjectAnnouncementCubit>().hasMore()) {
          context.read<SubjectAnnouncementCubit>().fetchMoreAnnouncements(
                useParentApi: context.read<AuthCubit>().isParent(),
                subjectId: widget.subject.id,
                childId: widget.childId,
              );
        }
        //to scroll to last in order for users to see the progress
        Future.delayed(const Duration(milliseconds: 10), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<SubjectLessonsCubit>().fetchSubjectLessons(
            subjectId: widget.subject.id,
            useParentApi: context.read<AuthCubit>().isParent(),
            childId: widget.childId,
          );
      context.read<SubjectAnnouncementCubit>().fetchSubjectAnnouncement(
            useParentApi: context.read<AuthCubit>().isParent(),
            subjectId: widget.subject.id,
            childId: widget.childId,
          );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_subjectAnnouncementScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildAppBar() {
    return ScreenTopBackgroundContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              const CustomBackButton(),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  widget.subject.showType
                      ? widget.subject.subjectNameWithType
                      : widget.subject.name,
                  style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: UiUtils.screenTitleFontSize,
                  ),
                ),
              ),
              AnimatedAlign(
                curve: UiUtils.tabBackgroundContainerAnimationCurve,
                duration: UiUtils.tabBackgroundContainerAnimationDuration,
                alignment: _selectedTabTitle == chaptersKey
                    ? AlignmentDirectional.centerStart
                    : AlignmentDirectional.centerEnd,
                child:
                    TabBarBackgroundContainer(boxConstraints: boxConstraints),
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerStart,
                isSelected: _selectedTabTitle == chaptersKey,
                onTap: () {
                  setState(() {
                    _selectedTabTitle = chaptersKey;
                  });
                },
                titleKey: chaptersKey,
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerEnd,
                isSelected: _selectedTabTitle == announcementKey,
                onTap: () {
                  setState(() {
                    _selectedTabTitle = announcementKey;
                  });
                },
                titleKey: announcementKey,
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: CustomRefreshIndicator(
              onRefreshCallback: () {
                if (_selectedTabTitle == chaptersKey) {
                  context.read<SubjectLessonsCubit>().fetchSubjectLessons(
                        subjectId: widget.subject.id,
                        useParentApi: context.read<AuthCubit>().isParent(),
                        childId: widget.childId,
                      );
                } else {
                  context
                      .read<SubjectAnnouncementCubit>()
                      .fetchSubjectAnnouncement(
                        useParentApi: context.read<AuthCubit>().isParent(),
                        subjectId: widget.subject.id,
                        childId: widget.childId,
                      );
                }
              },
              displacment: UiUtils.getScrollViewTopPadding(
                context: context,
                appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
              ),
              child: SizedBox(
                height: double.maxFinite,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: UiUtils.getScrollViewTopPadding(
                      context: context,
                      appBarHeightPercentage:
                          UiUtils.appBarBiggerHeightPercentage,
                    ),
                  ),
                  child: Column(
                    children: [
                      _selectedTabTitle == chaptersKey
                          ? ChaptersContainer(
                              childId: widget.childId,
                              subjectId: widget.subject.id,
                            )
                          : AnnouncementContainer(
                              subjectId: widget.subject.id,
                              childId: widget.childId,
                            )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(),
          ),
        ],
      ),
    );
  }
}
