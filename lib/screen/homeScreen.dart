import 'dart:convert';
import 'dart:developer';

import 'package:appchat/api/apis.dart';
import 'package:appchat/auth/profileScreen.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:appchat/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Homescreen> {
  List<ChatUser> list = [];

  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar
      appBar: AppBar(
        leading: const Icon(CupertinoIcons.home),
        title: const Text('Lyne'),
        actions: [
          //seacrh button
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),

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
                list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                  
               

              if(list.isNotEmpty){
                return ListView.builder(
                  itemCount: list.length,
                  padding: EdgeInsets.only(top: mq.height * .01),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return  ChatUserCard(user: list[index]);
                    // return Text('Name: ${list[index]}');
                  });
              }else{
                return const Center(child: Text ('No connections found!!!', style: TextStyle(fontSize: 20)));
              }
          }
        },
      ),
    );
  }
}
