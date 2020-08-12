import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Regi.dart';

class Registro extends StatefulWidget {
  //Registro({Key key}) : super(key: key);
  String nuser;
  int id_inver;
  int id;
  Regi r;
  String invernadero;
  Registro([this.id, this.nuser, this.invernadero, this.id_inver, this.r]);
  @override
  _RegistroState createState() => _RegistroState(
      this.id, this.nuser, this.invernadero, this.id_inver, this.r);
}

class _RegistroState extends State<Registro> {
  String nuser = " ";
  int id_inver;
  String mensaje;
  bool local;
  bool editar = false;
  TextEditingController numT = TextEditingController(); // numero del tunel
  TextEditingController numC1 = TextEditingController(); // numero de color 1
  TextEditingController numC2 = TextEditingController(); // numero de color 2
  TextEditingController numC3 = TextEditingController(); // numero de color 3
  TextEditingController tam = TextEditingController(); // tamaño
  TextEditingController brix = TextEditingController(); // tamaño
  TextEditingController brix2 = TextEditingController(); // tamaño
  int pudricion = 0;
  int v;
  DateTime _dateTime;
  Regi r;
  int id = 0;
  String invernadero;

  var dano = {
    'pudricion': 0,
    'dano_Tallo': 0,
    "Flojo": 0,
    "Dano_Mecanico": 0,
    "Blossom": 0,
    "Reventado": 0,
    "Mal_cierre": 0,
    "Deforme": 0,
    "Cicatriz": 0,
    "Dano_X_insecto": 0,
    "Color Disparejo": 0,
    "Caliz": 0,
    "Color_X_Virus": 0
  };

  _RegistroState(this.id, this.nuser, this.invernadero, this.id_inver,
      [this.r]) {
    if (this.r == null) {
      print("vacio");
      editar = false;
    } else {
      print("editar");
      numT.text = this.r.num_tunel.toString();
      numC1.text = this.r.num_color3.toString();
      numC2.text = this.r.num_color4.toString();
      numC3.text = this.r.num_color5.toString();
      tam.text = this.r.tamchico.toString();
      brix.text = this.r.Brix.toString();
      brix2.text = this.r.Brix.toString();
      dano['pudricion'] = this.r.pudricion;
      dano['dano_Tallo'] = this.r.tallo;
      dano['Flojo'] = this.r.flojo;
      dano['Dano_Mecanico'] = this.r.mecanico;
      dano['Blossom'] = this.r.blossom;
      dano['Mal_cierre'] = this.r.cierre;
      dano['Deforme'] = this.r.deforme;
      dano['Cicatriz'] = this.r.cicatriz;
      dano['Dano_X_insecto'] = this.r.insecto;
      dano['Color Disparejo'] = this.r.color_disparejo;
      dano['Caliz'] = this.r.caliz;
      dano['Color_X_Virus'] = this.r.viruz;
      editar = true;
    }
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

  bool validateDatos() {
    if (numT.text == "" ||
        numC1 == "" ||
        numC2 == "" ||
        numC3 == "" ||
        tam.text == "" ||
        brix.text == "") {
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
          'num_color3': int.parse(numC1.text),
          'num_color4': int.parse(numC2.text),
          'num_color5': int.parse(numC3.text),
          'tamchico': int.parse(tam.text),
          'Brix': double.parse(brix.text),
          'Brix2': double.parse(brix2.text),
          'pudricion': dano['pudricion'],
          'tallo': dano['dano_Tallo'],
          "flojo": dano["Flojo"],
          "mecanico": dano['Dano_Mecanico'],
          "blossom": dano['Blossom'],
          "reventado": dano["Reventado"],
          "cierre": dano["Mal_cierre"],
          "deforme": dano["Deforme"],
          "cicatriz": dano["Cicatriz"],
          "insecto": dano["Dano_X_insecto"],
          "color_disparejo": dano["Color Disparejo"],
          "caliz": dano["Caliz"],
          "viruz": dano["Color_X_Virus"],
          "fecha": DateTime.parse(this.r.fecha)
              .toString()
              .substring(0, DateTime.parse(this.r.fecha).toString().length - 2),
        };

        var conecctionResult = await Connectivity().checkConnectivity();
        if (conecctionResult != ConnectivityResult.none) {
          print(sharedPreferences.getString('tk')); // 192.168.1.135
          var hd = {'vefificador': sharedPreferences.getString('tk')};
          print(sharedPreferences.getInt('id_inver'));
          var response;
          try {
            response = await http.put("http://192.168.1.129:3000/actualizar/",
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
          'num_color3': int.parse(numC1.text),
          'num_color4': int.parse(numC2.text),
          'num_color5': int.parse(numC3.text),
          'tamchico': int.parse(tam.text),
          'Brix': double.parse(brix.text),
          'Brix2': double.parse(brix2.text),
          'pudricion': dano['pudricion'],
          'tallo': dano['dano_Tallo'],
          "flojo": dano["Flojo"],
          "mecanico": dano['Dano_Mecanico'],
          "blossom": dano['Blossom'],
          "reventado": dano["Reventado"],
          "cierre": dano["Mal_cierre"],
          "deforme": dano["Deforme"],
          "cicatriz": dano["Cicatriz"],
          "insecto": dano["Dano_X_insecto"],
          "color_disparejo": dano["Color Disparejo"],
          "caliz": dano["Caliz"],
          "viruz": dano["Color_X_Virus"],
          "fecha": _dateTime.toString()
        };
        print(json.encode(registro));
        var conecctionResult = await Connectivity().checkConnectivity();
        if (conecctionResult != ConnectivityResult.none) {
          print(sharedPreferences.getString('tk')); // 192.168.1.135
          var hd = {'vefificador': sharedPreferences.getString('tk')};
          var response;
          try {
            response = await http.post("http://192.168.1.129:3000/addC/",
                headers: hd,
                body: {
                  'REG': json.encode(registro)
                }).timeout(const Duration(seconds: 7));
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
                    caja("Numero de tunel", numT),
                    caja("Color-3", numC1),
                    caja("Color-4", numC2),
                    caja("Color-5", numC3),
                    caja("Tamaño Menor", tam),
                    caja("Brix", brix),
                    caja("Brix2", brix2),
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
                              danos("dano_Tallo"),
                              danos("Flojo"),
                              danos("Dano_Mecanico"),
                              danos("Blossom"),
                              danos("Reventado"),
                              danos("Mal_cierre"),
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
                              danos("Caliz"),
                              danos("Color_X_Virus"),
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("Registro"),
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

class DraweC extends StatelessWidget {
  //const DraweC({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Cimarron-Calidad"),
              accountEmail: Text("By-Dep-Priva"),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage("assets/images/pp.jpg"))),
            ),
            Ink(
              color: Colors.indigo,
              child: ListTile(
                title: Text(
                  "Nuevo Usuario",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Ink(
              color: Colors.indigo,
              child: ListTile(
                title: Text(
                  "Conoce mas de Cimarron",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
