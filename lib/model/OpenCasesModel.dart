class OpenCasesModel {
  String _id;
  String _status;
  String _updatedDate;
  String _specialistFirstName;
  String _specialistLastName;
  String _profilePicture;
  String _channelName;
  String _isOpen;
  String _selectedSchedule;
  String _specialistId;
  String _specializationName;
  String _selectedOption;
  String _caseStartTime;
  String _caseEndTime;
  String _seconds;

  OpenCasesModel(
    this._id,
    this._status,
    this._updatedDate,
    this._specialistFirstName,
    this._specialistLastName,
    this._profilePicture,
    this._channelName,
    this._isOpen,
    this._selectedSchedule,
    this._specialistId,
    this._specializationName,
    this._selectedOption,
    this._caseStartTime,
    this._caseEndTime,
    this._seconds,
  );

  String get seconds => _seconds;

  set seconds(String value) {
    _seconds = value;
  }

  String get caseStartTime => _caseStartTime;

  set caseStartTime(String value) {
    _caseStartTime = value;
  }

  String get specializationName => _specializationName;

  set specializationName(String value) {
    _specializationName = value;
  }

  String get profilePicture => _profilePicture;

  set profilePicture(String value) {
    _profilePicture = value;
  }

  String get specialistLastName => _specialistLastName;

  set specialistLastName(String value) {
    _specialistLastName = value;
  }

  String get specialistFirstName => _specialistFirstName;

  set specialistFirstName(String value) {
    _specialistFirstName = value;
  }

  String get updatedDate => _updatedDate;

  set updatedDate(String value) {
    _updatedDate = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get channelName => _channelName;

  set channelName(String value) {
    _channelName = value;
  }

  String get isOpen => _isOpen;

  set isOpen(String value) {
    _isOpen = value;
  }

  String get selectedSchedule => _selectedSchedule;

  set selectedSchedule(String value) {
    _selectedSchedule = value;
  }

  String get specialistId => _specialistId;

  set specialistId(String value) {
    _specialistId = value;
  }
  // 06-11-22 | Task - 4 scheduler case time is wrong |gwc

  String get selectedOption => _selectedOption;

  String get caseEndTime => _caseEndTime;

  set caseEndTime(String value) {
    _caseEndTime = value;
  }
}
