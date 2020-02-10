

import 'package:flutter_authentication/ui/screens/authentication.dart';
import 'package:flutter_authentication/ui/screens/fingerprint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authentication/ui/screens/notfound/notfound_page.dart';
import 'package:flutter_authentication/utils/uiData.dart';



class Router {


    static Route<dynamic> generateRoute(settings) {
      switch (settings.name) {
        case UIData.authRoute:
          return MaterialPageRoute(builder: (_) => Auth());
          break;
        case UIData.fingerPrintRoute:
          return MaterialPageRoute(builder: (_) => FingerPrintAuth());
          break;
      }
    }

    static Route<dynamic>  unknownRoute (settings) {
      return new MaterialPageRoute(
        builder: (context) => new NotFoundPage(
        ));
    }

}


