import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: 'Run Linux Commands in Flutter Application'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _state = "Initial State", _serviceName = 'exium-svc';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'SERVICE NAME : $_serviceName ',
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              _state != "" ? 'PREVIOUS STATUS : $_state' : '',
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              'Counter : $_counter',
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:  () async {
          var x = await queryService('start', _serviceName);
          print(x);
        },
        label: Text("PRESSED TO STOP $_serviceName SERVICE"),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<String> queryService(String operation, String serviceName) async{
    String output = "NONE";
    setState(() {
      _counter++;
    });
    try {
      await Process.run('C:\\Windows\\System32\\sc.exe', [(operation), (serviceName)])
          .then((result) {
        String str = result.stdout;
        if(str.contains('STATE')){
          LineSplitter ls = LineSplitter();
          List<String> lines = ls.convert(str);
          String tempStr = lines[3];
          List<String> splitedList = tempStr.split(':');
          setState(() {
            output = (splitedList[1].trim().split(' ')[2]);
            _state = output;
          });
        } else{
          setState(() {
            output =  "NO STATE KEYWORD FOUND";
          });
        }
      }).onError((error, stackTrace){
        setState(() {
          output = "INVALID-OPERATION";
        });
      }).catchError((e){
        setState(() {
          output = e.toString();
        });
      });
    }
    catch (e) {
      setState(() {
        output = e.toString();
      });
    }
    return output;
  }
}
