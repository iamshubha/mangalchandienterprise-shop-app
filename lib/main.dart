import 'dart:async';
import 'dart:io' show Platform;
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopscanner/ScanPage.dart';
import 'package:velocity_x/velocity_x.dart';

void main() {
  runApp(MaterialApp(home: HomePage()));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scanner Part"),
      ),
      body: Container(
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.name,
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            FlatButton(
                onPressed: () {
                  print(_nameController.text);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MyApp(name: _nameController.text)));
                },
                child: Text("Next"))
          ],
        ),
      ),
    );
  }
}

