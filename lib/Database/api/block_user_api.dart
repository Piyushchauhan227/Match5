import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:match5/Models/block_result.dart';
import 'package:match5/const.dart';

class BlockUserApi {
  Future<String> createBlockItem(blockingId, blockedId, isBlocked) async {
    var url = Uri.parse("$BASE_URL/block/block_user");
    var response = await http.post(url, body: {
      "blockingId": blockingId,
      "blockedId": blockedId,
      "isBlocked": isBlocked
    });

    var resData = jsonDecode(response.body);
    print(resData);
    return resData["id"];
  }

  Future<Blockresult> checkBlocking(blockingId, blockedId) async {
    var url = Uri.parse(
        "$BASE_URL/block/check_block?blockingId=$blockingId&blockedId=$blockedId");
    var response = await http.get(url);
    var resData = jsonDecode(response.body);
    print(resData);
    if (resData["message"] == "success") {
      print(resData["blockingId"]);
      return Blockresult(
          result: resData["isBlocked"], blockingId: resData["blockingId"]);
    } else if (resData["message"] == "failed") {
      return Blockresult(result: "failed", blockingId: "");
    } else {
      return Blockresult(result: "false", blockingId: "");
    }
  }

  Future<String> changeBlocking(blockingId, blockedId, isBlocked) async {
    var url = Uri.parse("$BASE_URL/block/change_blocking");
    var response = await http.post(url, body: {
      "blockingId": blockingId,
      "blockedId": blockedId,
      "isBlocked": isBlocked
    });

    var resData = jsonDecode(response.body);
    if (resData["message"] == "success") {
      return "true";
    } else {
      return "false";
    }
  }

  Future<List<dynamic>> getBlockedUsers(id) async {
    var url = Uri.parse("$BASE_URL/block/getBlockedUsers?id=$id");
    var response = await http.get(url);

    var resData = jsonDecode(response.body);

    print(resData);
    return resData["blockedUsers"];
  }

  Future<List<dynamic>> deleteBlockEntry(id) async {
    var url = Uri.parse("$BASE_URL/block/delete?id=$id");
    var response = await http.delete(url);

    var resData = jsonDecode(response.body);
    print("block chek mae");
    print(resData);
    return resData["blockedUsers"];
  }
}
