import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitaccs/f_cobranza.dart';
import 'package:visitaccs/r_venta.dart';
import 'constantes.dart' as constantes;
import 'package:http/http.dart' as http;

var IgmLogo = AssetImage("assets/ccs.png");

var logo = Image(image: IgmLogo);
enum AccionMenu {
  finalizar,
  otro,
}

class MainView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          // Define the default brightness and colors.
          // brightness: Brightness.dark,
          primaryColor: Colors.blue[900],
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
      home: CasaWidget(),
    );
  }
}

class CasaWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CasaWidgetState();
  }
}

class CasaWidgetState extends State<CasaWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton<AccionMenu>(
              onSelected: (AccionMenu result) {
                setState(() async {
                  if (result == AccionMenu.finalizar) {
                    Position position = await getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high);
                    SharedPreferences preferencias =
                        await SharedPreferences.getInstance();
                    String cliente = preferencias.getString("cliente") ?? "";
                    String laborventa =
                        preferencias.getString("laborventa") ?? "";

                    if (laborventa == "") {
                      var url = "${constantes.URL_SERVER_SSL}api_mobile/visitas/vendedors/api/";
                      var response = await http.post(url, body: {
                        'cliente_clave': cliente,
                        'vv_latitude': position.latitude.toString(),
                        'vv_longitude': position.longitude.toString(),
                        'vv_tipo': '3',
                        'vv_cliente': '1'
                      });

                      if (response.statusCode == 201) {
                        SharedPreferences preferences = await SharedPreferences.getInstance();
                        await preferences.clear();

                        Future.delayed(const Duration(milliseconds: 1000), () {
                          SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop');
                        });
                      }
                    } else {
                      SharedPreferences preferences = await SharedPreferences.getInstance();
                      await preferences.clear();
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      });
                    }
                  }
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<AccionMenu>>[
                const PopupMenuItem<AccionMenu>(
                  value: AccionMenu.finalizar,
                  child: Text('Finalizar visita'),
                ),
              ],
            )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/slide1_bg.jpg'), fit: BoxFit.fill)),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(30),
                  child: logo,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Container(
                    height: 50.0,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RealizoVentaView()),
                        );
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.grey, Color(0xfffefefe)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Container(
                          constraints:
                              BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                          alignment: Alignment.center,
                          child: Text(
                            "Realizó Venta",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Container(
                    height: 50.0,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RealizoCobranzaView()),
                        );
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xffa9032a), Color(0xff6d0019)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Container(
                          constraints:
                              BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                          alignment: Alignment.center,
                          child: Text(
                            "Realizó Cobranza",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ));
  }
}
