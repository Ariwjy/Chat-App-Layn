import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import '../models/chat_user.dart';

class APIs{
  static FirebaseAuth auth = FirebaseAuth.instance;
  

  //accessing cloud fire store
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static late ChatUser me;

  static User get user => auth.currentUser!;
  
  static Future<bool> userExist()async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async{
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        developer.log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }


   static Future<void> createUser()async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      id: user.uid, 
      name: user.displayName.toString(), 
      email: user.email.toString(),
      about: "Happy.",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: ''



       );

    return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>getAllUsers() {
     return firestore
      .collection('users')
      .where('id', isNotEqualTo: user.uid)
      .snapshots();
  }

  static Future<void> updateUserInfo()async {
    await firestore.collection('users').doc(user.uid).update({
      'name' : me.name,
      'about' : me.about,
    });
  }
}