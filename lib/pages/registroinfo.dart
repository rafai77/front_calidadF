import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:calidad/pages/registro.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Regi.dart';
import 'Registros.dart';
import 'Viewlocal.dart';

class RegInfo extends StatefulWidget {
  Regi r;
  bool local;
  RegInfo(this.r, this.local);
  @override
  _RegInfoState createState() => _RegInfoState(this.r, this.local);
}

class _RegInfoState extends State<RegInfo> {
  Regi r;
  bool local;
  String mensaje = "";
  _RegInfoState(this.r, this.local);

  sinConexion(var registro) async {
    final directory = await getApplicationDocumentsDirectory();
    var c = directory.path;
    File f = File('$c/regi.txt');
    var r = json.encode(registro);
    print(r);
    f.writeAsStringSync('$r,', mode: FileMode.append);

    print(directory);
    //Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("Tunel=" + r.num_tunel.toString()),
          actions: <Widget>[
            // action button
            IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () async {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  var conecctionResult =
                      await Connectivity().checkConnectivity();
                  if (conecctionResult != ConnectivityResult.none &&
                      local == false) {
                    print(sharedPreferences.getString('tk')); // 192.168.1.135
                    var hd = {'vefificador': sharedPreferences.getString('tk')};
                    print(sharedPreferences.getInt('id_inver'));
                    var response;
                    var id = this.r.id_reg;
                    try {
                      response = await http
                          .delete(
                            "http://192.168.1.129:3000/borrar/$id",
                            headers: hd,
                          )
                          .timeout(const Duration(seconds: 7));
                    } on TimeoutException catch (_) {
                      setState(() {
                        mensaje = 'no se pudo borrarr\n';
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

                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    final directory = await getApplicationDocumentsDirectory();
                    var c = directory.path;

                    File f = File('$c/regi.txt');
                    // Leer el archivo
                    String contents = await f.readAsString();

                    f.delete();

                    contents = contents.substring(0, contents.length - 1);
                    contents = "[" + contents + "]";

                    var datos = json.decode(contents);
                    var aux = [];
                    for (var i in datos) {
                      if (this.r.num_tunel != i['num_tunel']) aux.add((i));
                    }
                    print(aux.runtimeType);
                    if (!aux.isEmpty) sinConexion(aux[0]);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    //Navigator.pop(context);
                  }
                }),
            // action button
            IconButton(
              icon: Icon(Icons.mode_edit),
              onPressed: () async {
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Registro(
                            this.r.id_user,
                            sharedPreferences.getString('user'),
                            this.r.id_inve.toString(),
                            this.r.id_inve,
                            this.r)));
              },
            ),
            // overflow menu
          ],
        ),
        resizeToAvoidBottomPadding: false,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Center(
                child: Container(
                    margin: EdgeInsets.only(top: 50),
                    child: Column(
                      children: <Widget>[
                        Text("Color3 = " + r.num_color3.toString()),
                        Text("Color4 = " + r.num_color4.toString()),
                        Text("Color5 = " + r.num_color5.toString()),
                        Text("Tamañp chico = " + r.tamchico.toString()),
                        Text("Brix = " + r.Brix.toString()),
                        Text("Brix2 = " + r.Brix2.toString()),
                        Text("Pudicion = " + r.pudricion.toString()),
                        Text("tallo = " + r.tallo.toString()),
                        Text("flojo = " + r.flojo.toString()),
                        Text("Mecanico = " + r.mecanico.toString()),
                        Text("Blossom = " + r.blossom.toString()),
                        Text("Reventado = " + r.reventado.toString()),
                        Text("Cierre = " + r.cierre.toString()),
                        Text("Deforme = " + r.deforme.toString()),
                        Text("Cicatriz = " + r.cicatriz.toString()),
                        Text("Insecto = " + r.insecto.toString()),
                        Text("Color Disparejo = " +
                            r.color_disparejo.toString()),
                        Text("Caliz = " + r.caliz.toString()),
                        Text("Virus = " + r.viruz.toString()),
                        Text("Fecha = " + r.fecha.toString()),
                      ],
                    )))));
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("advertencias"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¡!.'),
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
}
