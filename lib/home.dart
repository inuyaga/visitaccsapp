import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:visitaccs/main_view.dart';
import 'package:status_alert/status_alert.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:visitaccs/constantes.dart' as constantes;
import 'package:visitaccs/obj/venta_cobranza.dart';

var IgmLogo = AssetImage("assets/ccs.png");
var FondoApp = AssetImage("assets/slide1_bg.jpg");
var logo = Image(image: IgmLogo);
var Fondo = Image(image: FondoApp);

class HomeView extends StatefulWidget {
  HomeViewWidgetState createState() => HomeViewWidgetState();
}

class HomeViewWidgetState extends State<HomeView> {
  ClienteData datoCliente = ClienteData();
  bool isLoading = false;
  String mensaje = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/slide1_bg.jpg'),
                    fit: BoxFit.fill)),
          ),
          Center(
            child: Column(
              children: [
                Container(
                  // color: Colors.white,
                  child: logo,
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(90),
                          bottomRight: Radius.circular(200))),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 150),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            80.0), // CHANGE BORDER RADIUS HERE
                        side: BorderSide(width: 2, color: Colors.yellowAccent),
                      ),
                      onPressed: () async {
                        try {
                          this.setState(() {
                            isLoading = true;
                          });
                          var result = await BarcodeScanner.scan();

                          if (result.type == ResultType.Barcode) {
                            final response = await http.get('${constantes.URL_SERVER_SSL}api_mobile/get/cliente/${result.rawContent}');
                            // print("codigo de respuesta:" + response.statusCode.toString());
                            if (response.statusCode == 200) {
                              Map<String, dynamic> responseJson =
                                  json.decode(response.body);
                              datoCliente.cliente = responseJson['cliente'];
                              datoCliente.nombre = responseJson['nombre'];
                              saveCliente(datoCliente);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainView()),
                              );
                            } else if (response.statusCode == 204) {
                              StatusAlert.show(context,
                                  duration: Duration(seconds: 8),
                                  title: 'Error',
                                  subtitle:
                                      'Cliente no existe ó El cliente no tiene asignado un vendedor',
                                  configuration:
                                      IconConfiguration(icon: Icons.cancel),
                                  subtitleOptions: StatusAlertTextConfiguration(
                                      softWrap: true));
                            }
                          }
                        } on PlatformException catch (e) {
                          if (e.code == BarcodeScanner.cameraAccessDenied) {
                            setState(() {
                              mensaje =
                                  "El usuario no dio permiso para el uso de la cámara!";
                            });
                          } else {
                            setState(() {
                              mensaje = "Error desconocido";
                            });
                          }
                        } on FormatException {
                          setState(() {
                            mensaje =
                                "nulo, el usuario presionó el botón de volver antes de escanear algo";
                          });
                        } on SocketException catch (e) {
                          setState(() {
                            mensaje = e.toString();
                          });
                        } finally {
                          this.setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      textColor: Colors.white,
                      color: Colors.grey,
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        child: const Text('Ingresar',
                            style: TextStyle(fontSize: 20)),
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text(
                            "www.computel.com.mx",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                Text("$mensaje")
              ],
            ),
          ),
          //   Container(
          //   decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //           begin: Alignment.topRight,
          //           end: Alignment.bottomLeft,
          //           colors: [Colors.blue, Colors.greenAccent])),
          // ),
        ],
      ),
    );
  }
}

void saveCliente(ClienteData datoCliente) async {
  SharedPreferences preferencias = await SharedPreferences.getInstance();
  preferencias.setString("cliente", datoCliente.cliente);
  preferencias.setString("nombre", datoCliente.nombre);
}
