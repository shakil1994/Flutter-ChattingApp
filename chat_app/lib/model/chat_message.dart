// @dart=2.9
class ChatMessage {
  int timeStamp;
  String senderId;
  String name;
  String content;
  bool picture;
  String uid;
  String pictureLink;

  ChatMessage(this.timeStamp, this.senderId, this.name, this.content,
      this.picture, this.uid, this.pictureLink);

  ChatMessage.fromJson(Map<String, dynamic> json) {
    timeStamp = json['timeStamp'];
    senderId = json['senderId'];
    name = json['name'];
    content = json['content'];
    picture = json['picture'];
    uid = json['uid'];
    pictureLink = json['pictureLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timeStamp'] = this.timeStamp;
    data['senderId'] = this.senderId;
    data['name'] = this.name;
    data['content'] = this.content;
    data['picture'] = this.picture;
    data['uid'] = this.uid;
    data['pictureLink'] = this.pictureLink;

    return data;
  }
}
