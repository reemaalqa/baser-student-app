import 'package:eschool/cubits/holidaysCubit.dart';
import 'package:eschool/data/repositories/systemInfoRepository.dart';
import 'package:eschool/ui/widgets/holidaysContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({Key? key}) : super(key: key);

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<HolidaysCubit>(
        create: (context) => HolidaysCubit(SystemRepository()),
        child: const HolidaysScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HolidaysContainer(),
    );
  }
}
