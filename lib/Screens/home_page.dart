import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chatapp/Models/chatroom_model.dart';
import 'package:firebase_chatapp/Models/firebaseHelper.dart';
import 'package:firebase_chatapp/Screens/chatroom_page.dart';
import 'package:firebase_chatapp/Screens/login_page.dart';
import 'package:firebase_chatapp/Screens/search_page.dart';

import 'package:flutter/material.dart';

import '../Models/user_model.dart';

class HomePage extends StatefulWidget {
  final User firebaseUser;
  final UserModel userData;
  const HomePage({
    super.key,
    required this.userData,
    required this.firebaseUser,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chat App"),
          actions: [
            IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const LoginPage()));
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        body: SafeArea(
          child: Container(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatroom")
                  .where("participants.${widget.userData.userId}",
                      isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot querySnapshot =
                        snapshot.data as QuerySnapshot;
                    return ListView.builder(
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: (context, index) {
                          ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                              querySnapshot.docs[index].data()
                                  as Map<String, dynamic>);
                          String targetUserId =
                              chatRoomModel.participants!["targetUser"];
                          return FutureBuilder(
                              future: FirebaseHelper.fetchUserDataModel(
                                  targetUserId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  UserModel targetUser =
                                      snapshot.data as UserModel;
                                  return ListTile(
                                    onTap: () {
                                      //navigate to chatroom
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ChatroomPage(
                                            targetUserData: targetUser,
                                            userData: widget.userData,
                                            firebaseUser: widget.firebaseUser,
                                            chatroom: chatRoomModel,
                                          ),
                                        ),
                                      );
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage:
                                          (targetUser.profilePicture != null)
                                              ? NetworkImage(
                                                  targetUser.profilePicture!)
                                              : null,
                                    ),
                                    title: Text(targetUser.fullName!),
                                    subtitle: Text(chatRoomModel.lastMessage!),
                                  );
                                } else {
                                  return Container();
                                }
                              });
                        });
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else {
                    return const Center(
                      child: Text("No chats found!"),
                    );
                  }
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SearchPage(
                userData: widget.userData,
                firebaseUser: widget.firebaseUser,
              ),
            ));
          },
          child: const Icon(
            Icons.search,
          ),
        ));
  }
}
