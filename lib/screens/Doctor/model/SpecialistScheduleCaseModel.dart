class SpecialistScheduleCaseModel {
  Status? status;
  List<Data>? data;

  SpecialistScheduleCaseModel({this.status, this.data});

  SpecialistScheduleCaseModel.fromJson(Map<String, dynamic> json) {
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
  int? id;
  int? doctorId;
  String? specialistId;
  int? specializationId;
  String? amount;
  String? status;
  String? channelName;
  int? appRating;
  String? appExperience;
  int? specialistRating;
  String? specialistExperience;
  String? disputeCause;
  String? disputeDescription;
  String? video;
  String? createdAt;
  String? updatedAt;
  Schedule? schedule;
  Doctor? doctor;
  String? specialist;

  Data(
      {this.id,
        this.doctorId,
        this.specialistId,
        this.specializationId,
        this.amount,
        this.status,
        this.channelName,
        this.appRating,
        this.appExperience,
        this.specialistRating,
        this.specialistExperience,
        this.disputeCause,
        this.disputeDescription,
        this.video,
        this.createdAt,
        this.updatedAt,
        this.schedule,
        this.doctor,
        this.specialist});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = json['doctor_id'];
    specialistId = json['specialist_id'].toString();
    specializationId = json['specialization_id'];
    amount = json['amount'];
    status = json['status'];
    channelName = json['channel_name'];
    appRating = json['app_rating'];
    appExperience = json['app_experience'];
    specialistRating = json['specialist_rating'];
    specialistExperience = json['specialist_experience'];
    disputeCause = json['dispute_cause'];
    disputeDescription = json['dispute_description'];
    video = json['video'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    schedule = json['schedule'] != null
        ? new Schedule.fromJson(json['schedule'])
        : null;
    doctor =
    json['doctor'] != null ? new Doctor.fromJson(json['doctor']) : null;
    specialist = json['specialist'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doctor_id'] = this.doctorId;
    data['specialist_id'] = this.specialistId;
    data['specialization_id'] = this.specializationId;
    data['amount'] = this.amount;
    data['status'] = this.status;
    data['channel_name'] = this.channelName;
    data['app_rating'] = this.appRating;
    data['app_experience'] = this.appExperience;
    data['specialist_rating'] = this.specialistRating;
    data['specialist_experience'] = this.specialistExperience;
    data['dispute_cause'] = this.disputeCause;
    data['dispute_description'] = this.disputeDescription;
    data['video'] = this.video;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.schedule != null) {
      data['schedule'] = this.schedule!.toJson();
    }
    if (this.doctor != null) {
      data['doctor'] = this.doctor!.toJson();
    }
    data['specialist'] = this.specialist;
    return data;
  }
}

class Schedule {
  int? caseId;
  String? scheduleOptions;
  String? selectedOption;
  int? notified;
  String? createdAt;
  String? updatedAt;
  Map? convertedOptions;

  Schedule(
      {this.caseId,
        this.scheduleOptions,
        this.selectedOption,
        this.notified,
        this.createdAt,
        this.updatedAt,
        this.convertedOptions});

  Schedule.fromJson(Map<String, dynamic> json) {
    caseId = json['case_id'];
    scheduleOptions = json['schedule_options'];
    selectedOption = json['selected_option'].toString();
    notified = json['notified'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    convertedOptions = json['converted_options'] != null
        ? json['converted_options']
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['case_id'] = this.caseId;
    data['schedule_options'] = this.scheduleOptions;
    data['selected_option'] = this.selectedOption;
    data['notified'] = this.notified;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.convertedOptions != null) {
      data['converted_options'] = this.convertedOptions!;
    }
    return data;
  }
}


class Doctor {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? emailVerifiedAt;
  String? mobile;
  String? mobileVerifiedAt;
  String? profilePicture;
  String? userActivatedAt;
  String? countryId;
  int? stateId;
  String? address;
  int? role;
  int? isActive;
  String? timezone;
  String? createdAt;
  String? updatedAt;

  Doctor(
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
        this.updatedAt});

  Doctor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    mobile = json['mobile'];
    mobileVerifiedAt = json['mobile_verified_at'];
    profilePicture = json['profile_picture'];
    userActivatedAt = json['user_activated_at'];
    countryId = json['country_id'].toString();
    stateId = json['state_id'];
    address = json['address'];
    role = json['role'];
    isActive = json['is_active'];
    timezone = json['timezone'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
    return data;
  }
}
