import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chatapp/Models/chatroom_model.dart';
import 'package:firebase_chatapp/Models/textfield_model.dart';
import 'package:firebase_chatapp/Screens/chatroom_page.dart';
import 'package:firebase_chatapp/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/user_model.dart';

class SearchPage extends StatefulWidget {
  final UserModel userData;
  final User firebaseUser;

  const SearchPage({
    super.key,
    required this.userData,
    required this.firebaseUser,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatroom;
    QuerySnapshot fetchExistingChatroom = await FirebaseFirestore.instance
        .collection("chatroom")
        .where("participants.${widget.userData.userId}", isEqualTo: true)
        .where("participants.${targetUser.userId}", isEqualTo: true)
        .get();

    if (fetchExistingChatroom.docs.isNotEmpty) {
      final chatroomMapObject = fetchExistingChatroom.docs[0].data();
      //as there exist only one chatroom for two individual participants
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(chatroomMapObject as Map<String, dynamic>);
      chatroom = existingChatroom;
    } else {
      ChatRoomModel newChatroom =
          ChatRoomModel(chatroomId: uuid.v1(), lastMessage: "", participants: {
        "user": widget.userData.userId,
        "targetUser": targetUser.userId,
        widget.userData.userId!: true,
        targetUser.userId!: true,
        widget.userData.fullName!: targetUser.fullName,
        widget.userData.emailId ?? widget.userData.phoneNumber!:
            targetUser.emailId ?? targetUser.phoneNumber,
      }
              //mapping userid with targetid
              // used bool to: 1. both participants are active.
              //2. if one blacks other than simple chage to false
              );
      await FirebaseFirestore.instance
          .collection("chatroom")
          .doc(newChatroom.chatroomId)
          .set(newChatroom.toMap());
      chatroom = newChatroom;
    }
    return chatroom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Search"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            children: [
              myTextField(
                label: "User Name",
                mycontroller: _searchController,
                prefixIcon: Icons.person_2_rounded,
              ),
              const Divider(
                height: 20,
              ),
              CupertinoButton.filled(
                  child: const Text(
                    "Find",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    setState(() {});
                  }),
              const Divider(
                height: 20,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("fullName", isEqualTo: _searchController.text)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      List<QueryDocumentSnapshot> searchedUsers =
                          snapshot.data!.docs;
                      // print(searchedUsers.length);
                      if (searchedUsers.isNotEmpty) {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: searchedUsers.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> userMap =
                                  searchedUsers[index].data()
                                      as Map<String, dynamic>;
                              UserModel targetUserData =
                                  UserModel.fromMap(userMap);
                              NavigatorState gapsNavigator =
                                  Navigator.of(context);
                              return ListTile(
                                title: Text(targetUserData.fullName!),
                                subtitle: Text(targetUserData.emailId ??
                                    targetUserData.phoneNumber!),
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: (targetUserData
                                          .profilePicture!.isNotEmpty)
                                      ? NetworkImage(
                                          targetUserData.profilePicture!)
                                      : null,
                                ),
                                trailing: const Icon(
                                    Icons.keyboard_arrow_right_outlined),
                                onTap: () async {
                                  ChatRoomModel? chatroom =
                                      await getChatroomModel(targetUserData);
                                  // open chat
                                  gapsNavigator.pop();
                                  gapsNavigator.push(MaterialPageRoute(
                                      builder: (context) => ChatroomPage(
                                            userData: widget.userData,
                                            firebaseUser: widget.firebaseUser,
                                            targetUserData: targetUserData,
                                            chatroom: chatroom!,
                                          )));
                                },
                              );
                            },
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "No record found!",
                          ),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return const Text("An error occured!");
                    } else {
                      return const Text("No user found!");
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
