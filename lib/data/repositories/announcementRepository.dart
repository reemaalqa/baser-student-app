import 'package:eschool/data/models/announcement.dart';
import 'package:eschool/utils/api.dart';

class AnnouncementRepository {
  //fetch notice board details
  Future<Map<String, dynamic>> fetchAnnouncements(
      {int? page,
      required bool useParentApi,
      required int childId,
      required bool isGeneralAnnouncement,
      int? subjectId,}) async {
    try {
      Map<String, dynamic> queryParameters = {
        "page": page ?? 0,
        "type": isGeneralAnnouncement ? "noticeboard" : "subject",
        "subject_id": subjectId ?? 0
      };
      if (queryParameters['page'] == 0) {
        queryParameters.remove("page");
      }

      if (isGeneralAnnouncement) {
        queryParameters.remove("subject_id");
      }

      //
      if (useParentApi) {
        if (!isGeneralAnnouncement) {
          queryParameters.addAll({
            "child_id": childId,
          });
        }
      }

      final result = await Api.get(
          url: useParentApi
              ? Api.generalAnnouncementsParent
              : Api.generalAnnouncements,
          useAuthToken: true,
          queryParameters: queryParameters,);

      return {
        "announcements": (result['data']['data'] as List)
            .map((e) => Announcement.fromJson(Map.from(e)))
            .toList(),
        "totalPage": result['data']['last_page'] as int,
        "currentPage": result['data']['current_page'] as int,
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
