import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/appConfigurationCubit.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/feesReceiptCubit.dart';
import 'package:eschool/cubits/studentFeesCubit.dart';
import 'package:eschool/data/models/paidFees.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/listItemForFeesStatus.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';

class FeesStatusScreen extends StatefulWidget {
  final Student studentDetails;
  const FeesStatusScreen({Key? key, required this.studentDetails})
      : super(key: key);

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) =>
          FeesStatusScreen(studentDetails: arguments['studentDetails']),
    );
  }

  @override
  State<FeesStatusScreen> createState() => _FeesStatusScreenState();
}

class _FeesStatusScreenState extends State<FeesStatusScreen> {
  @override
  void initState() {
    super.initState();
    fetchFeesList();
  }

  void fetchFeesList() {
    Future.delayed(Duration.zero, () {
      context.read<StudentFeesCubit>().fetchStudentFeesList(
            childId: widget.studentDetails.id,
            currentSessionYearId: context
                .read<AppConfigurationCubit>()
                .getAppConfiguration()
                .sessionYear
                .id,
          );
    });
  }

  Widget _buildAppBar(BuildContext context) {
    return ScreenTopBackgroundContainer(
      heightPercentage: UiUtils.appBarSmallerHeightPercentage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          context.read<AuthCubit>().isParent()
              ? const CustomBackButton()
              : const SizedBox(),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              UiUtils.getTranslatedLabel(context, feesKey),
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: UiUtils.screenTitleFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentYearPendingFees() {
    List<String> className = widget.studentDetails.classSectionName.split(' ');
    return ListItemForFeesStatus(
      className: className[0], //only className,without Division
      status: 0, //pending
      receiptProcessing: false,
      fileNamePrefix: "",
      year: context
          .read<AppConfigurationCubit>()
          .getAppConfiguration()
          .sessionYear
          .name,
      fees: const [],
      onItemTap: () {
        if (context
            .read<AppConfigurationCubit>()
            .getOnlineFeesPaymentStatus()) {
          Navigator.of(context).pushNamed(
            Routes.feesDetails,
            arguments: {
              "studentDetails": widget.studentDetails,
              "sessionYearId": context
                  .read<AppConfigurationCubit>()
                  .getAppConfiguration()
                  .sessionYear
                  .id,
            },
          );
        } else {
          //show snackbar
          UiUtils.showCustomSnackBar(
            context: context,
            errorMessage:
                UiUtils.getTranslatedLabel(context, offlinePaymentMsgKey),
            delayDuration: const Duration(milliseconds: 4500),
            backgroundColor: UiUtils.getColorScheme(context).primary,
          );
        }
      },
    );
  }

  Widget _buildFeesList(List<PaidFees> feesList) {
    bool isFeesPending = true;
    for (final listItem in feesList) {
      if (listItem.sessionYearId ==
          context
              .read<AppConfigurationCubit>()
              .getAppConfiguration()
              .sessionYear
              .id) {
        isFeesPending = false;
        break;
      }
    }
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFeesPending) _buildCurrentYearPendingFees(),
            BlocListener<FeesReceiptCubit, FeesReceiptState>(
              listener: (context, state) {
                if (state is FeesReceiptDownloadSuccess) {
                  final String msg =
                      "${UiUtils.getTranslatedLabel(context, state.successMessageKey)}\n${widget.studentDetails.getFullName()},$classKey ${state.fees.stClass.name}-${state.fees.sessionYear.name}";
                  UiUtils.showCustomSnackBar(
                    context: context,
                    errorMessage: msg,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  );
                  OpenFilex.open(state.filePath);
                }
                if (state is FeesReceiptDownloadFailure) {
                  UiUtils.showCustomSnackBar(
                    context: context,
                    errorMessage: UiUtils.getErrorMessageFromErrorCode(
                      context,
                      state.errorMessage,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  );
                }
              },
              child: Column(
                children: List.generate(feesList.length, (index) {
                  return BlocBuilder<FeesReceiptCubit, FeesReceiptState>(
                    builder: (context, state) {
                      return Animate(
                        effects: listItemAppearanceEffects(
                            itemIndex: index,
                            totalLoadedItems: feesList.length),
                        child: ListItemForFeesStatus(
                          year: feesList[index].sessionYear.name,
                          fileNamePrefix:
                              "${widget.studentDetails.getFullName()}_${classKey}_${feesList[index].stClass.name}_${feesList[index].sessionYear.name}",
                          status: feesList[index].isFullyPaid
                              ? 1
                              : 2, //1 paid, 2 partially paid
                          className: feesList[index].stClass.name!,
                          onItemTap: () {
                            if (feesList[index].sessionYearId ==
                                context
                                    .read<AppConfigurationCubit>()
                                    .getAppConfiguration()
                                    .sessionYear
                                    .id) {
                              if (context
                                  .read<AppConfigurationCubit>()
                                  .getOnlineFeesPaymentStatus()) {
                                Navigator.of(context).pushNamed(
                                  Routes.feesDetails,
                                  arguments: {
                                    "studentDetails": widget.studentDetails,
                                    "sessionYearId": context
                                        .read<AppConfigurationCubit>()
                                        .getAppConfiguration()
                                        .sessionYear
                                        .id,
                                  },
                                );
                              }
                            }
                          },
                          id: feesList[index].id,
                          fees: feesList,
                          receiptProcessing:
                              state is FeesReceiptDownloadInProgress &&
                                  feesList[index].id ==
                                      state.currentlyDownloading.id,
                        ),
                      );
                    },
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeesShimmerLoadingContainer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        horizontal: UiUtils.screenContentHorizontalPaddingInPercentage *
            MediaQuery.of(context).size.width,
      ),
      child: ShimmerLoadingContainer(
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: 9,
                    width: boxConstraints.maxWidth * (0.3),
                  ),
                ),
                SizedBox(
                  height: boxConstraints.maxWidth * (0.02),
                ),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: 10,
                    width: boxConstraints.maxWidth * (0.8),
                  ),
                ),
                SizedBox(
                  height: boxConstraints.maxWidth * (0.1),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeesLoading() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              UiUtils.defaultShimmerLoadingContentCount,
              (index) => _buildFeesShimmerLoadingContainer(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentFeesStatus() {
    return CustomRefreshIndicator(
      displacment: UiUtils.getScrollViewTopPadding(
        context: context,
        appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
      ),
      onRefreshCallback: () {
        fetchFeesList();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: UiUtils.getScrollViewBottomPadding(context),
          top: UiUtils.getScrollViewTopPadding(
            context: context,
            appBarHeightPercentage: UiUtils.appBarSmallerHeightPercentage,
          ),
        ),
        child: Column(
          children: [
            BlocBuilder<StudentFeesCubit, StudentFeesState>(
              builder: (context, state) {
                if (state is StudentFeesFetchSuccess) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: state.feesList.isEmpty
                        ? _buildCurrentYearPendingFees()
                        : _buildFeesList(state.feesList),
                  );
                }
                if (state is StudentFeesFetchFailure) {
                  return ErrorContainer(
                    errorMessageCode: state.errorMessage,
                    onTapRetry: () {
                      fetchFeesList();
                    },
                  );
                }

                return _buildFeesLoading();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildStudentFeesStatus(),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(context),
          ),
        ],
      ),
    );
  }
}
