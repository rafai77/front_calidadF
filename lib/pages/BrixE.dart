//pagina para agragar los brix

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:wasm';
import 'package:calidad/pages/Constantes.dart';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Regi.dart';

class BrixRegistro extends StatefulWidget {
  String fecha;
  String invernadero;
  BrixRegistro(this.fecha, this.invernadero);
  @override
  _BrixRegistroState createState() =>
      _BrixRegistroState(this.fecha, this.invernadero);
}

class _BrixRegistroState extends State<BrixRegistro> {
  String fecha;
  String invernadero;
  String mensaje;
  String tabla;
  TextEditingController brix1 = TextEditingController(); // numero del tunel
  TextEditingController brix2 = TextEditingController();
  TextEditingController brix3 = TextEditingController(); // numero del tunel
  TextEditingController brix4 = TextEditingController();

  _BrixRegistroState(this.fecha, this.invernadero);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("Brix´s 11"),
        ),
        resizeToAvoidBottomPadding: false,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
                alignment: Alignment.center,
                //padding: EdgeInsets.only(right: ),
                child: Column(
                  children: <Widget>[
                    cajas(),
                    FloatingActionButton(
                        backgroundColor: Colors.green,
                        onPressed: add,
                        tooltip: 'Increment',
                        child: Icon(Icons.add)),
                  ],
                ))));
  }

  @override
  void initState() {
    super.initState();
    print(this.invernadero);
    if (this.invernadero == "Invernadero-11") this.tabla = "totales11";
    if (this.invernadero == "Invernadero-12") this.tabla = "totales12";
    if (this.invernadero == "Invernadero-15") this.tabla = "totales15";
  }

  cajas() {
    if (this.invernadero == "Invernadero-11" ||
        this.invernadero == "Invernadero-15") {
      return Container(
          child: Column(
              children: <Widget>[caja("brix1", brix1), caja("brix2", brix2)]));
    }
    if (this.invernadero == "Invernadero-12") {
      return Container(
          child: Column(children: <Widget>[
        caja("brix1", brix1),
        caja("brix2", brix2),
        caja("brix3", brix3),
        caja("brix4", brix4),
      ]));
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

  add() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('tk') != null) {
      var hd = {'vefificador': sharedPreferences.getString('tk')};
      Map<String, dynamic> body;
      if (this.invernadero == "Invernadero-11" ||
          this.invernadero == "Invernadero-15") {
        body = {
          "fecha": this.fecha,
          "tabla": this.tabla,
          "Brix": (brix1.text),
          "Brix2": (brix2.text)
        };
      }
      if (this.invernadero == "Invernadero-12") {
        body = {
          "fecha": this.fecha,
          "tabla": this.tabla,
          "Brix1": (brix1.text),
          "Brix2": (brix2.text),
          "Brix3": (brix3.text),
          "Brix4": (brix4.text)
        };
      }

      var response;
      try {
        response = await http
            .put(Constant.DOMAIN + "/blixadd/", headers: hd, body: body)
            .timeout(const Duration(seconds: 15));
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
        var data = json.decode(response.body);
        print(data);
        if (!data["error"])
          Navigator.pop(context);
        else {
          mensaje = data["status"] + "\n";
          Navigator.pop(context);
        }
      });
    }
  }

  caja(String n, TextEditingController t) {
    return Container(
      // para las cajas de texto
      height: MediaQuery.of(context).size.height * .1,
      width: MediaQuery.of(context).size.width * .5,
      padding: EdgeInsets.only(top: 5),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * .49,
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .01,
              right: MediaQuery.of(context).size.width * .06,
              //
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 5,
                  ),
                ]),
            child: TextFormField(
              controller: t,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: n,
                  hintText: n,
                  icon: Icon(
                    Icons.brightness_low,
                    color: Colors.redAccent,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
