class SlotModel{
  String _date;
  String _slotTime;

  SlotModel(this._date,this._slotTime);

  String get slotTime => _slotTime;

  set slotTime(String value) {
    _slotTime = value;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }
}