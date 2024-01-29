import 'package:eschool/cubits/attendanceCubit.dart';
import 'package:eschool/data/repositories/studentRepository.dart';
import 'package:eschool/ui/widgets/attendanceContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChildAttendanceScreen extends StatelessWidget {
  final int childId;
  const ChildAttendanceScreen({Key? key, required this.childId})
      : super(key: key);

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<AttendanceCubit>(
              create: (context) => AttendanceCubit(StudentRepository()),
              child: ChildAttendanceScreen(
                  childId: routeSettings.arguments as int,),
            ),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AttendanceContainer(
        childId: childId,
      ),
    );
  }
}
