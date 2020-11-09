import 'package:flutter/material.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_view.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String cliente;
  Widget pageInitial;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visita CCS',
      theme: ThemeData(
          // Define the default brightness and colors.
          // brightness: Brightness.dark,
          // primaryColor: Colors.blue[900],
          // accentColor: Colors.cyan[600],

          // Define the default font family.
          fontFamily: 'Georgia',

          // Define the default TextTheme. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          )),
      home: FutureBuilder(
          future: obtenerpreferenciainit(),
          builder: (context, AsyncSnapshot<Widget> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                ),
              );
            }
            return snapshot.data;
          }),
    );
  }

  Future<Widget> obtenerpreferenciainit() async {
    SharedPreferences preferencias = await SharedPreferences.getInstance();
    cliente = preferencias.getString("cliente") ?? "";
    if (cliente == "") {
      pageInitial = HomeView();
    } else {
      pageInitial = MainView();
    }
    return pageInitial;
  }
}
