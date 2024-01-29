import 'package:eschool/data/models/electiveSubjectGroup.dart';
import 'package:eschool/utils/api.dart';

import '../../utils/constants.dart';

class ClassRepository {
  Future<List<ElectiveSubjectGroup>> getElectiveSubjects() async {
    try {
      final result = await Api.get(url: Api.classSubjects, useAuthToken: true);

      final electiveSubjectGroups =
          result['data']['elective_subject_group'] as List;
      // logger.i(electiveSubjectGroups);

      return electiveSubjectGroups
          .map((json) => ElectiveSubjectGroup.fromJson(json))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
