import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:match5/Database/api/block_user_api.dart';
import 'package:match5/const.dart';

class BlockedUsers extends StatefulWidget {
  const BlockedUsers({required this.id, super.key});

  final String id;

  @override
  State<BlockedUsers> createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  List<dynamic> listBlocked = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBlockedUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blocked users",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: listBlocked.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            "$BASE_URL/profile_pics/${listBlocked[index]["userProfile"]}"),
                      ),
                      title: Text(
                        listBlocked[index]["username"],
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: PopupMenuButton(
                          icon: Icon(Icons.more_vert),
                          itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                    onTap: () {
                                      unblockPerson(index);
                                    },
                                    child: Text("Unblock"))
                              ]),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  Future<void> getBlockedUsers() async {
    var list = await BlockUserApi().getBlockedUsers(widget.id);
    setState(() {
      listBlocked = list;
    });
  }

  Future<void> unblockPerson(index) async {
    var list = await BlockUserApi().deleteBlockEntry(widget.id);
    if (!mounted) return;
    setState(() {
      listBlocked.removeAt(index);
    });
  }
}
