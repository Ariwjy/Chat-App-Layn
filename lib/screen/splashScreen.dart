import 'dart:developer';

import 'package:appchat/api/apis.dart';
import 'package:appchat/auth/loginScreen.dart';
import 'package:appchat/screen/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';


//splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      //exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white, statusBarColor: Colors.white));

      if(APIs.auth.currentUser != null){

        log('\nUser: ${APIs.auth.currentUser}');
       

        Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => Homescreen())
      );
      }else{
        Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => Loginscreen())
      );
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      //body
      body: Stack(children: [
        //app logo
        Positioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset('images/icon.png')),
      ]),
    );
  }
}
