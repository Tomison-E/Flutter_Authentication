import 'package:flutter/material.dart';
import 'package:flutter_authentication/router/router.dart';
import 'package:flutter_authentication/utils/uiData.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication',
      theme: ThemeData(
          textTheme: GoogleFonts.openSansTextTheme(
            Theme.of(context).textTheme,
          )),
      onGenerateRoute: Router.generateRoute,
      onUnknownRoute: Router.unknownRoute,
      initialRoute: UIData.authRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

