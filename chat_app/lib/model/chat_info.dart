// @dart=2.9
class ChatInfo {
  String friendName, friendId, createId, lastMessage, createName;
  int lastUpdate, createDate;

  ChatInfo(
      {this.friendName,
      this.friendId,
      this.createId,
      this.lastMessage,
      this.createName,
      this.lastUpdate,
      this.createDate});

  ChatInfo.fromJson(Map<String, dynamic> json) {
    friendName = json['friendName'];
    friendId = json['friendId'];
    createId = json['createId'];
    lastMessage = json['lastMessage'];
    createName = json['createName'];
    lastUpdate = json['lastUpdate'];
    createDate = json['createDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['friendName'] = this.friendName;
    data['friendId'] = this.friendId;
    data['createId'] = this.createId;
    data['lastMessage'] = this.lastMessage;
    data['createName'] = this.createName;
    data['lastUpdate'] = this.lastUpdate;
    data['createDate'] = this.createDate;

    return data;
  }
}