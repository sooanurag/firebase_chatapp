import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chatapp/Firebase/firebase_options.dart';
import 'package:firebase_chatapp/Models/firebaseHelper.dart';
import 'package:firebase_chatapp/Models/user_model.dart';
import 'package:firebase_chatapp/Screens/complete_profile.dart';
import 'package:firebase_chatapp/Screens/home_page.dart';
import 'package:firebase_chatapp/Screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  User? currentUser = FirebaseAuth.instance.currentUser;
  runApp(MaterialApp(
    home: (currentUser != null)
        ? HomePage(
            userData:
                (await FirebaseHelper.fetchUserDataModel(currentUser.uid))!,
            firebaseUser: currentUser)
        : const LoginPage(),
  ));
}
