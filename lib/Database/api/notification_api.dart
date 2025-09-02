import 'dart:convert';

import 'package:match5/Database/api/user_api.dart';
import 'package:match5/const.dart';
import 'package:http/http.dart' as http;

class NotificationAPI {
  Future<void> notificationSend(
      id, username, messages, conversationId, path) async {
    try {
      var res = await OnBoardConnection().gettingUserDetails(id);
      var tokens = res.user.fcmToken;
      print("tokens aarhe hai ");
      print(tokens);
      var url = Uri.parse("$BASE_URL/notification/notify");
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "tokens": tokens,
            "message": messages,
            "username": username,
            "conversationId": conversationId,
            "otherUserId": id,
            "path": path
          }));

      var resData = jsonDecode(response.body);
    } catch (e) {}
  }

  Future<void> createUserNotification(String userId, String title,
      String message, String type, String time) async {
    var url = Uri.parse("$BASE_URL/notification/create_user_notification");

    try {
      var response = await http.post(url, body: {
        "userId": userId,
        "title": title,
        "message": message,
        "type": type,
        "time": time
      });

      var resData = jsonDecode(response.body);
    } catch (e) {
      return;
    }
  }

  Future<List<dynamic>> getUserNotifications(String userId) async {
    try {
      var url = Uri.parse(
          "$BASE_URL/notification/get_user_notification?userId=$userId");
      var response = await http.get(url);
      var resData = jsonDecode(response.body);
      print("notiss yipeeee");
      print(resData["notification"]);

      return resData["notification"];
    } catch (e) {
      return [false];
    }
  }

  // Future<List<dynamic>> getGlobalNotifications(){
  //   try{

  //   }
  // }
}
