import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen ({super.key});

  @override
  State<Homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      //app bar
      appBar: AppBar(
        leading: const Icon(CupertinoIcons.home),
        title: const Text ('Lyne'),
        actions: [
          //seacrh button
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),

          //menu button
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),

      //floating button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
            onPressed: () {}, child: const Icon(Icons.add_comment_rounded),),
        )
    );
  }
}