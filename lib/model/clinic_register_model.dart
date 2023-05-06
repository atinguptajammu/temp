class ClinicRegisterModel {
  Status? status;
  List<Data>? data;

  ClinicRegisterModel({this.status, this.data});

  ClinicRegisterModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] != null ? Status.fromJson(json['status']) : null;
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (status != null) {
      data['status'] = status!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Status {
  String? type;
  int? code;
  List<String>? message;
  bool? error;

  Status({this.type, this.code, this.message, this.error});

  Status.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    code = json['code'];
    message = json['message'].cast<String>();
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['code'] = code;
    data['message'] = message;
    data['error'] = error;
    return data;
  }
}

class Data {
  String? token;
  User? user;

  Data({this.token, this.user});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? firstName;
  String? lastName;
  String? mobile;
  String? stateId;
  String? email;
  String? address;
  int? role;
  bool? isActive;
  String? updatedAt;
  String? createdAt;
  int? id;

  User(
      {this.firstName,
      this.lastName,
      this.mobile,
      this.stateId,
      this.email,
      this.address,
      this.role,
      this.isActive,
      this.updatedAt,
      this.createdAt,
      this.id});

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    mobile = json['mobile'];
    stateId = json['state_id'];
    email = json['email'];
    address = json['address'];
    role = json['role'];
    isActive = json['is_active'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['mobile'] = mobile;
    data['state_id'] = stateId;
    data['email'] = email;
    data['address'] = address;
    data['role'] = role;
    data['is_active'] = isActive;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    return data;
  }
}
