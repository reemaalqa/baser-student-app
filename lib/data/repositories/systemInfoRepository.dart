import 'package:eschool/data/models/holiday.dart';
import 'package:eschool/data/models/sliderDetails.dart';
import 'package:eschool/utils/api.dart';
import 'package:eschool/utils/constants.dart';

class SystemRepository {
  Future<List<SliderDetails>> fetchSliders() async {
    try {
      final result = await Api.get(url: Api.getSliders, useAuthToken: false);
      return (result['data'] as List)
          .map((sliderDetails) => SliderDetails.fromJson(sliderDetails))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> fetchSettings({required String type}) async {
    try {
      final result = await Api.get(
          queryParameters: {"type": type},
          url: Api.settings,
          useAuthToken: false,);
      return result['data'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Holiday>> fetchHolidays() async {
    try {
      final result = await Api.get(url: Api.holidays, useAuthToken: false);
      return ((result['data'] ?? []) as List)
          .map((holiday) => Holiday.fromJson(Map.from(holiday)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
