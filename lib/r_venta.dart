import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_alert/status_alert.dart';
import 'package:visitaccs/obj/venta_cobranza.dart';
import 'package:http/http.dart' as http;
import 'constantes.dart' as constantes;

class RealizoVentaView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Realizó Venta"),
      ),
      body: FormularioVentaWidget(),
    );
  }
}

class FormularioVentaWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormularioVentaWidgetState();
  }
}

class FormularioVentaWidgetState extends State<FormularioVentaWidget> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    String numeroventa = "";
    String montoventa = "";
    return Form(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FutureBuilder(
                  future: obtenerpreferenciainit(),
                  builder: (context, AsyncSnapshot<Widget> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.redAccent),
                        ),
                      );
                    }
                    return snapshot.data;
                  }),
              Container(
                  padding:
                      const EdgeInsets.only(top: 15.0, left: 50.0, right: 50.0),
                  child: Container(
                    decoration: new BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(20.0)),
                        color: Colors.lightBlue[50]),
                    child: TextFormField(
                      onSaved: (val) => setState(() => numeroventa = val),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Ingrese un N° de venta';
                        } else {
                          _formKey.currentState.save();
                          return null;
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'N° de Venta',
                      ),
                    ),
                  )),
              Container(
                  padding:
                      const EdgeInsets.only(top: 15.0, left: 50.0, right: 50.0),
                  child: Container(
                    decoration: new BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(20.0)),
                        color: Colors.lightBlue[50]),
                    child: TextFormField(
                      onSaved: (val) => setState(() => montoventa = val),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Ingrese un Monto';
                        } else {
                          _formKey.currentState.save();
                          return null;
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Monto de Venta',
                      ),
                    ),
                  )),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: FlatButton(
                  color: Colors.blue[900],
                  shape: StadiumBorder(),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.

                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Row(
                        children: <Widget>[
                          CircularProgressIndicator(
                            backgroundColor: Colors.cyan,
                            strokeWidth: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text("Procesando datos.."),
                          )
                        ],
                      )));

                      Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                      SharedPreferences preferencias = await SharedPreferences.getInstance();
                      String cliente = preferencias.getString("cliente") ?? "";
                      

                      var url = constantes.URL_SERVER_SSL + 'api_mobile/visitas/vendedors/api/';
                      var response = await http.post(url, body: {
                        'cliente_clave': cliente,                          
                          'vv_latitude': position.latitude.toString(),
                          'vv_longitude': position.longitude.toString(),
                          'vv_numero_venta': numeroventa,
                          'vv_monto_venta': montoventa,
                          'vv_tipo': '1',
                          'vv_cliente': '1'
                        });

                        // print(response.statusCode);
                        // print(response.body);
                        if (response.statusCode == 201) {
                          StatusAlert.show(
                              context,
                              duration: Duration(seconds: 4),
                              title: 'Guardado',
                              subtitle: 'Registro exitoso',
                              configuration:
                                  IconConfiguration(icon: Icons.done_outline),
                            );
                            preferencias.setString("laborventa", 'ok');
                        }else {
                          StatusAlert.show(
                              context,
                              duration: Duration(seconds: 4),
                              title: 'Error',
                              subtitle: 'Error al intentar guardar verifique conexión',
                              configuration:
                                  IconConfiguration(icon: Icons.cancel),
                            );
                        }
                                                
                    }
                  },
                  // textColor: Colors.white,
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    child: const Text('Guardar',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Future<Widget> obtenerpreferenciainit() async {
    SharedPreferences preferencias = await SharedPreferences.getInstance();
    String cliente = preferencias.getString("cliente") ?? "";
    String nombre = preferencias.getString("nombre") ?? "";

    return Padding(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          children: [Text("N° Ciente: " + cliente), Text("Nombre: " + nombre)],
        ));
  }
}
