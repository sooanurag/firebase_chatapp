class UserModel {
  String? userId;
  String? fullName;
  String? emailId;
  String? profilePicture;
  String? phoneNumber;

  UserModel(
      {this.userId,
      this.fullName,
      this.emailId,
      this.profilePicture,
      this.phoneNumber});

  UserModel.fromMap(Map<String, dynamic> map) {
    userId = map["userId"];
    fullName = map["fullName"];
    emailId = map["emailId"];
    phoneNumber = map["phoneNumber"];
    profilePicture = map["profilePicture"];
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "fullName": fullName,
      "emailId": emailId,
      "phoneNumber": phoneNumber,
      "profilePicture": profilePicture,
    };
  }
}
