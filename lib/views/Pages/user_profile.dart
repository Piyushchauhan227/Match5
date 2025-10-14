import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/Services/ad_service.dart';
import 'package:match5/const.dart';
import 'package:match5/utils/choose_avatar.dart';
import 'package:match5/views/Pages/edit_profile.dart';
import 'package:match5/views/Pages/image_view.dart';
import 'package:match5/views/Pages/wallet_page.dart';
import 'package:provider/provider.dart';
import 'package:match5/Provider/user_provider.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({required this.user, super.key});

  final UserModel? user;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController _usernameEditingController =
      TextEditingController();

  // var genderList = ["Male", "Female", "Non-Binary"];
  final ImagePicker imagePicker = ImagePicker();
  XFile? file;
  var profilepic = "";
  String finalSelectedPicture = "";

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userNow = Provider.of<UserProvider>(context, listen: true).user;
    print("icnone $userNow");
    profilepic = userNow!.userProfile;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("My Profile",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (builder) => WalletPage()));
            },
            child: Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white, // or any background color you want
                borderRadius: BorderRadius.circular(20), // capsule effect
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/fire.png",
                    width: 18,
                    height: 23,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    userNow!.coins.toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 8,
                  )
                ],
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    chooseAvatar(userNow);
                  },
                  child: PhysicalModel(
                    elevation: 10,
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    shadowColor: Colors.black38,
                    child: CircleAvatar(
                      radius: 50,
                      child: ClipOval(
                        child:
                            Image.network("$BASE_URL/profile_pics/$profilepic"),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(userNow!.username,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => EditProfile(
                                    user: userNow,
                                  )));
                        },
                        child: Text(
                          "Edit profile",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )),
            SizedBox(
              height: 8,
            ),
            Center(
              child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  height: 170,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/fire_bg_second.png"),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(0),
                  child: SizedBox.expand(
                    child: Column(
                      // center within the Column
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${userNow.coins.toString()}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'FIRES',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 126, 75),
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                'Use them to match with more people.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (builder) => WalletPage()));
                            },
                            child: Text(
                              "Click for more",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                  )),
            ),
            Card(
              elevation: 10,
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info,
                                size: 30,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "About",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: userNow.about != ""
                                ? Text(
                                    "${userNow.about}",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                  )
                                : Text(
                                    "Write something about yourself",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                  ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.male,
                                size: 30,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text("Gender", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "${userNow.gender}",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.track_changes_rounded,
                                size: 30,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text("Interested Gender",
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "${userNow.interestedGender}",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void chooseAvatar(UserModel user) async {
    //get the list of character from api
    if (!mounted) return;
    var listOfImages = await OnBoardConnection().getAvatarList();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var changingUserProfile = false;
          var pictureIndex = -1;
          return StatefulBuilder(builder: (context, setstate) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 5,
                backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
                child: Container(
                  height: 500,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Choose your avatar",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: GridView.builder(
                          itemCount: listOfImages.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                          ),
                          itemBuilder: (context, index) {
                            bool isSelected = (widget.user!.userProfile ==
                                        listOfImages[index] &&
                                    !changingUserProfile) ||
                                pictureIndex == index;

                            return GestureDetector(
                                onTap: () {
                                  setstate(() {
                                    changingUserProfile = true;
                                    pictureIndex = index;
                                  });
                                },
                                child: Stack(
                                  children: [
                                    ChooseAvatar(
                                      avatarName: listOfImages[index],
                                    ),
                                    isSelected == true
                                        ? Positioned.fill(
                                            child: ClipOval(
                                              child: Image.asset(
                                                "assets/selected_profile_pic.png",
                                                fit: BoxFit.fill,
                                                height: 80,
                                                width: 80,
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height: 0,
                                          )
                                  ],
                                ));
                          },
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      //                   // Padding(
                      //                   //   padding: const EdgeInsets.all(8.0),
                      //                   //   child: SizedBox(
                      //                   //     width: double.infinity,
                      //                   //     child: TextButton(
                      //                   //       onPressed: () {
                      //                   //         filepicker();
                      //                   //       },
                      //                   //       child: Text(
                      //                   //         "Choose from gallery",
                      //                   //         style: TextStyle(color: Colors.white),
                      //                   //       ),
                      //                   //       style: TextButton.styleFrom(
                      //                   //           backgroundColor:
                      //                   //               Color.fromARGB(200, 26, 43, 92)),
                      //                   //     ),
                      //                   //   ),
                      //                   // ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () async {
                              if (changingUserProfile) {
                                if (widget.user!.userProfile ==
                                    listOfImages[pictureIndex]) {
                                  print("kujn i");
                                } else {
                                  finalSelectedPicture =
                                      listOfImages[pictureIndex];

                                  var userNew = await OnBoardConnection()
                                      .updateUser(
                                          user.id,
                                          user.gender,
                                          user.interestedGender,
                                          user.username,
                                          finalSelectedPicture,
                                          user.about);

                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .updateUser(userNew.user);
                                }
                              }
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Save",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(200, 26, 43, 92)),
                          ),
                        ),
                      )
                    ],
                  ),
                ));
          });
        });
  }

  void filepicker() async {
    file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final CroppedFile? croppedFile = await ImageCropper()
          .cropImage(sourcePath: file!.path, compressQuality: 100, uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Color.fromARGB(200, 227, 0, 34),
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
      ]);

      print(croppedFile!.path.toString());

      // Navigator.of(context).push(MaterialPageRoute(
      //     builder: (builder) =>
      //         ImageView(path: file!.path, onImageSent: () {})));
    }
  }
}
