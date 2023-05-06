class SpecializationModel{
  String _id;
  String _name;
  String _description;
  String _image;

  SpecializationModel(this._id,this._name,this._description,this._image);

  String get image => _image;

  set image(String value) {
    _image = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }
}