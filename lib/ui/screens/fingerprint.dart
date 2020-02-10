import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:flutter_authentication/utils/sizeConfig.dart';




class FingerPrintAuth extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<FingerPrintAuth> {
  static final  _scaffoldKey =  GlobalKey<ScaffoldState>();
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  String _authorized = 'Authenticating';
  Color _color = Colors.red;
  bool _isAuthenticating = false;
  double min =500.0;
  Timer _timer;
  int _begin = 40;

  final iosStrings = const AndroidAuthMessages(
    cancelButton: 'cancel',
    goToSettingsButton: 'settings',
    goToSettingsDescription: 'Please set up your Touch ID.',);

  Future<bool> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return false;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
    return canCheckBiometrics;
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,stickyAuth: true);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
      if(authenticated)_color= Colors.green;
    });
    _timer.cancel();
  }

  void _cancelAuthentication() {
    auth.stopAuthentication();
    _timer.cancel();
  }

  @override
  void initState() {
    _checkBiometrics().whenComplete((){
      if(_canCheckBiometrics){
        _authenticate();
        _startTimer();
      }
      else{
        _authorized = "Device does not have finger print hardware set up";
      }
    });
    super.initState();
  }

  @override
  void dispose(){
    _cancelAuthentication();
    super.dispose();
  }

  _startTimer(){
    const aSec = Duration(seconds: 1);
    _timer = Timer.periodic(aSec, (Timer timer)=> setState(
            (){
         if(_begin < 1){
           _cancelAuthentication();
         }
         else{
           _begin=_begin-1;
         }
        }
    ));

  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),duration: Duration(seconds: 10),action: _authorized!="Authorized"?SnackBarAction(label: "Retry Authentication", onPressed: (){
        _begin = 40;
      _checkBiometrics().whenComplete((){
        if(_canCheckBiometrics){
          _authenticate();
          _startTimer();
        }
        else{
          _authorized = "Device does not have finger print hardware set up";
        }
      });
    }):null,
    ));
  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp(
      home: Scaffold(
          key:_scaffoldKey,
          appBar: AppBar(
            title: const Text('Step 3/6',style: TextStyle(color: Colors.green,fontSize: 15),),
            leading: GestureDetector(child:Padding(child:Icon(Icons.arrow_back_ios,color: Colors.green),padding: EdgeInsets.all(5.0)),onTap: (){
              Navigator.pop(context);
            },),
            elevation: 0.0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
          ),
          body: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: SingleChildScrollView(
                child:  ConstrainedBox(constraints: BoxConstraints(minHeight: min,maxHeight: SizeConfig.blockSizeVertical*100>min?SizeConfig.blockSizeVertical*100:min),
                    child:Padding(child:
                    Column(
                      children: <Widget>[
                        Spacer(),
                        Image.asset("assets/touchID.png",height: 120,width: 120),
                        Spacer(),
                        RichText(text: TextSpan(text: "Fingerprint\n\n",style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold),children:
                        [
                          TextSpan(text: "place your registered finger on the sensor for authentication. ",style: TextStyle(fontWeight: FontWeight.w300)),
                        ]),textAlign: TextAlign.center),
                        Spacer(),
                        Icon(Icons.fingerprint,color: _color,size: 100),
                        SizedBox(height: 20.0),
                        RichText(text: TextSpan(text: "$_authorized ",style: TextStyle(color: _color,fontSize: 12.0),children: [
                          TextSpan(text:"0:$_begin",style: TextStyle(color: _color,fontSize: 12.0,fontWeight: FontWeight.w600))
                        ])),
                        Spacer(),
                        GestureDetector(child:Container(child: Text("Continue",style: TextStyle(color: Colors.white,fontSize: 15.0)),
                            height: 50.0,width: double.infinity,margin: EdgeInsets.only(left: 30.0,right: 30.0),decoration: BoxDecoration(gradient: LinearGradient(colors: [
                              Colors.green[200],Colors.green
                            ],),borderRadius: BorderRadius.circular(30.0)),alignment: Alignment.center),onTap: (){
                          _authorized=="Authorized"?showInSnackBar("Authentication successful"):showInSnackBar("Authentication Unsuccessful");
                        },),
                        Spacer(flex: 3,),
                      ],crossAxisAlignment: CrossAxisAlignment.center,
                    ),padding: EdgeInsets.only(left: 30.0,right: 30.0),)),
              )
          )),

    );
  }
}

