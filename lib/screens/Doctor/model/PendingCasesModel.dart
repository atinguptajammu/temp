class PendingCasesModel{
  String _id;
  String _status;
  String _updatedDate;
  String _isOpen;
  String _channelName;
  String _scheduleOption;

  PendingCasesModel(this._id,this._status,this._updatedDate,this._isOpen,this._channelName,this._scheduleOption);

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


  String get isOpen => _isOpen;

  set isOpen(String value) {
    _isOpen = value;
  }

  String get channelName => _channelName;

  set channelName(String value) {
    _channelName = value;
  }

  String get scheduleOption => _scheduleOption;

  set scheduleOption(String value) {
    _scheduleOption = value;
  }
}