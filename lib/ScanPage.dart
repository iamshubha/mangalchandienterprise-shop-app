import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

class MyApp extends StatefulWidget {
  MyApp({this.name});
  var name;
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ScanResult scanResult;
  final TextEditingController _weight = TextEditingController();
  final _price = TextEditingController();
  final _doc = TextEditingController();

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

  List<int> _phoneWidgets = [];
  int finalsum = 0;
  int arrint;
  @override
  Widget build(BuildContext context) {
    var contentList = <Widget>[
      if (scanResult != null)
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                trailing: IconButton(
                  icon: Icon(Icons.camera),
                  tooltip: "Scan",
                  onPressed: scan,
                ),
                title: Text("Docket No -"),
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Price',
                  ),
                ),
              ),

              FlatButton(
                onPressed: () {
                  updateUserDetails(
                    "${scanResult.rawContent}",
                    "${_weight.text}",
                    "${_price.text}",
                  );
                  setState(() {
                    arrint = int.parse(_price.text);
                    finalsum = finalsum + arrint;
                  });
                  _phoneWidgets.add(arrint);

                  _weight.clear();
                  _price.clear();
                  setState(() {
                    // ignore: unnecessary_statements
                    scanResult == null;
                  });
                },
                child: Text("Save"),
                color: Colors.cyan[300],
              ),
              // ],
              // ),
            ],
          ),
        ),
      "$_phoneWidgets".text.xl3.make(),
      "Total packet = ${_phoneWidgets.length}".text.xl3.make(),
      "Total Price = $finalsum".text.xl3.make()
      //  Text("$_phoneWidgets",)
    ];

    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Maa mangal chandi'),
          centerTitle: true,
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
    await Firestore.instance
        .collection("Docket-Collection")
        .document(uid)
        .setData({
      'Name': widget.name,
      'DocNumber': uid,
      'Price': price.toString(),
      'Weight': weight.toString(),
      'time': DateTime.now()
    });

    return "true";
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
