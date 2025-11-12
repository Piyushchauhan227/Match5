import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class RewardCard extends StatefulWidget {
  const RewardCard(
      {required this.fire,
      required this.reward,
      required this.price,
      required this.packName,
      required this.isAd,
      super.key});

  final String fire;
  final String reward;
  final String price;
  final String packName;
  final bool isAd;

  @override
  State<RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<RewardCard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAd) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color.fromARGB(197, 232, 157, 120)]),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: const Offset(0, 3),
                )
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                    ),
                  ),
                  child: Text(
                    '${widget.packName}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              if ((widget.fire == "assets/fire.png" ||
                  widget.fire == "assets/double_fire.png"))
                Image.asset(
                  widget.fire,
                  width: 50,
                  height: 50,
                ),
              if (widget.fire == "assets/fire_log.png")
                Image.asset(
                  widget.fire,
                  width: 100,
                  height: 50,
                ),
              if (widget.fire == "assets/triple_fire.png")
                Image.asset(
                  widget.fire,
                  width: 100,
                  height: 50,
                ),
              Padding(
                padding: EdgeInsetsGeometry.all(8),
                child: Text(
                  widget.reward,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  widget.price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              )
            ],
          ),
        ),
      );
    }
    if (widget.isAd) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color.fromARGB(197, 232, 157, 120)]),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: const Offset(0, 3),
                )
              ]),
          child: Stack(
            children: [
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.fire == "assets/watch_ad.png")
                      Icon(
                        Icons.ondemand_video_sharp,
                        color: Colors.red,
                        size: 58,
                      ),
                    Padding(
                        padding: EdgeInsetsGeometry.all(4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Earn 5 ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            Image.asset(
                              "assets/fire.png",
                              width: 20,
                              height: 20,
                            )
                          ],
                        )),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: Colors.red, // 👈 red border
                            width: 2, // border thickness
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.slow_motion_video_rounded,
                              size: 20,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Watch an ad",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 8,
                    )
                  ],
                ),
              ),
              // Positioned(
              //   top: 0,
              //   right: 0,
              //   child: Container(
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //     decoration: const BoxDecoration(
              //       color: Colors.red,
              //       borderRadius: BorderRadius.only(
              //         topRight: Radius.circular(15.0),
              //         bottomLeft: Radius.circular(15.0),
              //       ),
              //     ),
              //     child: Text(
              //       '${widget.packName}',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontWeight: FontWeight.bold,
              //         fontSize: 12,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      );
    }
    return SizedBox();
  }
}
