import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psyscale/classes/QuestionAnswer.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/Trouble.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/services/troubleServices.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/widgets.dart';

class AddQuestionnaire extends StatefulWidget {
  final Questionnaire questionnaire;
  final UserData userData;
  final Function changeTab;

  const AddQuestionnaire(
      {Key key, this.userData, this.questionnaire, this.changeTab})
      : super(key: key);
  @override
  _AddQuestionnaireState createState() => _AddQuestionnaireState();
}

class _AddQuestionnaireState extends State<AddQuestionnaire> {
  List<Trouble> troubles = [];
  bool isLoading = false;
  List<String> _steps = [
    'Questionnaire Informations',
    'List Of Questions',
    'List Of Answers',
    'List Of Evaluations'
  ];
  int _currentStep = 1;
  String _type = '1';
  String _troubleUid;
  String _nameEn = '';
  String _nameFr = '';
  String _nameAr = '';
  String _descreptionEn = '';
  String _descreptionFr = '';
  String _descreptionAr = '';
  int _localFrom = 0;
  String _localQuestionEn = '';
  String _localQuestionFr = '';
  String _localQuestionAr = '';
  List<Map<String, Object>> _questions = [];
  List<Map<String, Object>> _answers = [];
  List<QuestionAnswer> _questionsAnswers = [];
  List<Map<String, Object>> _localAnswers = [];
  List<Map<String, Object>> _evaluations = [];
  String _defaultLanguage = '';
  List<String> _supportedLanguages = [];
  bool _isEnglishSupported = true;
  bool _isFrenchSupported = true;
  bool _isArabicSupported = true;

  getTroublesList(QuerySnapshot data) async {
    troubles.clear();
    if (data != null) {
      data.docs.map((doc) {
        troubles.add(Trouble.dropDown(
          uid: doc.id,
          nameEn: doc['nameEn'],
          nameFr: doc['nameFr'],
          nameAr: doc['nameAr'],
          imageUrl: doc['imageUrl'],
        ));
      }).toList();
    }
  }

  updateQuestionnaire() async {
    setState(() {
      isLoading = true;
    });
    if (widget.userData.personalQuestionnaires == null) {
      widget.userData.personalQuestionnaires = [];
    }

    _supportedLanguages = [];
    if (_isEnglishSupported)
      _defaultLanguage = 'English';
    else if (_isFrenchSupported)
      _defaultLanguage = 'Français';
    else if (_isArabicSupported) _defaultLanguage = 'العربية';

    if (_isEnglishSupported) _supportedLanguages.add('English');
    if (_isFrenchSupported) _supportedLanguages.add('Français');
    if (_isArabicSupported) _supportedLanguages.add('العربية');
    Questionnaire questionnaire;
    if (widget.questionnaire == null) {
      questionnaire = Questionnaire(
        type: _type,
        troubleUid: _troubleUid,
        nameEn: _nameEn,
        nameFr: _nameFr,
        nameAr: _nameAr,
        defaultLanguage: _defaultLanguage,
        supportedLanguages: _supportedLanguages,
        descreptionEn: _descreptionEn,
        descreptionFr: _descreptionFr,
        descreptionAr: _descreptionAr,
        questions: _questions,
        answers: _answers,
        questionsAnswers: _questionsAnswers,
        evaluations: _evaluations,
      );
    } else {
      questionnaire = Questionnaire(
        type: widget.questionnaire.type,
        troubleUid: widget.questionnaire.troubleUid,
        nameEn: _nameEn,
        nameFr: _nameFr,
        nameAr: _nameAr,
        defaultLanguage: _defaultLanguage,
        supportedLanguages: _supportedLanguages,
        descreptionEn: _descreptionEn,
        descreptionFr: _descreptionFr,
        descreptionAr: _descreptionAr,
        questions: _questions,
        answers: _answers,
        questionsAnswers: _questionsAnswers,
        evaluations: _evaluations,
      );
      widget.userData.personalQuestionnaires.remove(widget.questionnaire);
    }
    widget.userData.personalQuestionnaires.add(questionnaire);
    await UsersServices(useruid: widget.userData.uid)
        .updatePersonnalQuestionnaires(widget.userData.personalQuestionnaires);
    setState(() {
      isLoading = false;
    });
    widget.changeTab(index: 8, backAppbarTitle: 'Questionnaires');
  }

  @override
  void initState() {
    if (widget.questionnaire != null) {
      _type = widget.questionnaire.type;
      _troubleUid = widget.questionnaire.troubleUid;
      _nameEn = widget.questionnaire.nameEn;
      _nameFr = widget.questionnaire.nameFr;
      _nameAr = widget.questionnaire.nameAr;
      _defaultLanguage = widget.questionnaire.defaultLanguage;
      _supportedLanguages = widget.questionnaire.supportedLanguages;
      _isEnglishSupported = _supportedLanguages.contains('English');
      _isFrenchSupported = _supportedLanguages.contains('Français');
      _isArabicSupported = _supportedLanguages.contains('العربية');
      _descreptionEn = widget.questionnaire.descreptionEn;
      _descreptionFr = widget.questionnaire.descreptionFr;
      _descreptionAr = widget.questionnaire.descreptionAr;
      _questions = widget.questionnaire.questions;
      _answers = widget.questionnaire.answers;
      _questionsAnswers = widget.questionnaire.questionsAnswers;
      _evaluations = widget.questionnaire.evaluations;

      if (_type == '1') {
        if (_steps.length == 3) {
          _steps[1] = 'List Of Questions';
          _steps[2] = 'List Of Answers';
          setState(() {
            _steps.add('List Of Evaluations');
          });
        }
      } else {
        if (_steps.length == 4) {
          _steps[1] = 'List Of Question/Answers ';
          _steps[2] = 'List Of Evaluations';
          setState(() {
            _steps.removeAt(3);
          });
        }
      }
      int _scortest = 0;
      widget.questionnaire.evaluations.forEach((element) {
        if (element['to'] as int > _scortest) {
          _scortest = element['to'];
        }
      });
      _localFrom = _scortest;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBar(
            context,
            widget.questionnaire == null
                ? 'Add Questionnaire'
                : 'Update Questionnaire',
            ''),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          widget.questionnaire != null
              ? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: deleteButton(context, () {
                    createDialog(context,
                        delteQuestionnaire(widget.questionnaire.uid), true);
                  },
                      text: 'Delete Questionnaire',
                      color: Colors.red,
                      icon: Icons.delete),
                )
              : SizedBox(),
        ],
      ),
      body: desktopWidget(
        Container(),
        Container(),
        _addQuestionnaireForm(),
      ),
    );
  }

  Widget _addQuestionnaireForm() {
    int index = 0;
    return isLoading
        ? loading(context)
        : Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(8.0),
                    children: _steps.map((element) {
                      index++;
                      return Card(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        margin: EdgeInsets.all(8.0),
                        shape: index < _currentStep
                            ? RoundedRectangleBorder(
                                side:
                                    BorderSide(color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(6.0),
                              )
                            : null,
                        elevation: 2.0,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: index < _currentStep
                                    ? CircleAvatar(
                                        backgroundColor: Colors.green,
                                        child: Icon(
                                          Icons.done,
                                          size: 30.0,
                                          color: Colors.white,
                                        ))
                                    : null,
                                title: Text(_steps[index - 1]),
                              ),
                            ),
                            index == _currentStep
                                ? index == 1
                                    ? _questionnaireInfo()
                                    : index == 2
                                        ? _type == '1'
                                            ? _questionsList()
                                            : _questionAnswerList()
                                        : index == 3
                                            ? _type == '1'
                                                ? _answersList()
                                                : _evaluationList()
                                            : index == 4
                                                ? _evaluationList()
                                                : SizedBox()
                                : SizedBox(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                _currentStep == 5 || (_currentStep == 4 && _type == '2')
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            stepsButton(
                                context: context,
                                text: 'Edit',
                                icon: Icons.edit,
                                type: 1,
                                onTap: () {
                                  setState(() {
                                    _currentStep--;
                                  });
                                }),
                            SizedBox(width: 6.0),
                            stepsButton(
                                context: context,
                                text: 'Save',
                                icon: Icons.save,
                                type: 2,
                                onTap: () {
                                  int _testScore = 0;
                                  _evaluations.forEach((evaluation) {
                                    if (evaluation['to'] as int > _testScore) {
                                      _testScore = evaluation['to'];
                                    }
                                  });
                                  updateQuestionnaire();
                                }),
                          ],
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          );
  }

  Widget _questionnaireInfo() {
    final _infoFormKey = GlobalKey<FormState>();
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Form(
            key: _infoFormKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(children: [
                SizedBox(height: 6.0),
                widget.questionnaire == null
                    ? DropdownButtonFormField(
                        decoration: textInputDecoration(context, 'Type'),
                        value: _type,
                        items: ['Static', 'Dynamic'].map((type) {
                          return DropdownMenuItem(
                            value: type == 'Static' ? '1' : '2',
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _type = value;
                          if (_type == '1') {
                            if (_steps.length == 3) {
                              _steps[1] = 'List Of Questions';
                              _steps[2] = 'List Of Answers';
                              setState(() {
                                _steps.add('List Of Evaluations');
                              });
                            }
                          } else {
                            if (_steps.length == 4) {
                              _steps[1] = 'List Of Question/Answers ';
                              _steps[2] = 'List Of Evaluations';
                              setState(() {
                                _steps.removeAt(3);
                              });
                            }
                          }
                        },
                      )
                    : SizedBox(),
                SizedBox(height: 6.0),
                widget.questionnaire == null
                    ? StreamBuilder(
                        stream: TroublesServices().troubleData,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            QuerySnapshot data = snapshot.data;
                            getTroublesList(data);
                            return DropdownButtonFormField(
                              decoration:
                                  textInputDecoration(context, 'Trouble'),
                              validator: (value) => _troubleUid == null
                                  ? 'Chose a trouble'
                                  : null,
                              value: _troubleUid,
                              items: troubles.map((trouble) {
                                return DropdownMenuItem(
                                  value: trouble.uid,
                                  child: Text(trouble
                                      .getName(widget.userData.language)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                _troubleUid = value;
                              },
                            );
                          } else {
                            return loading(context);
                          }
                        })
                    : SizedBox(),
                const SizedBox(height: 10.0),
                Text('Supported Languages:'),
                const SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text('English'),
                        leading: Checkbox(
                          value: _isEnglishSupported,
                          onChanged: (value) {
                            if (!(_isEnglishSupported &&
                                    !_isFrenchSupported &&
                                    !_isArabicSupported) &&
                                (widget.questionnaire == null ||
                                    !widget.questionnaire.supportedLanguages
                                        .contains('English'))) {
                              setState(() {
                                _isEnglishSupported = !_isEnglishSupported;
                              });
                            }
                          },
                        ),
                        onTap: () {
                          if (!(_isEnglishSupported &&
                                  !_isFrenchSupported &&
                                  !_isArabicSupported) &&
                              (widget.questionnaire == null ||
                                  !widget.questionnaire.supportedLanguages
                                      .contains('English'))) {
                            setState(() {
                              _isEnglishSupported = !_isEnglishSupported;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('Français'),
                        leading: Checkbox(
                          value: _isFrenchSupported,
                          onChanged: (value) {
                            if (!(_isFrenchSupported &&
                                    !_isEnglishSupported &&
                                    !_isArabicSupported) &&
                                (widget.questionnaire == null ||
                                    !widget.questionnaire.supportedLanguages
                                        .contains('Français'))) {
                              setState(() {
                                _isFrenchSupported = !_isFrenchSupported;
                              });
                            }
                          },
                        ),
                        onTap: () {
                          if (!(_isFrenchSupported &&
                                  !_isEnglishSupported &&
                                  !_isArabicSupported) &&
                              (widget.questionnaire == null ||
                                  !widget.questionnaire.supportedLanguages
                                      .contains('Français'))) {
                            setState(() {
                              _isFrenchSupported = !_isFrenchSupported;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('العربية'),
                        leading: Checkbox(
                          value: _isArabicSupported,
                          onChanged: (value) {
                            if (!(_isArabicSupported &&
                                    !_isFrenchSupported &&
                                    !_isEnglishSupported) &&
                                (widget.questionnaire == null ||
                                    !widget.questionnaire.supportedLanguages
                                        .contains('العربية'))) {
                              setState(() {
                                _isArabicSupported = !_isArabicSupported;
                              });
                            }
                          },
                        ),
                        onTap: () {
                          if (!(_isArabicSupported &&
                                  !_isFrenchSupported &&
                                  !_isEnglishSupported) &&
                              (widget.questionnaire == null ||
                                  !widget.questionnaire.supportedLanguages
                                      .contains('العربية'))) {
                            setState(() {
                              _isArabicSupported = !_isArabicSupported;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                formItem(
                  supportedLanguage: _isEnglishSupported,
                  initialVlue: _nameEn,
                  onChanged: (value) => _nameEn = value,
                  hint: 'English Name',
                  validatorMessage: 'Enter the Name',
                ),
                formItem(
                  supportedLanguage: _isFrenchSupported,
                  initialVlue: _nameFr,
                  onChanged: (value) => _nameFr = value,
                  hint: 'Frensh Name',
                  validatorMessage: 'Enter the Name',
                ),
                formItem(
                  supportedLanguage: _isArabicSupported,
                  initialVlue: _nameAr,
                  onChanged: (value) => _nameAr = value,
                  hint: 'Arabic Name',
                  validatorMessage: 'Enter the Name',
                ),
                formItem(
                  supportedLanguage: _isEnglishSupported,
                  initialVlue: _descreptionEn,
                  onChanged: (value) => _descreptionEn = value,
                  hint: 'English Descreption',
                  validatorMessage: 'Enter the Descreption',
                ),
                formItem(
                  supportedLanguage: _isFrenchSupported,
                  initialVlue: _descreptionFr,
                  onChanged: (value) => _descreptionFr = value,
                  hint: 'Frensh Descreption',
                  validatorMessage: 'Enter the Descreption',
                ),
                formItem(
                  supportedLanguage: _isArabicSupported,
                  initialVlue: _descreptionAr,
                  onChanged: (value) => _descreptionAr = value,
                  hint: 'Arabic Descreption',
                  validatorMessage: 'Enter the Descreption',
                )
              ]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Spacer(),
                stepsButton(
                    context: context,
                    text: 'Next',
                    icon: Icons.navigate_next,
                    type: 2,
                    onTap: () {
                      if (_infoFormKey.currentState.validate()) {
                        setState(() {
                          _currentStep++;
                        });
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionsList() {
    final _questionsformKey = GlobalKey<FormState>();
    String _questionEn = '';
    String _questionFr = '';
    String _questionAr = '';

    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Column(
            children: _questions
                .map((question) => Card(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Constants.myGrey, width: 1.0)),
                    child: ListTile(
                      title: Text(_isEnglishSupported
                          ? question['questionEn']
                          : _isFrenchSupported
                              ? question['questionFr']
                              : question['questionAr']),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _questions.remove(question);
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Constants.border,
                        ),
                      ),
                    )))
                .toList(),
          ),
          Form(
            key: _questionsformKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  formItem(
                    supportedLanguage: _isEnglishSupported,
                    initialVlue: _questionEn,
                    onChanged: (value) => _questionEn = value,
                    hint: 'English Question',
                    validatorMessage: 'Enter the Question',
                  ),
                  formItem(
                    supportedLanguage: _isFrenchSupported,
                    initialVlue: _questionFr,
                    onChanged: (value) => _questionFr = value,
                    hint: 'Frensh Question',
                    validatorMessage: 'Enter the Question',
                  ),
                  formItem(
                    supportedLanguage: _isArabicSupported,
                    initialVlue: _questionAr,
                    onChanged: (value) => _questionAr = value,
                    hint: 'Arabic Question',
                    validatorMessage: 'Enter the Question',
                  ),
                ],
              ),
            ),
          ),
          insidStepButton(context, 'Add Question', () {
            if (_questionsformKey.currentState.validate()) {
              setState(() {
                _questions.add({
                  'questionEn': _questionEn,
                  'questionFr': _questionFr,
                  'questionAr': _questionAr,
                });
                _questionEn = '';
                _questionFr = '';
                _questionAr = '';
              });
            }
          }),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                stepsButton(
                    context: context,
                    text: 'Previos',
                    icon: Icons.navigate_before,
                    type: 1,
                    onTap: () {
                      setState(() {
                        _currentStep--;
                      });
                    }),
                Spacer(),
                stepsButton(
                    context: context,
                    text: 'Next',
                    icon: Icons.navigate_next,
                    type: 2,
                    onTap: () {
                      if (_questions.isEmpty) {
                        final snackBar = SnackBar(
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Theme.of(context).accentColor,
                                width: 2.0),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          content: Text('At least one question'),
                          duration: Duration(seconds: 2),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        setState(() {
                          _currentStep++;
                        });
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _answersList() {
    final _answersformKey = GlobalKey<FormState>();
    String _answerEn = '';
    String _answerFr = '';
    String _answerAr = '';
    String _score = '';

    return Container(
      padding: EdgeInsets.all(8.0),
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Column(
            children: _answers
                .map((answer) => Card(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Constants.myGrey, width: 1.0)),
                    child: ListTile(
                      title: Text(_isEnglishSupported
                          ? answer['answerEn']
                          : _isFrenchSupported
                              ? answer['answerFr']
                              : answer['answerAr']),
                      subtitle: Text('score: ${answer['score']}'),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _answers.remove(answer);
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Constants.border,
                        ),
                      ),
                    )))
                .toList(),
          ),
          Form(
            key: _answersformKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  formItem(
                    supportedLanguage: _isEnglishSupported,
                    initialVlue: _answerEn,
                    onChanged: (value) => _answerEn = value,
                    hint: 'English Answer',
                    validatorMessage: 'Enter the Answer',
                  ),
                  formItem(
                    supportedLanguage: _isFrenchSupported,
                    initialVlue: _answerFr,
                    onChanged: (value) => _answerFr = value,
                    hint: 'Frensh Answer',
                    validatorMessage: 'Enter the Answer',
                  ),
                  formItem(
                    supportedLanguage: _isArabicSupported,
                    initialVlue: _answerAr,
                    onChanged: (value) => _answerAr = value,
                    hint: 'Arabic Answer',
                    validatorMessage: 'Enter the Answer',
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _score,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    decoration: textInputDecoration(context, 'Score'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (value) {
                      return _score = value;
                    },
                  ),
                  SizedBox(height: 6.0),
                ],
              ),
            ),
          ),
          insidStepButton(context, 'Add Answer', () {
            if (_answersformKey.currentState.validate()) {
              setState(() {
                _answers.add({
                  'answerEn': _answerEn,
                  'answerFr': _answerFr,
                  'answerAr': _answerAr,
                  'score': int.parse(_score),
                });
                _answerEn = '';
                _answerFr = '';
                _answerAr = '';
                _score = '';
              });
            }
          }),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                stepsButton(
                    context: context,
                    text: 'Previos',
                    icon: Icons.navigate_before,
                    type: 1,
                    onTap: () {
                      setState(() {
                        _currentStep--;
                      });
                    }),
                Spacer(),
                stepsButton(
                    context: context,
                    text: 'Next',
                    icon: Icons.navigate_next,
                    type: 2,
                    onTap: () {
                      if (_answers.isEmpty) {
                        final snackBar = SnackBar(
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Theme.of(context).accentColor,
                                width: 2.0),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          content: Text('At least one answer'),
                          duration: Duration(seconds: 2),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        setState(() {
                          _currentStep++;
                        });
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionAnswerList() {
    final _questionsformKey = GlobalKey<FormState>();
    final _answersformKey = GlobalKey<FormState>();

    String _answerEn = '';
    String _answerFr = '';
    String _answerAr = '';
    String _score = '';
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Column(
            children: _questionsAnswers.map((questionAnswer) {
              return Card(
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Constants.myGrey, width: 1.0),
                    borderRadius: BorderRadius.circular(20.0)),
                child: Column(
                  children: [
                    ListTile(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Constants.myGrey, width: 1.0),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          )),
                      title: Text(_isEnglishSupported
                          ? questionAnswer.questionEn
                          : _isFrenchSupported
                              ? questionAnswer.questionFr
                              : questionAnswer.questionAr),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _questionsAnswers.remove(questionAnswer);
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Constants.border,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 30.0),
                      child: Column(
                        children: questionAnswer.answers
                            .map((answer) => Column(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Constants.myGrey,
                                              width: 1.0)),
                                      child: ListTile(
                                        title: Text(_isEnglishSupported
                                            ? answer['answerEn']
                                            : _isFrenchSupported
                                                ? answer['answerFr']
                                                : answer['answerAr']),
                                        subtitle:
                                            Text('score: ${answer['score']}'),
                                        trailing: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              questionAnswer.answers
                                                  .remove(answer);
                                            });
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Constants.border,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Form(
            key: _questionsformKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  formItem(
                    supportedLanguage: _isEnglishSupported,
                    initialVlue: _localQuestionEn,
                    onChanged: (value) => _localQuestionEn = value,
                    hint: 'English Question',
                    validatorMessage: 'Enter the Question',
                  ),
                  formItem(
                    supportedLanguage: _isFrenchSupported,
                    initialVlue: _localQuestionFr,
                    onChanged: (value) => _localQuestionFr = value,
                    hint: 'Frensh Question',
                    validatorMessage: 'Enter the Question',
                  ),
                  formItem(
                    supportedLanguage: _isArabicSupported,
                    initialVlue: _localQuestionAr,
                    onChanged: (value) => _localQuestionAr = value,
                    hint: 'Arabic Question',
                    validatorMessage: 'Enter the Question',
                  ),
                ],
              ),
            ),
          ),
          Text(
            'Answers',
            style: TextStyle(fontSize: 20.0),
          ),
          Column(
            children: _localAnswers
                .map((answer) => Card(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Constants.myGrey, width: 1.0)),
                    child: ListTile(
                      title: Text(_isEnglishSupported
                          ? answer['answerEn']
                          : _isFrenchSupported
                              ? answer['answerFr']
                              : answer['answerAr']),
                      subtitle: Text('score: ${answer['score']}'),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _localAnswers.remove(answer);
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Constants.border,
                        ),
                      ),
                    )))
                .toList(),
          ),
          Form(
            key: _answersformKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  formItem(
                    supportedLanguage: _isEnglishSupported,
                    initialVlue: _answerEn,
                    onChanged: (value) => _answerEn = value,
                    hint: 'English Answer',
                    validatorMessage: 'Enter the Answer',
                  ),
                  formItem(
                    supportedLanguage: _isFrenchSupported,
                    initialVlue: _answerFr,
                    onChanged: (value) => _answerFr = value,
                    hint: 'Frensh Answer',
                    validatorMessage: 'Enter the Answer',
                  ),
                  formItem(
                    supportedLanguage: _isArabicSupported,
                    initialVlue: _answerAr,
                    onChanged: (value) => _answerAr = value,
                    hint: 'Arabic Answer',
                    validatorMessage: 'Enter the Answer',
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _score,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    decoration: textInputDecoration(context, 'Score'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (value) {
                      return _score = value;
                    },
                  ),
                  SizedBox(height: 6.0),
                ],
              ),
            ),
          ),
          insidStepButton(context, 'Add Answer', () {
            if (_answersformKey.currentState.validate()) {
              setState(() {
                _localAnswers.add({
                  'answerEn': _answerEn,
                  'answerFr': _answerFr,
                  'answerAr': _answerAr,
                  'score': int.parse(_score),
                });
                _answerEn = '';
                _answerFr = '';
                _answerAr = '';
                _score = '';
              });
            }
          }),
          SizedBox(height: 8.0),
          insidStepButton(context, 'Add Question', () {
            if (_questionsformKey.currentState.validate()) {
              if (_localAnswers.isNotEmpty) {
                QuestionAnswer questionAnswer = QuestionAnswer(
                  questionEn: _localQuestionEn,
                  questionFr: _localQuestionFr,
                  questionAr: _localQuestionAr,
                  answers: [],
                );
                questionAnswer.answers.addAll(_localAnswers);
                _questionsAnswers.add(questionAnswer);
                setState(() {
                  _localQuestionEn = '';
                  _localQuestionFr = '';
                  _localQuestionAr = '';
                  _localAnswers.clear();
                });
              } else {
                final snackBar = SnackBar(
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Theme.of(context).accentColor, width: 2.0),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  content: Text('At least one Answer'),
                  duration: Duration(seconds: 2),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }
          }),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                stepsButton(
                    context: context,
                    text: 'Previos',
                    icon: Icons.navigate_before,
                    type: 1,
                    onTap: () {
                      setState(() {
                        _currentStep--;
                      });
                    }),
                Spacer(),
                stepsButton(
                    context: context,
                    text: 'Next',
                    icon: Icons.navigate_next,
                    type: 2,
                    onTap: () {
                      if (_questionsAnswers.isEmpty) {
                        final snackBar = SnackBar(
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Theme.of(context).accentColor,
                                width: 2.0),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          content: Text('At least one question'),
                          duration: Duration(seconds: 2),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        setState(() {
                          _currentStep++;
                        });
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _evaluationList() {
    final _evaluationsformKey = GlobalKey<FormState>();
    String _from = '';
    String _to = '';
    String _messageEn = '';
    String _messageFr = '';
    String _messageAr = '';

    return Container(
      padding: EdgeInsets.all(8.0),
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Column(
            children: _evaluations.map((evaluation) {
              String message = _isEnglishSupported
                  ? evaluation['messageEn']
                  : _isFrenchSupported
                      ? evaluation['messageFr']
                      : evaluation['messageAr'];
              return Card(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Constants.myGrey, width: 1.0)),
                  child: ListTile(
                    title: Text(
                        'From: ${evaluation['from']}, To: ${evaluation['to']}'),
                    subtitle: Text('message: $message'),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          _evaluations.remove(evaluation);
                        });
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Constants.border,
                      ),
                    ),
                  ));
            }).toList(),
          ),
          Form(
            key: _evaluationsformKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _from,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    decoration: textInputDecoration(context, 'From').copyWith(
                        hintText: '${_localFrom == 0 ? 0 : _localFrom + 1}'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (value) {
                      return _from = value;
                    },
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _to,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    decoration: textInputDecoration(context, 'To'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (value) {
                      return _to = value;
                    },
                  ),
                  formItem(
                    supportedLanguage: _isEnglishSupported,
                    initialVlue: _messageEn,
                    onChanged: (value) => _messageEn = value,
                    hint: 'English Message',
                    validatorMessage: 'Enter the Message',
                  ),
                  formItem(
                    supportedLanguage: _isFrenchSupported,
                    initialVlue: _messageFr,
                    onChanged: (value) => _messageFr = value,
                    hint: 'Frensh Message',
                    validatorMessage: 'Enter the Message',
                  ),
                  formItem(
                    supportedLanguage: _isArabicSupported,
                    initialVlue: _messageAr,
                    onChanged: (value) => _messageAr = value,
                    hint: 'Arabic Message',
                    validatorMessage: 'Enter the Message',
                  ),
                ],
              ),
            ),
          ),
          insidStepButton(context, 'Add Evaluation', () {
            if (_evaluationsformKey.currentState.validate()) {
              setState(() {
                _evaluations.add({
                  'messageEn': _messageEn,
                  'messageFr': _messageFr,
                  'messageAr': _messageAr,
                  'from': int.parse(_from),
                  'to': int.parse(_to),
                });
                _localFrom = int.parse(_to);
                _messageEn = '';
                _messageFr = '';
                _messageAr = '';
                _from = '';
                _to = '';
              });
            }
          }),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                stepsButton(
                    context: context,
                    text: 'Previos',
                    icon: Icons.navigate_before,
                    type: 1,
                    onTap: () {
                      setState(() {
                        _currentStep--;
                      });
                    }),
                Spacer(),
                stepsButton(
                    context: context,
                    text: 'Next',
                    icon: Icons.navigate_next,
                    type: 2,
                    onTap: () {
                      if (_evaluations.isEmpty) {
                        final snackBar = SnackBar(
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Theme.of(context).accentColor,
                                width: 2.0),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          content: Text('At least one evaluation'),
                          duration: Duration(seconds: 2),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        setState(() {
                          _currentStep++;
                        });
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget formItem(
      {bool supportedLanguage,
      String initialVlue,
      Function onChanged,
      String validatorMessage,
      String hint}) {
    return supportedLanguage
        ? Column(children: [
            const SizedBox(height: 6.0),
            TextFormField(
              initialValue: initialVlue,
              validator: (value) => value.isEmpty ? validatorMessage : null,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: textInputDecoration(context, hint),
              onChanged: onChanged,
            ),
          ])
        : SizedBox();
  }

  Widget delteQuestionnaire(String questionnaireUid) {
    return Container(
      padding: EdgeInsets.all(8.0),
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.0),
          Text(
            'Confirm Delete Questionnaire',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.0),
          Text(
            'Are you sure you want to delete this questionnaire?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          SizedBox(height: 12.0),
          Container(
            width: 100,
            child: InkWell(
              onTap: () async {
                widget.userData.personalQuestionnaires
                    .remove(widget.questionnaire);
                await UsersServices(useruid: widget.userData.uid)
                    .updatePersonnalQuestionnaires(
                        widget.userData.personalQuestionnaires);

                Navigator.pop(context);
                widget.changeTab(index: 8, backAppbarTitle: 'Questionnaires');
                snackBar(
                    context, 'The questionnaire has been deleted successfully');
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(18.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
