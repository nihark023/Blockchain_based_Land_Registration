import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:land_registration/constant/constants.dart';
import 'package:land_registration/widget/header.dart';
import 'package:provider/provider.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import '../providers/LandRegisterModel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_search/mapbox_search.dart';
import '../constant/utils.dart';
import '../providers/MetamaskProvider.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({Key? key}) : super(key: key);

  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  late String name, age, city, adharNumber, panNumber, document, email;

  double width = 590;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false, isAdded = false;
  String docuName = "";
  late PlatformFile documentFile;
  String cid = "", docUrl = "";
  String pinataJwt =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiJmMTkyZjMzOS00ZDNjLTRiZTktYWUwNC03MDM2NzdmOGJiYzEiLCJlbWFpbCI6Im5paGFya25paGFya0BnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGluX3BvbGljeSI6eyJyZWdpb25zIjpbeyJkZXNpcmVkUmVwbGljYXRpb25Db3VudCI6MSwiaWQiOiJGUkExIn0seyJkZXNpcmVkUmVwbGljYXRpb25Db3VudCI6MSwiaWQiOiJOWUMxIn1dLCJ2ZXJzaW9uIjoxfSwibWZhX2VuYWJsZWQiOmZhbHNlLCJzdGF0dXMiOiJBQ1RJVkUifSwiYXV0aGVudGljYXRpb25UeXBlIjoic2NvcGVkS2V5Iiwic2NvcGVkS2V5S2V5IjoiNDNlYmM2MjZlZTk2OWEzNDdlNGMiLCJzY29wZWRLZXlTZWNyZXQiOiIzNjllNTNjZjcyNmZjYmRiZjc0ZWMyOWQ3MWU3YTI2YzllZDk5NzIyNWIyZWUwMDY0NTI2NGQ3YmYxZmE3OTk4IiwiZXhwIjoxNzYyODQ3NTc1fQ.MORJElomwznFU2gJzl9KUZfMh7axHLWJe60vIt4InQw";

  List<MapBoxPlace> predictions = [];
  late PlacesSearch placesSearch;
  final FocusNode _focusNode = FocusNode();
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  TextEditingController addressController = TextEditingController();

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
        builder: (context) => Positioned(
              width: 540,
              child: CompositedTransformFollower(
                link: this._layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, 40 + 5.0),
                child: Material(
                  elevation: 4.0,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: List.generate(
                        predictions.length,
                        (index) => ListTile(
                              title:
                                  Text(predictions[index].placeName.toString()),
                              onTap: () {
                                addressController.text =
                                    predictions[index].placeName.toString();

                                setState(() {});
                                _overlayEntry.remove();
                                _overlayEntry.dispose();
                              },
                            )),
                  ),
                ),
              ),
            ));
  }

  Future<void> autocomplete(value) async {
    List<MapBoxPlace>? res = await placesSearch.getPlaces(value);
    if (res != null) predictions = res;
    setState(() {});
    // print(res);
    // print(res![0].placeName);
    // print(res![0].geometry!.coordinates);
    // print(res![0]);
  }

  @override
  void initState() {
    placesSearch = PlacesSearch(
      apiKey: mapBoxApiKey,
      limit: 10,
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _overlayEntry = this._createOverlayEntry();
        Overlay.of(context)!.insert(_overlayEntry);
      } else {
        _overlayEntry.remove();
      }
    });
    super.initState();
  }

  pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf'],
    );

    if (result != null) {
      docuName = result.files.single.name;
      documentFile = result.files.first;
    }
  }

  Future<bool> uploadDocument() async {
    String url = "https://api.pinata.cloud/pinning/pinFileToIPFS";
    var headers = {"Authorization": "Bearer $pinataJwt"};

    if (docuName != null && documentFile != null) {
      try {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers.addAll(headers);

        // Add file to the request
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            documentFile!.bytes!,
            filename: docuName,
          ),
        );

        // Send the request
        var response = await request.send();
        var responseData = await http.Response.fromStream(response);

        if (response.statusCode == 200) {
          var data = jsonDecode(responseData.body);
          cid = data["IpfsHash"];
          docUrl = "https://$cid.ipfs.dweb.link";
          print("Document uploaded successfully: $docUrl");
          return true;
        } else {
          print("Failed to upload: ${responseData.body}");
          showToast("Upload failed: ${responseData.body}",
              backgroundColor: Colors.red);
        }
      } catch (e) {
        print("Error during upload: $e");
        showToast("Exception: $e", backgroundColor: Colors.red);
      }
    } else {
      print("No document selected.");
      showToast("Choose Document", backgroundColor: Colors.red, context: null);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<LandRegisterModel>(context);
    var model2 = Provider.of<MetaMaskProvider>(context);
    return Scaffold(
        body: Column(children: [
      // Header Widget
      Container(
        child: const Material(
          elevation: 10,
          child: Padding(
            padding:
                EdgeInsets.only(left: 150.0, top: 15, right: 50, bottom: 15),
            child: HeaderWidget(),
          ),
        ),
      ),
      Center(
        child: Material(
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            width: width,
            child: Form(
              key: _formKey,
              child: Column(
                // scrollDirection: Axis.vertical,
                // shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        name = val;
                      },
                      decoration: const InputDecoration(
                        isDense: true, // Added this
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                        hintText: 'Enter Name',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter age';
                        }
                        return null;
                      },
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      onChanged: (val) {
                        age = val;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      decoration: const InputDecoration(
                        isDense: true, // Added this
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(),
                        labelText: 'Age',
                        hintText: 'Enter Age',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: CompositedTransformTarget(
                      link: this._layerLink,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        style: const TextStyle(
                          fontSize: 15,
                        ),

                        controller: addressController,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            autocomplete(value);
                            _overlayEntry.remove();
                            _overlayEntry = this._createOverlayEntry();
                            Overlay.of(context)!.insert(_overlayEntry);
                          } else {
                            if (predictions.length > 0 && mounted) {
                              setState(() {
                                predictions = [];
                              });
                            }
                          }
                        },
                        focusNode: this._focusNode,
                        //obscureText: true,
                        decoration: const InputDecoration(
                          isDense: true, // Added this
                          contentPadding: EdgeInsets.all(12),
                          border: OutlineInputBorder(),
                          labelText: 'Address',
                          hintText: 'Enter Address',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Adhar number';
                        } else if (value.length != 12)
                          return 'Please enter Valid Adhar number';
                        return null;
                      },
                      //maxLength: 12,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      onChanged: (val) {
                        adharNumber = val;
                      },
                      //obscureText: true,
                      decoration: const InputDecoration(
                        isDense: true, // Added this
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(),
                        labelText: 'Adhar',
                        hintText: 'Enter Adhar Number',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Pan Number';
                        } else if (value.length != 10)
                          return 'Please enter Valid Adhar number';
                        return null;
                      },
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      //maxLength: 10,

                      onChanged: (val) {
                        panNumber = val;
                      },
                      //obscureText: true,
                      decoration: const InputDecoration(
                        isDense: true, // Added this
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(),
                        labelText: 'Pan',
                        hintText: 'Enter Pan Number',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        MaterialButton(
                          color: Colors.grey,
                          onPressed: pickDocument,
                          child: const Text('Upload Document'),
                        ),
                        Text(docuName)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      validator: (value) {
                        RegExp regex = RegExp(
                            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                            r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                            r"{0,253}[a-zA-Z0-9])?)*$");
                        if (!regex.hasMatch(value!) || value == null)
                          return 'Enter a valid email address';
                        else
                          return null;
                      },
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      onChanged: (val) {
                        email = val;
                      },
                      //obscureText: true,
                      decoration: const InputDecoration(
                        isDense: true, // Added this
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: 'Enter Email',
                      ),
                    ),
                  ),
                  isAdded
                      ? CustomButton('Contine to Login', () {
                          Navigator.pop(context);
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => UserDashBoard()));
                          Navigator.of(context).pushNamed(
                            '/user',
                          );
                        })
                      : CustomButton(
                          'Add',
                          isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    try {
                                      SmartDialog.showLoading(
                                          msg: "Uploading Document");
                                      bool isFileupload =
                                          await uploadDocument();
                                      SmartDialog.dismiss();
                                      if (isFileupload) {
                                        if (connectedWithMetamask)
                                          await model2.registerUser(
                                              name,
                                              age,
                                              addressController.text,
                                              adharNumber,
                                              panNumber,
                                              docUrl,
                                              email);
                                        else
                                          await model.registerUser(
                                              name,
                                              age,
                                              addressController.text,
                                              adharNumber,
                                              panNumber,
                                              docuName,
                                              docUrl,
                                              email);
                                        showToast("Successfully Registered",
                                            context: context,
                                            backgroundColor: Colors.green);
                                        isAdded = true;
                                      }
                                    } catch (e) {
                                      print(e);
                                      showToast("Something Went Wrong",
                                          context: context,
                                          backgroundColor: Colors.red);
                                    }

                                    setState(() {
                                      isLoading = false;
                                    });
                                  }

                                  //model.makePaymentTestFun();
                                }),
                  isLoading ? const CircularProgressIndicator() : Container()
                ],
              ),
            ),
          ),
        ),
      ),
    ]));
  }
}
