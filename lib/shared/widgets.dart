import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:transparent_image/transparent_image.dart';

Widget appBar(BuildContext context, String txt1, String txt2) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        txt1,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 30,
        ),
      ),
      Text(txt2,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).accentColor,
            fontSize: 30,
          )),
    ],
  );
}

Widget loading(BuildContext context) {
  return Container(
    color: Colors.transparent,
    child: Center(
      child: SpinKitChasingDots(
        color: Theme.of(context).accentColor,
        size: 50.0,
      ),
    ),
  );
}

Widget loadingImage(BuildContext context, String image) {
  return Stack(
    fit: StackFit.expand,
    children: [
      Container(
        color: Colors.transparent,
        child: Center(
          child: SpinKitPulse(
            color: Theme.of(context).accentColor,
            size: 50.0,
          ),
        ),
      ),
      FadeInImage.memoryNetwork(
        fit: BoxFit.cover,
        placeholder: kTransparentImage,
        image: image,
      ),
    ],
  );
}

Widget checkYourNetwork(BuildContext context) {
  return Container(
    color: Colors.transparent,
    child: Center(
      child: Text('Check Your Network'),
    ),
  );
}

Widget error() {
  return Container(
    child: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.warning),
        ),
        Text('Error in loadind data')
      ],
    ),
  );
}

InputDecoration textInputDecoration(BuildContext context, String hint) {
  return InputDecoration(
    filled: true,
    hintText: hint,
    labelText: hint,
    labelStyle: TextStyle(color: Constants.myGrey),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Constants.myGrey,
        width: 2.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).accentColor,
        width: 2.0,
      ),
    ),
  );
}

InputDecoration searchTextInputDecoration(
    BuildContext context, Function onPressed) {
  return InputDecoration(
    filled: true,
    hintText: 'Search',
    labelText: 'Search',
    labelStyle: TextStyle(color: Constants.myGrey),
    prefixIcon: Icon(
      Icons.search,
      size: 30.0,
    ),
    suffixIcon: IconButton(
      alignment: Alignment.center,
      icon: Icon(
        Icons.close,
        size: 30.0,
      ),
      focusColor: Theme.of(context).accentColor,
      onPressed: onPressed,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(
        color: Constants.myGrey,
        width: 0.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(
        color: Theme.of(context).accentColor,
        width: 0.5,
      ),
    ),
  );
}

Widget desktopWidget(
    Widget flexibleChild1, Widget flexibleChild2, Widget mainChild) {
  return Row(children: [
    Flexible(
      flex: 2,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: flexibleChild1,
        ),
      ),
    ),
    const Spacer(),
    Container(
      width: 720.0,
      child: mainChild,
    ),
    const Spacer(),
    Flexible(
      flex: 2,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: flexibleChild2,
        ),
      ),
    ),
  ]);
}

Widget divider() {
  return Divider(
    color: Constants.myGrey,
    thickness: 1.5,
  );
}

Widget emptyList() {
  return Container(
    alignment: Alignment.center,
    child: Text(
      'No Result To Show',
      style: TextStyle(fontSize: 30, color: Constants.myGrey),
    ),
  );
}

Widget deleteButton(BuildContext context, Function onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          Icon(
            Icons.delete,
            color: Colors.red,
          ),
          SizedBox(width: 8.0),
          Text(
            'Delete',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}
