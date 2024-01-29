import 'package:eschool/data/models/subject.dart';
import 'package:eschool/ui/screens/home/widgets/examContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExamScreen extends StatelessWidget {
  final int? childId;
  final List<Subject>? subjects;
  const ExamScreen({Key? key, this.childId, this.subjects}) : super(key: key);

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => ExamScreen(
        childId: arguments['childId'],
        subjects: arguments['subjects'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExamContainer(
        childId: childId,
        subjects: subjects,
      ),
    );
  }
}
