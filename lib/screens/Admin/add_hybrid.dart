import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psyscale/classes/QuestionAnswer.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/Trouble.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/services/googleSheetServices.dart';
import 'package:psyscale/services/hybridServices.dart';
import 'package:psyscale/services/troubleServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class AddHybrid extends StatefulWidget {
  final Questionnaire questionnaire;
  final UserData userData;
  final Function changeTab;

  const AddHybrid({Key key, this.userData, this.questionnaire, this.changeTab})
      : super(key: key);
  @override
  _AddHybridState createState() => _AddHybridState();
}

class _AddHybridState extends State<AddHybrid> {
  List<Trouble> troubles = [];
  bool isLoading = false;
  List<String> _steps = [
    'Questionnaire Informations',
    'List Of Classes',
    'List Of Question/Answers',
  ];
  int _currentStep = 1;
  String _troubleUid;
  String _nameEn = '';
  String _nameFr = '';
  String _nameAr = '';
  String _descreptionEn = '';
  String _descreptionFr = '';
  String _descreptionAr = '';
  String _stockageUrl = '';
  String _localQuestionEn = '';
  String _localQuestionFr = '';
  String _localQuestionAr = '';
  String _localClasseEn = '';
  String _localClasseFr = '';
  String _localClasseAr = '';
  List<QuestionAnswer> _questionsAnswers = [];
  List<Map<String, Object>> _classes = [];
  List<Map<String, Object>> _localAnswers = [];
  HybridServices hybridServices = HybridServices();
  GoogleSheetApi _googleSheetApi = GoogleSheetApi();

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

  addQuestionnaire() async {
    setState(() {
      isLoading = true;
    });
    await hybridServices
        .addHybridData(Questionnaire(
      troubleUid: _troubleUid,
      nameEn: _nameEn,
      nameFr: _nameFr,
      nameAr: _nameAr,
      defaultLanguage: 'English',
      supportedLanguages: ['English', 'Français', 'العربية'],
      descreptionEn: _descreptionEn,
      descreptionFr: _descreptionFr,
      descreptionAr: _descreptionAr,
      stockageUrl: _stockageUrl.split('/')[5],
      classes: _classes,
      questionsAnswers: _questionsAnswers,
    ))
        .then((value) {
      if (value != null) {
        createGoogleSheet();

        setState(() {
          isLoading = false;
        });
        widget.changeTab(
          index: 5,
          backAppbarTitle: 'Hybrids',
        );
      }
    });
  }

  updateQuestionnaire() async {
    setState(() {
      isLoading = true;
    });
    await hybridServices.updateHybridData(Questionnaire(
      uid: widget.questionnaire.uid,
      nameEn: _nameEn,
      nameFr: _nameFr,
      nameAr: _nameAr,
      descreptionEn: _descreptionEn,
      descreptionFr: _descreptionFr,
      descreptionAr: _descreptionAr,
      classes: _classes,
      questionsAnswers: _questionsAnswers,
    ));

    createGoogleSheet();

    setState(() {
      isLoading = false;
    });
    widget.changeTab(
      index: 5,
      backAppbarTitle: 'Hybrid',
    );
  }

  createGoogleSheet() {
    String _sheetId = widget.questionnaire == null
        ? _stockageUrl.split('/')[5]
        : _stockageUrl;
    List<String> _questions = [];
    _questions.add('class');
    _questionsAnswers.forEach((element) {
      _questions.add(element.questionEn);
    });

    _googleSheetApi.init(_sheetId, _nameEn, _questions, 'first');
  }

  @override
  void initState() {
    if (widget.questionnaire != null) {
      _troubleUid = widget.questionnaire.troubleUid;
      _nameEn = widget.questionnaire.nameEn;
      _nameFr = widget.questionnaire.nameFr;
      _nameAr = widget.questionnaire.nameAr;
      _descreptionEn = widget.questionnaire.descreptionEn;
      _descreptionFr = widget.questionnaire.descreptionFr;
      _descreptionAr = widget.questionnaire.descreptionAr;
      _stockageUrl = widget.questionnaire.stockageUrl;
      _classes = widget.questionnaire.classes;
      _questionsAnswers = widget.questionnaire.questionsAnswers;
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
                ? 'Add Hybrid Questionnaire'
                : 'Update Hybrid Questionnaire',
            ''),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          widget.questionnaire != null
              ? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: deleteButton(context, () {
                    createDialog(
                        context, delteHybrid(widget.questionnaire.uid), true);
                  },
                      text: 'Delete Hybrid',
                      color: Colors.red,
                      icon: Icons.delete),
                )
              : const SizedBox(),
        ],
      ),
      body: Responsive.isMobile(context)
          ? _addQuestionnaireForm()
          : desktopWidget(
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
                    padding: const EdgeInsets.all(8.0),
                    children: _steps.map((element) {
                      index++;
                      return Card(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        margin: const EdgeInsets.all(8.0),
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
                                        ? _classesList()
                                        : index == 3
                                            ? _questionAnswerList()
                                            : const SizedBox()
                                : const SizedBox(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                _currentStep == 4
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
                                  widget.questionnaire == null
                                      ? addQuestionnaire()
                                      : updateQuestionnaire();
                                }),
                          ],
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          );
  }

  Widget _questionnaireInfo() {
    final _infoFormKey = GlobalKey<FormState>();
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Form(
            key: _infoFormKey,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(children: [
                const SizedBox(height: 6.0),
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
                    : const SizedBox(),
                const SizedBox(height: 6.0),
                TextFormField(
                  initialValue: _nameEn,
                  validator: (value) => value.isEmpty ? 'Enter the Name' : null,
                  decoration: textInputDecoration(context, 'English Name'),
                  onChanged: (value) => _nameEn = value,
                ),
                const SizedBox(height: 6.0),
                TextFormField(
                  initialValue: _nameFr,
                  validator: (value) => value.isEmpty ? 'Enter the Name' : null,
                  decoration: textInputDecoration(context, 'Frensh Name'),
                  onChanged: (value) => _nameFr = value,
                ),
                const SizedBox(height: 6.0),
                TextFormField(
                  initialValue: _nameAr,
                  validator: (value) => value.isEmpty ? 'Enter the Name' : null,
                  decoration: textInputDecoration(context, 'Arabic Name'),
                  onChanged: (value) => _nameAr = value,
                ),
                const SizedBox(height: 6.0),
                TextFormField(
                  initialValue: _descreptionEn,
                  validator: (value) =>
                      value.isEmpty ? 'Enter the Descreption' : null,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration:
                      textInputDecoration(context, 'English Descreption'),
                  onChanged: (value) => _descreptionEn = value,
                ),
                const SizedBox(height: 6.0),
                TextFormField(
                  initialValue: _descreptionFr,
                  validator: (value) =>
                      value.isEmpty ? 'Enter the Descreption' : null,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration:
                      textInputDecoration(context, 'Frensh Descreption'),
                  onChanged: (value) => _descreptionFr = value,
                ),
                const SizedBox(height: 6.0),
                TextFormField(
                  initialValue: _descreptionAr,
                  validator: (value) =>
                      value.isEmpty ? 'Enter the Descreption' : null,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration:
                      textInputDecoration(context, 'Arabic Descreption'),
                  onChanged: (value) => _descreptionAr = value,
                ),
                const SizedBox(height: 6.0),
                widget.questionnaire == null
                    ? TextFormField(
                        initialValue: _stockageUrl,
                        validator: (value) => value.isEmpty
                            ? 'Enter the link of stockage'
                            : value.split('/').length < 6
                                ? 'Enter valid url'
                                : null,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: textInputDecoration(
                                context, 'Google sheet url')
                            .copyWith(
                                hintText:
                                    'https://docs.google.com/spreadsheets/d/...'),
                        onChanged: (value) {
                          return _stockageUrl = value;
                        },
                      )
                    : const SizedBox(),
                const SizedBox(height: 6.0),
              ]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Spacer(),
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

  Widget _classesList() {
    final _classesformkey = GlobalKey<FormState>();
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          ..._classes
              .map((classe) => Card(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Constants.myGrey, width: 1.0)),
                  child: ListTile(
                    title: Text(classe['classEn']),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          _localAnswers.remove(classe);
                        });
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Constants.border,
                      ),
                    ),
                  )))
              .toList(),
          Form(
            key: _classesformkey,
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  const SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _localClasseEn,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'English Class'),
                    onChanged: (value) => _localClasseEn = value,
                  ),
                  const SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _localClasseFr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Frensh Class'),
                    onChanged: (value) => _localClasseFr = value,
                  ),
                  const SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _localClasseAr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Arabic Class'),
                    onChanged: (value) => _localClasseAr = value,
                  ),
                  const SizedBox(height: 6.0),
                ],
              ),
            ),
          ),
          insidStepButton(context, 'Add Class', () {
            if (_classesformkey.currentState.validate()) {
              setState(() {
                _classes.add({
                  'classEn': _localClasseEn,
                  'classFr': _localClasseFr,
                  'classAr': _localClasseAr,
                });
                _localClasseEn = '';
                _localClasseFr = '';
                _localClasseAr = '';
              });
            }
          }),
          Container(
            padding: const EdgeInsets.all(8.0),
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
                      if (_classes.isEmpty) {
                        final snackBar = SnackBar(
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Theme.of(context).accentColor,
                                width: 2.0),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          content: Text('At least one classe'),
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
    return Container(
      padding: const EdgeInsets.all(8.0),
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
                      title: Text(questionAnswer.questionEn),
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
                                        title: Text(answer['answerEn']),
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
              margin:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  const SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _localQuestionEn,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration:
                        textInputDecoration(context, 'English Question'),
                    onChanged: (value) => _localQuestionEn = value,
                  ),
                  const SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _localQuestionFr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Frensh Question'),
                    onChanged: (value) => _localQuestionFr = value,
                  ),
                  const SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _localQuestionAr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Arabic Question'),
                    onChanged: (value) => _localQuestionAr = value,
                  ),
                  const SizedBox(height: 6.0),
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
                      title: Text(answer['answerEn']),
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
              margin:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  const SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _answerEn,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'English Answer'),
                    onChanged: (value) => _answerEn = value,
                  ),
                  const SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _answerFr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Frensh Answer'),
                    onChanged: (value) => _answerFr = value,
                  ),
                  const SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _answerAr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Arabic Answer'),
                    onChanged: (value) => _answerAr = value,
                  ),
                  const SizedBox(height: 6.0),
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
                });
                _answerEn = '';
                _answerFr = '';
                _answerAr = '';
              });
            }
          }),
          const SizedBox(height: 8.0),
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
            padding: const EdgeInsets.all(8.0),
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

  Widget delteHybrid(String hybridUid) {
    return Container(
      padding: EdgeInsets.all(8.0),
      width: 350,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.0),
          Text(
            'Confirm Delete Questionnaire Hybrid',
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
              onTap: () {
                HybridServices().deleteHybrid(hybridUid);
                Navigator.pop(context);
                widget.changeTab(
                  index: 5,
                  backAppbarTitle: 'Hybrid',
                );
                snackBar(context,
                    'The questionnaire hybrid has been deleted successfully');
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
