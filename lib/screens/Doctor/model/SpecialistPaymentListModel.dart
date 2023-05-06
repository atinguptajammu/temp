class SpecialistPaymentListModel {
  String _caseId;
  String _firstName;
  String _lastName;
  String _profile;
  String _description;
  String _amount;
  String _createdDate;
  String _status;
  bool _eligible;

  SpecialistPaymentListModel(
    this._caseId,
    this._firstName,
    this._lastName,
    this._profile,
    this._description,
    this._amount,
    this._createdDate,
    this._status,
    this._eligible,
  );

  bool get eligible => _eligible;

  set eligible(bool value){
    _eligible = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get createdDate => _createdDate;

  set createdDate(String value) {
    _createdDate = value;
  }

  String get amount => _amount;

  set amount(String value) {
    _amount = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get profile => _profile;

  set profile(String value) {
    _profile = value;
  }

  String get lastName => _lastName;

  set lastName(String value) {
    _lastName = value;
  }

  String get firstName => _firstName;

  set firstName(String value) {
    _firstName = value;
  }

  String get caseId => _caseId;

  set caseId(String value) {
    _caseId = value;
  }
}
