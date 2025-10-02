import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:match5/const.dart';

class ReportUserApi {
  Future<void> reportUser(reportId, reportedId, reason, conversationId) async {
    try {
      var url = Uri.parse("$BASE_URL/report/createReport");
      var response = await http.post(url, body: {
        "reportId": reportId,
        "reportedId": reportedId,
        "reason": reason,
        "conversationId": conversationId
      });

      var resData = jsonDecode(response.body);
    } catch (e) {
      print("Didnt worked $e");
    }
  }
}
