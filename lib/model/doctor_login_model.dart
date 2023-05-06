class DoctorLoginModel {
  Status? status;
  List<Data>? data;

  DoctorLoginModel({this.status, this.data});

  DoctorLoginModel.fromJson(Map<String, dynamic> json) {
    status =
    json['status'] != null ? new Status.fromJson(json['status']) : null;
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['status'] = this.status!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['code'] = this.code;
    data['message'] = this.message;
    data['error'] = this.error;
    return data;
  }
}

class Data {
  String? token;
  User? user;

  Data({this.token, this.user});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  Null? emailVerifiedAt;
  String? mobile;
  Null? mobileVerifiedAt;
  String? profilePicture;
  String? userActivatedAt;
  int? countryId;
  int? stateId;
  String? address;
  int? role;
  int? isActive;
  String? timezone;
  String? createdAt;
  String? updatedAt;
  bool? eligible;
  Specialization? specialization;
  Specialist? specialist;
  String? clinicName;

  User(
      {this.id,
        this.firstName,
        this.lastName,
        this.email,
        this.emailVerifiedAt,
        this.mobile,
        this.mobileVerifiedAt,
        this.profilePicture,
        this.userActivatedAt,
        this.countryId,
        this.stateId,
        this.address,
        this.role,
        this.isActive,
        this.timezone,
        this.createdAt,
        this.updatedAt,
        this.eligible,
        this.specialization,
        this.specialist,
        //#GCW 01-02-2023
        this.clinicName
      });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    mobile = json['mobile'];
    mobileVerifiedAt = json['mobile_verified_at'];
    profilePicture = json['profile_picture'];
    userActivatedAt = json['user_activated_at'];
    countryId = json['country_id'];
    stateId = json['state_id'];
    address = json['address'];
    role = json['role'];
    isActive = json['is_active'];
    timezone = json['timezone'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    eligible = json['eligible'];
    specialization = json['specialization'] != null
        ? new Specialization.fromJson(json['specialization'])
        : null;
    specialist = json['specialist'] != null
        ? new Specialist.fromJson(json['specialist'])
        : null;
    //#GCW 01-02-2023
    clinicName = json['clinic_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['mobile'] = this.mobile;
    data['mobile_verified_at'] = this.mobileVerifiedAt;
    data['profile_picture'] = this.profilePicture;
    data['user_activated_at'] = this.userActivatedAt;
    data['country_id'] = this.countryId;
    data['state_id'] = this.stateId;
    data['address'] = this.address;
    data['role'] = this.role;
    data['is_active'] = this.isActive;
    data['timezone'] = this.timezone;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['eligible'] = this.eligible;
    if (this.specialization != null) {
      data['specialization'] = this.specialization!.toJson();
    }
    if (this.specialist != null) {
      data['specialist'] = this.specialist!.toJson();
    }
    return data;
  }
}

class Specialization {
  int? id;
  String? name;
  String? description;
  String? image;
  String? createdAt;
  String? updatedAt;

  Specialization(
      {this.id,
        this.name,
        this.description,
        this.image,
        this.createdAt,
        this.updatedAt});

  Specialization.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Specialist {
  int? id;
  int? userId;
  String? slug;
  String? bio;
  String? education;
  String? accountNumber;
  String? branchCode;
  String? accountName;
  String? degree;
  String? createdAt;
  String? updatedAt;
  int? specializationId;
  String? license;
  Specialization? specialization;

  Specialist(
      {this.id,
        this.userId,
        this.slug,
        this.bio,
        this.education,
        this.accountNumber,
        this.branchCode,
        this.accountName,
        this.degree,
        this.createdAt,
        this.updatedAt,
        this.specializationId,
        this.license,
        this.specialization});

  Specialist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    slug = json['slug'];
    bio = json['bio'];
    education = json['education'];
    accountNumber = json['account_number'];
    branchCode = json['branch_code'];
    accountName = json['account_name'];
    degree = json['degree'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    specializationId = json['specialization_id'];
    license = json['license'];
    specialization = json['specialization'] != null
        ? new Specialization.fromJson(json['specialization'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['slug'] = this.slug;
    data['bio'] = this.bio;
    data['education'] = this.education;
    data['account_number'] = this.accountNumber;
    data['branch_code'] = this.branchCode;
    data['account_name'] = this.accountName;
    data['degree'] = this.degree;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['specialization_id'] = this.specializationId;
    data['license'] = this.license;
    if (this.specialization != null) {
      data['specialization'] = this.specialization!.toJson();
    }
    return data;
  }
}
