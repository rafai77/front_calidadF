import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:calidad/pages/inv-16/Regi16.dart';
import 'package:calidad/pages/inv-16/registro16.dart';
import 'package:calidad/pages/Constantes.dart';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RegInfo16 extends StatefulWidget {
  Regi16 r;
  bool local;
  RegInfo16(this.r, this.local);
  @override
  _RegInfoState16 createState() => _RegInfoState16(this.r, this.local);
}

class _RegInfoState16 extends State<RegInfo16> {
  Regi16 r;
  bool local;
  String mensaje = "";
  _RegInfoState16(this.r, this.local);

  @override
  void initState() {
    super.initState();
    print(this.r.dano_virus);
  }

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
                            Constant.DOMAIN + "/borrar16/$id",
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
                        builder: (context) => Registro16(
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
                        Text("Racimo1 =: " + this.r.racimo1.toString()),
                        Text("Racimo2 =: " + this.r.racimo2.toString()),
                        Text("Racimo3 =: " + this.r.racimo3.toString()),
                        Text("Racimo4 =: " + this.r.racimo4.toString()),
                        Text("Racimo5 =: " + this.r.racimo5.toString()),
                        Text("Racimo6 =: " + this.r.racimo6.toString()),
                        Text("Tamaño menor =: " + this.r.tamchico.toString()),
                        Text("Lado =: " + this.r.lado.toString()),
                        Text("peso =: " + this.r.peso.toString()),
                        Text("daño por virus =: " + r.dano_virus.toString()),
                        Text("Pudricion =: " + this.r.pudricion.toString()),
                        Text("Flojo =: " + this.r.flojo.toString()),
                        Text("Mecanico =: " + this.r.mecanico.toString()),
                        Text("Blossom =: " + this.r.blossom.toString()),
                        Text("cierre =: " + this.r.cierre.toString()),
                        Text("Insecto presencia =: " +
                            this.r.insectop.toString()),
                        Text("craking =: " + this.r.craking.toString()),
                        Text("Insecto daño =: " + this.r.insectod.toString()),
                        Text("Corte =: " + this.r.corte.toString()),
                        Text("Golpe =: " + this.r.golpe.toString()),
                        Text("Extra Verde =: " + this.r.exverde.toString()),
                        Text("Color_disparejo =: " +
                            this.r.color_disparejo.toString()),
                        Text("Arrudago =: " + this.r.arrudago.toString()),
                        Text("Blotchy =: " + this.r.blotchy.toString()),
                        Text("Suelto =: " + this.r.suelto.toString()),
                        Text("Fecha =: " + this.r.fecha.toString()),
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
