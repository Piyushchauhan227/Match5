import 'package:match5/Models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Helper {
  static String isLoggedIn = "isLoggedIn";
  static String id = "id";
  static bool isHomePageAlreadyLoaded = false;
  static UserModel userModel = UserModel(
      id: "",
      name: "",
      email: "",
      gender: "",
      interestedGender: "",
      username: "",
      fcmToken: [],
      coins: 0,
      userProfile: "",
      about: "");

  // static Future<bool> saveLoginInfoAtFirst() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return await prefs.setBool(isLoggedIn, false);
  // }

  static Future<bool> saveLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(isLoggedIn, true);
  }

  static Future<bool> saveLoginId(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(id, value);
  }

  static Future<bool> saveFCMToken(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString("fcm_token", value);
  }

  static Future<String?> getFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("fcm_token");
  }

  static Future<bool> savePreviousFCMToken(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString("prev_fcm_token", value);
  }

  static Future<String?> getPreviousFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("prev_fcm_token");
  }

  // Read Data
  static Future getLoginInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(isLoggedIn);
  }

  static Future getLoginId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(id);
  }

  static void setHomePageLoaded() {
    isHomePageAlreadyLoaded = true;
  }

  static bool getHomePageLoaded() {
    return isHomePageAlreadyLoaded;
  }

  static void saveHomePageUser(UserModel user) {
    userModel = user;
  }

  static UserModel getHomePageUser() {
    return userModel;
  }
}
