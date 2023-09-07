import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chatapp/Models/showDialog.dart';
import 'package:firebase_chatapp/Models/textfield_model.dart';
import 'package:firebase_chatapp/Models/user_model.dart';
import 'package:firebase_chatapp/Screens/home_page.dart';
import 'package:firebase_chatapp/Screens/login_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User? firebaseUser;

  const CompleteProfile(
      {super.key, required this.userModel, this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  File? imageFile;

  selectImage(ImageSource source) async {
    XFile? pickedImageFile = await ImagePicker().pickImage(source: source);
    if (pickedImageFile != null) {
      cropImage(pickedImageFile);
    }
  }

  cropImage(XFile pickedImageFile) async {
    CroppedFile? croppedIMageFile =
        await ImageCropper().cropImage(sourcePath: pickedImageFile.path);
    if (croppedIMageFile != null) {
      setState(() {
        imageFile = File(croppedIMageFile.path);
      });
    }
  }

  showProfilePicturesOptionsDialog() {
    ShowDialogModel.alertDialog(
      context,
      "Profile picture!",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context).pop();
              selectImage(ImageSource.gallery);
            },
            title: const Text("Select from Gallery"),
            leading: const Icon(Icons.photo_album_rounded),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pop();
              selectImage(ImageSource.camera);
            },
            title: const Text("Pick from Camera"),
            leading: const Icon(Icons.camera_alt_rounded),
          )
        ],
      ),
      [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("close"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    NavigatorState gapsNavigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Complete Profile"),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                gapsNavigator.popUntil((route) => route.isFirst);
                gapsNavigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded))
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(
              height: 40,
            ),
            CupertinoButton(
              onPressed: () {
                showProfilePicturesOptionsDialog();
              },
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue,
                backgroundImage:
                    (imageFile != null) ? FileImage(imageFile!) : null,
                child: (imageFile == null)
                    ? const Icon(
                        Icons.person_2_rounded,
                        size: 50,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const Divider(
              height: 40,
            ),
            myTextField(
              label: "First Name",
              mycontroller: _firstNameController,
              invalidText: "Enter Full Name!",
              prefixIcon: Icons.person_2_rounded,
            ),
            const Divider(
              height: 20,
            ),
            myTextField(
              label: "Last Name",
              mycontroller: _lastNameController,
              invalidText: "Enter Full Name!",
              prefixIcon: Icons.person_2_rounded,
            ),
            const Divider(
              height: 20,
            ),
            CupertinoButton.filled(
                child: const Text(
                  "Submit",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  submitButton();
                })
          ],
        ),
      ),
    );
  }

  Future<String> uploadDataToFirebaseStorage(File imageFile) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepicture")
        .child(widget.userModel.userId.toString())
        .putFile(imageFile);
    TaskSnapshot uploadTaskSnapshot = await uploadTask;
    return await uploadTaskSnapshot.ref.getDownloadURL();
  }

  submitButton() async {
    final gapsNavigator = Navigator.of(context);
    String fullName =
        "${_firstNameController.text} ${_lastNameController.text}";
    String? imageURL;

    if (imageFile != null) {
      imageURL = await uploadDataToFirebaseStorage(imageFile!);
    } else {
      imageURL = "";
    }

    if (fullName.isNotEmpty && fullName != " ") {
      widget.userModel.fullName = fullName;
      widget.userModel.profilePicture = imageURL;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userModel.userId)
          .set(widget.userModel.toMap());
      gapsNavigator.popUntil((route) => route.isFirst);
      gapsNavigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(
            userData: widget.userModel,
            firebaseUser: FirebaseAuth.instance.currentUser!,
          ),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ShowDialogModel.alertDialog(
          context, "Error", const Text("Enter Full Name"), [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("close"))
      ]);
    }
  }
}
