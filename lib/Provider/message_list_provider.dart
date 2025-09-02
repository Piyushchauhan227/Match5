import 'package:flutter/material.dart';

class MessageListProvider with ChangeNotifier {
  List<dynamic> _list = [];

  List<dynamic>? get listFromDb => _list;

  void setList(List<dynamic> list) {
    _list = list;
    notifyListeners();
  }

  void deleteConversation(String otherId) {
    _list.removeWhere((conv) => conv["sentTo"] == otherId);
    print("check kri etge");
    print(otherId);
    notifyListeners();
  }

  void updateConversation(conversationId, message, time) {
    final index = _list.indexWhere((c) => c["id"] == conversationId);
    if (index != -1) {
      final updated = _list.removeAt(index);
      updated["message"] = message;
      updated["time"] = time;
      _list.insert(0, updated);
      notifyListeners();
    }
  }
}
