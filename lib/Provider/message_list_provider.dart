import 'package:flutter/material.dart';

class MessageListProvider with ChangeNotifier {
  List<dynamic> _list = [];
  bool hasNewMessage = false;

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

  void changeStatus(conversationId) {
    print("change status mein $conversationId");

    final index = _list.indexWhere((c) => c["id"] == conversationId);
    if (index != -1) {
      _list[index]["status"] = "seen";
    }
    notifyListeners();
  }

  void setMessageIndicator(bool value) {
    hasNewMessage = value;
    notifyListeners();
  }

  void getMessageIndicator() {
    final index = _list.indexWhere((c) => c["status"] == "sent");
    if (index != -1) {
      hasNewMessage = true;
    } else {
      hasNewMessage = false;
    }
    notifyListeners();
  }
}
