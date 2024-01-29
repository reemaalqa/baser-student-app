import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eschool/data/models/chatNotificationData.dart';
import 'package:eschool/data/repositories/settingsRepository.dart';
import 'package:eschool/utils/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatNotificationsUtils {
  static int? currentChattingUserId;

  static late StreamController<ChatNotificationData>
      notificationStreamController;

  static initialize() {
    //remove old data when initilizing to remove terminated state data
    SettingsRepository().setBackgroundChatNotificationData(data: []);
    notificationStreamController = StreamController.broadcast();
  }

  static dispose() {
    notificationStreamController.close();
  }

  //foreground chat notification handler
  static addChatStreamAndShowNotification({required RemoteMessage message}) {
    final chatNotification =
        ChatNotificationData.fromRemoteMessage(remoteMessage: message);
    notificationStreamController.add(chatNotification);
    if (currentChattingUserId != chatNotification.fromUser.userId &&
        Platform.isAndroid) {
      createChatNotification(chatData: chatNotification, message: message);
    }
  }

  static addChatStreamValue({required ChatNotificationData chatData}) {
    notificationStreamController.add(chatData);
  }

  static createChatNotification(
      {required ChatNotificationData chatData,
      required RemoteMessage message}) async {
    String title = "";
    String body = "";
    String type = "";
    String? image;

    if (message.notification != null) {
      title = message.notification?.title ?? "";
      body = message.notification?.body ?? "";
    } else {
      title = message.data["title"] ?? "";
      body = message.data["body"] ?? "";
    }
    type = message.data['type'] ?? "";
    image = message.data['image'];

    if (image == null) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          autoDismissible: true,
          title: title,
          body: body,
          locked: false,
          wakeUpScreen: true,
          payload: {
            "type": type,
            "sender_info": message.data['sender_info'],
          },
          channelKey: chatNotificationChannelKey,
          notificationLayout: NotificationLayout.BigText,
        ),
      );
    } else {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          autoDismissible: true,
          title: title,
          body: body,
          locked: false,
          wakeUpScreen: true,
          bigPicture: image,
          payload: {
            "type": type,
            "sender_info": message.data['sender_info'],
          },
          channelKey: chatNotificationChannelKey,
          notificationLayout: NotificationLayout.BigPicture,
        ),
      );
    }
  }
}
