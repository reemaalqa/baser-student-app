// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eschool/cubits/feesTransactionCubit.dart';
import 'package:eschool/data/models/feesTransaction.dart';
import 'package:eschool/ui/styles/colors.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/data/repositories/studentRepository.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter_svg/svg.dart';

class FeesTransactionScreen extends StatefulWidget {
  const FeesTransactionScreen({Key? key}) : super(key: key);

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (context) => FeesTransactionsCubit(StudentRepository()),
        child: const FeesTransactionScreen(),
      ),
    );
  }

  @override
  State<FeesTransactionScreen> createState() => _FeesTransactionScreenState();
}

class _FeesTransactionScreenState extends State<FeesTransactionScreen> {
  late final ScrollController _scrollController = ScrollController()
    ..addListener(_feesTransactionScrollListener);

  void _feesTransactionScrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<FeesTransactionsCubit>().hasMore()) {
        context.read<FeesTransactionsCubit>().fetchMoreFeesTransactions();
      }
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      fetchFeesTransactions();
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_feesTransactionScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void fetchFeesTransactions() {
    context.read<FeesTransactionsCubit>().fetchFeesTransactions(
          page: 1,
        );
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
              UiUtils.getTranslatedLabel(context, feesTransactionKey),
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

  Widget _buildShimmerLoader() {
    return ShimmerLoadingContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return SizedBox(
            height: double.maxFinite,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: UiUtils.defaultShimmerLoadingContentCount,
              itemBuilder: (context, index) {
                return _buildOneTransactionShimmerLoader();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOneTransactionShimmerLoader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: MediaQuery.of(context).size.width * (0.075),
      ),
      child: const ShimmerLoadingContainer(
        child: CustomShimmerContainer(
          height: 100,
          borderRadius: 10,
        ),
      ),
    );
  }

  Widget _buildSingleTransactionItem({
    required FeesTransaction transaction,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: MediaQuery.of(context).size.width * (0.075),
      ),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.background,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          transaction.sessionYear.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        " • ",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          transaction.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Center(
                          child: SvgPicture.asset(
                            transaction.modeImagePath,
                            width: 35,
                            height: 35,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${UiUtils.getTranslatedLabel(context, transaction.feeTypeKey)} ${UiUtils.getTranslatedLabel(context, feesKey)}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "${UiUtils.getTranslatedLabel(context, transaction.modeKey)} ${UiUtils.getTranslatedLabel(context, paymentKey)}${transaction.mode == 2 ? " (${transaction.paymentGatewayString}) " : ""}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              if (transaction.date != null)
                                Text(
                                  UiUtils.formatDateAndTime(transaction.date!),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                  ),
                  width: 80,
                  decoration: BoxDecoration(
                    color: transaction.paymentStatus == 1
                        ? greenColor
                        : transaction.paymentStatus == 0
                            ? redColor
                            : orangeColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    UiUtils.getTranslatedLabel(
                      context,
                      transaction.paymentStatusKey,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  UiUtils.formatAmount(
                    strVal: transaction.totalAmount.toStringAsFixed(2),
                    context: context,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: UiUtils.screenTitleFontSize,
                  ),
                ),
              ],
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
          BlocBuilder<FeesTransactionsCubit, FeesTransactionState>(
            builder: (context, state) {
              if (state is FeesTransactionFetchSuccess) {
                return state.feesTransactions.isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                          top: UiUtils.getScrollViewTopPadding(
                            context: context,
                            appBarHeightPercentage:
                                UiUtils.appBarSmallerHeightPercentage,
                          ),
                        ),
                        child: const NoDataContainer(
                          titleKey: noFeesTransactionsFoundKey,
                        ),
                      )
                    : CustomRefreshIndicator(
                        displacment: UiUtils.getScrollViewTopPadding(
                          context: context,
                          appBarHeightPercentage:
                              UiUtils.appBarSmallerHeightPercentage,
                        ),
                        onRefreshCallback: () {
                          if (!context
                              .read<FeesTransactionsCubit>()
                              .isLoading()) {
                            fetchFeesTransactions();
                          }
                        },
                        child: SizedBox(
                          height: double.maxFinite,
                          width: double.maxFinite,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(
                              top: UiUtils.getScrollViewTopPadding(
                                context: context,
                                appBarHeightPercentage:
                                    UiUtils.appBarSmallerHeightPercentage,
                              ),
                              bottom:
                                  UiUtils.getScrollViewBottomPadding(context),
                            ),
                            child: Column(
                              children: List.generate(
                                state.feesTransactions.length,
                                (index) {
                                  {
                                    return Animate(
                                      effects: listItemAppearanceEffects(
                                        itemIndex: index,
                                      ),
                                      child: _buildSingleTransactionItem(
                                        transaction:
                                            state.feesTransactions[index],
                                      ),
                                    );
                                  }
                                },
                              )..addAll([
                                  if (state.moreTransactionsFetchInProgress)
                                    _buildOneTransactionShimmerLoader(),
                                  if (state.moreTransactionsFetchError &&
                                      !state.moreTransactionsFetchInProgress)
                                    Center(
                                      child: CupertinoButton(
                                        child: Text(
                                          UiUtils.getTranslatedLabel(
                                            context,
                                            retryKey,
                                          ),
                                        ),
                                        onPressed: () {
                                          context
                                              .read<FeesTransactionsCubit>()
                                              .fetchMoreFeesTransactions();
                                        },
                                      ),
                                    )
                                ]),
                            ),
                          ),
                        ),
                      );
              }
              if (state is FeesTransactionFetchFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessageCode: state.errorMessage,
                    onTapRetry: () {
                      context
                          .read<FeesTransactionsCubit>()
                          .fetchFeesTransactions(
                            page: 1,
                          );
                    },
                  ),
                );
              }
              return Padding(
                padding: EdgeInsets.only(
                  top: UiUtils.getScrollViewTopPadding(
                    context: context,
                    appBarHeightPercentage:
                        UiUtils.appBarSmallerHeightPercentage,
                  ),
                ),
                child: _buildShimmerLoader(),
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(context),
          ),
        ],
      ),
    );
  }
}
