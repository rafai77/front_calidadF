import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:calidad/pages/inv-12/Registros12.dart';
import 'package:calidad/pages/inv-12/registro12.dart';
import 'package:calidad/pages/registro.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Registros.dart';
import 'Viewlocal.dart';
import 'inv-12/Viewlocal12.dart';
import 'package:calidad/pages/Constantes.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  bool local = false;
  String dropdownValue1 = null;
  bool drop1 = false;
  String dropdownValue2 = null;
  bool drop2 = false;
  String valorD1 = "";
  String valorD2 = "";
  List ldI; //lista de invernaderos
  String mensaje;
  @override
  void initState() {
    obtener();

    //print(l['Nombre']);
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

  Map<int, String> listaInven = Map();
  void genrarlista() {
    print(ldI);
    if (ldI.length == 1) {
      listaInven[ldI[0]['id_inver']] = ldI[0]['Nombre'];
    }
    for (var i = 0; i < ldI.length; i++) {
      listaInven[ldI[i]['id_inver']] = ldI[i]['Nombre'];
    }
    setState(() {
      drop1 = true;
      dropdownValue1 = listaInven[ldI[0]['id_inver']];
      drop2 = true;
      dropdownValue2 = listaInven[ldI[0]['id_inver']];
    });
    dropdownValue1 = listaInven[ldI[0]['id_inver']];
    drop1 = true;
    drop2 = true;
    dropdownValue2 = listaInven[ldI[0]['id_inver']];
    print(listaInven);
  }

  Future<List> obtener() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var conecctionResult = await Connectivity().checkConnectivity();
    if (conecctionResult != ConnectivityResult.none) {
      print("conectado");
      print(sharedPreferences.getString('rol'));
      var id_inver = sharedPreferences.getInt('id_inver');
      if (sharedPreferences.getString('tk') != null) {
        var hd = {'vefificador': sharedPreferences.getString('tk')};
        var response;
        try {
          response = await http
              .get(
                //
                Constant.DOMAIN + "/invernadero/$id_inver",
                headers: hd,
              )
              .timeout(const Duration(seconds: 7));
        } on TimeoutException catch (_) {
          setState(() {
            mensaje =
                'Sin conexion al servidor\nSe puede guardar o editar datos locales';
            _showMyDialog();
            sinConexion();
          });
          throw ('Sin conexion al servidor');
        } on SocketException {
          setState(() {
            sinConexion();
            throw ('Sin internet  o falla de servidor ');
          });
        } on HttpException {
          sharedPreferences.clear();
          sharedPreferences.commit();
          throw ("No se encontro esa peticion");
        } on FormatException {
          sharedPreferences.clear();
          sharedPreferences.commit();
          throw ("Formato erroneo ");
        }

        print(response);
        ldI = json.decode(response.body);
        genrarlista();
        print(listaInven[ldI[0]['id_inver']]);
        dropdownValue1 = listaInven[ldI[0]['id_inver']];
        drop1 = true;
        drop2 = true;
        dropdownValue2 = listaInven[ldI[0]['id_inver']];
        sharedPreferences.setString(
            "invernadero", listaInven[ldI[0]['id_inver']]);

        return ldI;
      }
    } else {
      sinConexion();
    }
  }

  sinConexion() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      print("no-conectado");
      local = true;
      var idV = sharedPreferences.getInt('id_inver');

      ldI = [
        {'id_inver': idV, 'Nombre': sharedPreferences.getString("invernadero")}
      ];
      genrarlista();

      dropdownValue1 = listaInven[ldI[0]['id_inver']];
      drop1 = true;
      drop2 = true;
      dropdownValue2 = listaInven[ldI[0]['id_inver']];
      sharedPreferences.setString(
          "invernadero", listaInven[ldI[0]['id_inver']]);
    });
  }

  targetaInvernadero() {
    return Container(
      height: MediaQuery.of(context).size.height * .3,
      width: MediaQuery.of(context).size.width / 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: Colors.blue[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0.0, 10.0),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Center(
              heightFactor: 2,
              child: Text("Seleccione el invernadero ",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ))),
          Center(
            child: Container(
              padding: EdgeInsets.only(
                  top: (MediaQuery.of(context).size.height * .03)),
              child: DropdownButton<String>(
                value: dropdownValue1,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.blue),
                underline: Container(
                  height: 2,
                  color: Colors.green,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue1 = newValue;
                  });
                },
                items: listaInven.values
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          Center(
            heightFactor: MediaQuery.of(context).size.height * .0025,
            child: FloatingActionButton(
              onPressed: agregar,
              heroTag: "Add",
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  targetaViewlocal() {
    return Container(
      height: MediaQuery.of(context).size.height * .3,
      width: MediaQuery.of(context).size.width / 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: Colors.blue[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0.0, 10.0),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Center(
              heightFactor: 2,
              child: Text("Ver Registros ",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ))),
          Center(
            child: Container(
              padding: EdgeInsets.only(
                  top: (MediaQuery.of(context).size.height * .03)),
              child: DropdownButton<String>(
                value: dropdownValue2,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.blue),
                underline: Container(
                  height: 2,
                  color: Colors.green,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue2 = newValue;
                    valorD2 = newValue;
                  });
                },
                items: listaInven.values
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          Center(
            heightFactor: MediaQuery.of(context).size.height * .0025,
            child: FloatingActionButton(
              heroTag: "View",
              onPressed: vista,
              tooltip: 'Increment',
              child: Icon(Icons.view_comfy),
            ),
          ),
        ],
      ),
    );
  }

  targetaView() {
    return Container(
      height: MediaQuery.of(context).size.height * .3,
      width: MediaQuery.of(context).size.width / 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: Colors.blue[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0.0, 10.0),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Center(
              heightFactor: 2,
              child: Text("Ver Registros ",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ))),
          Center(
            child: Container(
              padding: EdgeInsets.only(
                  top: (MediaQuery.of(context).size.height * .03)),
              child: DropdownButton<String>(
                value: dropdownValue2,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.blue),
                underline: Container(
                  height: 2,
                  color: Colors.green,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue2 = newValue;
                    valorD2 = newValue;
                  });
                },
                items: listaInven.values
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          Center(
            heightFactor: MediaQuery.of(context).size.height * .0025,
            child: FloatingActionButton(
              heroTag: "View",
              onPressed: vista,
              tooltip: 'Increment',
              child: Icon(Icons.view_comfy),
            ),
          ),
        ],
      ),
    );
  }

  tarjetas() {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 7, top: 5),
          width: MediaQuery.of(context).size.width * .47,
          padding: EdgeInsets.only(right: 5),
          child: targetaInvernadero(),
        ),
        Container(
          margin: EdgeInsets.only(left: 8, top: 5),
          width: MediaQuery.of(context).size.width * .47,
          child: targetaView(),
        ),
      ],
    );
  }

  Future<bool> con() //verifica la conexion
  async {
    var conecctionResult = await Connectivity().checkConnectivity();
    setState(() {
      if (conecctionResult != ConnectivityResult.none) {
        return false;
      }
      return true;
    });
  }

  Widget build(BuildContext context) {
    return Container(
      child: !drop1
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                tarjetas(),
                Container(
                  margin: EdgeInsets.only(top: 35),
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * .1,
                      width: MediaQuery.of(context).size.width * .85,
                      child: RaisedButton(
                        child: Text("Datos locales"),
                        color: Colors.red,
                        splashColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        onPressed: datoslocales,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  datoslocales() async {
    try {
      SharedPreferences s = await SharedPreferences.getInstance();
      final directory = await getApplicationDocumentsDirectory();
      var c = directory.path;
      File f = File('$c/regi.txt');
      // Leer el archivo
      String contents = await f.readAsString();
      //f.delete();
      contents = contents.substring(0, contents.length - 1);
      contents = "[" + contents + "]";
      //son.decode(contents);
      //print(contents);
      //print(json.decode(contents));
      //print(json.decode(contents));
      var datos = json.decode(contents);
      print(datos);
      if (s.getInt('id_inver') == 11) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Viewlocal(datos)));
      }
      if (s.getInt('id_inver') == 12) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Viewlocal12(datos)));
      }
    } on FileSystemException {
      print("No tiene archivos locales ");
      setState(() {
        mensaje = "No tiene archivos locales ";
        _showMyDialog();
      });
    }
  }

  agregar() async {
    print("agregar" + dropdownValue1);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id_inver = 0;
    var conecctionResult = await Connectivity().checkConnectivity();
    if (conecctionResult != ConnectivityResult.none) {
      for (var i in ldI) {
        if (i['Nombre'] == dropdownValue1) {
          print(i['id_inver']);
          id_inver = i['id_inver'];
        }
      }
    } else {
      id_inver = sharedPreferences.getInt('id_inver');
    }
    if (sharedPreferences.getInt('id_inver') == 11) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Registro(
                  sharedPreferences.getInt('id'),
                  sharedPreferences.getString('user'),
                  dropdownValue1,
                  id_inver)));
    }
    if (sharedPreferences.getInt('id_inver') == 12) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Registro12(
                  sharedPreferences.getInt('id'),
                  sharedPreferences.getString('user'),
                  dropdownValue1,
                  id_inver)));
    }
  }

  vista() async {
    print("view " + dropdownValue2);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getInt('id_inver') == 11) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegistrosView(
                  sharedPreferences.getString('user'), dropdownValue2)));
    }
    if (sharedPreferences.getInt('id_inver') == 12) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegistrosView12(
                  sharedPreferences.getString('user'), dropdownValue2)));
    }
  }
}
