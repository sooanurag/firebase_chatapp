class MessageModel {
  String? messageId;
  String? senderId;
  String? text;
  bool? seen;
  DateTime? createdOn;

  MessageModel({
    this.senderId,
    this.text,
    this.seen,
    this.createdOn,
    this.messageId,
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    senderId = map["senderId"];
    messageId = map["messageId"];
    text = map["text"];
    seen = map["seen"];
    createdOn = map["createdOn"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "messageId": messageId,
      "text": text,
      "seen": seen,
      "createdOn": createdOn,
    };
  }
}
