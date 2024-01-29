import 'dart:convert';

import 'package:eschool/utils/appLanguages.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
//

//For localization of app
class AppLocalization {
  final Locale locale;

  //it will hold key of text and it's values in given language
  late Map<String, String> _localizedValues;

  AppLocalization(this.locale);

  //to access applocalization instance any where in app using context
  static AppLocalization? of(BuildContext context) {
    return Localizations.of(context, AppLocalization);
  }

  //to load json(language) from assets
  Future loadJson() async {
    final String languageJsonName = locale.countryCode == null
        ? locale.languageCode
        : "${locale.languageCode}-${locale.countryCode}";
    final String jsonStringValues =
        await rootBundle.loadString('assets/languages/$languageJsonName.json');
    //value from rootbundle will be encoded string
    final Map<String, dynamic> mappedJson = json.decode(jsonStringValues);

    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  //to get translated value of given title/key
  String? getTranslatedValues(String? key) {
    return _localizedValues[key!];
  }

  //need to declare custom delegate
  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationDelegate();
}

//Custom app delegate
class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  //providing all supporated languages
  @override
  bool isSupported(Locale locale) {
    //
    return appLanguages
        .map(
          (appLanguage) =>
              UiUtils.getLocaleFromLanguageCode(appLanguage.languageCode),
        )
        .toList()
        .contains(locale);
  }

  //load languageCode.json files
  @override
  Future<AppLocalization> load(Locale locale) async {
    final AppLocalization localization = AppLocalization(locale);
    await localization.loadJson();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) {
    return false;
  }
}
