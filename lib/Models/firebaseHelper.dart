import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chatapp/Models/user_model.dart';

class FirebaseHelper {
  static Future<UserModel?> fetchUserDataModel(String uid) async {
    UserModel? userData;
    DocumentSnapshot docsSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (docsSnap.data() != null) {
      userData = UserModel.fromMap(docsSnap.data() as Map<String, dynamic>);
    }
    return userData;
  }
}
