import 'package:flutter/material.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/views/home_screen.dart';
import 'package:match5/views/onBoardScreens/login_screen.dart';
import 'package:match5/utils/login_helper.dart';
import 'package:provider/provider.dart';
import 'package:match5/Provider/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? loginCheck = false;
  UserModel? userhere;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    var check = await Helper.getLoginInfo();
    print(check);
    print("uiske upr");

    if (check != Null) {
      print("yhan bhi");
      var id = await Helper.getLoginId();
      var res = await OnBoardConnection().gettingUserDetails(id);
      if (res != false) {
        if (!mounted) return;
        Provider.of<UserProvider>(context, listen: false).setUser(res.user);
        setState(() {
          userhere = res.user;
        });
        setState(() {
          loginCheck = true;
        });
      } else {
        print("yheen dikkt hai");
      }
    } else {
      setState(() {
        loginCheck = check;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
            onTap: () {
              print(loginCheck);
              loginCheck == true
                  ? Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (builder) => HomeScreen(user: userhere!)))
                  : Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (builder) => const Loginscreen()));
            },
            child: const Text(
              "Match5",
              style: TextStyle(fontSize: 44),
            )),
      ),
    );
  }
}
