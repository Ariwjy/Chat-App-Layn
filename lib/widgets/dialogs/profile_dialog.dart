import 'package:appchat/models/chat_user.dart';
import 'package:appchat/screen/view_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(
          children: [
            // user profile
            Positioned(
                    top: mq.height * .075,
                    left: mq.width * .1,
                    child: ClipOval(
  child: CachedNetworkImage(
    width: mq.height * .25, // Sesuaikan dengan tinggi untuk membuat lingkaran
    height: mq.height * .25, // Sesuaikan dengan tinggi untuk membuat lingkaran
    fit: BoxFit.cover,
    imageUrl: user.image,
    errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
  ),
),

                  ),

              // user name
            Positioned(
              left: mq.width * .04,
              top: mq.height * .02,
              width: mq.width * .55, 
              child: Text(user.name,
              style: const TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.w500)),
            ),

            //info button
                  
              Positioned(
                  right: 8,
                  top: 6,
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => ViewProfileScreen(user: user )));
                    },
                    minWidth: 0,
                    padding: const EdgeInsets.all(0),
                    shape: CircleBorder(),
                    child: Icon(
                    Icons.info_outline, 
                    color: Colors.blue,
                    size: 30,
              ),
            ),
          )
          ],
          )),
    );
  }
}
