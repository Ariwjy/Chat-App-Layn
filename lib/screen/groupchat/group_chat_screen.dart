import 'package:appchat/api/apis.dart';
import 'package:appchat/auth/profileScreen.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:appchat/screen/groupchat/creategroup/add_members.dart';
import 'package:appchat/screen/groupchat/group_chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appchat/screen/homeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupChatHomeScreen extends StatefulWidget {
  const GroupChatHomeScreen({Key? key}) : super(key: key);

  @override
  _GroupChatHomeScreenState createState() => _GroupChatHomeScreenState();
}

class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  List<ChatUser> _list = [];

  final List<ChatUser> _searchList = [];

  bool _isSearching = false;


  List groupList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
            leading: IconButton(
            icon: const Icon(CupertinoIcons.home),
            onPressed:(){
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => Homescreen()), 
                  (Route<dynamic> route) => false,);
              },
            ),
            title: _isSearching ?
            TextField(
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Name, Email, ...'),
                autofocus: true,
                style: TextStyle(fontSize: 17, letterSpacing: 0.5),    
                onChanged: (val){
                  _searchList.clear();
        
                  for (var i in _list) {
                    if(i.name.toLowerCase().contains(val.toLowerCase()) || 
                      i.email.toLowerCase().contains(val.toLowerCase())) {
                        _searchList.add(i);
                      }
                      setState(() {
                        _searchList;
                      });
                  }
                },      
              )
            : const Text('Layn'),
            actions: [
              //seacrh button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching =! _isSearching;
                  });
                }, 
                icon: Icon(_isSearching 
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search)),
        
              //menu button
              IconButton(onPressed: () {
                Navigator.push(
                  context, MaterialPageRoute(
                    builder: (_) => ProfileScreen(user: APIs.me)));
              }, icon: const Icon(Icons.more_vert)),
              IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupChatHomeScreen(),
                  ),
                );
              },
              icon: Icon(Icons.group),
              ),
            ],
          ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : groupList.isEmpty
              ? Center(
                  child: Text(
                    "No groups available. Create a new group!",
                    style: TextStyle(fontSize: 18),
                  ),
                )
          : ListView.builder(
                  itemCount: groupList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GroupChatRoom(
                            groupName: groupList[index]['name'],
                            groupChatId: groupList[index]['id'],
                          ),
                        ),
                      ),
                      leading: Icon(Icons.group),
                      title: Text(groupList[index]['name']),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.create),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddMembersInGroup(),
          ),
        ),
        tooltip: "Create Group",
      ),
    );
  }
}