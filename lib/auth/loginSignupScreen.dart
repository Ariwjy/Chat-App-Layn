import 'package:appchat/auth/loginScreen.dart';
import 'package:appchat/auth/signupScreen.dart';
import 'package:appchat/main.dart';
import 'package:flutter/material.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
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

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        AnimatedPositioned(
          duration: const Duration(seconds: 1),
          top: mq.height * .15,
          right: _isAnimate ? mq.width * .25 : -mq.width * .5,
          width: mq.width * .5,
          child: Image.asset('images/icon.png'),
        ),

        // Positioned for the title "LAYN"
        Positioned(
          top: mq.height * .38, // Adjust this value to place the title below the logo
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'LAYN',
              style: TextStyle(
                fontSize: 24, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),

        Positioned(
          bottom: mq.height * .3, // Position of the new button
          left: mq.width * .05,
          width: mq.width * .9,
          height: mq.height * .07,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 178, 255, 219),
              shape: const StadiumBorder(),
              elevation: 1,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Loginscreen()),
              );
            },
            icon: Icon(Icons.login), // Add an icon if needed
            label: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(
                    text: "LOGIN",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: mq.height * .2, // Position of the new button
          left: mq.width * .05,
          width: mq.width * .9,
          height: mq.height * .07,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 178, 255, 219),
              shape: const StadiumBorder(),
              elevation: 1,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Signupscreen()),
              );
            },
            icon: Icon(Icons.person_add), // Add an icon if needed
            label: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(
                    text: "SIGN UP",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
