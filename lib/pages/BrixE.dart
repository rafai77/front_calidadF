//pagina para agragar los brix

import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
  TextEditingController brix1 = TextEditingController(); // numero del tunel
  TextEditingController brix2 = TextEditingController();

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
                    caja("brix1", brix1),
                    caja("brix2", brix2),
                    FloatingActionButton(
                        backgroundColor: Colors.green,
                        onPressed: null,
                        tooltip: 'Increment',
                        child: Icon(Icons.add)),
                  ],
                ))));
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
