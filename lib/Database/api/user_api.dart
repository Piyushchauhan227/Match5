import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:match5/Models/login_result.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/const.dart';

class OnBoardConnection {
  //post signup
  Future<LoginResultEnd> signupInMongo(name, email) async {
    var url = Uri.parse('$BASE_URL/user/signup');
    var response = await http.post(url, body: {'name': name, 'email': email});
    var resData = jsonDecode(response.body);
    print("hi hello");
    print(resData);
    return LoginResultEnd(
        result: response.statusCode,
        user: UserModel(
            id: resData["id"],
            name: resData["name"],
            email: resData["email"],
            gender: resData["gender"],
            interestedGender: resData["interestedGender"],
            username: resData["username"],
            fcmToken: resData["fcmToken"],
            coins: resData["coins"],
            userProfile: resData["userProfile"],
            about: resData["about"]));
  }

  //post method for login
  Future<dynamic> loginInMongo(email) async {
    try {
      var url = Uri.parse('$BASE_URL/user/login');
      var response = await http.post(url, body: {'email': email});
      var resData = jsonDecode(response.body);
      if (response.statusCode == 400) {
        return LoginResultEnd(
            result: response.statusCode,
            user: UserModel(
                id: "",
                name: "",
                email: "",
                gender: "",
                interestedGender: "",
                username: "",
                fcmToken: [],
                coins: -1,
                userProfile: "",
                about: ""));
      } else {
        return LoginResultEnd(
            result: response.statusCode,
            user: UserModel(
                id: resData["id"],
                name: resData["name"],
                email: resData["email"],
                gender: resData["gender"],
                interestedGender: resData["interestedGender"],
                username: resData["username"],
                fcmToken: resData["fcmToken"],
                coins: resData["coins"],
                userProfile: resData["userProfile"],
                about: resData["about"]));
      }
    } catch (e) {}
  }

  //post method for getting user details
  Future<dynamic> gettingUserDetails(id) async {
    var url = Uri.parse('$BASE_URL/user/info');
    try {
      var response = await http.post(url, body: {'id': id});
      var resData = jsonDecode(response.body);

      print("ethe chk km");
      print(resData);
      return LoginResultEnd(
          result: response.statusCode,
          user: UserModel(
              id: resData["id"],
              name: resData["name"],
              email: resData["email"],
              gender: resData["gender"],
              interestedGender: resData["interestedGender"],
              username: resData["username"],
              fcmToken: resData["fcmToken"],
              coins: resData["coins"],
              userProfile: resData["userProfile"],
              about: resData["about"]));
    } catch (e) {
      print("chk jatta");
      return false;
    }
  }

  //update user
  Future<LoginResultEnd> updateUser(
      id, gender, interestedGender, username, userProfile, about) async {
    var url = Uri.parse('$BASE_URL/user/update');
    var response = await http.patch(url, body: {
      "id": id,
      "gender": gender,
      "interestedGender": interestedGender,
      "username": username,
      "userProfile": userProfile,
      "about": about
    });
    var resData = jsonDecode(response.body);
    print(resData);
    return LoginResultEnd(
        result: response.statusCode,
        user: UserModel(
            id: resData["id"],
            name: resData["name"],
            email: resData["email"],
            gender: resData["gender"],
            interestedGender: resData["interestedGender"],
            username: resData["username"],
            fcmToken: resData["fcmToken"],
            coins: resData["coins"],
            userProfile: resData["userProfile"],
            about: resData["about"]));
  }

  Future<void> updateAndDeleteFCMToken(id, newToken, prevToken) async {
    try {
      var url = Uri.parse("$BASE_URL/user/updateAndDeleteFCM");
      var response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id.toString(),
          'newToken': newToken,
          'prevToken': prevToken,
        }),
      );

      var resData = jsonDecode(response.body);
    } catch (e) {
      debugPrint("error in reg tokens $e");
    }
  }

  Future<void> updateFCM(id, newToken) async {
    try {
      var url = Uri.parse("$BASE_URL/user/updateFCM");
      print("urrrls are $id and new tokens are $newToken");
      var response =
          await http.patch(url, body: {"id": id, "newToken": newToken});

      var resData = jsonDecode(response.body);
      print(resData);
    } catch (e) {
      return null;
    }
    // resData["fcmToken"];
  }

  Future<String> deleteFCMToken(id, token) async {
    var url = Uri.parse("$BASE_URL/user/deleteOldFCM");
    var response = await http.patch(url, body: {"id": id, "fcmToken": token});

    var resData = jsonDecode(response.body);
    print(resData);
    return resData["fcmToken"];
  }

  Future<List<dynamic>> getAvatarList() async {
    var url = Uri.parse("$BASE_URL/user/getAvatarName");
    var response = await http.get(url);
    var resData = jsonDecode(response.body);
    print(resData);
    return resData;
  }

  Future<void> deletFcmTokens(id) async {
    try {
      var url = Uri.parse("$BASE_URL/user/deleteFCM?id=$id");
      var response = await http.patch(url);
      var resData = jsonDecode(response.body);
    } catch (e) {
      print("not able to clean fcm in db $e");
    }
  }

  Future<void> updateUserFires(fires, id) async {
    try {
      var incrementValue = fires.toString();
      print("incremented fires are $incrementValue");
      var url =
          Uri.parse("$BASE_URL/user/updateFires?id=$id&fires=$incrementValue");
      var response = await http.patch(url);
      var resData = jsonDecode(response.body);
      print(resData);
    } catch (e) {
      print("error in decrementing $e");
    }
  }
}
