class NeedHelpModel {
  Status? status;

  NeedHelpModel({
    this.status,
  });

  NeedHelpModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] != null ? new Status.fromJson(json['status']) : null;
    if (json['data'] != null) {}
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['status'] = this.status!.toJson();
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
