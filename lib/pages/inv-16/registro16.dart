import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:calidad/pages/Constantes.dart';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Regi16.dart';

class Registro16 extends StatefulWidget {
  String nuser;
  int id_inver;
  int id;
  Regi16 r;
  String invernadero;
  Registro16([this.id, this.nuser, this.invernadero, this.id_inver, this.r]);
  @override
  _Registro16State createState() => _Registro16State(
      this.id, this.nuser, this.invernadero, this.id_inver, this.r);
}

class _Registro16State extends State<Registro16> {
  String nuser = " ";
  int id_inver;
  String mensaje;
  bool local;
  bool editar = false;
  TextEditingController numT = TextEditingController(); // numero del tunel
  TextEditingController rac1 = TextEditingController(); // numero de color 1
  TextEditingController rac2 = TextEditingController(); // racero de color 2
  TextEditingController rac3 = TextEditingController(); // racero de color 3
  TextEditingController rac4 = TextEditingController(); // racero de color 1
  TextEditingController rac5 = TextEditingController(); // racero de color 2
  TextEditingController rac6 = TextEditingController(); // numero de color 3
  TextEditingController tam = TextEditingController(); // tamaño
  TextEditingController peso = TextEditingController(); // tamaño
  TextEditingController lado = TextEditingController(); // lado

  var dano = {
    'pudricion': 0,
    "Flojo": 0,
    "Dano_Mecanico": 0,
    "Blossom": 0,
    "Golpe": 0,
    "Mal_cierre": 0,
    "Deforme": 0,
    "Incecto_presencia": 0,
    "Craking": 0,
    "Cicatriz": 0,
    "Corte": 0,
    "Extra_verde": 0,
    "Dano_X_insecto": 0,
    "Color Disparejo": 0,
    "Arrudago": 0,
    "Blotchy": 0,
    "Suelto": 0,
    "Daño_x_virus": 0
  };

  int pudricion = 0;
  int v;
  DateTime _dateTime;
  Regi16 r;
  int id = 0;
  String invernadero;
  bool ladoi = false; // false es para S y true para N
  String laredo = "S";

  _Registro16State(this.id, this.nuser, this.invernadero, this.id_inver,
      [this.r]) {
    if (this.r == null) {
      editar = false;
    } else {
      editar = true;
      numT.text = this.r.num_tunel.toString();
      rac1.text = this.r.racimo1.toString();
      rac2.text = this.r.racimo2.toString();
      rac3.text = this.r.racimo3.toString();
      rac4.text = this.r.racimo4.toString();
      rac5.text = this.r.racimo5.toString();
      rac6.text = this.r.racimo6.toString();
      tam.text = this.r.tamchico.toString();
      peso.text = this.r.peso.toString();
      dano['pudricion'] = this.r.pudricion;
      dano["Flojo"] = this.r.flojo;
      dano['Dano_Mecanico'] = this.r.mecanico;
      dano['Blossom'] = this.r.blossom;
      dano["Mal_cierre"] = this.r.cierre;
      dano["Deforme"] = this.r.deforme;
      dano["Cicatriz"] = this.r.cicatriz;
      dano["Dano_X_insecto"] = this.r.insectod;
      dano["Incecto_presencia"] = this.r.insectop;
      dano["Daño_x_virus"] = this.r.dano_virus;
      dano["Craking"] = this.r.craking;
      dano["Corte"] = this.r.corte;
      dano["Golpe"] = this.r.golpe;
      dano["Extra_verde"] = this.r.exverde;
      dano["arrudago"] = this.r.arrudago;
      dano["Blotchy"] = this.r.blotchy;
      dano["Suelto"] = this.r.suelto;
      dano["Color Disparejo"] = this.r.color_disparejo;
      print(this.r.fecha.toString());
    }
    //va para editar los datos
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
            padding: EdgeInsets.only(top: 1, left: 16, right: 16, bottom: 4),
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
                  )),
            ),
          ),
        ],
      ),
    );
  }

  cajaS(String n, TextEditingController t) {
    return Container(
      // para las cajas de texto
      height: MediaQuery.of(context).size.height * .1,
      width: MediaQuery.of(context).size.width * .5,
      padding: EdgeInsets.only(top: 5),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * .49,
            padding: EdgeInsets.only(top: 1, left: 16, right: 16, bottom: 4),
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
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  labelText: n,
                  hintText: n,
                  icon: Icon(
                    Icons.brightness_low,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  danos([String n = "pudricion"]) {
    return Container(
      height: MediaQuery.of(context).size.height * .06,
      width: MediaQuery.of(context).size.width * .70,
      child: Row(
        children: <Widget>[
          Container(
            //width: ,
            height: MediaQuery.of(context).size.height * .05,
            child: FloatingActionButton(
              onPressed: () => {
                setState(() {
                  if (dano[n] > 0) dano[n] = dano[n] - 1;
                })
              },
              heroTag: "Menos" + n,
              tooltip: 'Menos' + n,
              child: Icon(Icons.exposure_neg_1),
            ),
          ),
          Text(n + "=" + (dano[n].toString())),
          Container(
            height: MediaQuery.of(context).size.height * .05,
            child: FloatingActionButton(
              onPressed: () => {
                setState(() {
                  dano[n] = dano[n] + 1;
                })
              },
              heroTag: "Mas" + n,
              tooltip: 'Mas' + n,
              child: Icon(Icons.plus_one),
            ),
          ),
        ],
      ),
    );
  }

  bool validateDatos() {
    if (rac1.text == "" ||
        rac2.text == "" ||
        rac3.text == "" ||
        rac4.text == "" ||
        rac5.text == "" ||
        rac6.text == "" ||
        numT.text == "" ||
        peso.text == "" ||
        tam.text == "") {
      setState(() {
        mensaje = "Cajas de texto vacias\nComplete todos los espacios";
        _showMyDialog();
      });
      return false;
    } else {
      return true;
    }
  }

  addBD() async //agegar a bd addC
  {
    if (validateDatos()) {
      if (editar) {
        print(this.id_inver);
        print("editar");
        //print(dano);
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        //id_user,id_inve,num_tunel,num_color3,num_color4,num_color5,tamchico,Brix
        Map<String, dynamic> registro = {
          'id_user': sharedPreferences.getInt('id'),
          'id_inve': this.id_inver,
          'num_tunel': int.parse(numT.text),
          "racimo1": int.parse(rac1.text),
          "racimo2": int.parse(rac2.text),
          "racimo3": int.parse(rac3.text),
          "racimo4": int.parse(rac4.text),
          "racimo5": int.parse(rac5.text),
          "racimo6": int.parse(rac6.text),
          'tamchico': int.parse(tam.text),
          "peso": double.parse(peso.text),
          'pudricion': dano['pudricion'],
          "flojo": dano["Flojo"],
          "mecanico": dano['Dano_Mecanico'],
          "blossom": dano['Blossom'],
          "cierre": dano["Mal_cierre"],
          "deforme": dano["Deforme"],
          "cicatriz": dano["Cicatriz"],
          "insecto_daño": dano["Dano_X_insecto"],
          "insecto_presencia": dano["Incecto_presencia"],
          "dano_virus": dano["Daño_x_virus"],
          "craking": dano["Craking"],
          "corte": dano["Corte"],
          "golpe": dano["Golpe"],
          "exverde": dano["Extra_verde"],
          "arrudago": dano["arrudago"],
          "blotchy": dano["Blotchy"],
          "suelto": dano["Suelto"],
          "color_disparejo": dano["Color Disparejo"],
          "fecha": DateTime.parse(this.r.fecha)
              .toString()
              .substring(0, DateTime.parse(this.r.fecha).toString().length - 2),
          "lado": laredo
        };

        var conecctionResult = await Connectivity().checkConnectivity();
        if (conecctionResult != ConnectivityResult.none) {
          print(sharedPreferences.getString('tk')); // 192.168.1.135
          var hd = {'vefificador': sharedPreferences.getString('tk')};
          print(sharedPreferences.getInt('id_inver'));
          var response;
          try {
            response = await http.put(Constant.DOMAIN + "/actualizar16/",
                headers: hd,
                body: {
                  'id': this.r.id_reg.toString(),
                  'REG': json.encode(registro)
                }).timeout(const Duration(seconds: 7));
          } on TimeoutException catch (_) {
            setState(() {
              mensaje = 'Sin conexion al servidor\n';
              _showMyDialog();
              Navigator.pop(context);
              Navigator.pop(context);
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

          var data = json.decode(response.body);
          print(data[0]);
          print(response.body);
          if (data['error'] == true) {
            setState(() {});
          } else {
            setState(() {
              print("bien ${data['status']}");
              Navigator.pop(context);
              Navigator.pop(context);
              //Navigator.pop(context);
            });
            //}
          }
        } else {
          //editar localmente

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
            if (this.r.num_tunel == i['num_tunel'])
              aux.add((registro));
            else
              aux.add((i));
          }
          print(aux.runtimeType);

          sinConexion(aux[0]);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } else {
        print(this.id_inver);
        print("agregar");
        //print(dano);
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        //id_user,id_inve,num_tunel,num_color3,num_color4,num_color5,tamchico,Brix
        Map<String, dynamic> registro = {
          'id_user': sharedPreferences.getInt('id'),
          'id_inve': this.id_inver,
          'num_tunel': int.parse(numT.text),
          "racimo1": int.parse(rac1.text),
          "racimo2": int.parse(rac2.text),
          "racimo3": int.parse(rac3.text),
          "racimo4": int.parse(rac4.text),
          "racimo5": int.parse(rac5.text),
          "racimo6": int.parse(rac6.text),
          'tamchico': int.parse(tam.text),
          "peso": double.parse(peso.text),
          'pudricion': dano['pudricion'],
          "flojo": dano["Flojo"],
          "mecanico": dano['Dano_Mecanico'],
          "blossom": dano['Blossom'],
          "cierre": dano["Mal_cierre"],
          "deforme": dano["Deforme"],
          "cicatriz": dano["Cicatriz"],
          "insecto_daño": dano["Dano_X_insecto"],
          "insecto_presencia": dano["Incecto_presencia"],
          "dano_virus": dano["Daño_x_virus"],
          "craking": dano["Craking"],
          "corte": dano["Corte"],
          "golpe": dano["Golpe"],
          "exverde": dano["Extra_verde"],
          "arrudago": dano["Arrudago"],
          "blotchy": dano["Blotchy"],
          "suelto": dano["Suelto"],
          "color_disparejo": dano["Color Disparejo"],
          "fecha": _dateTime.toString(),
          "lado": laredo
        };
        print(json.encode(registro));
        var conecctionResult = await Connectivity().checkConnectivity();
        if (conecctionResult != ConnectivityResult.none) {
          print(sharedPreferences.getString('tk')); // 192.168.1.135
          var hd = {'vefificador': sharedPreferences.getString('tk')};
          var response;
          try {
            response = await http.post(Constant.DOMAIN + "/addC16/",
                headers: hd,
                body: {
                  'REG': json.encode(registro)
                }).timeout(const Duration(seconds: 15));
          } on TimeoutException catch (_) {
            setState(() {
              sinConexion(registro);
              mensaje =
                  'Sin conexion al servidor\n se guardo el registro localmente';
              _showMyDialog();
              Navigator.pop(context);
              Navigator.pop(context);
            });
            throw ('Sin conexion al servidor');
          } on SocketException {
            setState(() {
              sinConexion(registro);
              throw ('Sin internet  o falla de servidor ');
            });
          } on HttpException {
            throw ("No se encontro esa peticion");
          } on FormatException {
            throw ("Formato erroneo ");
          }

          var data = json.decode(response.body);
          print(data[0]);
          print(response.body);
          if (data['error'] == true) {
            setState(() {
              mensaje = "Registro mal\n Posiblemente ya registro ese tunel ";
              _showMyDialog();
            });
          } else {
            setState(() {
              print("bien ${data['status']}");
              Navigator.pop(context);
            });
            //}
          }
          return data;
        } else // datos locales
        {
          sinConexion(registro);
          Navigator.pop(context);
        }
      }
    }
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

  all() {
    return Container(
        height: MediaQuery.of(context).size.height * .9,
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * .5,
              width: MediaQuery.of(context).size.width / 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                color: Colors.white30,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green,
                    offset: Offset(0.0, 10.0),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
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
                          initialDate: _dateTime,
                          firstDate: DateTime(2001),
                          lastDate: DateTime(2030),
                        ).then((date) {
                          setState(() {
                            //print(DateFormat('kk:mm:ss \n EEE d MMM').format(now));
                            setState(() {
                              if (date != null) _dateTime = date;
                            });
                          });
                        });
                      },
                      child: Icon(Icons.calendar_today),
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[Text("Checador= " + nuser)],
                    ),
                    Text(invernadero),
                    caja("Tunel", numT),
                    caja("racimo-1", rac1),
                    caja("racimo-2", rac2),
                    caja("racimo-3", rac3),
                    caja("racimo-4", rac4),
                    caja("racimo-5", rac5),
                    caja("racimo-6", rac6),
                    caja("Tamaño Menor", tam),
                    caja("Peso", peso),
                    Text("Lado =" + laredo),
                    Switch(
                        value: ladoi,
                        onChanged: (val) {
                          setState(() {
                            ladoi = val;
                            if (ladoi)
                              laredo = "N";
                            else
                              laredo = "S";
                            print(laredo);
                          });
                        }),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 8),
              height: MediaQuery.of(context).size.height * .3,
              width: MediaQuery.of(context).size.width / 1,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Colors.white30,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green,
                              offset: Offset(0.0, 10.0),
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              danos("pudricion"),
                              danos("Incecto_presencia"),
                              danos("Flojo"),
                              danos("Dano_Mecanico"),
                              danos("Blossom"),
                              danos("Golpe"),
                              danos("Mal_cierre"),
                              danos("Craking"),
                              danos("Extra_verde"),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Colors.white38,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green,
                              offset: Offset(0.0, 10.0),
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              danos("Deforme"),
                              danos("Cicatriz"),
                              danos("Dano_X_insecto"),
                              danos("Color Disparejo"),
                              danos("Corte"),
                              danos("Arrudago"),
                              danos("Blotchy"),
                              danos("Suelto"),
                              danos("Daño_x_virus"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: addBD,
                tooltip: 'Increment',
                child: Icon(Icons.add)),
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      vC();
    });
    if (!editar) {
      _dateTime = DateTime.now();
    } else {
      _dateTime = null;
    }

    super.initState();
  }

  Future<bool> vC() async // checha la conexion a internet
  {
    var conecctionResult = await Connectivity().checkConnectivity();
    if (conecctionResult != ConnectivityResult.none) {
      return true;
    }
    print("conectado");
    setState(() {
      mensaje =
          "No tienes acceso a internet todo sera guardado localmente \ncuando acabes de registrar conectate para subir tus datos";
      _showMyDialog();
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("Registro 16"),
        ),
        resizeToAvoidBottomPadding: false,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
                //padding: EdgeInsets.only(right: ),
                child: Column(
              children: <Widget>[
                (nuser == null)
                    ? Center(child: CircularProgressIndicator())
                    : all(),
              ],
            ))));
  }
}
