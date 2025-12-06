// ignore_for_file: non_constant_identifier_names

class User {
  String? user_id;
  String? name;
  String? email;
  String? password;
  String? phone;
  String? reg_date;

  User(
      {this.user_id,
      this.name,
      this.email,
      this.password,
      this.phone,
      this.reg_date});

  User.fromJson(Map<String, dynamic> json) {
    user_id = json['user_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    reg_date = json['reg_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = user_id;
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['phone'] = phone;
    data['reg_date'] = reg_date;
    return data;
  }
}