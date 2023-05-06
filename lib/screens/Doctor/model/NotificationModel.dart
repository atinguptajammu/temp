class NotificationModel{
  String _id;
  String _title;
  String _createdAt;

  NotificationModel(this._id,this._title,this._createdAt);

  String get createdAt => _createdAt;

  set createdAt(String value) {
    _createdAt = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }
}