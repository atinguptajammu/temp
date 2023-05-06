class GetAnswerModel{
  String _id;
  String _question;
  String _answers;

  GetAnswerModel(this._id,this._question,this._answers);

  String get answers => _answers;

  set answers(String value) {
    _answers = value;
  }

  String get question => _question;

  set question(String value) {
    _question = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }
}