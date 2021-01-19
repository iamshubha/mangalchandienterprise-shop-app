import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopscanner/ScanPage.dart';
import 'package:velocity_x/velocity_x.dart';

void main() {
  runApp(
    MaterialApp(
      home: HomePage(),
    ),
  );
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              keyboardType: TextInputType.name,
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ).p(20),
            FlatButton(
                color: Colors.cyan,
                onPressed: () {
                  print(_nameController.text);
                  if (_nameController.text.length != 0) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MyApp(name: _nameController.text)));
                  }else{
                      Fluttertoast.showToast(
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.cyan,
                            textColor: Colors.white,
                            fontSize: 16.0,
                            msg: 'Please Enter Your Name');
                  }
                },
                child: Text("Next"))
          ],
        ),
      ),
    );
  }
}
