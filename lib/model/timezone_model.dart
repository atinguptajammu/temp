class TimezoneModel {
  Status? status;
  Data? data;

  TimezoneModel({this.status, this.data});

  TimezoneModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] != null ? Status.fromJson(json['status']) : null;
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (status != null) {
      data['status'] = status!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
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
  String? pacificHonolulu;
  String? americaAdak;
  String? americaAnchorage;
  String? americaLosAngeles;
  String? americaDenver;
  String? americaChicago;
  String? americaNewYork;

  Data(
      {this.pacificHonolulu,
      this.americaAdak,
      this.americaAnchorage,
      this.americaLosAngeles,
      this.americaDenver,
      this.americaChicago,
      this.americaNewYork});

  Data.fromJson(Map<String, dynamic> json) {
    pacificHonolulu = json['Pacific/Honolulu'];
    americaAdak = json['America/Adak'];
    americaAnchorage = json['America/Anchorage'];
    americaLosAngeles = json['America/Los_Angeles'];
    americaDenver = json['America/Denver'];
    americaChicago = json['America/Chicago'];
    americaNewYork = json['America/New_York'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Pacific/Honolulu'] = pacificHonolulu;
    data['America/Adak'] = americaAdak;
    data['America/Anchorage'] = americaAnchorage;
    data['America/Los_Angeles'] = americaLosAngeles;
    data['America/Denver'] = americaDenver;
    data['America/Chicago'] = americaChicago;
    data['America/New_York'] = americaNewYork;
    return data;
  }
}
