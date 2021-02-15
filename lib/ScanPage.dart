import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:velocity_x/velocity_x.dart';

class MyApp extends StatefulWidget {
  MyApp({this.name});
  final String name;
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool bal = false;
  int _wVal = 4;
  ScanResult scanResult;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _weight = TextEditingController();
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
                    controller: _weight,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter Weight';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Weight',
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    // mainAxisAlignment: Main,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _wVal = 2;
                          });
                        },
                        child: Container(
                          color: _wVal == 2 ? Colors.white : Colors.green[400],
                          alignment: Alignment.center,
                          height: 50,
                          width: 80,
                          child: "NorthEast".text.make(),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _wVal = 0;
                          });
                        },
                        child: Container(
                          color: _wVal == 0 ? Colors.white : Colors.green[400],
                          alignment: Alignment.center,
                          height: 50,
                          width: 80,
                          child: "WB".text.make(),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _wVal = 1;
                          });
                        },
                        child: Container(
                          color: _wVal == 1 ? Colors.white : Colors.green[400],
                          alignment: Alignment.center,
                          height: 50,
                          width: 80,
                          child: "Other".text.make(),
                        ),
                      )
                    ],
                  ),
                ).p(20),

                FlatButton(
                  onPressed: () {
                    if (scanResult.rawContent.length == 13) {
                      if (_formKey.currentState.validate()) {
                        if (_wVal != 4) {
                          updateUserDetails(
                            "${scanResult.rawContent}",
                            "${_weight.text}",
                          ).then((value) {
                            setState(() {
                              scanResult.rawContent = null;
                              _weight.clear();
                              _wVal = 4;
                              scanResult = null;
                              // ignore: unnecessary_statements
                              scanResult == null;
                              bal = false;
                            });
                          });
                        } else {
                          Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.cyan,
                              textColor: Colors.white,
                              fontSize: 16.0,
                              msg: 'Please Select Area');
                        }
                      }
                    } else {
                      Fluttertoast.showToast(
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.cyan,
                          textColor: Colors.white,
                          fontSize: 16.0,
                          msg: 'AWB Invalid');
                    }
                  },
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

  String abal = DateTime.now().toString().substring(0, 10);
  String path = 'bapan';

  // "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";

  final CollectionReference userCollection =
      Firestore.instance.collection('Users');
  Future updateUserDetails(String uid, String weight) async {
    await Firestore.instance
        .collection(path)
        .document(abal)
        .collection(uid)
        .document(widget.name)
        .setData({
      'Name': widget.name,
      'AWB Number': uid,
      'Weight': weight.toString(),
      'Area': _wVal == 2
          ? "NorthEast"
          : _wVal == 0
              ? "WB"
              : "Other",

      //  _wVal.toString(),
      'Time': DateTime.now()
    });
    // await Firestore.instance.collection(path).document().setData(data);

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
}
