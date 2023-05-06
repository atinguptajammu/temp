class SpecialistHistoryModel {
  int _id;
  String _profileImage;
  String _firstName;
  String _lastName;
  String _date;
  String _status;
  String _isOpen;
  String _video;
  String _chat;
  String _amount;
  //jj
  //String date;

  SpecialistHistoryModel(
    this._id,
    this._profileImage,
    this._firstName,
    this._lastName,
    this._date,
    this._status,
    this._isOpen,
    this._video,
    this._chat,
    this._amount,
      //this.date
  );


  String get chat => _chat;

  set chat(String value) {
    _chat = value;
  }

  String get amount => _amount;

  set amount(String value) {
    _amount = value;
  }

  String get video => _video;

  set video(String value) {
    _video = value;
  }

  String get isOpen => _isOpen;

  set isOpen(String value) {
    _isOpen = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  String get lastName => _lastName;

  set lastName(String value) {
    _lastName = value;
  }

  String get firstName => _firstName;

  set firstName(String value) {
    _firstName = value;
  }

  String get profileImage => _profileImage;

  set profileImage(String value) {
    _profileImage = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }
}
