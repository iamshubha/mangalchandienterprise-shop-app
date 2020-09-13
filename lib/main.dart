import 'dart:async';
import 'dart:io' show Platform;
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(_MyApp());
}

class _MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> {
  ScanResult scanResult;
  final TextEditingController _weight = TextEditingController();
  final _price = TextEditingController();

  final _flashOnController = TextEditingController(text: "Flash on");
  final _flashOffController = TextEditingController(text: "Flash off");
  final _cancelController = TextEditingController(text: "Cancel");

  var _aspectTolerance = 0.00;
  var _numberOfCameras = 0;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = true;

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  @override
  initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var contentList = <Widget>[
      if (scanResult != null)
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text("Raw Content"),
                subtitle: Text(scanResult.rawContent ?? ""),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  controller: _weight,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Weight',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _price,
                  onChanged: (value) {
                    print(value);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Price',
                  ),
                ),
              ),
              Center(
                child: FlatButton(
                  onPressed: () {
                    updateUserDetails(
                      "${scanResult.rawContent}",
                      "${_weight.text}",
                      "${_price.text}",
                    );
                    
                  },
                  child: Text("fgvkdl "),
                  color: Colors.cyan[300],
                ),
              ),
            ],
          ),
        ),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Barcode Scanner Example'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.camera),
              tooltip: "Scan",
              onPressed: scan,
            )
          ],
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: false,
          children: contentList,
        ),
      ),
    );
  }

  final CollectionReference userCollection =
      Firestore.instance.collection('Users');
  Future updateUserDetails(String uid, String price, String weight) async {
    dynamic message;

    // final a = await userCollection
    //     .document(uid)
    //     .updateData({
    //       'DocNumber': uid,
    //       'Price': price.toString(),
    //       'Weight': weight.toString(),
    //     })
    //     .whenComplete(() => message = "Success")
    //     .catchError((error) => message = error);
    await Firestore.instance
        .collection("books")
        .document(uid)
        .setData({
          'DocNumber': uid,
          'Price': price.toString(),
          'Weight': weight.toString(),
        })
        // .whenComplete(() => message = 'Success')
        // .catchError((error) => message = error)
        ;
    // await userCollection
    //     .document(uid)
    //     .collection('task')
    //     .document('ds.documentID')
    //     .updateData({
    //       'DocNumber': uid,
    //       'Price': price.toString(),
    //       'Weight': weight.toString(),
    // });
    // await userCollection
    //     .document(uid)
    //     .updateData({
    //       'DocNumber': uid,
    //       'Price': price.toString(),
    //       'Weight': weight.toString(),
    //     })
    //     .whenComplete(() => message = 'Success')
    //     .catchError((error) => message = error);

    return "true";
  }

  void createRecord() async {
    await Firestore.instance.collection("books").document("1").setData({
      'title': 'Mastering Flutter',
      'description': 'Programming Guide for Dart'
    });

    DocumentReference ref = await Firestore.instance.collection("books").add({
      'title': 'Flutter in Action',
      'description': 'Complete Programming Guide to learn Flutter'
    });
    print(ref.documentID);
  }

  Future scan() async {
    try {
      var options = ScanOptions(
        strings: {
          "cancel": _cancelController.text,
          "flash_on": _flashOnController.text,
          "flash_off": _flashOffController.text,
        },
        restrictFormat: selectedFormats,
        useCamera: _selectedCamera,
        autoEnableFlash: _autoEnableFlash,
        android: AndroidOptions(
          aspectTolerance: _aspectTolerance,
          useAutoFocus: _useAutoFocus,
        ),
      );

      var result = await BarcodeScanner.scan(options: options);
      print(result.rawContent);
      setState(() {
        rs = result.rawContent;
      });
      setState(() => scanResult = result);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }
  String rs;
}
