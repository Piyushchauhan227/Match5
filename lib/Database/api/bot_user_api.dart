import 'dart:convert';

import 'package:match5/const.dart';
import 'package:http/http.dart' as http;

class BotUserAPI {
  Future<dynamic> createBot(
      username, String gender, String interestedGender) async {
    try {
      var url = Uri.parse(
          "$BASE_URL/bot/createBots?&username=$username&gender=${gender}&interestedGender=${interestedGender}");
      var response = await http.post(url);
      var resData = jsonDecode(response.body);
      print("yehsan se");
      print(resData["user"]);
      return resData["user"];
    } catch (e) {
      print("Message is failed $e");
      return null;
    }
  }

  Future<List<dynamic>> getBots(id, gender) async {
    try {
      var url = Uri.parse("$BASE_URL/bot/getBot?id=$id&gender=$gender");
      var response = await http.get(url);
      var resData = jsonDecode(response.body);

      print(resData["user"]);
      return resData["user"];
    } catch (e) {
      return [];
    }
  }

  Future<void> updateBot(id, botId) async {
    try {
      var url = Uri.parse("$BASE_URL/bot/updateBot?id=$id&botId=$botId");
      print("update bot");
      var response = await http.patch(url);
      var resData = jsonDecode(response.body);
      print(resData);
      return;
    } catch (e) {
      print("Meessage is clear $e");
      return;
    }
  }
}
