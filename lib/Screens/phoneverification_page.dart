import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chatapp/Models/textfield_model.dart';
import 'package:firebase_chatapp/Models/user_model.dart';
import 'package:firebase_chatapp/Screens/complete_profile.dart';
import 'package:flutter/material.dart';

class PhoneVerificationPage extends StatefulWidget {
  final String verficationID;
  final String inputPhone;
  const PhoneVerificationPage({
    super.key,
    required this.verficationID,
    required this.inputPhone,
  });

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _otpController = TextEditingController();

  verifyButton() async {
    String otp = _otpController.text;
    NavigatorState gapsNavigator = Navigator.of(context);

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verficationID,
      smsCode: otp,
    );

    try {
      UserCredential userCredentail =
          await FirebaseAuth.instance.signInWithCredential(credential);
      UserModel newUser = await storeUserCrendentials(
        userCredential: userCredentail,
      );
      gapsNavigator.popUntil((route) => route.isFirst);
      gapsNavigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => CompleteProfile(
            userModel: newUser,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.code.toString()),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("close")),
          ],
        ),
      );
    }
  }

  Future<UserModel> storeUserCrendentials({
    required UserCredential userCredential,
  }) async {
    String uId = userCredential.user!.uid;
    UserModel newUser = UserModel(phoneNumber: widget.inputPhone, userId: uId);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uId)
        .set(newUser.toMap());
    return newUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("OTP verification"),
        centerTitle: false,
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            myTextField(
              label: "Enter OTP",
              mycontroller: _otpController,
              invalidText: "Enter OTP!",
              obscure: true,
              prefixIcon: Icons.password_rounded,
            ),
            const Divider(
              height: 20,
            ),
            TextButton(
                onPressed: () {
                  verifyButton();
                },
                child: Text(
                  "Verfy OTP",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ))
          ],
        ),
      )),
    );
  }
}
