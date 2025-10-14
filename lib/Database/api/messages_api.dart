import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:match5/Models/message_model.dart';
import 'package:match5/Models/message_model_in_db.dart';
import 'package:match5/const.dart';
import 'package:http/http.dart' as http;
import 'package:match5/utils/login_helper.dart';

class MessagesAPI {
  Future<String> createConversation(
      message, time, sentTo, sentBy, path, isBot, String status) async {
    try {
      var url = Uri.parse('$BASE_URL/message/create_conversation');
      var response = await http.post(url, body: {
        "message": message,
        "time": time,
        "sentTo": sentTo,
        "sentBy": sentBy,
        "path": path,
        "isBot": isBot,
        "status": status
      });
      var resData = jsonDecode(response.body);

      return resData["array"];
    } catch (e) {
      return "";
    }
  }

  Future<String> getConversationId(sentTo, sentBy) async {
    try {
      var url = Uri.parse(
          "$BASE_URL/message/get_conversation_id?sentTo=$sentTo&sentBy=$sentBy");

      var response = await http.get(url);
      var resData = jsonDecode(response.body);

      if (resData["id"] != null) {
        return resData["id"];
      } else {
        return "null";
      }
    } catch (e) {
      return "null";
    }
  }

  Future<bool> updateConversation(
      message, time, sentTo, sentBy, conversationId, status, path) async {
    try {
      var url = Uri.parse("$BASE_URL/message/update_conversation");
      var response = await http.post(url, body: {
        "message": message,
        "time": time,
        "sentTo": sentTo,
        "sentBy": sentBy,
        "id": conversationId,
        "status": status,
        "path": path
      });

      var resData = jsonDecode(response.body);
      return resData["limit"];
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getSentByMessages(sentBy) async {
    try {
      List<MessageModelInDB> list = [];
      var url = Uri.parse(
          '$BASE_URL/message/get_conversations_by_user?sentBy=$sentBy');
      var response = await http.get(url);
      var resData = jsonDecode(response.body);
      print("idhr ku ni");
      print(resData["list"]);
      return resData["list"];
    } catch (e) {
      return [];
    }
  }

  Future<List<MessageModel>> getConversationBetweenUsers(
      sentBy, sentTo, page, conId) async {
    try {
      List<MessageModel> conversation = [];
      var myId = await Helper.getLoginId();
      print("dd");
      print(conId);
      var url = Uri.parse(
          "$BASE_URL/message/get_conversation_between_users?sentTo=$sentTo&sentBy=$sentBy&page=$page&conId=$conId");
      var response = await http.get(url);
      var resData = jsonDecode(response.body);

      for (var i = 0; i < resData["chat"].length; i++) {
        if (resData["chat"][i] != null) {
          var type = "";
          var sentTo = resData["chat"][i]["sentTo"];
          if (myId != sentTo) {
            type = "source";
          } else {
            type = "reply";
          }
          conversation.add(MessageModel(
              type: type,
              message: resData["chat"][i]["message"],
              time: resData["chat"][i]["time"],
              path: resData["chat"][i]["path"],
              status: resData["chat"][i]["status"]));
        }
      }
      return conversation;
    } catch (e) {
      return [];
    }
  }

  deleteConversation(otherUserId, myId) async {
    var url = Uri.parse("$BASE_URL/message/delete_conversation");
    try {
      var response =
          await http.delete(url, body: {"sentTo": otherUserId, "sentBy": myId});
      var resData = jsonDecode(response.body);

      print("deleting here");
      print(resData);
    } catch (e) {
      print(e);
    }
  }

  Future<void> getConversationEvenIfDeleted(id) async {
    try {
      print("lgta hai yhi nhi chla");
      var url = Uri.parse(
          "$BASE_URL/message/get_conversation_even_deleted?conversationId=$id");
      var response = await http.get(url);

      var resData = jsonDecode(response.body);

      var deletedFor = resData["list"]["deletedFor"];
      if (deletedFor.length >= 2) {
        // await updateConversation(message, time, sentTo, sentBy, conversationId, status)

        //yahan pe update krna hai conversation ko
      }
      // print(resData["list"]);
    } catch (e) {
      debugPrint("error in getConvo even delete $e");
    }
  }

  Future<bool> getlimitInfo(id) async {
    try {
      print("limit ke andar");
      var url = Uri.parse("$BASE_URL/message/limitReached?conversationId=$id");
      var response = await http.get(url);

      var resData = jsonDecode(response.body);
      print("res btau");
      print(resData);
      return resData["limit"];
    } catch (e) {
      return false;
    }
  }
}
