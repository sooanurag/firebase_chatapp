import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chatapp/Models/messages_model.dart';
import 'package:firebase_chatapp/Models/textfield_model.dart';
import 'package:firebase_chatapp/Models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/chatroom_model.dart';
import '../main.dart';

class ChatroomPage extends StatefulWidget {
  final UserModel targetUserData;
  final UserModel userData;
  final User firebaseUser;
  final ChatRoomModel chatroom;

  const ChatroomPage({
    super.key,
    required this.targetUserData,
    required this.userData,
    required this.firebaseUser,
    required this.chatroom,
  });

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  final _messageController = TextEditingController();

  void sendMessage() async {
    String inputMessage = _messageController.text.trim();

    if (inputMessage.isNotEmpty) {
      MessageModel newMessage = MessageModel(
        messageId: uuid.v1(),
        senderId: widget.userData.userId,
        text: inputMessage,
        createdOn: DateTime.now(),
        seen: false,
      );
      FirebaseFirestore.instance
          .collection("chatroom")
          .doc(widget.chatroom.chatroomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(
            newMessage.toMap(),
          );
      _messageController.clear();
      // await will wait for server to store on firestore,
      // not using will store in local db, when device will get online
      // then it will store on firestore.
      widget.chatroom.lastMessage = inputMessage;
      FirebaseFirestore.instance
          .collection("chatroom")
          .doc(widget.chatroom.chatroomId)
          .set(widget.chatroom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: (widget.targetUserData.profilePicture!.isNotEmpty)
                  ? NetworkImage(widget.targetUserData.profilePicture!)
                  : null,
            ),
            const VerticalDivider(),
            Text(widget.targetUserData.fullName!),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            margin: const EdgeInsets.all(10),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatroom")
                  .doc(widget.chatroom.chatroomId)
                  .collection("messages")
                  .orderBy("createdOn", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot querySnapshot =
                        snapshot.data as QuerySnapshot;
                    return ListView.builder(
                        padding: EdgeInsets.zero,
                        reverse: true,
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: ((context, index) {
                          MessageModel currentMessage = MessageModel.fromMap(
                              querySnapshot.docs[index].data()
                                  as Map<String, dynamic>);
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: (currentMessage.senderId ==
                                        widget.userData.userId)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      decoration: BoxDecoration(
                                          color: (currentMessage.senderId ==
                                                  widget.userData.userId)
                                              ? Colors.blueGrey.withOpacity(.5)
                                              : Colors.green.withOpacity(.5),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          currentMessage.text!,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      )),
                                ],
                              ),
                              const Divider(
                                height: 2,
                              ),
                              Row(
                                mainAxisAlignment: (currentMessage.senderId ==
                                        widget.userData.userId)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat("H:mm d/M/yy")
                                        .format(currentMessage.createdOn!),
                                    style: const TextStyle(fontSize: 8),
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 5,
                              ),
                            ],
                          );
                        }));
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("An error occured!"),
                    );
                  } else {
                    return const Center(
                      child: Text("Say hi!"),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          )),
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 25,
            ),
            child: Row(
              children: [
                Flexible(
                  child: myTextField(
                    label: "Write you message...",
                    mycontroller: _messageController,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.blue,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
