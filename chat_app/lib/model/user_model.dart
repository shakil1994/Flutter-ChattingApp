// @dart=2.9
class UserModel {
  String firstName;
  String lastName;
  String phone;

  UserModel({this.firstName, this.lastName, this.phone});

  UserModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['phone'] = this.phone;

    return data;
  }
}
