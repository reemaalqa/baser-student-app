import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/subjectAnnouncementsCubit.dart';
import 'package:eschool/data/models/announcement.dart';
import 'package:eschool/ui/widgets/announcementDetailsContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/announcementShimmerLoadingContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';

import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnnouncementContainer extends StatefulWidget {
  final int subjectId;
  final int? childId;
  const AnnouncementContainer({Key? key, required this.subjectId, this.childId})
      : super(key: key);

  @override
  State<AnnouncementContainer> createState() => _AnnouncementContainerState();
}

class _AnnouncementContainerState extends State<AnnouncementContainer> {
  Widget _buildAnnouncementDetailsContainer({
    required Announcement subjectAnnouncement,
    required int index,
    required int totalAnnouncements,
    required bool hasMoreAnnouncements,
    required bool hasMoreAnnouncementsInProgress,
    required bool fetchMoreAnnouncementsFailure,
  }) {
    return Column(
      children: [
        Animate(
          effects: listItemAppearanceEffects(itemIndex: index),
          child: AnnouncementDetailsContainer(
            announcement: subjectAnnouncement,
          ),
        ),
        //show announcement loading container after last announcement container
        if (index == (totalAnnouncements - 1) &&
            hasMoreAnnouncements &&
            hasMoreAnnouncementsInProgress)
          const AnnouncementShimmerLoadingContainer(),

        if (index == (totalAnnouncements - 1) &&
            hasMoreAnnouncements &&
            fetchMoreAnnouncementsFailure)
          Center(
            child: CupertinoButton(
              child: Text(UiUtils.getTranslatedLabel(context, retryKey)),
              onPressed: () {
                context.read<SubjectAnnouncementCubit>().fetchMoreAnnouncements(
                      useParentApi: context.read<AuthCubit>().isParent(),
                      subjectId: widget.subjectId,
                      childId: widget.childId,
                    );
              },
            ),
          ),
      ],
    );
  }

  //
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectAnnouncementCubit, SubjectAnnouncementState>(
      builder: (context, state) {
        if (state is SubjectAnnouncementFetchSuccess) {
          return state.announcements.isEmpty
              ? const NoDataContainer(titleKey: noAnnouncementKey)
              : Column(
                  children: List.generate(
                    state.announcements.length,
                    (index) => index,
                  )
                      .map(
                        (index) => _buildAnnouncementDetailsContainer(
                          subjectAnnouncement: state.announcements[index],
                          index: index,
                          totalAnnouncements: state.announcements.length,
                          hasMoreAnnouncements: context
                              .read<SubjectAnnouncementCubit>()
                              .hasMore(),
                          hasMoreAnnouncementsInProgress:
                              state.fetchMoreAnnouncementsInProgress,
                          fetchMoreAnnouncementsFailure:
                              state.moreAnnouncementsFetchError,
                        ),
                      )
                      .toList(),
                );
        }

        if (state is SubjectAnnouncementFetchFailure) {
          return ErrorContainer(
            errorMessageCode: state.errorMessage,
            onTapRetry: () {
              context.read<SubjectAnnouncementCubit>().fetchSubjectAnnouncement(
                    subjectId: widget.subjectId,
                    useParentApi: context.read<AuthCubit>().isParent(),
                    childId: widget.childId,
                  );
            },
          );
        }

        return Column(
          children: List.generate(
            UiUtils.defaultShimmerLoadingContentCount,
            (index) => index,
          ).map((e) => const AnnouncementShimmerLoadingContainer()).toList(),
        );
      },
    );
  }
}
