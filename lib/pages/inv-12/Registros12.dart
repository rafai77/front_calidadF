import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:calidad/pages/inv-12/regi12.dart';
import 'package:calidad/pages/inv-12/registro12info.dart';
import 'package:calidad/pages/registroinfo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:calidad/pages/Constantes.dart';

class RegistrosView12 extends StatefulWidget {
  String invernadero;
  String user;
  RegistrosView12([this.user, this.invernadero]);
  @override
  _RegistrosViewState12 createState() =>
      _RegistrosViewState12(this.user, this.invernadero);
}

class _RegistrosViewState12 extends State<RegistrosView12> {
  String invernadero;
  DateTime _dateTime;
  bool lista;
  Future fregistros;
  String user;
  String mensaje;
  StreamController<List<Regi12>> ldR; //lista de registros
  _RegistrosViewState12([this.user, this.invernadero]);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Registros"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                informacion();
              }),
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
              Container(
                padding: EdgeInsets.only(
                    //bottom: (MediaQuery.of(context).size.height * .85),
                    //left: (MediaQuery.of(context).size.width)
                    ),
                //width: MediaQuery.of(context).size.width * .15,
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
                          initialDate: _dateTime,
                          firstDate: DateTime(2001),
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
              ),
              Container(
                  margin: EdgeInsets.only(bottom: 90),
                  child: StreamBuilder(
                    stream: ldR.stream,
                    builder: (BuildContext contex, AsyncSnapshot snapshot) {
                      if (!lista) {
                        return Row(children: <Widget>[
                          Center(child: Text("Sin datos de esta fecha.....")),
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
                                        child: RefreshIndicator(
                                            onRefresh: informacion,
                                            child: ListView.builder(
                                                scrollDirection: Axis.vertical,
                                                shrinkWrap: true,
                                                physics:
                                                    AlwaysScrollableScrollPhysics(),
                                                itemCount: snapshot.data.length,
                                                itemBuilder:
                                                    (BuildContext contex,
                                                        int index) {
                                                  return Container(
                                                      //padding: EdgeInsets.fr,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              .1,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                          color: Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.blue,
                                                              blurRadius: 2,
                                                            ),
                                                          ]),
                                                      child: ListTile(
                                                        title: Text(
                                                          "Tunel = " +
                                                              snapshot
                                                                  .data[index]
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
                                                                      RegInfo12(
                                                                          snapshot
                                                                              .data[index],
                                                                          false))),
                                                        },
                                                        subtitle: Text("Color 3=" +
                                                            snapshot.data[index]
                                                                .num_color3
                                                                .toString() +
                                                            " \n" +
                                                            "Color 4=" +
                                                            snapshot.data[index]
                                                                .num_color4
                                                                .toString() +
                                                            " \nColor 5=" +
                                                            snapshot.data[index]
                                                                .num_color5
                                                                .toString() +
                                                            " \n" "Fecha=" +
                                                            snapshot.data[index]
                                                                .fecha
                                                                .toString() +
                                                            " \n \t...toda la informacion...\t"),
                                                      ));
                                                })))))
                          ]);
                    },
                  ))
            ],
          )),
    );
  }

  reginfo() async {}

  @override
  void initState() {
    super.initState();
    informacion();
    _dateTime = DateTime.now();
    lista = false;
    ldR = StreamController<List<Regi12>>();
  }

  Future<Null> informacion() //obtener todos los registros del invernadero
  async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getString('rol'));
    if (sharedPreferences.getString('tk') != null) {
      //(_dateTime != null) ? _dateTime : _dateTime = DateTime.now();

      print(_dateTime);
      Map<String, String> dat = {
        "name": this.invernadero,
        "fecha": _dateTime.toString()
      };
      var hd = {'vefificador': sharedPreferences.getString('tk')};
      var response;

      try {
        response = await http
            .post(Constant.DOMAIN + "/registros12/", headers: hd, body: {
          "fecha": _dateTime.toString(),
          "name": this.invernadero,
        }).timeout(const Duration(seconds: 7));
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

      List<Regi12> aux = [];
      var data = json.decode(response.body);
      print(data);
      if (data[0] == null) {
        setState(() {
          lista = false;
        });

        print("mal dia");
      } else {
        for (var i in data) {
          Regi12 r = Regi12(
              i["id_reg"],
              i['id_user'],
              i['id_inve'],
              i['num_tunel'],
              i['num_color3'],
              i['num_color4'],
              i["num_color5"],
              i['tamchico'],
              i["peso"],
              i['pudricion'],
              i['tallo'],
              i['flojo'],
              i['mecanico'],
              i['blossom'],
              i['reventado'],
              i['cierre'],
              i['deforme'],
              i['cicatriz'],
              i['insecto'],
              i['color_disparejo'],
              i['caliz'],
              i['viruz'],
              i['fecha'],
              i['lado']);
          aux.add(r);
        }
        setState(() {
          lista = true;
        });

        ldR.add(aux);
        print(aux);
        print("buen dia");
      }
    }
    //print(ldR.length);
    //return ldR;
  }

  //pasar a mapa

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
