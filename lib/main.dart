// import 'dart:io' show Platform;
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:http/http.dart' as http;

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
                            builder: (_) =>
                                //  MyApp(name: _nameController.text)
                                DocketWeight()));
                  } else {
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

class DocketWeight extends StatefulWidget {
  @override
  _DocketWeightState createState() => _DocketWeightState();
}

class _DocketWeightState extends State<DocketWeight> {
  String _waybill;
  String _phone;
  int _gm;
  String _name;
  String product_details;
  String _add;
  String commodity_value;

  bool bal = false;
  int _wVal = 4;
  ScanResult scanResult;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _weight = '15';
  // final _price = TextEditingController();
  final _doc = TextEditingController();
  final _flashOnController = TextEditingController(text: "Flash on");
  final _flashOffController = TextEditingController(text: "Flash off");
  final _cancelController = TextEditingController(text: "Cancel");
  var _aspectTolerance = 0.00;
  var _numberOfCameras = 0;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  Future<void> getData() async {
    int val = int.parse(_weight.toString());
    print(val);
    print(val.runtimeType);
    try {
      String url = "https://track.delhivery.com/api/p/edit";
      final _body = {
        "waybill": "6524810417620",
        "gm": val, // _weight as int,
        "name": "test",
        "product_details": "t",
        "add": "test para dummy pur",
        "commodity_value": "120"
      };
      print(_body);
      final _header = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Token ea1e0ff0bf1e7de1f3104558a7d313e99db961c5",
      };

      final response =
          await http.post(url, body: jsonEncode(_body), headers: _header);
      print(response.body);
    } catch (e) {
      print(e);
    }
  }

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      setState(() {});
    });
  }

  // List<int> _phoneWidgets = [];
  int finalsum = 0;
  int arrint;
  Future scan() async {
    print(_weight);
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
        scanResult = result;
      });
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
  @override
  Widget build(BuildContext context) {
    var contentList = <Widget>[
      if (scanResult != null)
        Card(
          child: Form(
            key: _formKey,
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
                    initialValue: _weight,
                    onChanged: (v) {
                      setState(() {
                        _weight = v;
                      });
                    },
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please Reference number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Reference number',
                    ),
                  ),
                ),

                FlatButton(
                  onPressed: scan
                  // ()
                  // {
                  //   if (scanResult.rawContent.length == 13) {
                  //     if (_formKey.currentState.validate()) {
                  //       if (_wVal != 4) {
                  //         updateUserDetails(
                  //           "${scanResult.rawContent}",
                  //           "${_weight.text}",
                  //         ).then((value) {
                  //           setState(() {
                  //             scanResult.rawContent = null;
                  //             _weight.clear();
                  //             _wVal = 4;
                  //             scanResult = null;
                  //             // ignore: unnecessary_statements
                  //             scanResult == null;
                  //             bal = false;
                  //           });
                  //         });
                  //       } else {
                  //         Fluttertoast.showToast(
                  //             toastLength: Toast.LENGTH_SHORT,
                  //             gravity: ToastGravity.BOTTOM,
                  //             timeInSecForIosWeb: 1,
                  //             backgroundColor: Colors.cyan,
                  //             textColor: Colors.white,
                  //             fontSize: 16.0,
                  //             msg: 'Please Select Area');
                  //       }
                  //     }
                  //   } else {
                  //     Fluttertoast.showToast(
                  //         toastLength: Toast.LENGTH_SHORT,
                  //         gravity: ToastGravity.BOTTOM,
                  //         timeInSecForIosWeb: 1,
                  //         backgroundColor: Colors.cyan,
                  //         textColor: Colors.white,
                  //         fontSize: 16.0,
                  //         msg: 'AWB Invalid');
                  //   }
                  // }
                  ,
                  child: Text("Save"),
                  color: Colors.cyan[300],
                )

                // ],
                // ),
              ],
            ),
          ),
        ),
      // "$_phoneWidgets".text.xl3.make(),
      // "Total packet = ${_phoneWidgets.length}".text.xl3.make(),
      // "Total Price = $finalsum".text.xl3.make()
      //  Text("$_phoneWidgets",)
    ];

    return Container(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            getData();
          },
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          title: Text('Scanner'),
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
}
