class SpecialistRatingModel {
  int _id;
  String _userId;
  String _firstName;
  String _lastName;
  String _profileImage;
  String _specialization;
  String _rating;
  String _degree;
  String _education;
  String _bio;
  String _timeZone;
  String _address;
  String _email;
  String _mobile;

  SpecialistRatingModel(
    this._id,
    this._userId,
    this._firstName,
    this._lastName,
    this._profileImage,
    this._specialization,
    this._rating,
    this._bio,
    this._degree,
    this._education,
    this._timeZone,
    this._address,
    this._email,
    this._mobile,
  );

  String get mobile => _mobile;

  set mobile(String value) {
    _mobile = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get address => _address;

  set address(String value) {
    _address = value;
  }

  String get timeZone => _timeZone;

  set timeZone(String value) {
    _timeZone = value;
  }

  String get degree => _degree;

  set degree(String value) {
    _degree = value;
  }

  String get rating => _rating;

  set rating(String value) {
    _rating = value;
  }

  String get specialization => _specialization;

  set specialization(String value) {
    _specialization = value;
  }

  String get profileImage => _profileImage;

  set profileImage(String value) {
    _profileImage = value;
  }

  String get lastName => _lastName;

  set lastName(String value) {
    _lastName = value;
  }

  String get firstName => _firstName;

  set firstName(String value) {
    _firstName = value;
  }

  String get userId => _userId;

  set userId(String value) {
    _userId = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String get education => _education;

  set education(String value) {
    _education = value;
  }

  String get bio => _bio;

  set bio(String value) {
    _bio = value;
  }
}
