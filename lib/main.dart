import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:calidad/pages/Constantes.dart';
import 'package:calidad/pages/Viewlocal.dart';
import 'package:calidad/pages/Constantes.dart';
import 'package:calidad/pages/Constantes.dart';
import 'package:calidad/pages/Registros.dart';
import 'package:calidad/pages/home.dart';
import 'package:calidad/pages/inv-12/Registros12.dart';
import 'package:calidad/pages/inv-12/Viewlocal12.dart';
import 'package:calidad/pages/inv-12/registro12.dart';
import 'package:calidad/pages/registro.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(CalidadApp());

class CalidadApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Calidad-Cimarron",
      home: MainPage(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => Home(),
        '/registro': (BuildContext context) => Registro(0, "", "", 0),
        '/LoginPage': (BuildContext context) => LoginPage(),
        '/Registros': (BuildContext context) => RegistrosView(),
        '/Viewlocal': (BuildContext context) => Viewlocal(),
        '/registro12': (BuildContext context) => Registro12(0, "", "", 0),
        '/Registros12': (BuildContext context) => RegistrosView12(),
        '/Viewlocal12': (BuildContext context) => Viewlocal12(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  SharedPreferences sharedPreferences;

  logg() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("tk") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext contex) => LoginPage()),
          (Route<dynamic> router) => false);
    }
  }

  @override
  void initState() {
    logg();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Home"),
          backgroundColor: Colors.green,
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                sharedPreferences.clear();
                sharedPreferences.commit();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext contex) => LoginPage()),
                    (Route<dynamic> router) => false);
              },
              child: Icon(Icons.exit_to_app),
            )
          ],
        ),
        body: Home());
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usert = TextEditingController();
  TextEditingController passt = TextEditingController();
  String mensaje = "";
  String usuario = "";
  bool loggin = false;

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

  vefificarT() {
    if (usert.text == "" || passt.text == "") {
      mensaje = "Introducir los datos";
      return false;
    }
    return true;
  }

  login() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("1");
    if (vefificarT()) {
      print("1.2");
      //loggin = true;
      print(Constant.DOMAIN + "/loggin/");
      var response;
      try {
        response = await http.post(Constant.DOMAIN + "/loggin/", body: {
          "user": usert.text,
          "pass": passt.text,
        }).timeout(const Duration(seconds: 7));
      } on TimeoutException catch (_) {
        setState(() {
          mensaje = 'Sin conexion al servidor';
          loggin = false;
          _showMyDialog();
        });
        throw ('Sin conexion al servidor');
      } on SocketException {
        setState(() {
          loggin = false;
          _showMyDialog();
          loggin = false;
        });
        throw ('Sin internet  o falla de servidor sock');
      } on HttpException {
        setState(() {
          loggin = false;
          mensaje = "peticion mal";
          _showMyDialog();
          loggin = false;
        });
        throw ("No se encontro esa peticion");
      } on FormatException {
        setState(() {
          loggin = false;
          mensaje = "peticion maal";
          _showMyDialog();
          loggin = false;
        });
        throw ("Formato erroneo ");
      }

      var data = json.decode(response.body);
      print(data[0]);
      print(response.body);
      if (data['error'] == true) {
        setState(() {
          mensaje = "${data['status']}";
          print(mensaje);
          loggin = false;
          _showMyDialog();
          loggin = false;
        });
      } else {
        setState(() {
          loggin = false;
          print(data['user']);
          sharedPreferences.setInt("id", data['user']['id']);
          sharedPreferences.setString("tk", data['token']);
          sharedPreferences.setString("user", data['user']['user']);
          sharedPreferences.setString("rol", data['user']['rol']);
          sharedPreferences.setInt("id_inver", data['id_inver']);

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext contex) => MainPage()),
              (Route<dynamic> router) => false);

          print("bien ${data['status']}");
        });
      }
      return data;
    }

    //loggin = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DraweC(),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Loggin"),
      ),
      resizeToAvoidBottomPadding: false,
      body: Form(
        child: Container(
          color: Colors.white,
          child: loggin ? Center(child: CircularProgressIndicator()) : all(),
        ),
      ),
    );
  }

  all() {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * .25,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("assets/images/Cimarron.png"),
              )),
              child: Stack(),
            ),
          ],
        ),
        Container(
            // para las cajas de texto
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width / 1.2,
            padding: EdgeInsets.only(top: 5),
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  padding:
                      EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 5,
                        ),
                      ]),
                  child: TextFormField(
                    controller: usert,
                    decoration: InputDecoration(
                        labelText: "Usuario",
                        hintText: "Usuario",
                        icon: Icon(
                          Icons.account_circle,
                        )),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 60),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    padding:
                        EdgeInsets.only(top: 4, left: 14, right: 16, bottom: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 5,
                          ),
                        ]),
                    child: TextFormField(
                      controller: passt,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "Contraseña",
                          hintText: "Contraseña",
                          suffixIcon: Icon(Icons.visibility),
                          icon: Icon(Icons.vpn_key)),
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(top: 50),
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 42),
                          child: Container(
                            width: MediaQuery.of(context).size.width * .3,
                            height: 50,
                            child: RaisedButton(
                              child: Text("Ingresar"),
                              color: Colors.green,
                              splashColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              onPressed: () {
                                setState(() {
                                  loggin = true;
                                  login();
                                });

                                //login();
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width * .3,
                            height: 50,
                            child: RaisedButton(
                              child: Text("Registrarse"),
                              color: Colors.blue,
                              splashColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              onPressed: null,
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            )),
      ],
    );
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
