import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FullScreenImageView extends StatelessWidget {
  const FullScreenImageView({required this.imagepath, super.key});

  final String imagepath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.pink,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          actions: [
            // IconButton(
            //   onPressed: () {
            //     downloadImage(context);
            //   },
            //   icon: Icon(Icons.download),
            //   tooltip: "Download",
            // )
          ],
        ),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: InteractiveViewer(
                child: Image.network(
              imagepath,
              fit: BoxFit.cover,
            )),
          ),
        ));
  }

  Future<void> downloadImage(BuildContext context) async {
    try {
      //ask for storage permission
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Storage permission denied")));
          return;
        }
      }
      //get directory to save
      final dir =
          await getExternalStorageDirectories(type: StorageDirectory.downloads);
      String filename = imagepath.split("/").last;

      String savepath = "${dir!.first.path}/$filename";

      final response = await http.get(Uri.parse(imagepath));
      final file = File(savepath);
      await file.writeAsBytes(response.bodyBytes);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Image downloaded")));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unable to download image ${e}")));
    }
  }
}
