import 'dart:io';
import 'package:appchat/screen/groupchat/group_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class GroupChatRoom extends StatefulWidget {
  final String groupChatId, groupName;

  GroupChatRoom({required this.groupName, required this.groupChatId, Key? key})
      : super(key: key);

  @override
  _GroupChatRoomState createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  bool _showEmoji = false, _isUploading = false;

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  void onPickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('chatImages').child(fileName);

      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String imageUrl = await snapshot.ref.getDownloadURL();

      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.displayName,
        "message": imageUrl,
        "type": "img",
        "time": FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('hh:mm a').format(dateTime); // Format as 'HH:MM AM/PM'
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() => _showEmoji = !_showEmoji);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Container(
              color: isLightMode
                  ? const Color.fromARGB(255, 234, 248, 255)
                  : Colors.black,
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('groups')
                          .doc(widget.groupChatId)
                          .collection('chats')
                          .orderBy('time')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var docs = snapshot.data!.docs.reversed.toList();
                          return ListView.builder(
                            reverse: true,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> chatMap =
                                  docs[index].data() as Map<String, dynamic>;
                              return messageTile(size, chatMap);
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                  if (_isUploading)
                    const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            child: CircularProgressIndicator(strokeWidth: 2))),
                  _chatInput(size),
                  if (_showEmoji)
                    SizedBox(
                      height: size.height * .35,
                      child: EmojiPicker(
                        textEditingController: _message,
                        config: Config(),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GroupInfo(
          groupName: widget.groupName,
          groupId: widget.groupChatId,
        ),
      )),
      child: StreamBuilder<DocumentSnapshot>(
        stream:
            _firestore.collection('groups').doc(widget.groupChatId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.data() as Map<String, dynamic>?;

          // Check if data is null or empty
          if (data == null || !data.containsKey('members')) {
            return Center(child: Text('No data found'));
          }

          // Retrieve members list from Firestore data
          List<dynamic>? members = data['members'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.grey),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: Colors.grey,
                            width: 1), // Border berwarna abu-abu
                      ),
                      child: CachedNetworkImage(
                        imageUrl: data['groupImage'] ?? '',
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          backgroundImage: imageProvider,
                          backgroundColor: Colors
                              .grey, // Warna background abu-abu untuk CircleAvatar
                        ),
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => CircleAvatar(
                          backgroundColor: Colors
                              .grey, // Jika terjadi kesalahan, tampilkan CircleAvatar abu-abu
                          child: Icon(CupertinoIcons.group),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.groupName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (members != null && members.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            members.length <= 2
                                ? members
                                    .map((member) => member['name'])
                                    .join(', ')
                                : '${members[0]['name']}, ${members[1]['name']}, ...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chatInput(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: Icon(Icons.emoji_emotions, color: Colors.blueAccent),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _message,
                      decoration: InputDecoration(
                        hintText: "Type Something...",
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none,
                      ),
                      onTap: () {
                        if (_showEmoji)
                          setState(() => _showEmoji = !_showEmoji);
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: onPickImage,
                    icon: Icon(Icons.image, color: Colors.blueAccent),
                  ),
                  IconButton(
                    onPressed: () async {
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        setState(() => _isUploading = true);
                        File imageFile = File(image.path);
                        String fileName =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        Reference storageReference = FirebaseStorage.instance
                            .ref()
                            .child('chatImages')
                            .child(fileName);

                        UploadTask uploadTask =
                            storageReference.putFile(imageFile);
                        TaskSnapshot snapshot = await uploadTask;
                        String imageUrl = await snapshot.ref.getDownloadURL();

                        Map<String, dynamic> chatData = {
                          "sendBy": _auth.currentUser!.displayName,
                          "message": imageUrl,
                          "type": "img",
                          "time": FieldValue.serverTimestamp(),
                        };

                        await _firestore
                            .collection('groups')
                            .doc(widget.groupChatId)
                            .collection('chats')
                            .add(chatData);
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: Icon(Icons.camera_alt_rounded,
                        color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: onSendMessage,
            color: Colors.green,
            shape: CircleBorder(),
            padding: EdgeInsets.all(10),
            child: Icon(Icons.send, color: Colors.white, size: 25),
          ),
        ],
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    bool isMe = chatMap['sendBy'] == _auth.currentUser!.displayName;
   

    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: chatMap['type'] == 'text'
          ? Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              decoration: BoxDecoration(
                color: isMe ? Colors.green : Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatMap['sendBy'],
                    style: TextStyle(
                        fontSize: 12,
                        color: isMe ? Colors.white70 : Colors.black54),
                  ),
                  SizedBox(height: 5),
                  Text(
                    chatMap['message'],
                    style: TextStyle(
                        fontSize: 16,
                        color: isMe ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 3),
                  Text(
                    chatMap['time'] != null
                        ? formatTimestamp(chatMap['time'])
                        : '',
                    style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : Colors.black54),
                  ),
                 
                ],
              ),
            )
          : Container(
              height: size.height / 2.5,
              width: size.width / 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: isMe ? Colors.green : Colors.grey[300],
              ),
              padding: EdgeInsets.all(5),
              child: Image.network(chatMap['message'], fit: BoxFit.cover),
            ),
    );
  }
}
