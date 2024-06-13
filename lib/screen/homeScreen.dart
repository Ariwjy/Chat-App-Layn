import 'dart:developer';

import 'package:appchat/api/apis.dart';
import 'package:appchat/auth/profileScreen.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:appchat/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Homescreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

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
            : const Text('Lyne'),
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
            ],
          ),
        
          //floating button
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () async {
                await APIs.auth.signOut();
                await GoogleSignIn().signOut();
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
        
          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
        
                case ConnectionState.active:
                case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                      
                   
        
                  if(_list.isNotEmpty){
                    return ListView.builder(
                      itemCount: _isSearching ? _searchList.length : _list.length,
                      padding: EdgeInsets.only(top: mq.height * .01),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return  ChatUserCard(
                          user: 
                           _isSearching ? _searchList[index] : _list[index]);// return Text('Name: ${list[index]}');
                      });
                  }else{
                    return const Center(child: Text ('No connections found!!!', style: TextStyle(fontSize: 20)));
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}