import 'package:eschool/utils/labelKeys.dart';
import 'package:logger/logger.dart';

//database urls
//Please add your admin panel url here and make sure you do not add '/' at the end of the url
//const String baseUrl = "https://eschool.wrteam.me"; //https://eschool.wrteam.me
const String baseUrl = "https://e-system.labs2030.com";
const String databaseUrl = "$baseUrl/api/";
const String storageUrl = "$baseUrl/storage/";

//error message display duration
const Duration errorMessageDisplayDuration = Duration(milliseconds: 3000);

//home menu bottom sheet animation duration
const Duration homeMenuBottomSheetAnimationDuration =
Duration(milliseconds: 300);

//Change slider duration
const Duration changeSliderDuration = Duration(seconds: 5);

//Number of latest notices to show in home container
const int numberOfLatestNoticesInHomeScreen = 3;

//the limit used in pagination APIs where offset and limit logic is used, change to fetch items accordingly
const int offsetLimitPaginationAPIDefaultItemFetchLimit = 15;

//chat message sending related controls
const int maxFilesOrImagesInOneMessage = 30;
const int maxFileSizeInBytesCanBeSent =
10000000; //1000000 = 1 MB (default is 10000000 = 10 MB)
const int maxCharactersInATextMessage = 500;

//notification channel keys
const String notificationChannelKey = "basic_channel";
const String chatNotificationChannelKey = "chat_notifications_channel";

//Set demo version this when upload this code to codecanyon
const bool isDemoVersion = false;

//to enable and disable default credentials in login page
const bool showDefaultCredentials = false;
//default credentials of student
const String defaultStudentGRNumber = "student123";
const String defaultStudentPassword = "student123";
//default credentials of parent
const String defaultParentEmail = "parent@gmail.com";
const String defaultParentPassword = "parent123";

//animations configuration
//if this is false all item appearance animations will be turned off
const bool isApplicationItemAnimationOn = true;
//note: do not add Milliseconds values less then 10 as it'll result in errors
const int listItemAnimationDelayInMilliseconds = 100;
const int itemFadeAnimationDurationInMilliseconds = 250;
const int itemZoomAnimationDurationInMilliseconds = 200;
const int itemBouncScaleAnimationDurationInMilliseconds = 200;

String getExamStatusTypeKey(String examStatus) {
  if (examStatus == "0") {
    return upComingKey;
  }
  if (examStatus == "1") {
    return onGoingKey;
  }
  return completedKey;
}

List<String> examFilters = [allExamsKey, upComingKey, onGoingKey, completedKey];

var logger = Logger(
  printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: false // Should each log logger.i contain a timestamp
  ),
);