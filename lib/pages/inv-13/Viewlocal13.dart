import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:calidad/pages/inv-13/registro13info.dart';
import 'package:calidad/pages/inv-16/Regi16.dart';
import 'package:calidad/pages/inv-16/registro16info.dart';
import 'package:http/http.dart' as http;

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calidad/pages/Constantes.dart';

class Viewlocal13 extends StatefulWidget {
  @override
  var datos;
  Viewlocal13([this.datos]);

  _Viewlocal13State createState() => _Viewlocal13State(this.datos);
}

class _Viewlocal13State extends State<Viewlocal13> {
  @override
  var datos;
  String mensaje;
  bool lista;
  StreamController<List<Regi16>> ldR;
  _Viewlocal13State([this.datos]);
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Registros"),
      ),
      resizeToAvoidBottomPadding: false,
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    //bottom: (MediaQuery.of(context).size.height * .85),
                    //left: (MediaQuery.of(context).size.width)
                    ),
                child: Center(
                  child: Text("Datos Almacenados Localmente"),
                ),
                //width: MediaQuery.of(context).size.width * .15,
              ),
              Container(
                  margin: EdgeInsets.only(bottom: 90),
                  child: StreamBuilder(
                    stream: ldR.stream,
                    builder: (BuildContext contex, AsyncSnapshot snapshot) {
                      if (snapshot.data == null) {
                        return Row(children: <Widget>[
                          Center(child: Text("sin datos.....")),
                        ]);
                      }
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.only(top: 25),
                                width: MediaQuery.of(context).size.width * .7,
                                height: MediaQuery.of(context).size.height * .6,
                                child: Center(
                                    child: Container(
                                        //padding: EdgeInsets.only(bottom: 20),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.2,
                                        child: ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            physics: ScrollPhysics(),
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (BuildContext contex,
                                                int index) {
                                              return Container(
                                                  //padding: EdgeInsets.fr,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      .1,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.blue,
                                                          blurRadius: 2,
                                                        ),
                                                      ]),
                                                  child: ListTile(
                                                    title: Text(
                                                      "Tunel = " +
                                                          snapshot.data[index]
                                                              .num_tunel
                                                              .toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    onTap: () => {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  RegInfo13(
                                                                      snapshot.data[
                                                                          index],
                                                                      false))),
                                                    },
                                                    subtitle: Text("Racimo 1= " +
                                                        snapshot
                                                            .data[index].racimo1
                                                            .toString() +
                                                        " \n" +
                                                        "Racimo 2= " +
                                                        snapshot
                                                            .data[index].racimo2
                                                            .toString() +
                                                        " \racimo 3= " +
                                                        snapshot
                                                            .data[index].racimo3
                                                            .toString() +
                                                        " \n" "Fecha= " +
                                                        snapshot
                                                            .data[index].fecha
                                                            .toString() +
                                                        " \n \t...toda la informacion...\t"),
                                                  ));
                                            }))))
                          ]);
                    },
                  )),
              FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: subir,
                  tooltip: 'Increment',
                  child: Icon(Icons.cloud_upload))
            ],
          )),
    );
  }

  subir() async {
    List<bool> status = [];
    List<int> tunelesMal = [];
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final directory = await getApplicationDocumentsDirectory();
    var conecctionResult = await Connectivity().checkConnectivity();
    if (conecctionResult != ConnectivityResult.none) {
      print(sharedPreferences.getString('tk')); // 192.168.1.135
      var hd = {'vefificador': sharedPreferences.getString('tk')};
      for (var i in this.datos) {
        //print(i);
        //i['num_color3'] = null;
        var response;

        try {
          response = await http.post(Constant.DOMAIN + "/addC13/",
              headers: hd,
              body: {
                'REG': json.encode(i)
              }).timeout(const Duration(seconds: 7));
        } on TimeoutException catch (_) {
          setState(() {
            mensaje =
                'Sin conexion al servidor\nSe puede guardar o editar datos locales';
            _showMyDialog();
          });
          throw ('Sin conexion al servidor');
        } on SocketException {
          setState(() {
            mensaje = 'Sin conexion al servidor';
            _showMyDialog();
            throw ('Sin internet  o falla de servidor ');
          });
        } on HttpException {
          throw ("No se encontro esa peticion");
        } on FormatException {
          throw ("Formato erroneo ");
        }

        var data = json.decode(response.body);
        status.add(data['error']);
        tunelesMal.add(i['num_tunel']);
        //status.addAll(data);
        //print(response.body);
      }
      print(status);
      print(tunelesMal);
      setState(() {
        var c = directory.path;
        File f = File('$c/regi.txt');
        f.delete();
        int ca = 0;
        String er = "No se agregaron los siguientes tuneles:\n";
        for (var i = 0; i < status.length; i++) {
          if (status[i]) {
            ca++;
            er += '\t *' + tunelesMal[i].toString() + "\n";
            var r = json.encode(this.datos[i]);
            f.writeAsStringSync('$r,', mode: FileMode.append);
          }
        }
        print(ca);
        if (ca == 0) {
          Navigator.pop(context);
        } else {
          setState(() {
            mensaje = er;
            _showMyDialog();
          });
        }
      });
      //}

    } else // datos locales
    {
      setState(() {
        mensaje = "Sin internet ";
        _showMyDialog();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print(this.datos);
    ldR = StreamController<List<Regi16>>();
    datosC();
  }

  void datosC() {
    List<Regi16> aux = [];
    for (var i in this.datos) {
      Regi16 r = Regi16(
        i["id_reg"],
        i['id_user'],
        i['id_inve'],
        i['num_tunel'],
        i['racimo1'],
        i['racimo2'],
        i["racimo3"],
        i['racimo4'],
        i['racimo5'],
        i['racimo6'],
        i['tamchico'],
        i["pudricion"],
        i["lado"],
        i["peso"],
        i["flojo"],
        i["mecanico"],
        i["blossom"],
        i["daño_virus"],
        i["cierre"],
        i["deforme"],
        i["cicatriz"],
        i["insecto_presencia"],
        i["insecto_daño"],
        i["craking"],
        i["corte"],
        i["golpe"],
        i["exverde"],
        i["color_disparejo"],
        i["arrugado"],
        i["blotchy"],
        i["suelto"],
        i["fecha"],
      );

      aux.add(r);
      setState(() {
        lista = true;
      });
      ldR.add(aux);
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
}
