import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:calidad/pages/BrixE.dart';
import 'package:calidad/pages/registroinfo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:calidad/pages/Constantes.dart';

import 'Regi.dart';

class Brixs extends StatefulWidget {
  String invernadero;
  String user;
  Brixs(this.user, this.invernadero);
  @override
  _BrixsState createState() => _BrixsState(this.user, this.invernadero);
}

class _BrixsState extends State<Brixs> {
  String invernadero;
  String user;
  DateTime _dateTime;
  bool lista;
  Future fregistros;
  String mensaje;
  var datos = null;
  _BrixsState(this.user, this.invernadero);

  caja() {
    if (datos == null) {
      datos = ({"fecha": "sin datos para mostrar", "Cantidad": 0});
    }
    if (datos["fecha"] == null)
      datos = ({"fecha": "sin datos para mostrar", "Cantidad": 0});
    return Container(
      width: MediaQuery.of(context).size.width * .75,
      padding: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [BoxShadow(color: Colors.blue, blurRadius: 5)],
      ),
      child: InkWell(
          splashColor: Colors.blue,
          onTap: () => {
                if (datos["cantidad"] != null)
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BrixRegistro(
                              datos["fecha"].substring(0, 10),
                              this.invernadero)))
                else
                  {
                    setState(() {
                      mensaje = "Dia invalido";
                      _showMyDialog();
                    })
                  }
              },
          child: Column(
            children: <Widget>[
              Text("Ingresar Los Brix´s\n"),
              Text("Dia: " + datos["fecha"].substring(0, 10)),
              Text("N.Surcos: " + datos["cantidad"].toString()),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("Brix"),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.refresh), onPressed: informacion),
          ],
        ),
        resizeToAvoidBottomPadding: false,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                      child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_dateTime == null
                            ? DateTime.now().day.toString() +
                                "-" +
                                DateTime.now().month.toString() +
                                "-" +
                                DateTime.now().year.toString()
                            : _dateTime.day.toString() +
                                "-" +
                                _dateTime.month.toString() +
                                "-" +
                                _dateTime.year.toString()),
                        FloatingActionButton(
                          heroTag: "calendario",
                          onPressed: () {
                            showDatePicker(
                              cancelText: null,
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2019),
                              lastDate: DateTime(2030),
                            ).then((date) {
                              setState(() {
                                informacion();
                                if (date != null) _dateTime = date;
                              });
                            });
                          },
                          child: Icon(Icons.calendar_today),
                        ),
                      ],
                    ),
                  )),
                  caja(),
                ])));
  }

  Future<Null> informacion() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('tk') != null) {
      Map<String, String> dat = {"fecha": _dateTime.toString()};
      var hd = {'vefificador': sharedPreferences.getString('tk')};
      var inv = "";
      if (this.invernadero == "Invernadero-12") {
        inv = "totales12";
      }
      if (this.invernadero == "Invernadero-11") {
        inv = "totales11";
      }
      var response;
      try {
        response = await http.post(Constant.DOMAIN + "/brix/",
            headers: hd,
            body: {
              "fecha": _dateTime.toString(),
              "tabla": inv
            }).timeout(const Duration(seconds: 15));
      } on TimeoutException catch (_) {
        setState(() {
          mensaje = 'Sin conexion al servidor';
          _showMyDialog();
        });
        throw ('Sin conexion al servidor');
      } on SocketException {
        setState(() {
          throw ('Sin internet  o falla de servidor ');
        });
      } on HttpException {
        throw ("No se encontro esa peticion");
      } on FormatException {
        throw ("Formato erroneo ");
      }
      setState(() {
        datos = json.decode(response.body);
      });

      print(datos);

      //print(data);
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ERROR"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ERROR.'),
                Text(mensaje),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    informacion();
    _dateTime = DateTime.now();

    //super.initState();
  }
}
