class MessageModelInDB {
  String time;
  String date;
  String message;
  String sentTo;
  String sentBy;
  DateTime createdAt;
  String path;

  MessageModelInDB(
      {required this.time,
      required this.date,
      required this.message,
      required this.sentTo,
      required this.sentBy,
      required this.createdAt,
      required this.path});
}
