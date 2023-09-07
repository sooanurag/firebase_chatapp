import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chatapp/Models/textfield_model.dart';
import 'package:firebase_chatapp/Models/user_model.dart';
import 'package:firebase_chatapp/Screens/home_page.dart';
import 'package:firebase_chatapp/Screens/phone_page.dart';
import 'package:firebase_chatapp/Screens/signup_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  loginButton() async {
    String inputEmail = _emailController.text;
    String inputPassword = _passwordController.text;
    UserCredential loginCredential;

    try {
      loginCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: inputEmail,
        password: inputPassword,
      );
      UserModel userData = await fetchUserData(userCredential: loginCredential);
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HomePage(
                userData: userData,
                firebaseUser: loginCredential.user!,
              )));
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
                Navigator.pop(context);
              },
              child: const Text("close"),
            ),
          ],
        ),
      );
    }
  }

  Future<UserModel> fetchUserData({
    required UserCredential userCredential,
  }) async {
    String uId = userCredential.user!.uid;
    DocumentSnapshot userData =
        await FirebaseFirestore.instance.collection("users").doc(uId).get();
    return UserModel.fromMap(userData.data() as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    "Chat App",
                    style: TextStyle(
                      fontSize: 46,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(
                    height: 30,
                  ),
                  myTextField(
                    label: "Email Address",
                    mycontroller: _emailController,
                    hint: "abc@xyz.com",
                    invalidText: "Enter your registered email",
                    prefixIcon: Icons.email_rounded,
                  ),
                  const Divider(
                    height: 20,
                  ),
                  myTextField(
                    label: "Password",
                    mycontroller: _passwordController,
                    invalidText: "Enter your password",
                    prefixIcon: Icons.password_rounded,
                    obscure: true,
                  ),
                  const Divider(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        loginButton();
                      }
                    },
                    child: const Text(
                      "Log in",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Log-in using",
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PhonePage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Phone?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Do not have an account?",
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text(
                "Sign Up!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
