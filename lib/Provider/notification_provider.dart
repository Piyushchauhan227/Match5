import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  List<dynamic> _list = [];

  List<dynamic> get list => _list;

  void setList(List<dynamic> notiList) {
    _list = notiList;
    notifyListeners();
  }
}
