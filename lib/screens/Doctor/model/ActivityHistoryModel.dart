class ActivityHistoryModel {
  String _id;
  String _profilePicture;
  String _firstName;
  String _lastName;
  String _specialization;
  String _medicalNumber;
  String _createdDate;
  String _status;
  String _isOpen;
  String _video;
  String _chat;

  ActivityHistoryModel(this._id, this._profilePicture, this._firstName, this._lastName, this._specialization, this._medicalNumber, this._createdDate, this._status,this._isOpen,this._video,this._chat);

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get createdDate => _createdDate;

  set createdDate(String value) {
    _createdDate = value;
  }

  String get medicalNumber => _medicalNumber;

  set medicalNumber(String value) {
    _medicalNumber = value;
  }

  String get specialization => _specialization;

  set specialization(String value) {
    _specialization = value;
  }

  String get lastName => _lastName;

  set lastName(String value) {
    _lastName = value;
  }

  String get firstName => _firstName;

  set firstName(String value) {
    _firstName = value;
  }

  String get profilePicture => _profilePicture;

  set profilePicture(String value) {
    _profilePicture = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get isOpen => _isOpen;

  set isOpen(String value) {
    _isOpen = value;
  }

  String get video => _video;

  set video(String value) {
    _video = value;
  }

  String get chat => _chat;

  set chat(String value) {
    _chat = value;
  }
}
