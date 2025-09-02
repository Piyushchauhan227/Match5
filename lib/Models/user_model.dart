class UserModel {
  String id;
  String name;
  String email;
  String gender;
  String interestedGender;
  String username;
  List<dynamic> fcmToken;
  int coins;
  String userProfile;
  String about;

  UserModel(
      {required this.id,
      required this.name,
      required this.email,
      required this.gender,
      required this.interestedGender,
      required this.username,
      required this.fcmToken,
      required this.coins,
      required this.userProfile,
      required this.about});
}
