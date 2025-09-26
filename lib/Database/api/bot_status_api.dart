import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:match5/const.dart';

class BotStatusApi {
  Future<void> createBotStatus(userId, botId) async {
    try {
      print("botting yahan bhi ${userId}");
      var url = Uri.parse("$BASE_URL/botStatus/createStatus");
      var response =
          await http.post(url, body: {"userId": userId, "botId": botId});

      var resData = jsonDecode(response.body);
      return;
    } catch (e) {
      print("something wrong mate $e");
      return;
    }
  }

  Future<String> getBotStatus(userId, botId) async {
    try {
      var url = Uri.parse("$BASE_URL/botStatus/getStatus");
      var response = await http.post(url, body: {userId, botId});
      var resData = jsonDecode(response.body);
      print('status bhi hai ab ${resData["status"]}');
      return resData["status"];
    } catch (e) {
      return "offline";
    }
  }

  Future<void> changeBotStatus(userId, botId, status) async {
    try {
      var url = Uri.parse("$BASE_URL/botStatus/updateStatus");
      var response = await http.post(url, body: {userId, botId, status});
      var resData = jsonDecode(response.body);
      print('status bhi hai ab ${resData["status"]}');
      return resData["status"];
    } catch (e) {
      print("something wrong here mate $e");
    }
  }
}
