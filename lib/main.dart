import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfluttershare/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() {

  //firestore.instance.settings(timestampsInSnapshotsEnabled:true).then((value) => null);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterShare',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(

          primarySwatch: Colors.deepPurple,//primryColor
          accentColor: Colors.teal,

      ),

      home: Home(),
    );
  }
}
