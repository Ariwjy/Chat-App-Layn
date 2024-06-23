import 'dart:developer';

import 'package:appchat/api/apis.dart';
import 'package:appchat/auth/profileScreen.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:appchat/models/message.dart';
import 'package:appchat/screen/groupchat/group_chat_screen.dart';
import 'package:appchat/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helper/dialogs.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Homescreen> {
  List<ChatUser> _list = [];


  final List<ChatUser> _searchList = [];

  bool _isSearching = false;


@override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

     

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if(_isSearching){
            setState(() {
              _isSearching = ! _isSearching;
            });
          }else{
            return Future.value(true);
          }
          return Future.value(false);
        },
        child: Scaffold(
          //app bar
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
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

              //menu button
              IconButton(onPressed: () {
                Navigator.push(
                  context, MaterialPageRoute(
                    builder: (_) => ProfileScreen(user: APIs.me)));
              }, icon: const Icon(Icons.more_vert)),
              
             

             
            ],
          ),
        
          //floating button
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () {
                _addChatUserDialog();
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
        
            body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                case ConnectionState.active:
                case ConnectionState.done:
                  final userIds = snapshot.data?.docs.map((e) => e.id).toList() ?? [];

                  return StreamBuilder(
                    stream: APIs.getAllUsers(userIds),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(child: CircularProgressIndicator());

                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

                          if (_list.isEmpty) {
                            return const Center(
                              child: Text('No Contact Added', style: TextStyle(fontSize: 20)),
                            );
                          }

                          // Fetch the last message for each user and store it in a map
                          Map<String, Message> lastMessages = {};
                          List<Future<void>> futures = [];

                          for (ChatUser user in _list) {
                            futures.add(
                              APIs.getLastMessage(user).first.then((snapshot) {
                                if (snapshot.docs.isNotEmpty) {
                                  lastMessages[user.id] = Message.fromJson(snapshot.docs.first.data());
                                }
                              }),
                            );
                          }

                          // Wait for all futures to complete
                          return FutureBuilder(
                            future: Future.wait(futures),
                            builder: (context, _) {
                              if (_.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              // Sort users based on the timestamp of their last message
                              _list.sort((a, b) {
                                final aLastMessage = lastMessages[a.id];
                                final bLastMessage = lastMessages[b.id];

                                if (aLastMessage == null && bLastMessage == null) return 0;
                                if (aLastMessage == null) return 1;
                                if (bLastMessage == null) return -1;

                                return bLastMessage.sent.compareTo(aLastMessage.sent);
                              });

                              return ListView.builder(
                                itemCount: _isSearching ? _searchList.length : _list.length,
                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .01),
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final user = _isSearching ? _searchList[index] : _list[index];
                                  return ChatUserCard(
                                    user: user,
                                    onDelete: (deletedUser) {
                                      setState(() {
                                        _list.remove(deletedUser);
                                        if (_isSearching) {
                                          _searchList.remove(deletedUser);
                                        }
                                      });
                                    },
                                  );
                                },
                              );
                            },
                          );
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  

   // for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('Add User')
                  
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnackBar(
                                context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}