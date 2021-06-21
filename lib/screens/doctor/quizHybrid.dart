import 'package:flutter/material.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/services/googleSheetServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class QuizHybrid extends StatefulWidget {
  final Questionnaire questionnaire;
  final String languge;
  final Function changeTab;
  final int backIndex;

  const QuizHybrid({
    Key key,
    this.questionnaire,
    this.languge,
    this.changeTab,
    this.backIndex,
  }) : super(key: key);
  @override
  _QuizHybridState createState() => _QuizHybridState();
}

class _QuizHybridState extends State<QuizHybrid> {
  int _currentQuestionIndex = 0;
  List<int> _choises;
  String _choisedClass;
  bool isLoading = false;
  GoogleSheetApi _googleSheetApi = GoogleSheetApi();

  @override
  void initState() {
    _choises =
        List<int>.filled(widget.questionnaire.getQuestionsCount() + 1, -1);

    super.initState();
  }

  savedataCollected() {
    List<String> items = [];
    items.add(_choisedClass);
    for (int i = 1; i < _choises.length; i++) {
      items.add(_choises[i].toString());
    }
    _googleSheetApi
        .init(
      widget.questionnaire.stockageUrl,
      widget.questionnaire.nameEn,
      items,
      'items',
    )
        .then((value) {
      setState(() {
        isLoading = true;
      });
      widget.changeTab(index: widget.backIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? mainView()
        : desktopWidget(Container(), Container(), mainView());
  }

  Widget mainView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.border,
        iconTheme: IconThemeData(color: Constants.myGrey),
        elevation: 0.0,
      ),
      body: isLoading
          ? loading(context)
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              color: Constants.border,
              child: Column(
                children: [
                  Text(
                    widget.questionnaire.getName(widget.languge),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 35,
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xff3f4768), width: 3),
                        borderRadius: BorderRadius.circular(50)),
                    child: Stack(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) => Container(
                            width: constraints.maxWidth *
                                ((_currentQuestionIndex) /
                                    widget.questionnaire
                                        .getQuestionsCount()), //cover 50%
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).accentColor,
                                  Colors.white
                                ],
                                stops: [0.6, 1],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                tileMode: TileMode.repeated,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Text.rich(
                    _currentQuestionIndex <=
                            widget.questionnaire.getQuestionsCount()
                        ? TextSpan(
                            text: 'Question ${_currentQuestionIndex + 1}',
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(color: Constants.myGrey),
                            children: [
                                TextSpan(
                                    text:
                                        '/${widget.questionnaire.getQuestionsCount() + 1}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        .copyWith(color: Constants.myGrey))
                              ])
                        : TextSpan(
                            text: 'Done!!',
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(color: Constants.myGrey),
                          ),
                  ),
                  Spacer(flex: 1),
                  divider(),
                  Spacer(flex: 2),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: _currentQuestionIndex <=
                            widget.questionnaire.getQuestionsCount()
                        ? questionsQuiz()
                        : score(),
                  ),
                  Spacer(flex: 2),
                ],
              ),
            ),
    );
  }

  Widget questionsQuiz() {
    String _question = '';
    List<Map<String, Object>> _answers = [];

    if (_currentQuestionIndex == 0) {
      switch (widget.languge) {
        case 'English':
          _question = 'Choose the category to which your patient belongs';
          break;
        case 'Français':
          _question =
              'Choisissez la catégorie à laquelle appartient votre patient';
          break;
        case 'العربية':
          _question = 'اختر الفئة التي ينتمي إليها مريضك';
          break;
      }
      _answers = widget.questionnaire.getClassesList(widget.languge);
    } else {
      _question = widget.questionnaire
          .getQuesAnsQuestion(widget.languge, _currentQuestionIndex - 1);
      _answers = widget.questionnaire
          .getAnswersList(widget.languge, _currentQuestionIndex - 1);
    }

    return Column(
      children: [
        Text(
          _question,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 10.0),
        Column(
          children: _answers
              .map(
                (answer) => InkWell(
                  onTap: () {
                    setState(() {
                      if (_currentQuestionIndex == 0) {
                        _choisedClass = answer['answer'];
                      }
                      _choises[_currentQuestionIndex] = answer['score'];
                    });
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width - 100,
                      margin: EdgeInsets.only(top: 10.0),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 2.0,
                            color: _choises[_currentQuestionIndex] ==
                                    answer['score']
                                ? Theme.of(context).accentColor
                                : Constants.myGrey),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Text(
                        answer['answer'],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Constants.myGrey,
                            fontWeight: FontWeight.w400),
                      )),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _currentQuestionIndex == 0
                ? SizedBox()
                : Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_outlined),
                        onPressed: () {
                          setState(() {
                            _currentQuestionIndex--;
                          });
                        }),
                  ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: IconButton(
                  icon: Icon(_currentQuestionIndex ==
                          widget.questionnaire.getQuestionsCount() + 1
                      ? Icons.done
                      : Icons.arrow_forward_ios_outlined),
                  onPressed: () {
                    _choises[_currentQuestionIndex] != -1
                        ? setState(() {
                            _currentQuestionIndex++;
                          })
                        : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            elevation: 1.0,
                            content: Text('You have to choise'),
                            duration: Duration(seconds: 2),
                          ));
                  }),
            ),
          ],
        )
      ],
    );
  }

  Widget score() {
    return Column(
      children: [
        Text(
          'Thank you so much for your time!!',
          style: Theme.of(context)
              .textTheme
              .headline3
              .copyWith(color: Constants.myGrey),
        ),
        SizedBox(height: MediaQuery.of(context).size.height / 5),
        InkWell(
          onTap: () {
            setState(() {
              isLoading = true;
            });
            savedataCollected();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 18.0),
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            child: Text(
              'Done',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}