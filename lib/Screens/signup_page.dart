import 'package:firebase_chatapp/Models/textfield_model.dart';
import 'package:firebase_chatapp/Models/user_model.dart';
import 'package:firebase_chatapp/Screens/complete_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  signupButton(
    NavigatorState gapsNavigator,
  ) async {
    String inputEmail = _emailController.text;
    String inputPassword = _passwordController.text;
    UserCredential signUpCredential;

    try {
      signUpCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: inputEmail,
        password: inputPassword,
      );
      UserModel newUser = await storeUserCredential(
        userCredential: signUpCredential,
        inputEmail: inputEmail,
      );
      gapsNavigator.popUntil((route) => route.isFirst);
      gapsNavigator.pushReplacement(
        MaterialPageRoute(builder: (context) => CompleteProfile(userModel: newUser,)),
      );
    } on FirebaseAuthException catch (e) {

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.code.toString()),
          actions: [
            TextButton(
              onPressed: () {
                gapsNavigator.pop();
              },
              child: const Text("close"),
            ),
          ],
        ),
      );
    }
  }

  Future<UserModel> storeUserCredential({
    required UserCredential userCredential,
    required String inputEmail,
  }) async {
    String uId = userCredential.user!.uid;
    UserModel newUser = UserModel(
      userId: uId,
      emailId: inputEmail,
    );

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uId)
        .set(newUser.toMap());
    return newUser;
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Sign Up"),
        centerTitle: false,
      ),
      body: SafeArea(
          child: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Divider(
                height: 40,
              ),
              Text(
                "Create an Account!",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const Divider(
                height: 20,
              ),
              myTextField(
                label: "Email Address",
                mycontroller: _emailController,
                hint: "abc@xyz.com",
                invalidText: "Enter emial!",
                prefixIcon: Icons.email_rounded,
              ),
              const Divider(
                height: 20,
              ),
              myTextField(
                label: "Password",
                mycontroller: _passwordController,
                invalidText: "Enter password!",
                prefixIcon: Icons.password_rounded,
                obscure: true,
              ),
              const Divider(
                height: 20,
              ),
              myTextField(
                label: "Confirm password",
                mycontroller: _confirmPasswordController,
                invalidText: "Enter password again!",
                prefixIcon: Icons.password_rounded,
                obscure: true,
              ),
              const Divider(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (_passwordController.text ==
                        _confirmPasswordController.text) {
                      signupButton(
                        Navigator.of(context),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Error!"),
                          content: const Text("Passwords did'nt match!"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Close"),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
