

import 'dart:developer';

import 'package:appchat/main.dart';
import 'package:appchat/screen/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen ({super.key});

  @override
  State<Loginscreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Loginscreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

_handleGoogleBtnClick(){
  _signInWithGoogle().then((user) {
    log('\nUser: ${user.user}');
    log('\nUserAdditionalInfo: ${user.additionalUserInfo}');
    Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => const Homescreen()));
  });
}

Future<UserCredential> _signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return  Scaffold(
      //app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text ('Welcome to Lyne'),
      ),

      body: Stack(children: [
        AnimatedPositioned(
          duration: const Duration(seconds: 1),
          top: mq.height * .15,
          right: _isAnimate ? mq.width * .25 : -mq.width * .5 , 
          width: mq.width * .5, 
          child: Image.asset('images/icon.png')),

        Positioned(
          bottom: mq.height * .15,
          left: mq.width * .05, 
          width: mq.width * .9,
          height: mq.height * .07, 
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 219, 255, 178),
              shape: const StadiumBorder(),
              elevation: 1,
            ),
            onPressed: () {
              _handleGoogleBtnClick();
            }, 
            icon: Image.asset('images/google.png'), 
            label: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(text: "Sign In With "),
                  TextSpan(
                    text: "Google",
                    style: TextStyle(fontWeight: FontWeight.w500)),
                ]), 
              ))),
        ]),
    );
  }
}