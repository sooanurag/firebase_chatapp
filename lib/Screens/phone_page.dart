import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chatapp/Models/textfield_model.dart';
import 'package:flutter/material.dart';

import 'phoneverification_page.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final _phoneController = TextEditingController();

  sendButton() async {
    String inputPhoneNumber = "+91${_phoneController.text}";

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: inputPhoneNumber,
      verificationCompleted: (phoneAuthCredential) {},
      verificationFailed: (error) {},
      codeSent: (verificationId, forceResendingToken) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PhoneVerificationPage(
                  verficationID: verificationId,
                  inputPhone: inputPhoneNumber,
                )));
      },
      codeAutoRetrievalTimeout: (verificationId) {},
      timeout: const Duration(seconds: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Phone"),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  "Enter valid Phone number!",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                const Divider(
                  height: 20,
                ),
                myTextField(
                  label: "Phone",
                  mycontroller: _phoneController,
                  invalidText: "Enter Phone number!",
                  prefixIcon: Icons.phone,
                ),
                const Divider(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    sendButton();
                  },
                  child: const Text(
                    "Send OTP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
