import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/Trouble.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/Admin/hybridData.dart';
import 'package:psyscale/services/hybridServices.dart';
import 'package:psyscale/services/troubleServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/widgets.dart';
import 'package:webviewx/webviewx.dart';
// import 'package:url_launcher/url_launcher.dart';

class Hybrid extends StatefulWidget {
  final ValueListenable<String> search;
  final Function changeTab;
  const Hybrid({Key key, this.search, this.changeTab}) : super(key: key);

  @override
  _HybridState createState() => _HybridState();
}

class _HybridState extends State<Hybrid> {
  List<Questionnaire> allQuestionnaires = [];
  final List<Trouble> allTroubles = [];
  List<Questionnaire> questionnaires = [];

  List<bool> troubleExpanded = [];

  getTroublesList(QuerySnapshot data, String language) async {
    allTroubles.clear();
    if (data != null) {
      data.docs.forEach((doc) {
        allTroubles.add(Trouble(
          uid: doc.id,
          nameEn: doc['nameEn'],
          nameFr: doc['nameFr'],
          nameAr: doc['nameAr'],
          questionnaresCount: doc['questionnaresCount'],
          descreptionEn: doc['descreptionEn'],
          descreptionFr: doc['descreptionFr'],
          descreptionAr: doc['descreptionAr'],
          imageUrl: doc['imageUrl'],
        ));
        troubleExpanded.add(false);
      });
      allTroubles
          .sort((a, b) => a.getName(language).compareTo(b.getName(language)));
    }
  }

  getQuestionnairesList(QuerySnapshot data, String language) async {
    allQuestionnaires.clear();
    questionnaires.clear();
    if (data != null) {
      data.docs.forEach((doc) {
        allQuestionnaires.add(Questionnaire(
            uid: doc.id,
            troubleUid: doc['troubleUid'],
            nameEn: doc['nameEn'],
            nameFr: doc['nameFr'],
            nameAr: doc['nameAr'],
            descreptionEn: doc['descreptionEn'],
            descreptionFr: doc['descreptionFr'],
            descreptionAr: doc['descreptionAr'],
            stockageUrl: doc['stockageUrl'],
            classes: Questionnaire.getList(doc['classes']),
            questionsAnswers:
                Questionnaire.getQuestionAnswerList(doc['questionsAnswers'])));
      });
      allQuestionnaires.forEach((element) {
        if (element
            .getName(language)
            .toLowerCase()
            .contains(widget.search.value.toLowerCase())) {
          questionnaires.add(element);
        }
      });

      questionnaires
          .sort((a, b) => a.getName(language).compareTo(b.getName(language)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return Scaffold(
        body: StreamBuilder(
            stream: TroublesServices().troubleData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                QuerySnapshot data = snapshot.data;
                getTroublesList(data, userData.language);
                return StreamBuilder(
                    stream: HybridServices().hybridData,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        QuerySnapshot data = snapshot.data;
                        getQuestionnairesList(data, userData.language);
                        return Stack(
                          children: [
                            Positioned(
                              bottom: 8.0,
                              left: 8.0,
                              child: customButton(
                                context: context,
                                icon: Icons.add,
                                text: 'Google Forms',
                                width: 160,
                                onTap: () async {
                                  Constants.navigationFunc(
                                      context, GoogleForms());

                                  // const url = "https://docs.google.com/forms";
                                  // if (await canLaunch(url))
                                  //   await launch(url);
                                  // else
                                  //   // can't launch url, there is some error
                                  //   throw "Could not launch $url";
                                },
                              ),
                            ),
                            desktopWidget(
                              Container(),
                              Container(),
                              Container(
                                alignment: questionnaires.isEmpty
                                    ? Alignment.center
                                    : Alignment.topCenter,
                                color: Theme.of(context).backgroundColor,
                                height: double.infinity,
                                child: CustomScrollView(
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: _buildPanel(),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return loading(context);
                      }
                    });
              } else {
                return loading(context);
              }
            }),
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          backgroundColor: Theme.of(context).accentColor,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            widget.changeTab(index: 1);
          },
        ));
  }

  Widget _buildPanel() {
    final userData = Provider.of<UserData>(context);
    int index = -1;
    return widget.search.value != ''
        ? questionnaires.isEmpty
            ? emptyList()
            : GridView.count(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 3.0,
                children: questionnaires.map((questionnaire) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Constants.myGrey, width: 1.0),
                        borderRadius: BorderRadius.circular(24.0)),
                    elevation: 2.0,
                    child: InkWell(
                      onTap: () {
                        Constants.navigationFunc(
                          context,
                          HybridData(questionnaire: questionnaire),
                        );
                      },
                      child: ListTile(
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(questionnaire.getName(userData.language)),
                        ),
                        subtitle: Text(
                          questionnaire.getDescreption(userData.language),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            widget.changeTab(
                                index: 1, questionnaire: questionnaire);
                          },
                          icon: Icon(Icons.edit),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
        : ExpansionPanelList(
            animationDuration:
                Duration(milliseconds: Constants.animationDuration),
            expansionCallback: (panelIndex, isExpanded) {
              setState(() {
                troubleExpanded[panelIndex] = !isExpanded;
              });
            },
            children: allTroubles.map((Trouble trouble) {
              index++;
              List<Questionnaire> _localQuestionnaires = [];
              questionnaires.forEach((questionnaire) {
                if (questionnaire.troubleUid == trouble.uid) {
                  _localQuestionnaires.add(questionnaire);
                }
              });
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(
                      trouble.getName(userData.language),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text('${_localQuestionnaires.length} hybrides'),
                    leading: CircleAvatar(
                        backgroundImage: NetworkImage(trouble.imageUrl)),
                  );
                },
                canTapOnHeader: true,
                isExpanded: troubleExpanded[index],
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: _localQuestionnaires.isEmpty
                        ? emptyList()
                        : GridView.count(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            childAspectRatio: 3.0,
                            children: _localQuestionnaires.map((questionnaire) {
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Constants.myGrey, width: 1.0),
                                    borderRadius: BorderRadius.circular(24.0)),
                                elevation: 2.0,
                                child: InkWell(
                                  onTap: () {
                                    widget.changeTab(
                                        index: 1, questionnaire: questionnaire);
                                  },
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(questionnaire
                                          .getName(userData.language)),
                                    ),
                                    subtitle: Text(
                                      questionnaire
                                          .getDescreption(userData.language),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                    trailing: IconButton(
                                        onPressed: () {
                                          Constants.navigationFunc(
                                            context,
                                            HybridData(
                                                questionnaire: questionnaire),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.cloud_download_outlined,
                                          color: Colors.green,
                                        )),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              );
            }).toList(),
          );
  }
}

class GoogleForms extends StatelessWidget {
  const GoogleForms({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: WebViewX(
          initialContent: 'https://docs.google.com/forms',
          initialSourceType: SourceType.URL,
        ),
      ),
    );
  }
}
