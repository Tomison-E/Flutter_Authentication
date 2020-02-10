import 'dart:async';

import 'package:flutter_authentication/utils/uiData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authentication/utils/sizeConfig.dart';
import 'package:pin_view/pin_view.dart';
import 'dart:io' show Platform;

class Auth extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Auth> {
  static final _scaffoldKeys = GlobalKey<ScaffoldState>();
  final double min = 400.0;
  String phoneNumber = "+2348166569640";
  final String sendingPhoneNumber = "0903 114 8014";
  Timer _timer;
  int _begin = 40;

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  _startTimer() {
    const aSec = Duration(seconds: 1);
    _timer = Timer.periodic(
        aSec,
        (Timer timer) => setState(() {
              _begin < 1 ? timer.cancel() : _begin = _begin - 1;
            }));
  }

  void showInSnackBar(String value) {
    _scaffoldKeys.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      duration: Duration(seconds: 10),
    ));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp(
      home: Scaffold(
          key: _scaffoldKeys,
          appBar: AppBar(
            title: const Text(
              'Step 2/6',
              style: TextStyle(color: Colors.green, fontSize: 15),
            ),
            leading: Icon(Icons.arrow_back_ios, color: Colors.green),
            elevation: 0.0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
          ),
          body: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: min,
                        maxHeight: SizeConfig.blockSizeVertical * 100 > min
                            ? SizeConfig.blockSizeVertical * 100
                            : min),
                    child: Padding(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 30.0),
                          Image.asset("assets/pin.png",
                              height: 120, width: 120),
                          SizedBox(height: 50.0),
                          RichText(
                              text: TextSpan(
                                  text: "Verfication\n\n",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(
                                        text:
                                            "Enter 4 digit number that was sent to $phoneNumber",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300)),
                                  ]),
                              textAlign: TextAlign.center),
                          Spacer(),
                          Material(
                              child: Container(
                                color: Colors.white,
                                height: 200.0,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 100.0,
                                      child: PinView(
                                        count: 6,
                                        autoFocusFirstField: false,
                                        dashPositions: [],
                                        sms: Platform.isAndroid
                                            ? SmsListener(
                                                from: sendingPhoneNumber,
                                                formatBody: (String body) {
                                                  String codeRaw =
                                                      body.split(": ")[1];
                                                  List<String> code =
                                                      codeRaw.split("-");
                                                  return code.join;
                                                })
                                            : null,
                                        submit: (String pin) {
                                          FocusScopeNode currentFocus =
                                              FocusScope.of(context);
                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                          showInSnackBar(
                                              "Pin $pin received successfully");
                                          _timer.cancel();
                                        },
                                        inputDecoration: InputDecoration(
                                            focusColor: Colors.green,
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.green))),
                                      ),
                                    ),
                                    GestureDetector(
                                      child: Container(
                                          child: Text("Continue",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0)),
                                          height: 50.0,
                                          width: double.infinity,
                                          margin: EdgeInsets.only(
                                              left: 30.0, right: 30.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.green[200],
                                                  Colors.green
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(30.0)),
                                          alignment: Alignment.center),
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, UIData.fingerPrintRoute);
                                      },
                                    )
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                ),
                              ),
                              elevation: 1.0),
                          SizedBox(height: 20.0),
                          RichText(
                              text: TextSpan(
                                  text: "Re-send code in ",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 12.0),
                                  children: [
                                TextSpan(
                                    text: "0:$_begin",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600))
                              ])),
                          Spacer(flex: 3),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.center,
                      ),
                      padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    )),
              ))),
    );
  }
}
