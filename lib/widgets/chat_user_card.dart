import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../screen/chat_screen.dart';
import 'dialogs/profile_dialog.dart';
import '../helper/dialogs.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  final Function(ChatUser) onDelete;

  const ChatUserCard({super.key, required this.user, required this.onDelete});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info (if null --> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // for navigating to chat screen
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        onLongPress: () {
          _showDeleteDialog();
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

            if (list.isNotEmpty) _message = list[0];

            return ListTile(
              // user profile picture
              leading: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(user: widget.user),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: CachedNetworkImage(
                    width: 50,
                    height: 50,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
              ),

              // user name
              title: Text(widget.user.name),

              // last message
              subtitle: Text(
                _message != null ? (_message!.type == Type.image ? 'image' : _message!.msg) : widget.user.about,
                maxLines: 1,
              ),

              // last message time
              trailing: _message == null
                  ? null // show nothing when no message is sent
                  : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                      ? // show for unread message
                      Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                      : Text(
                          MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),
                          style: const TextStyle(color: Colors.black54),
                        ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Chat'),
          content: const Text('Are you sure you want to delete this chat?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                bool isDeleted = await APIs.deleteChatUser(widget.user.id);
                if (isDeleted) {
                  widget.onDelete(widget.user);
                }
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
