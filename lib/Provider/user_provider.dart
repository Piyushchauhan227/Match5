import 'package:flutter/material.dart';
import 'package:match5/Models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void decreaseFires() {
    _user!.coins--;
    notifyListeners();
  }

  void increaseFires() {
    _user!.coins = _user!.coins + 5;
    notifyListeners();
  }
}
